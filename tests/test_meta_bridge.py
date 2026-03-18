"""
Mock-Tests für meta-bridge.
Läuft ohne laufenden Server — alle externen Calls werden via respx gemockt.
"""
import json
import pytest
import respx
import httpx

from conftest import make_sig, MESSENGER_PAYLOAD, INSTAGRAM_PAYLOAD, ECHO_PAYLOAD


# ─── GET /health ──────────────────────────────────────────────────────────────

@pytest.mark.asyncio
async def test_health_ok(bridge_client):
    resp = await bridge_client.get("/health")
    assert resp.status_code == 200
    data = resp.json()
    assert data["ok"] is True
    assert data["service"] == "meta-bridge"
    assert "redis" in data
    assert "postgres" in data


# ─── GET /webhook — Verifikation ──────────────────────────────────────────────

@pytest.mark.asyncio
async def test_webhook_verify_ok(bridge_client, verify_token):
    resp = await bridge_client.get(
        "/webhook",
        params={
            "hub_mode": "subscribe",
            "hub_verify_token": verify_token,
            "hub_challenge": "test_challenge_abc",
        },
    )
    assert resp.status_code == 200
    assert resp.text == "test_challenge_abc"


@pytest.mark.asyncio
async def test_webhook_verify_wrong_token(bridge_client):
    resp = await bridge_client.get(
        "/webhook",
        params={
            "hub_mode": "subscribe",
            "hub_verify_token": "FALSCHES_TOKEN",
            "hub_challenge": "xyz",
        },
    )
    assert resp.status_code == 403


@pytest.mark.asyncio
async def test_webhook_verify_wrong_mode(bridge_client, verify_token):
    resp = await bridge_client.get(
        "/webhook",
        params={
            "hub_mode": "unsubscribe",
            "hub_verify_token": verify_token,
            "hub_challenge": "xyz",
        },
    )
    assert resp.status_code == 403


@pytest.mark.asyncio
async def test_webhook_verify_empty_params(bridge_client):
    resp = await bridge_client.get("/webhook")
    assert resp.status_code == 403


# ─── POST /webhook — Eingehende Events ───────────────────────────────────────

@pytest.mark.asyncio
async def test_webhook_post_invalid_signature(bridge_client):
    body = json.dumps(MESSENGER_PAYLOAD).encode()
    resp = await bridge_client.post(
        "/webhook",
        content=body,
        headers={
            "X-Hub-Signature-256": "sha256=invalidsignature",
            "Content-Type": "application/json",
        },
    )
    assert resp.status_code == 403


@pytest.mark.asyncio
async def test_webhook_post_missing_signature(bridge_client):
    body = json.dumps(MESSENGER_PAYLOAD).encode()
    resp = await bridge_client.post(
        "/webhook",
        content=body,
        headers={"Content-Type": "application/json"},
    )
    assert resp.status_code == 403


@pytest.mark.asyncio
async def test_webhook_post_invalid_json(bridge_client, app_secret):
    body = b"nicht-json-content"
    sig = make_sig(body, app_secret)
    resp = await bridge_client.post(
        "/webhook",
        content=body,
        headers={
            "X-Hub-Signature-256": sig,
            "Content-Type": "application/json",
        },
    )
    assert resp.status_code == 400


@pytest.mark.asyncio
async def test_webhook_post_messenger_event(bridge_client, app_secret):
    """Gültiger Messenger-Event → 200, Background-Task gestartet."""
    body = json.dumps(MESSENGER_PAYLOAD).encode()
    sig = make_sig(body, app_secret)

    with respx.mock:
        respx.post("http://127.0.0.1:18789/hooks/meta").mock(
            return_value=httpx.Response(200, json={"text": "Antwort von Ava"})
        )
        respx.post("https://graph.facebook.com/v19.0/me/messages").mock(
            return_value=httpx.Response(200, json={"message_id": "m_reply_1"})
        )

        resp = await bridge_client.post(
            "/webhook",
            content=body,
            headers={
                "X-Hub-Signature-256": sig,
                "Content-Type": "application/json",
            },
        )

    assert resp.status_code == 200
    assert resp.json() == {"ok": True}


@pytest.mark.asyncio
async def test_webhook_post_instagram_event(bridge_client, app_secret):
    """Gültiger Instagram-Event → 200."""
    body = json.dumps(INSTAGRAM_PAYLOAD).encode()
    sig = make_sig(body, app_secret)

    with respx.mock:
        respx.post("http://127.0.0.1:18789/hooks/meta").mock(
            return_value=httpx.Response(200, json={"text": "IG-Antwort"})
        )
        respx.post("https://graph.facebook.com/v19.0/me/messages").mock(
            return_value=httpx.Response(200, json={"message_id": "m_ig_reply"})
        )

        resp = await bridge_client.post(
            "/webhook",
            content=body,
            headers={
                "X-Hub-Signature-256": sig,
                "Content-Type": "application/json",
            },
        )

    assert resp.status_code == 200


@pytest.mark.asyncio
async def test_webhook_post_echo_ignored(bridge_client, app_secret):
    """Echo-Nachrichten werden ignoriert — kein OpenClaw-Call."""
    body = json.dumps(ECHO_PAYLOAD).encode()
    sig = make_sig(body, app_secret)

    with respx.mock:
        # Kein Mock für OpenClaw — wenn ein Call käme, würde respx einen Fehler werfen
        resp = await bridge_client.post(
            "/webhook",
            content=body,
            headers={
                "X-Hub-Signature-256": sig,
                "Content-Type": "application/json",
            },
        )

    assert resp.status_code == 200


