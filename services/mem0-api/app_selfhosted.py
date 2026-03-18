"""
mem0 API — Semantisches Langzeit-Memory (Variant A: Self-Hosted).

Backend: mem0ai Python SDK + Qdrant (vectors) + Neo4j (graph) + Ollama (embeddings).
Identische API wie app.py (Supermemory), austauschbar.

Endpunkte:
  POST /memory/add      → Eintrag speichern
  POST /memory/search   → Semantische Suche
  GET  /memory/{user_id}→ Alle Einträge eines Nutzers
  DELETE /memory/{id}   → Eintrag löschen
  GET  /health          → Dienststatus + Backend-Ping
"""

import asyncio
import logging
import os
from typing import Any

import httpx
from fastapi import FastAPI, HTTPException
from mem0 import Memory
from pydantic import BaseModel, Field

# ─── Logging ────────────────────────────────────────────────────────────────

logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s [%(levelname)s] %(message)s",
)
logger = logging.getLogger("mem0-api")

# ─── Konfiguration ───────────────────────────────────────────────────────────

QDRANT_HOST: str    = os.getenv("QDRANT_HOST", "localhost")
QDRANT_PORT: int    = int(os.getenv("QDRANT_PORT", "6333"))

NEO4J_URL: str      = os.getenv("NEO4J_URL", "bolt://localhost:7687")
NEO4J_USER: str     = os.getenv("NEO4J_USER", "neo4j")
NEO4J_PASSWORD: str = os.environ["NEO4J_PASSWORD"]      # Pflicht

OLLAMA_BASE: str    = os.getenv("OLLAMA_BASE", "http://localhost:11434")
LLM_MODEL: str      = os.getenv("MEM0_LLM_MODEL", "llama3.2")
EMBED_MODEL: str    = os.getenv("MEM0_EMBED_MODEL", "bge-m3")

# ─── mem0 Initialisierung ─────────────────────────────────────────────────

_mem0_config = {
    "vector_store": {
        "provider": "qdrant",
        "config": {
            "host": QDRANT_HOST,
            "port": QDRANT_PORT,
            "collection_name": "social_ai_memory",
        },
    },
    "graph_store": {
        "provider": "neo4j",
        "config": {
            "url": NEO4J_URL,
            "username": NEO4J_USER,
            "password": NEO4J_PASSWORD,
        },
    },
    "llm": {
        "provider": "ollama",
        "config": {
            "model": LLM_MODEL,
            "ollama_base_url": OLLAMA_BASE,
        },
    },
    "embedder": {
        "provider": "ollama",
        "config": {
            "model": EMBED_MODEL,
            "ollama_base_url": OLLAMA_BASE,
        },
    },
}

try:
    _memory = Memory.from_config(_mem0_config)
    logger.info(
        f"mem0 self-hosted ready — Qdrant={QDRANT_HOST}:{QDRANT_PORT} "
        f"Neo4j={NEO4J_URL} LLM={LLM_MODEL} Embed={EMBED_MODEL}"
    )
except Exception as exc:
    logger.error(f"mem0 init failed: {exc}")
    raise

# ─── Pydantic-Modelle ────────────────────────────────────────────────────────

class AddRequest(BaseModel):
    user_id: str = Field(..., description="Nutzer-ID (PSID oder interne ID)")
    content: str = Field(..., description="Zu speichernder Inhalt")
    metadata: dict[str, Any] = Field(default_factory=dict, description="Optionale Metadaten")


class SearchRequest(BaseModel):
    user_id: str = Field(..., description="Nutzer-ID")
    query: str   = Field(..., description="Suchanfrage (natürliche Sprache)")
    limit: int   = Field(10, ge=1, le=50, description="Maximale Treffer")


# ─── FastAPI App ──────────────────────────────────────────────────────────────

app = FastAPI(title="mem0-api (self-hosted)", version="2.0.0")


