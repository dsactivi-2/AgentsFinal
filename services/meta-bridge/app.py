"""
Meta Bridge v2 — Bidirektionale Meta Webhook Bridge für Facebook/Instagram/Messenger.

Neu in v2:
  - Postgres: Deduplizierung via processed_events-Tabelle (PRIMARY KEY = kein Duplikat möglich)
  - Postgres: Nachrichten-Logging (messages-Tabelle) + graceful fallback

Neu in v2.1:
  - Error-Logging: Alle Fehler in error_logs-Tabelle + strukturiertes stderr
  - Retry: Meta Graph API 2× mit Backoff (3s → 6s)
  - Retry: OpenClaw 2× mit 5s Pause bei Timeout/Fehler
  - Kein Redis — PostgreSQL ist einziges Backend (persistent, überlebt Restarts)

Endpunkte:
  GET  /webhook        → Meta Webhook-Verifikation
  POST /webhook        → Eingehende Meta Events
  POST /reply          → Interner Endpunkt für OpenClaw-Antworten
  GET  /health         → Status aller Backends
  GET  /admin/errors   → Letzte Fehler aus error_logs
"""

import asyncio
import hashlib
import hmac
import json
import logging
import os
import time
import uuid
from contextlib import asynccontextmanager
from typing import Any

import base64
import httpx
from fastapi import BackgroundTasks, FastAPI, HTTPException, Request
from fastapi.responses import PlainTextResponse

try:
    from PIL import Image
    import io
    _HAS_PILLOW = True
except ImportError:
    _HAS_PILLOW = False

try:
    import asyncpg  # type: ignore
    _HAS_ASYNCPG = True
except ImportError:
    _HAS_ASYNCPG = False

# ─── Logging ────────────────────────────────────────────────────────────────

logging.basicConfig(
    level=logging.INFO,
    format='{"time":"%(asctime)s","level":"%(levelname)s","msg":%(message)s}',
)
logger = logging.getLogger("meta-bridge")


def log(msg: str, **kwargs: Any) -> None:
    extra = json.dumps(kwargs) if kwargs else "{}"
    logger.info(f'"{msg}", "extra":{extra}')


def log_error(msg: str, **kwargs: Any) -> None:
    extra = json.dumps(kwargs) if kwargs else "{}"
    logger.error(f'"{msg}", "extra":{extra}')


# ─── Konfiguration ───────────────────────────────────────────────────────────

VERIFY_TOKEN: str = os.environ["META_VERIFY_TOKEN"]
APP_SECRET: str = os.environ["META_APP_SECRET"]
PAGE_ACCESS_TOKEN: str = os.environ["META_PAGE_ACCESS_TOKEN"]
OPENCLAW_HOOK_URL: str = os.getenv(
    "OPENCLAW_HOOK_URL", "http://127.0.0.1:18789/hooks/meta"
)
META_GRAPH_URL: str = "https://graph.facebook.com/v19.0/me/messages"
OLLAMA_CLOUD_API_KEY: str = os.getenv("OLLAMA_CLOUD_API_KEY", "")
OLLAMA_CLOUD_API_BASE: str = os.getenv("OLLAMA_CLOUD_API_BASE", "https://ollama.com/api")
VISION_MODEL: str = os.getenv("VISION_MODEL", "qwen3.5:cloud")
VISION_ENABLED: bool = bool(OLLAMA_CLOUD_API_KEY)
OPENCLAW_TIMEOUT: float = float(os.getenv("OPENCLAW_TIMEOUT", "45"))
META_API_TIMEOUT: float = float(os.getenv("META_API_TIMEOUT", "10"))

DB_HOST: str = os.getenv("DB_HOST", "127.0.0.1")
DB_PORT: int = int(os.getenv("DB_PORT", "5432"))
DB_NAME: str = os.getenv("DB_NAME", "social_ai")
DB_USER: str = os.getenv("DB_USER", "postgres")
DB_PASSWORD: str = os.getenv("DB_PASSWORD", "")

DEDUP_TTL: int = 300  # 5 Minuten in Sekunden

# ─── Runtime State ───────────────────────────────────────────────────────────

_seen_ids: dict[str, float] = {}  # In-Memory Fallback-Dedup (wenn Postgres nicht erreichbar)
db_pool: Any = None


# ─── Lifespan (Startup / Shutdown) ──────────────────────────────────────────

