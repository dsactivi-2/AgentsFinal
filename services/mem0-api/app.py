"""
mem0 API — Semantisches Langzeit-Memory via Supermemory.ai.

Wrapper-API die intern die Supermemory REST API nutzt.
Kein OpenAI-Key nötig — nur SUPERMEMORY_API_KEY.

Endpunkte:
  POST /memory/add      → Eintrag speichern
  POST /memory/search   → Semantische Suche
  GET  /memory/{user_id}→ Alle Einträge eines Nutzers
  DELETE /memory/{id}   → Eintrag löschen
  GET  /health          → Dienststatus
"""

import logging
import os
from typing import Any

import httpx
from fastapi import FastAPI, HTTPException
from pydantic import BaseModel, Field

# ─── Logging ────────────────────────────────────────────────────────────────

logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s [%(levelname)s] %(message)s",
)
logger = logging.getLogger("mem0-api")

# ─── Konfiguration ───────────────────────────────────────────────────────────

SUPERMEMORY_API_KEY: str = os.environ["SUPERMEMORY_API_KEY"]
SUPERMEMORY_BASE: str = "https://api.supermemory.ai/v3"

# Container-Tag für diese Stack-Instanz (trennt Memories von anderen Projekten)
CONTAINER_TAG: str = os.getenv("SUPERMEMORY_CONTAINER_TAG", "social-ai-stack")

TIMEOUT: float = float(os.getenv("MEM0_TIMEOUT", "15"))

# ─── HTTP-Client Helper ──────────────────────────────────────────────────────

def _headers() -> dict[str, str]:
    return {
        "Authorization": f"Bearer {SUPERMEMORY_API_KEY}",
        "Content-Type": "application/json",
    }


async def _sm_post(path: str, payload: dict) -> dict:
    async with httpx.AsyncClient(timeout=TIMEOUT) as client:
        resp = await client.post(
            f"{SUPERMEMORY_BASE}{path}",
            json=payload,
            headers=_headers(),
        )
    if resp.status_code not in (200, 201):
        raise HTTPException(
            status_code=502,
            detail=f"Supermemory error {resp.status_code}: {resp.text[:200]}",
        )
    return resp.json()


async def _sm_delete(path: str) -> dict:
    async with httpx.AsyncClient(timeout=TIMEOUT) as client:
        resp = await client.delete(
            f"{SUPERMEMORY_BASE}{path}",
            headers=_headers(),
        )
    if resp.status_code not in (200, 204):
        raise HTTPException(
            status_code=502,
            detail=f"Supermemory delete error {resp.status_code}: {resp.text[:200]}",
        )
    return {"ok": True}


# ─── Pydantic-Modelle ────────────────────────────────────────────────────────

class AddRequest(BaseModel):
    user_id: str = Field(..., description="Nutzer-ID (PSID oder interne ID)")
    content: str = Field(..., description="Zu speichernder Inhalt")
    metadata: dict[str, Any] = Field(default_factory=dict, description="Optionale Metadaten")


class SearchRequest(BaseModel):
    user_id: str = Field(..., description="Nutzer-ID")
    query: str = Field(..., description="Suchanfrage (natürliche Sprache)")
    limit: int = Field(10, ge=1, le=50, description="Maximale Treffer")


# ─── FastAPI App ──────────────────────────────────────────────────────────────

app = FastAPI(title="mem0-api", version="1.0.0")


@app.get("/health")
async def health() -> dict:
    """Dienststatus + Supermemory-Ping."""
    api_ok = False
    error: str | None = None
    try:
        async with httpx.AsyncClient(timeout=5) as client:
            resp = await client.post(
                f"{SUPERMEMORY_BASE}/search",
                json={"q": "health_check", "limit": 1},
                headers=_headers(),
            )
        api_ok = resp.status_code == 200
    except Exception as exc:
        error = str(exc)

    return {
        "ok": api_ok,
        "service": "mem0-api",
        "backend": "supermemory",
        "container_tag": CONTAINER_TAG,
        "api": "ok" if api_ok else "error",
        "error": error,
    }


@app.post("/memory/add")
async def add_memory(req: AddRequest) -> dict:
    """
    Speichert einen Eintrag im Supermemory-Backend.
    Setzt containerTags für Isolation und user_id als Metadata.
    """
    if not req.content.strip():
        raise HTTPException(status_code=422, detail="content must not be empty")
    if not req.user_id.strip():
        raise HTTPException(status_code=422, detail="user_id must not be empty")

    # Inhalt mit User-Kontext anreichern
    enriched = f"[user:{req.user_id}]\n\n{req.content}"

    payload: dict[str, Any] = {
        "content": enriched,
        "containerTags": [CONTAINER_TAG, f"user:{req.user_id}"],
        "metadata": {
            "user_id": req.user_id,
            "source": "mem0-api",
            **req.metadata,
        },
    }

    result = await _sm_post("/documents", payload)
    doc_id = result.get("id") or result.get("documentId", "unknown")

    logger.info(f"memory_add user={req.user_id[:8]}*** doc_id={doc_id}")
    return {"ok": True, "id": doc_id, "result": result}


@app.post("/memory/search")
async def search_memory(req: SearchRequest) -> dict:
    """Semantische Suche über die Memories eines Nutzers."""
    if not req.query.strip():
        raise HTTPException(status_code=422, detail="query must not be empty")
    if not req.user_id.strip():
        raise HTTPException(status_code=422, detail="user_id must not be empty")

    payload: dict[str, Any] = {
        "q": req.query,
        "limit": req.limit,
        "containerTags": [CONTAINER_TAG, f"user:{req.user_id}"],
    }

    result = await _sm_post("/search", payload)
    hits = result.get("results", [])

    logger.info(
        f"memory_search user={req.user_id[:8]}*** "
        f"query={req.query[:40]!r} hits={len(hits)}"
    )
    return {"ok": True, "user_id": req.user_id, "count": len(hits), "results": hits}


@app.get("/memory/{user_id}")
async def get_memories(user_id: str) -> dict:
    """
    Sucht alle Memories eines Nutzers via Supermemory.
    Nutzt eine weite Suche um alle Einträge zu finden.
    """
    if not user_id.strip():
        raise HTTPException(status_code=422, detail="user_id must not be empty")

    payload: dict[str, Any] = {
        "q": f"user:{user_id}",
        "limit": 50,
        "containerTags": [CONTAINER_TAG, f"user:{user_id}"],
    }

    result = await _sm_post("/search", payload)
    hits = result.get("results", [])

    logger.info(f"memory_get_all user={user_id[:8]}*** count={len(hits)}")
    return {"ok": True, "user_id": user_id, "count": len(hits), "results": hits}


@app.delete("/memory/{document_id}")
async def delete_memory(document_id: str) -> dict:
    """Löscht ein Dokument aus Supermemory anhand seiner Document-ID."""
    if not document_id.strip():
        raise HTTPException(status_code=422, detail="document_id must not be empty")

    result = await _sm_delete(f"/documents/{document_id}")
    logger.info(f"memory_delete doc_id={document_id}")
    return {"ok": True, "deleted": document_id}