@pytest.mark.asyncio
async def test_webhook_post_empty_payload(bridge_client, app_secret):
    """Payload ohne Events → 200 (nichts zu verarbeiten)."""
    payload = {"object": "page", "entry": []}
    body = json.dumps(payload).encode()
    sig = make_sig(body, app_secret)

    with respx.mock:
        resp = await bridge_client.post(
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
async def test_reply_ok(bridge_client):
    with respx.mock:
        respx.post("https://graph.facebook.com/v19.0/me/messages").mock(
            return_value=httpx.Response(200, json={"message_id": "m_out_1"})
        )
        resp = await bridge_client.post(
            "/reply",
            json={"psid": "psid_test_123", "text": "Hallo!", "platform": "messenger"},
        )

    assert resp.status_code == 200
    assert resp.json()["ok"] is True


@pytest.mark.asyncio
async def test_reply_missing_psid(bridge_client):
    resp = await bridge_client.post(
        "/reply",
        json={"text": "Hallo!", "platform": "messenger"},
    )
    assert resp.status_code == 422


@pytest.mark.asyncio
async def test_reply_missing_text(bridge_client):
    resp = await bridge_client.post(
        "/reply",
        json={"psid": "psid_test_123", "platform": "messenger"},
    )
    assert resp.status_code == 422


@pytest.mark.asyncio
async def test_reply_empty_psid(bridge_client):
    resp = await bridge_client.post(
        "/reply",
        json={"psid": "  ", "text": "Test", "platform": "messenger"},
    )
    assert resp.status_code == 422


@pytest.mark.asyncio
async def test_reply_empty_text(bridge_client):
    resp = await bridge_client.post(
        "/reply",
        json={"psid": "psid_123", "text": "", "platform": "messenger"},
    )
    assert resp.status_code == 422


@pytest.mark.asyncio
async def test_reply_invalid_platform(bridge_client):
    resp = await bridge_client.post(
        "/reply",
        json={"psid": "psid_123", "text": "Test", "platform": "tiktok"},
    )
    assert resp.status_code == 422


@pytest.mark.asyncio
async def test_reply_test_platform(bridge_client):
    """'test' Platform ist erlaubt."""
    with respx.mock:
        respx.post("https://graph.facebook.com/v19.0/me/messages").mock(
            return_value=httpx.Response(200, json={"message_id": "m_test"})
        )
        resp = await bridge_client.post(
            "/reply",
            json={"psid": "psid_test", "text": "Test message", "platform": "test"},
        )
    assert resp.status_code == 200


# ─── GET /admin/errors ────────────────────────────────────────────────────────

@pytest.mark.asyncio
async def test_admin_errors_no_db(bridge_client):
    """Ohne DB-Verbindung → 503."""
    resp = await bridge_client.get("/admin/errors")
    assert resp.status_code == 503


# ─── _extract_events — Unit Tests via Payload-Verarbeitung ───────────────────

def test_extract_events_messenger(bridge_mod):
    events = bridge_mod._extract_events(MESSENGER_PAYLOAD)
    assert len(events) == 1
    ev = events[0]
    assert ev["psid"] == "psid_111"
    assert ev["message_id"] == "mid_abc123"
    assert ev["text"] == "Hallo Ava"
    assert ev["platform"] == "messenger"


def test_extract_events_instagram(bridge_mod):
    events = bridge_mod._extract_events(INSTAGRAM_PAYLOAD)
    assert len(events) == 1
    ev = events[0]
    assert ev["psid"] == "ig_psid_333"
    assert ev["message_id"] == "mid_ig_xyz"
    assert ev["platform"] == "instagram"


def test_extract_events_echo_ignored(bridge_mod):
    events = bridge_mod._extract_events(ECHO_PAYLOAD)
    assert len(events) == 0


def test_extract_events_empty_entry(bridge_mod):
    payload = {"object": "page", "entry": []}
    events = bridge_mod._extract_events(payload)
    assert events == []


def test_extract_events_missing_mid_ignored(bridge_mod):
    """Events ohne message_id werden ignoriert."""
    payload = {
        "object": "page",
        "entry": [{
            "messaging": [{
                "sender": {"id": "psid_x"},
                "message": {"text": "kein mid"}  # kein "mid"
            }]
        }]
    }
    events = bridge_mod._extract_events(payload)
    assert len(events) == 0


# ─── _verify_signature — Unit Tests ──────────────────────────────────────────

def test_verify_signature_valid(bridge_mod, app_secret):
    body = b'{"test": "payload"}'
    import hashlib
    import hmac as hmac_mod
    sig = "sha256=" + hmac_mod.new(app_secret.encode(), body, hashlib.sha256).hexdigest()
    assert bridge_mod._verify_signature(body, sig) is True


def test_verify_signature_wrong_secret(bridge_mod):
    body = b'{"test": "payload"}'
    import hashlib
    import hmac as hmac_mod
    sig = "sha256=" + hmac_mod.new(b"wrong_secret", body, hashlib.sha256).hexdigest()
    assert bridge_mod._verify_signature(body, sig) is False


def test_verify_signature_none_header(bridge_mod):
    assert bridge_mod._verify_signature(b"body", None) is False


def test_verify_signature_wrong_prefix(bridge_mod):
    assert bridge_mod._verify_signature(b"body", "md5=abc123") is False


def test_verify_signature_empty_header(bridge_mod):
    assert bridge_mod._verify_signature(b"body", "") is False
