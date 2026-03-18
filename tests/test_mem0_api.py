"""
Mock-Tests für mem0-api.
Läuft ohne laufenden Server — alle Supermemory-Calls werden via respx gemockt.
"""
import pytest
import respx
import httpx

from conftest import mem0_client  # noqa: F401 — fixture import


SUPERMEMORY_BASE = "https://api.supermemory.ai/v3"


# ─── GET /health ──────────────────────────────────────────────────────────────

@pytest.mark.asyncio
async def test_health_ok(mem0_client):
    with respx.mock:
        respx.post(f"{SUPERMEMORY_BASE}/search").mock(
            return_value=httpx.Response(200, json={"results": []})
        )
        resp = await mem0_client.get("/health")

    assert resp.status_code == 200
    data = resp.json()
    assert data["ok"] is True
    assert data["service"] == "mem0-api"
    assert data["backend"] == "supermemory"
    assert "container_tag" in data
    assert data["api"] == "ok"


@pytest.mark.asyncio
async def test_health_supermemory_error(mem0_client):
    """Supermemory antwortet mit 500 → ok=False, api=error."""
    with respx.mock:
        respx.post(f"{SUPERMEMORY_BASE}/search").mock(
            return_value=httpx.Response(500, text="Internal Server Error")
        )
        resp = await mem0_client.get("/health")

    assert resp.status_code == 200
    data = resp.json()
    assert data["ok"] is False
    assert data["api"] == "error"


@pytest.mark.asyncio
async def test_health_supermemory_unreachable(mem0_client):
    """Supermemory nicht erreichbar → ok=False, error enthält Fehlermeldung."""
    with respx.mock:
        respx.post(f"{SUPERMEMORY_BASE}/search").mock(
            side_effect=httpx.ConnectError("Connection refused")
        )
        resp = await mem0_client.get("/health")

    assert resp.status_code == 200
    data = resp.json()
    assert data["ok"] is False
    assert data["error"] is not None


# ─── POST /memory/add ─────────────────────────────────────────────────────────

@pytest.mark.asyncio
async def test_add_memory_ok(mem0_client):
    with respx.mock:
        respx.post(f"{SUPERMEMORY_BASE}/documents").mock(
            return_value=httpx.Response(201, json={"id": "doc_abc123"})
        )
        resp = await mem0_client.post(
            "/memory/add",
            json={"user_id": "psid_test_111", "content": "Test memory content"},
        )

    assert resp.status_code == 200
    data = resp.json()
    assert data["ok"] is True
    assert data["id"] == "doc_abc123"


@pytest.mark.asyncio
async def test_add_memory_with_metadata(mem0_client):
    with respx.mock:
        respx.post(f"{SUPERMEMORY_BASE}/documents").mock(
            return_value=httpx.Response(200, json={"documentId": "doc_xyz"})
        )
        resp = await mem0_client.post(
            "/memory/add",
            json={
                "user_id": "psid_222",
                "content": "Lead interessiert sich für Produkt X",
                "metadata": {"platform": "messenger", "intent": "lead"},
            },
        )

    assert resp.status_code == 200
    assert resp.json()["id"] == "doc_xyz"


@pytest.mark.asyncio
async def test_add_memory_empty_content(mem0_client):
    resp = await mem0_client.post(
        "/memory/add",
        json={"user_id": "psid_333", "content": ""},
    )
    assert resp.status_code == 422


@pytest.mark.asyncio
async def test_add_memory_whitespace_content(mem0_client):
    resp = await mem0_client.post(
        "/memory/add",
        json={"user_id": "psid_333", "content": "   "},
    )
    assert resp.status_code == 422


@pytest.mark.asyncio
async def test_add_memory_empty_user_id(mem0_client):
    resp = await mem0_client.post(
        "/memory/add",
        json={"user_id": "", "content": "some content"},
    )
    assert resp.status_code == 422


@pytest.mark.asyncio
async def test_add_memory_whitespace_user_id(mem0_client):
    resp = await mem0_client.post(
        "/memory/add",
        json={"user_id": "  ", "content": "some content"},
    )
    assert resp.status_code == 422


@pytest.mark.asyncio
async def test_add_memory_missing_fields(mem0_client):
    """Fehlende Pflichtfelder → 422."""
    resp = await mem0_client.post("/memory/add", json={"user_id": "psid_x"})
    assert resp.status_code == 422


@pytest.mark.asyncio
async def test_add_memory_supermemory_error(mem0_client):
    """Supermemory gibt 503 zurück → 502 von mem0-api."""
    with respx.mock:
        respx.post(f"{SUPERMEMORY_BASE}/documents").mock(
            return_value=httpx.Response(503, text="Service Unavailable")
        )
        resp = await mem0_client.post(
            "/memory/add",
            json={"user_id": "psid_444", "content": "Test"},
        )

    assert resp.status_code == 502