@asynccontextmanager
async def lifespan(app: FastAPI):
    global db_pool

    # Postgres
    if _HAS_ASYNCPG:
        try:
            db_pool = await asyncpg.create_pool(
                host=DB_HOST,
                port=DB_PORT,
                database=DB_NAME,
                user=DB_USER,
                password=DB_PASSWORD or None,
                min_size=1,
                max_size=5,
                command_timeout=10,
            )
            log("postgres_connected", host=DB_HOST, db=DB_NAME)
        except Exception as exc:
            log_error("postgres_unavailable", error=str(exc))
            db_pool = None
    else:
        log("asyncpg_not_installed", hint="pip install asyncpg")

    yield  # App läuft

    if db_pool:
        await db_pool.close()


# ─── Deduplizierung ──────────────────────────────────────────────────────────

async def _is_duplicate(message_id: str) -> bool:
    """
    Prüft ob message_id bereits verarbeitet wurde.
    Primär: PostgreSQL INSERT ON CONFLICT (persistent, überlebt Restarts, kein TTL nötig).
    Fallback: In-Memory TTL-Dict (wenn Postgres nicht erreichbar).
    """
    # ── Primär: PostgreSQL ────────────────────────────────────────────────────
    if db_pool:
        try:
            async with db_pool.acquire() as conn:
                result = await conn.execute(
                    "INSERT INTO processed_events(message_id) VALUES($1) ON CONFLICT DO NOTHING",
                    message_id,
                )
                # result = "INSERT 0 1" → neu (kein Duplikat)
                # result = "INSERT 0 0" → Konflikt (Duplikat)
                return result == "INSERT 0 0"
        except Exception as exc:
            log_error("pg_dedup_error", error=str(exc))
            # Fall through zu In-Memory Fallback

    # ── Fallback: In-Memory ───────────────────────────────────────────────────
    now = time.monotonic()
    expired = [k for k, t in _seen_ids.items() if now - t > DEDUP_TTL]
    for k in expired:
        del _seen_ids[k]
    if message_id in _seen_ids:
        return True
    _seen_ids[message_id] = now
    return False


# ─── Postgres Logging ────────────────────────────────────────────────────────

async def _log_message(
    psid: str,
    platform: str,
    direction: str,
    content: str,
    meta_message_id: str | None = None,
    request_id: str | None = None,
) -> None:
    """
    Schreibt Nachricht in messages-Tabelle (aus schema.sql).
    Fehler stoppen nicht die Bridge (nur geloggt).
    """
    if not db_pool:
        return
    try:
        async with db_pool.acquire() as conn:
            await conn.execute(
                """
                INSERT INTO messages
                    (platform, psid, direction, content,
                     meta_message_id, request_id, processed)
                VALUES ($1, $2, $3, $4, $5, $6, true)
                """,
                platform,
                psid,
                direction,
                content[:10_000],
                meta_message_id,
                request_id,
            )
    except Exception as exc:
        log_error("db_log_failed", direction=direction, error=str(exc))


# ─── Error-Logging in DB ────────────────────────────────────────────────────

async def _log_error_to_db(
    error_type: str,
    error_msg: str,
    request_id: str = "",
    context: dict | None = None,
) -> None:
    """Schreibt Fehler in error_logs-Tabelle. Fehler stoppen nicht die Bridge."""
    if not db_pool:
        return
    try:
        async with db_pool.acquire() as conn:
            await conn.execute(
                """
                INSERT INTO error_logs(service, error_type, error_msg, request_id, context)
                VALUES ($1, $2, $3, $4, $5)
                """,
                "meta-bridge",
                error_type,
                error_msg,
                request_id,
                json.dumps(context or {}),
            )
    except Exception as exc:
        log_error("error_log_write_failed", error=str(exc))


# ─── Signatur-Verifikation ───────────────────────────────────────────────────

def _verify_signature(body: bytes, signature_header: str | None) -> bool:
    """Verifiziert X-Hub-Signature-256 gegen APP_SECRET (constant-time compare)."""
    if not signature_header or not signature_header.startswith("sha256="):
        return False
    expected = "sha256=" + hmac.new(
        APP_SECRET.encode("utf-8"), body, hashlib.sha256
    ).hexdigest()
    return hmac.compare_digest(expected, signature_header)


# ─── Meta Graph API ───────────────────────────────────────────────────────────

