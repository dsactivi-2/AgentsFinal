"""
Shared test fixtures and configuration.

Env-Vars werden VOR allen App-Importen gesetzt (App liest sie beim Import).
Beide Apps (meta-bridge, mem0-api) werden via importlib geladen um
sys.modules["app"] Konflikte zu vermeiden.
"""
import importlib.util
import os
import sys
import hashlib
import hmac as hmac_mod

import pytest
import pytest_asyncio
import httpx
from httpx import AsyncClient, ASGITransport

# ─── Env-Vars ZUERST — vor allen Importen ─────────────────────────────────────
os.environ.setdefault("META_VERIFY_TOKEN", "test_verify_token")
os.environ.setdefault("META_APP_SECRET", "test_app_secret_1234567890ab")
os.environ.setdefault("META_PAGE_ACCESS_TOKEN", "test_page_token")
os.environ.setdefault("OPENCLAW_HOOK_URL", "http://127.0.0.1:18789/hooks/meta")
os.environ.setdefault("SUPERMEMORY_API_KEY", "sm_test_key_1234567890")
# Nicht-existente Ports → Connection Refused → Graceful Degradation
os.environ.setdefault("REDIS_URL", "redis://127.0.0.1:9999/0")
os.environ.setdefault("DB_HOST", "127.0.0.1")
os.environ.setdefault("DB_PORT", "9999")
os.environ.setdefault("DB_NAME", "test_nonexistent")
os.environ.setdefault("DB_USER", "postgres")
os.environ.setdefault("DB_PASSWORD", "test")


# ─── Pfade ────────────────────────────────────────────────────────────────────
BASE_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
META_BRIDGE_APP_PATH = os.path.join(BASE_DIR, "services", "meta-bridge", "app.py")
MEM0_API_APP_PATH = os.path.join(BASE_DIR, "services", "mem0-api", "app.py")


def _load_module(name: str, path: str):
    """Lädt App-Modul mit eindeutigem Namen (verhindert sys.modules Konflikte)."""
    if name in sys.modules:
        return sys.modules[name]
    spec = importlib.util.spec_from_file_location(name, path)
    mod = importlib.util.module_from_spec(spec)
    sys.modules[name] = mod
    spec.loader.exec_module(mod)
    return mod


# ─── Signatur-Helper (für Webhook-Tests) ──────────────────────────────────────

def make_sig(body: bytes, secret: str = "test_app_secret_1234567890ab") -> str:
    """Berechnet X-Hub-Signature-256 für Meta Webhook Tests."""
    return "sha256=" + hmac_mod.new(
        secret.encode("utf-8"), body, hashlib.sha256
    ).hexdigest()


# ─── Meta-Bridge Fixtures ─────────────────────────────────────────────────────

@pytest_asyncio.fixture
async def bridge_client():
    """Async HTTP-Client gegen die meta-bridge FastAPI-App (kein echter Server)."""
    bridge_mod = _load_module("meta_bridge_app", META_BRIDGE_APP_PATH)
    async with AsyncClient(
        transport=ASGITransport(app=bridge_mod.app),
        base_url="http://testserver",
    ) as client:
        yield client


@pytest.fixture
def bridge_mod():
    """meta-bridge Modul (für Zugriff auf interne Funktionen)."""
    return _load_module("meta_bridge_app", META_BRIDGE_APP_PATH)


@pytest.fixture
def app_secret() -> str:
    return os.environ["META_APP_SECRET"]


@pytest.fixture
def verify_token() -> str:
    return os.environ["META_VERIFY_TOKEN"]


# ─── mem0-api Fixtures ────────────────────────────────────────────────────────

@pytest_asyncio.fixture
async def mem0_client():
    """Async HTTP-Client gegen die mem0-api FastAPI-App (kein echter Server)."""
    mem0_mod = _load_module("mem0_api_app", MEM0_API_APP_PATH)
    async with AsyncClient(
        transport=ASGITransport(app=mem0_mod.app),
        base_url="http://testserver",
    ) as client:
        yield client


# ─── Test-Payloads ────────────────────────────────────────────────────────────

MESSENGER_PAYLOAD = {
    "object": "page",
    "entry": [{
        "id": "123456",
        "time": 1700000000,
        "messaging": [{
            "sender": {"id": "psid_111"},
            "recipient": {"id": "page_222"},
            "timestamp": 1700000000,
            "message": {
                "mid": "mid_abc123",
                "text": "Hallo Ava"
            }
        }]
    }]
}

INSTAGRAM_PAYLOAD = {
    "object": "instagram",
    "entry": [{
        "id": "123456",
        "time": 1700000000,
        "changes": [{
            "field": "messages",
            "value": {
                "sender": {"id": "ig_psid_333"},
                "recipient": {"id": "ig_page_444"},
                "message": {
                    "mid": "mid_ig_xyz",
                    "text": "Hi from Instagram"
                }
            }
        }]
    }]
}

ECHO_PAYLOAD = {
    "object": "page",
    "entry": [{
        "id": "123456",
        "time": 1700000000,
        "messaging": [{
            "sender": {"id": "psid_111"},
            "recipient": {"id": "page_222"},
            "timestamp": 1700000000,
            "message": {
                "mid": "mid_echo_999",
                "text": "Echo",
                "is_echo": True
            }
        }]
    }]
}
