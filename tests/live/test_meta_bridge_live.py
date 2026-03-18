"""
Live-Tests für meta-bridge — laufen gegen einen echten Server.
Werden übersprungen wenn Server nicht erreichbar ist.

Ausführen:
  export META_BRIDGE_URL=http://127.0.0.1:8085
  pytest tests/live/test_meta_bridge_live.py -v
"""
import os
import json
import hashlib
import hmac as hmac_mod

import httpx
import pytest

BASE_URL = os.getenv("META_BRIDGE_URL", "http://127.0.0.1:8085")
APP_SECRET = os.getenv("META_APP_SECRET", "")
VERIFY_TOKEN = os.getenv("META_VERIFY_TOKEN", "")


def _is_reachable() -> bool:
    try:
        with httpx.Client(timeout=3.0) as c:
            resp = c.get(f"{BASE_URL}/health")
            return resp.status_code == 200
    except Exception:
        return False


def _make_sig(body: bytes, secret: str) -> str:
    return "sha256=" + hmac_mod.new(
        secret.encode("utf-8"), body, hashlib.sha256
    ).hexdigest()


pytestmark = pytest.mark.skipif(
    not _is_reachable(),
    reason=f"meta-bridge nicht erreichbar auf {BASE_URL}",
)


# ─── GET /health ──────────────────────────────────────────────────────────────

@pytest.mark.asyncio
async def test_health():
    async with httpx.AsyncClient(base_url=BASE_URL, timeout=5.0) as client:
        resp = await client.get("/health")
    assert resp.status_code == 200
    data = resp.json()
    assert data["ok"] is True
    assert data["service"] == "meta-bridge"
    assert "redis" in data
    assert "postgres" in data


# ─── GET /webhook — Verifikation ──────────────────────────────────────────────

@pytest.mark.asyncio
async def test_webhook_verify():
    if not VERIFY_TOKEN:
        pytest.skip("META_VERIFY_TOKEN nicht gesetzt")

    async with httpx.AsyncClient(base_url=BASE_URL, timeout=5.0) as client:
        resp = await client.get(
            "/webhook",
            params={
                "hub_mode": "subscribe",
                "hub_verify_token": VERIFY_TOKEN,
                "hub_challenge": "live_test_challenge_abc",
            },
        )
    assert resp.status_code == 200
    assert resp.text == "live_test_challenge_abc"


@pytest.mark.asyncio
async def test_webhook_verify_wrong_token():
    async with httpx.AsyncClient(base_url=BASE_URL, timeout=5.0) as client:
        resp = await client.get(
            "/webhook",
            params={
                "hub_mode": "subscribe",
                "hub_verify_token": "DEFINITELY_WRONG_TOKEN_12345",
                "hub_challenge": "xyz",
            },
        )
    assert resp.status_code == 403


# ─── POST /webhook — Signatur-Prüfung ─────────────────────────────────────────

@pytest.mark.asyncio
async def test_webhook_post_invalid_signature():
    body = b'{"object": "page", "entry": []}'
    async with httpx.AsyncClient(base_url=BASE_URL, timeout=5.0) as client:
        resp = await client.post(
            "/webhook",
            content=body,
            headers={
                "X-Hub-Signature-256": "sha256=invalidsignature000",
                "Content-Type": "application/json",
            },
        )
    assert resp.status_code == 403


@pytest.mark.asyncio
async def test_webhook_post_empty_payload():
    """Leeres Entry-Array — gültige Signatur → 200, kein Crash."""
    if not APP_SECRET:
        pytest.skip("META_APP_SECRET nicht gesetzt")

    payload = {"object": "page", "entry": []}
    body = json.dumps(payload).encode()
    sig = _make_sig(body, APP_SECRET)

    async with httpx.AsyncClient(base_url=BASE_URL, timeout=10.0) as client:
        resp = await client.post(
            "/webhook",
            content=body,
            headers={
                "X-Hub-Signature-256": sig,
                "Content-Type": "application/json",
            },
        )
    assert resp.status_code == 200


# ─── POST /reply ──────────────────────────────────────────────────────────────

@pytest.mark.asyncio
async def test_reply_missing_fields():
    """Fehlende Pflichtfelder → 422 (kein externer Call nötig)."""
    async with httpx.AsyncClient(base_url=BASE_URL, timeout=5.0) as client:
        resp = await client.post(
            "/reply",
            json={"text": "test"},  # psid fehlt
        )
    assert resp.status_code == 422


@pytest.mark.asyncio
async def test_reply_invalid_platform():
    async with httpx.AsyncClient(base_url=BASE_URL, timeout=5.0) as client:
        resp = await client.post(
            "/reply",
            json={"psid": "psid_live_test", "text": "test", "platform": "tiktok"},
        )
    assert resp.status_code == 422