async def send_meta_message(
    recipient_psid: str,
    text: str,
    platform: str = "messenger",
    request_id: str | None = None,
) -> bool:
    """Sendet Textnachricht via Meta Graph API und loggt ausgehende Nachricht in Postgres."""
    payload = {
        "recipient": {"id": recipient_psid},
        "message": {"text": text[:2000]},  # Meta-Limit: 2000 Zeichen
        "messaging_type": "RESPONSE",
    }
    try:
        async with httpx.AsyncClient(timeout=META_API_TIMEOUT) as client:
            resp = await client.post(
                META_GRAPH_URL,
                params={"access_token": PAGE_ACCESS_TOKEN},
                json=payload,
            )
        if resp.status_code == 200:
            log("meta_send_ok", psid=recipient_psid[:8] + "***")
            await _log_message(
                recipient_psid, platform, "out", text, request_id=request_id
            )
            return True
        log_error(
            "meta_send_failed",
            status=resp.status_code,
            body=resp.text[:200],
            psid=recipient_psid[:8] + "***",
        )
        return False
    except Exception as exc:
        log_error("meta_send_exception", error=str(exc))
        return False


async def _send_meta_with_retry(
    psid: str,
    platform: str,
    text: str,
    request_id: str | None = None,
    max_retries: int = 2,
) -> bool:
    """Sendet Meta-Nachricht mit exponentiellem Backoff (3s → 6s). Logt nach Erschöpfung."""
    for attempt in range(max_retries + 1):
        ok = await send_meta_message(psid, text, platform=platform, request_id=request_id)
        if ok:
            return True
        if attempt < max_retries:
            delay = 3 * (2 ** attempt)  # 3s, 6s
            log_error("meta_send_retry", attempt=attempt + 1, delay_s=delay, psid=psid[:8] + "***")
            await asyncio.sleep(delay)
    await _log_error_to_db(
        "meta_send_exhausted",
        f"All {max_retries + 1} attempts failed",
        request_id=request_id or "",
        context={"psid_prefix": psid[:8], "platform": platform},
    )
    return False


# ─── Vision: Bildbeschreibung via Ollama ─────────────────────────────────────

async def _describe_image(image_url: str, page_token: str = "") -> str | None:
    """
    Downloads image from Meta CDN and sends to qwen3.5:cloud for description.
    Returns text description or None on failure.
    """
    if not VISION_ENABLED or not _HAS_PILLOW:
        return None
    try:
        # Download image (Meta URLs need page token)
        params = {}
        if page_token:
            params["access_token"] = page_token
        async with httpx.AsyncClient(timeout=15) as client:
            img_resp = await client.get(image_url, params=params, follow_redirects=True)
        if img_resp.status_code != 200:
            log_error("vision_download_failed", status=img_resp.status_code, url=image_url[:60])
            return None

        # Resize with Pillow (max 1024px, JPEG)
        img = Image.open(io.BytesIO(img_resp.content)).convert("RGB")
        img.thumbnail((1024, 1024), Image.LANCZOS)
        buf = io.BytesIO()
        img.save(buf, format="JPEG", quality=85)
        img_b64 = base64.b64encode(buf.getvalue()).decode("utf-8")

        # Call qwen3.5:cloud via Ollama API
        async with httpx.AsyncClient(timeout=30) as client:
            vision_resp = await client.post(
                f"{OLLAMA_CLOUD_API_BASE}/chat",
                headers={"Authorization": f"Bearer {OLLAMA_CLOUD_API_KEY}"},
                json={
                    "model": VISION_MODEL,
                    "messages": [{
                        "role": "user",
                        "content": "Describe this image in detail. What objects, people, text, or context do you see? Be specific and concise.",
                        "images": [img_b64],
                    }],
                    "stream": False,
                },
            )
        if vision_resp.status_code != 200:
            log_error("vision_api_failed", status=vision_resp.status_code)
            return None

        description = vision_resp.json().get("message", {}).get("content", "").strip()
        log("vision_ok", model=VISION_MODEL, chars=len(description))
        return description or None

    except Exception as exc:
        log_error("vision_exception", error=str(exc))
        return None


async def _process_attachments(attachments: list) -> str:
    """
    Processes image attachments and returns combined text description.
    Skips non-image attachments.
    """
    descriptions = []
    for att in attachments:
        att_type = att.get("type", "")
        if att_type not in ("image", "photo"):
            continue
        url = att.get("payload", {}).get("url", "")
        if not url:
            continue
        desc = await _describe_image(url, page_token=PAGE_ACCESS_TOKEN)
        if desc:
            descriptions.append(f"[Bild: {desc}]")
    return " ".join(descriptions)


# ─── Payload-Normalisierung ──────────────────────────────────────────────────

