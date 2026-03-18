# Install Placeholders — Alle Werte die bei Installation ersetzt werden müssen

Alle Werte mit `replace_me`, `your_*`, `REPLACE_*` müssen vor dem ersten Start befüllt werden.
Werte ohne Quelle werden selbst generiert (z.B. via `openssl rand -hex 32`).

---

## PFLICHT — Ohne diese startet nichts

### 1. `services/meta-bridge/.env`

| Variable | Wert holen unter | Beispiel |
|----------|-----------------|---------|
| `META_APP_SECRET` | developers.facebook.com → App → Settings → Basic → App Secret | `abc123def456...` |
| `META_VERIFY_TOKEN` | Selbst wählen (beliebiger String) | `ava-webhook-2026` |
| `META_PAGE_ACCESS_TOKEN` | developers.facebook.com → App → Messenger → Settings → Access Tokens → Generate | `EAABwzLixnjY...` |

### 2. `config/.env`

| Variable | Wert holen unter | Beispiel |
|----------|-----------------|---------|
| `OLLAMA_CLOUD_API_KEY` | ollama.com/cloud → Account → API Keys | `oc_live_abc123...` |
| `SUPERMEMORY_API_KEY` | supermemory.ai → Dashboard → API Keys | `sm_abc123def456...` |

### 3. `deploy/postiz/.env`

| Variable | Wert holen unter | Beispiel |
|----------|-----------------|---------|
| `JWT_SECRET` | Selbst generieren: `openssl rand -hex 32` | `a1b2c3d4e5f6...` (64 Zeichen) |
| `POSTGRES_PASSWORD` | Selbst wählen (sicheres Passwort) | `MySecurePass123!` |
| `DATABASE_URL` | Gleiche Passwort wie oben einsetzen | `postgresql://postiz:MySecurePass123!@postgres:5432/postiz` |
| `MAIN_URL` | Deine Postiz-Domain | `https://postiz.deinedomain.com` |
| `FRONTEND_URL` | Gleiche Domain | `https://postiz.deinedomain.com` |
| `FACEBOOK_APP_ID` | developers.facebook.com → App → Settings → Basic → App ID | `1234567890123` |
| `FACEBOOK_APP_SECRET` | developers.facebook.com → App → Settings → Basic → App Secret | `abc123def456...` |

### 4. `config/openclaw.json`

| Feld | Wert | Beispiel |
|------|------|---------|
| `gateway.auth.token` | Selbst generieren: `openssl rand -hex 32` | `a1b2c3d4e5f6...` |
| `gateway.controlUi.allowedOrigins[0]` | Deine OpenClaw-Domain | `https://marki.deinedomain.com` |
| `gateway.controlUi.allowedOrigins[1]` | Tailscale-Domain (optional) | `https://marki.tail47b17c.ts.net` |

### 5. `deploy/caddy/Caddyfile.example`

| Placeholder | Ersetzen mit |
|-------------|-------------|
| `postiz.example.com` | Deine Postiz-Domain, z.B. `postiz.deinedomain.com` |
| `meta.example.com` | Deine Meta-Bridge-Domain, z.B. `meta.deinedomain.com` |

---

## OPTIONAL — Nur bei Bedarf

### `services/meta-bridge/.env`

| Variable | Wann nötig | Wert holen unter |
|----------|-----------|-----------------|
| `ADMIN_PSID` | Nach erstem Login — PSID aus Meta-Bridge-Log ablesen | `tail -f /tmp/meta-bridge.log \| grep psid` |
| `AD_ACCOUNT_ID` | Nur für Ads Manager Skill | developers.facebook.com → Ad Accounts → `act_XXXXXXXXX` |
| `OLLAMA_CLOUD_API_KEY` | Nur wenn Vision (Bildanalyse) aktiv | ollama.com/cloud |

### `config/.env`

| Variable | Wann nötig | Wert holen unter |
|----------|-----------|-----------------|
| `ANTHROPIC_API_KEY` | Nur wenn Anthropic als Fallback-LLM | console.anthropic.com → API Keys |

### `services/mem0-api/.env` (nur Variant A Self-Hosted)

| Variable | Wann nötig |
|----------|-----------|
| `NEO4J_PASSWORD` | Nur wenn Self-Hosted Memory (Variant A) gewählt |

---

## Schnell-Generierung aller Secrets

```bash
# JWT Secret für Postiz
echo "JWT_SECRET=$(openssl rand -hex 32)"

# OpenClaw Gateway Token
echo "OPENCLAW_TOKEN=$(openssl rand -hex 32)"

# Postiz Postgres Passwort
echo "POSTGRES_PASSWORD=$(openssl rand -base64 24 | tr -d /=+)"
```

---

## Reihenfolge beim Befüllen

1. Facebook App anlegen → `META_APP_SECRET`, `META_APP_ID`, `META_PAGE_ACCESS_TOKEN`
2. Ollama Cloud Account → `OLLAMA_CLOUD_API_KEY`
3. Supermemory Account → `SUPERMEMORY_API_KEY`
4. Secrets generieren → `JWT_SECRET`, `OPENCLAW_TOKEN`, `POSTGRES_PASSWORD`
5. Domains festlegen → alle `*.example.com` Platzhalter
6. `bootstrap.sh` ausführen
7. `ADMIN_PSID` nach erstem Test-Login nachträglich eintragen