# ─── POST /memory/search ──────────────────────────────────────────────────────

@pytest.mark.asyncio
async def test_search_memory_ok(mem0_client):
    hits = [{"id": "doc_1", "content": "Lead info", "score": 0.95}]
    with respx.mock:
        respx.post(f"{SUPERMEMORY_BASE}/search").mock(
            return_value=httpx.Response(200, json={"results": hits})
        )
        resp = await mem0_client.post(
            "/memory/search",
            json={"user_id": "psid_111", "query": "lead interesse"},
        )

    assert resp.status_code == 200
    data = resp.json()
    assert data["ok"] is True
    assert data["user_id"] == "psid_111"
    assert data["count"] == 1
    assert len(data["results"]) == 1


@pytest.mark.asyncio
async def test_search_memory_no_results(mem0_client):
    with respx.mock:
        respx.post(f"{SUPERMEMORY_BASE}/search").mock(
            return_value=httpx.Response(200, json={"results": []})
        )
        resp = await mem0_client.post(
            "/memory/search",
            json={"user_id": "psid_111", "query": "unbekannte anfrage xyz"},
        )

    assert resp.status_code == 200
    assert resp.json()["count"] == 0


@pytest.mark.asyncio
async def test_search_memory_custom_limit(mem0_client):
    hits = [{"id": f"doc_{i}"} for i in range(5)]
    with respx.mock:
        respx.post(f"{SUPERMEMORY_BASE}/search").mock(
            return_value=httpx.Response(200, json={"results": hits})
        )
        resp = await mem0_client.post(
            "/memory/search",
            json={"user_id": "psid_111", "query": "test", "limit": 5},
        )

    assert resp.status_code == 200
    assert resp.json()["count"] == 5


@pytest.mark.asyncio
async def test_search_memory_empty_query(mem0_client):
    resp = await mem0_client.post(
        "/memory/search",
        json={"user_id": "psid_111", "query": ""},
    )
    assert resp.status_code == 422


@pytest.mark.asyncio
async def test_search_memory_whitespace_query(mem0_client):
    resp = await mem0_client.post(
        "/memory/search",
        json={"user_id": "psid_111", "query": "  "},
    )
    assert resp.status_code == 422


@pytest.mark.asyncio
async def test_search_memory_empty_user_id(mem0_client):
    resp = await mem0_client.post(
        "/memory/search",
        json={"user_id": "", "query": "test"},
    )
    assert resp.status_code == 422


@pytest.mark.asyncio
async def test_search_memory_limit_validation(mem0_client):
    """limit > 50 → 422."""
    resp = await mem0_client.post(
        "/memory/search",
        json={"user_id": "psid_111", "query": "test", "limit": 100},
    )
    assert resp.status_code == 422


# ─── GET /memory/{user_id} ────────────────────────────────────────────────────

@pytest.mark.asyncio
async def test_get_memories_ok(mem0_client):
    hits = [{"id": "doc_1"}, {"id": "doc_2"}]
    with respx.mock:
        respx.post(f"{SUPERMEMORY_BASE}/search").mock(
            return_value=httpx.Response(200, json={"results": hits})
        )
        resp = await mem0_client.get("/memory/psid_test_777")

    assert resp.status_code == 200
    data = resp.json()
    assert data["ok"] is True
    assert data["user_id"] == "psid_test_777"
    assert data["count"] == 2


@pytest.mark.asyncio
async def test_get_memories_empty(mem0_client):
    with respx.mock:
        respx.post(f"{SUPERMEMORY_BASE}/search").mock(
            return_value=httpx.Response(200, json={"results": []})
        )
        resp = await mem0_client.get("/memory/psid_new_user")

    assert resp.status_code == 200
    assert resp.json()["count"] == 0


# ─── DELETE /memory/{document_id} ────────────────────────────────────────────

@pytest.mark.asyncio
async def test_delete_memory_ok(mem0_client):
    with respx.mock:
        respx.delete(f"{SUPERMEMORY_BASE}/documents/doc_del_123").mock(
            return_value=httpx.Response(200, json={"deleted": True})
        )
        resp = await mem0_client.delete("/memory/doc_del_123")

    assert resp.status_code == 200
    data = resp.json()
    assert data["ok"] is True
    assert data["deleted"] == "doc_del_123"


@pytest.mark.asyncio
async def test_delete_memory_sm_error(mem0_client):
    """Supermemory gibt 404 zurück → 502 von mem0-api."""
    with respx.mock:
        respx.delete(f"{SUPERMEMORY_BASE}/documents/nonexistent").mock(
            return_value=httpx.Response(404, text="Not Found")
        )
        resp = await mem0_client.delete("/memory/nonexistent")

    assert resp.status_code == 502