def _extract_events(payload: dict) -> list[dict]:
    """
    Extrahiert normalisierte Events aus dem Meta Webhook-Payload.
    Unterstützt Messenger (messaging[]) und Instagram (changes[]).
    """
    events: list[dict] = []
    obj_type = payload.get("object", "")

    for entry in payload.get("entry", []):
        # ── Messenger / Facebook ──────────────────────────────────────────
        for msg_event in entry.get("messaging", []):
            sender = msg_event.get("sender", {}).get("id", "")
            message = msg_event.get("message", {})
            msg_id = message.get("mid", "")
            text = message.get("text", "")
            attachments = message.get("attachments", [])

            if not sender or not msg_id:
                continue
            if message.get("is_echo"):  # Eigene gesendete Nachrichten ignorieren
                continue

            events.append({
                "psid": sender,
                "message_id": msg_id,
                "text": text,
                "attachments": attachments,
                "platform": "messenger",
                "object": obj_type,
            })

        # ── Instagram ─────────────────────────────────────────────────────
        for change in entry.get("changes", []):
            value = change.get("value", {})
            if change.get("field") != "messages":
                continue

            sender = value.get("sender", {}).get("id", "")
            msg = value.get("message", {})
            msg_id = msg.get("mid", "")
            text = msg.get("text", "")

            if not sender or not msg_id:
                continue

            attachments = msg.get("attachments", [])
            events.append({
                "psid": sender,
                "message_id": msg_id,
                "text": text,
                "attachments": attachments,
                "platform": "instagram",
                "object": obj_type,
            })

    return events


# ─── OpenClaw-Integration ────────────────────────────────────────────────────

async def _process_event(event: dict, request_id: str) -> None:
    """
    Verarbeitet ein normalisiertes Event:
    1. Loggt eingehende Nachricht in Postgres
    2. Sendet Event an OpenClaw Hook
    3. Parst Antwort
    4. Sendet Antwort via Meta Graph API (wird auch in Postgres geloggt)
    """
    psid = event["psid"]
    platform = event["platform"]
    t0 = time.monotonic()

    log(
        "processing_event",
        request_id=request_id,
        psid=psid[:8] + "***",
        platform=platform,
        has_text=bool(event.get("text")),
    )

    # Vision: Bilder verarbeiten bevor OpenClaw
    image_text = ""
    if event.get("attachments") and VISION_ENABLED:
        image_text = await _process_attachments(event["attachments"])
        if image_text:
            log("vision_processed", request_id=request_id, chars=len(image_text))

    # Kombinierten Text erstellen
    raw_text = event.get("text", "") or ""
    combined_text = raw_text
    if image_text:
        combined_text = (raw_text + "\n" + image_text).strip() if raw_text else image_text

    # Eingehende Nachricht in Postgres loggen
    await _log_message(
        psid,
        platform,
        "in",
        combined_text or "[attachment]",
        meta_message_id=event.get("message_id"),
        request_id=request_id,
    )

    openclaw_payload = {
        "request_id": request_id,
        "psid": psid,
        "platform": platform,
        "text": combined_text,
        "attachments": event.get("attachments", []),
        "message_id": event["message_id"],
    }

    reply_text: str | None = None

    for attempt in range(2):
        try:
            async with httpx.AsyncClient(timeout=OPENCLAW_TIMEOUT) as client:
                resp = await client.post(OPENCLAW_HOOK_URL, json=openclaw_payload)

            elapsed = round(time.monotonic() - t0, 2)

            if resp.status_code == 200:
                try:
                    data = resp.json()
                    reply_text = (
                        data.get("text")
                        or data.get("reply")
                        or data.get("response")
                        or data.get("content")
                    )
                    if not reply_text and isinstance(data, str):
                        reply_text = data
                except Exception:
                    raw = resp.text.strip()
                    if raw:
                        reply_text = raw

                log(
                    "openclaw_ok",
                    request_id=request_id,
                    elapsed_s=elapsed,
                    has_reply=bool(reply_text),
                )
                break  # Erfolgreich — kein Retry nötig
            else:
                log_error(
                    "openclaw_error",
                    request_id=request_id,
                    status=resp.status_code,
                    body=resp.text[:200],
                    elapsed_s=elapsed,
                )
                if attempt == 1:
                    await _log_error_to_db(
                        "openclaw_error_exhausted",
                        f"HTTP {resp.status_code}",
                        request_id=request_id,
                        context={"status": resp.status_code},
                    )

        except httpx.TimeoutException:
            log_error("openclaw_timeout", request_id=request_id, timeout_s=OPENCLAW_TIMEOUT, attempt=attempt + 1)
            if attempt == 0:
                await asyncio.sleep(5)
            else:
                await _log_error_to_db(
                    "openclaw_timeout_exhausted",
                    f"Timeout after {OPENCLAW_TIMEOUT}s (2 attempts)",
                    request_id=request_id,
                )
        except Exception as exc:
            log_error("openclaw_exception", request_id=request_id, error=str(exc))
            await _log_error_to_db(
                "openclaw_exception",
                str(exc)[:500],
                request_id=request_id,
            )
            break  # Unbekannter Fehler — kein Retry

    if reply_text:
        await _send_meta_with_retry(psid, platform, reply_text, request_id=request_id)


