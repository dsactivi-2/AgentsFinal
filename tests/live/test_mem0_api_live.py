"""
Live-Tests für mem0-api — laufen gegen einen echten Server + Supermemory.
Werden übersprungen wenn Server nicht erreichbar ist.

Ausführen:
  export MEM0_API_URL=http://127.0.0.1:8010
  pytest tests/live/test_mem0_api_live.py -v
"""
import os
import time

import httpx
import pytest

BASE_URL = os.getenv("MEM0_API_URL", "http://127.0.0.1:8010")


def _is_reachable() -> bool:
    try:
        with httpx.Client(timeout=3.0) as c:
            resp = c.get(f"{BASE_URL}/health")
            return resp.status_code == 200
    except Exception:
        return False


pytestmark = pytest.mark.skipif(
    not _is_reachable(),
    reason=f"mem0-api nicht erreichbar auf {BASE_URL}",
)

# Test-User-ID mit Timestamp für Isolation (keine Konflikte bei parallelen Runs)
TEST_USER = f"live_test_user_{int(time.time())}"


# ─── GET /health ──────────────────────────────────────────────────────────────

@pytest.mark.asyncio
async def test_health():
    async with httpx.AsyncClient(base_url=BASE_URL, timeout=10.0) as client:
        resp = await client.get("/health")
    assert resp.status_code == 200
    data = resp.json()
    assert data["service"] == "mem0-api"
    assert data["backend"] == "supermemory"
    # ok kann False sein wenn Supermemory-API-Key ungültig
    assert "ok" in data
    assert "api" in data


# ─── POST /memory/add ─────────────────────────────────────────────────────────

@pytest.mark.asyncio
async def test_add_memory_empty_content():
    """Leerer Content → 422 (kein Supermemory-Call nötig)."""
    async with httpx.AsyncClient(base_url=BASE_URL, timeout=5.0) as client:
        resp = await client.post(
            "/memory/add",
            json={"user_id": TEST_USER, "content": ""},
        )
    assert resp.status_code == 422


@pytest.mark.asyncio
async def test_add_memory_empty_user_id():
    async with httpx.AsyncClient(base_url=BASE_URL, timeout=5.0) as client:
        resp = await client.post(
            "/memory/add",
            json={"user_id": "", "content": "test"},
        )
    assert resp.status_code == 422


# ─── POST /memory/search ──────────────────────────────────────────────────────

@pytest.mark.asyncio
async def test_search_memory_empty_query():
    async with httpx.AsyncClient(base_url=BASE_URL, timeout=5.0) as client:
        resp = await client.post(
            "/memory/search",
            json={"user_id": TEST_USER, "query": ""},
        )
    assert resp.status_code == 422


@pytest.mark.asyncio
async def test_search_memory_returns_structure():
    """Gültige Suche → response hat ok, user_id, count, results."""
    async with httpx.AsyncClient(base_url=BASE_URL, timeout=15.0) as client:
        resp = await client.post(
            "/memory/search",
            json={"user_id": TEST_USER, "query": "live test query"},
        )
    # 200 wenn Supermemory erreichbar, 502 wenn API Key ungültig/nicht gesetzt
    if resp.status_code == 200:
        data = resp.json()
        assert data["ok"] is True
        assert data["user_id"] == TEST_USER
        assert "count" in data
        assert "results" in data
    else:
        assert resp.status_code in (502, 503)