@app.get("/health")
async def health() -> dict:
    """Dienststatus: Qdrant + Neo4j + Ollama Erreichbarkeit prüfen."""
    backends: dict[str, str] = {}
    errors: list[str] = []

    async with httpx.AsyncClient(timeout=5) as client:
        # Qdrant
        try:
            r = await client.get(f"http://{QDRANT_HOST}:{QDRANT_PORT}/healthz")
            backends["qdrant"] = "ok" if r.status_code == 200 else f"http_{r.status_code}"
        except Exception as e:
            backends["qdrant"] = "error"
            errors.append(f"qdrant: {e}")

        # Ollama
        try:
            r = await client.get(f"{OLLAMA_BASE}/api/version")
            backends["ollama"] = "ok" if r.status_code == 200 else f"http_{r.status_code}"
        except Exception as e:
            backends["ollama"] = "error"
            errors.append(f"ollama: {e}")

    # Neo4j (sync driver, run in thread)
    try:
        from neo4j import GraphDatabase  # type: ignore[import]
        def _ping() -> str:
            with GraphDatabase.driver(NEO4J_URL, auth=(NEO4J_USER, NEO4J_PASSWORD)) as d:
                d.verify_connectivity()
            return "ok"
        backends["neo4j"] = await asyncio.to_thread(_ping)
    except Exception as e:
        backends["neo4j"] = "error"
        errors.append(f"neo4j: {e}")

    all_ok = all(v == "ok" for v in backends.values())
    return {
        "ok": all_ok,
        "service": "mem0-api",
        "backend": "self-hosted",
        "backends": backends,
        "errors": errors if errors else None,
    }


@app.post("/memory/add")
async def add_memory(req: AddRequest) -> dict:
    """Speichert einen Eintrag via mem0ai (Qdrant + Neo4j)."""
    if not req.content.strip():
        raise HTTPException(status_code=422, detail="content must not be empty")
    if not req.user_id.strip():
        raise HTTPException(status_code=422, detail="user_id must not be empty")

    metadata = {"source": "mem0-api", **req.metadata}

    try:
        result = await asyncio.to_thread(
            _memory.add,
            req.content,
            user_id=req.user_id,
            metadata=metadata,
        )
    except Exception as exc:
        logger.error(f"memory_add error user={req.user_id[:8]}***: {exc}")
        raise HTTPException(status_code=502, detail=f"mem0 add failed: {exc}") from exc

    # mem0 returns list of result dicts with 'id' field
    results = result if isinstance(result, list) else [result]
    doc_id = results[0].get("id", "unknown") if results else "unknown"

    logger.info(f"memory_add user={req.user_id[:8]}*** doc_id={doc_id}")
    return {"ok": True, "id": doc_id, "result": results}


@app.post("/memory/search")
async def search_memory(req: SearchRequest) -> dict:
    """Semantische Suche via mem0ai."""
    if not req.query.strip():
        raise HTTPException(status_code=422, detail="query must not be empty")
    if not req.user_id.strip():
        raise HTTPException(status_code=422, detail="user_id must not be empty")

    try:
        results = await asyncio.to_thread(
            _memory.search,
            req.query,
            user_id=req.user_id,
            limit=req.limit,
        )
    except Exception as exc:
        logger.error(f"memory_search error user={req.user_id[:8]}***: {exc}")
        raise HTTPException(status_code=502, detail=f"mem0 search failed: {exc}") from exc

    hits = results if isinstance(results, list) else results.get("results", [])

    logger.info(
        f"memory_search user={req.user_id[:8]}*** "
        f"query={req.query[:40]!r} hits={len(hits)}"
    )
    return {"ok": True, "user_id": req.user_id, "count": len(hits), "results": hits}


@app.get("/memory/{user_id}")
async def get_memories(user_id: str) -> dict:
    """Alle gespeicherten Memories eines Nutzers."""
    if not user_id.strip():
        raise HTTPException(status_code=422, detail="user_id must not be empty")

    try:
        results = await asyncio.to_thread(_memory.get_all, user_id=user_id)
    except Exception as exc:
        logger.error(f"memory_get_all error user={user_id[:8]}***: {exc}")
        raise HTTPException(status_code=502, detail=f"mem0 get_all failed: {exc}") from exc

    hits = results if isinstance(results, list) else results.get("results", [])

    logger.info(f"memory_get_all user={user_id[:8]}*** count={len(hits)}")
    return {"ok": True, "user_id": user_id, "count": len(hits), "results": hits}


@app.delete("/memory/{memory_id}")
async def delete_memory(memory_id: str) -> dict:
    """Löscht einen Memory-Eintrag anhand seiner ID."""
    if not memory_id.strip():
        raise HTTPException(status_code=422, detail="memory_id must not be empty")

    try:
        await asyncio.to_thread(_memory.delete, memory_id)
    except Exception as exc:
        logger.error(f"memory_delete error id={memory_id}: {exc}")
        raise HTTPException(status_code=502, detail=f"mem0 delete failed: {exc}") from exc

    logger.info(f"memory_delete id={memory_id}")
    return {"ok": True, "deleted": memory_id}