# ─── FastAPI App ──────────────────────────────────────────────────────────────

app = FastAPI(title="meta-bridge", version="2.2.0", lifespan=lifespan)


@app.get("/health")
async def health() -> dict:
    """Dienststatus aller Backends."""
    return {
        "ok": True,
        "service": "meta-bridge",
        "version": "2.2.0",
        "postgres": db_pool is not None,
    }


@app.get("/admin/errors")
async def get_errors(limit: int = 50) -> dict:
    """Letzte Fehler aus error_logs-Tabelle (meta-bridge). Auth: intern only."""
    if not db_pool:
        raise HTTPException(status_code=503, detail="Database not available")
    limit = min(max(1, limit), 200)
    async with db_pool.acquire() as conn:
        rows = await conn.fetch(
            """
            SELECT id, error_type, error_msg, request_id, context, resolved, created_at
            FROM error_logs
            WHERE service = 'meta-bridge'
            ORDER BY created_at DESC
            LIMIT $1
            """,
            limit,
        )
    errors = [
        {
            "id": str(r["id"]),
            "error_type": r["error_type"],
            "error_msg": r["error_msg"],
            "request_id": r["request_id"],
            "context": json.loads(r["context"]) if r["context"] else {},
            "resolved": r["resolved"],
            "created_at": r["created_at"].isoformat(),
        }
        for r in rows
    ]
    return {"ok": True, "count": len(errors), "errors": errors}


@app.get("/webhook", response_class=PlainTextResponse)
async def verify_webhook(
    hub_mode: str = "",
    hub_verify_token: str = "",
    hub_challenge: str = "",
) -> str:
    """Meta Webhook-Verifikation (Subscribe-Flow)."""
    if hub_mode == "subscribe" and hub_verify_token == VERIFY_TOKEN:
        log("webhook_verified")
        return hub_challenge
    log_error("webhook_verify_failed", mode=hub_mode)
    raise HTTPException(status_code=403, detail="Verification failed")


@app.post("/webhook", status_code=200)
async def receive_webhook(
    request: Request,
    background_tasks: BackgroundTasks,
) -> dict:
    """
    Empfängt Meta Webhook Events.
    Antwortet sofort 200 (Meta erwartet < 5s Response).
    Verarbeitung (OpenClaw + Antwort) läuft als Background Task.
    """
    body = await request.body()

    sig = request.headers.get("X-Hub-Signature-256")
    if not _verify_signature(body, sig):
        log_error("signature_invalid")
        raise HTTPException(status_code=403, detail="Invalid signature")

    try:
        payload = json.loads(body)
    except json.JSONDecodeError:
        log_error("invalid_json")
        raise HTTPException(status_code=400, detail="Invalid JSON")

    events = _extract_events(payload)

    for event in events:
        msg_id = event.get("message_id", "")
        if not msg_id:
            continue
        if await _is_duplicate(msg_id):
            log("duplicate_skipped", message_id=msg_id)
            continue

        request_id = str(uuid.uuid4())[:8]
        background_tasks.add_task(_process_event, event, request_id)

    return {"ok": True}


@app.post("/reply", status_code=200)
async def receive_reply(request: Request) -> dict:
    """
    Interner Endpunkt: OpenClaw kann hierüber Antworten asynchron zurückschicken.
    Erwartet: {"psid": "...", "text": "...", "platform": "messenger"}
    """
    try:
        data = await request.json()
    except Exception:
        raise HTTPException(status_code=400, detail="Invalid JSON")

    psid = data.get("psid", "").strip()
    text = data.get("text", "").strip()
    platform = data.get("platform", "messenger").strip()

    if not psid:
        raise HTTPException(status_code=422, detail="psid is required")
    if not text:
        raise HTTPException(status_code=422, detail="text is required")
    if platform not in ("messenger", "instagram", "whatsapp", "test"):
        raise HTTPException(status_code=422, detail=f"Unknown platform: {platform}")

    success = await send_meta_message(psid, text, platform=platform)
    return {"ok": success}
