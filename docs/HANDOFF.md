# HANDOFF — AgentsFinal / Session 2026-03-18

## Aktueller Stand (LIVE)

**Branch:** `refactor/openclaw-conform` — letzter Commit `bd8f204`
**Repo:** `git@github.com:dsactivi-2/AgentsFinal.git`
**Server:** `178.104.64.120` (Hetzner) | Tailscale: `marki` (`100.88.196.1`)
**Dashboard:** `https://marki.ds.activi.io/#token=4b2a2952dd46ab0c1bb4ada6568d655c7197f881eefa5f18`
**Tailscale Dashboard:** `https://marki.tail47b17c.ts.net/#token=4b2a2952dd46ab0c1bb4ada6568d655c7197f881eefa5f18`

---

## Was vollständig erledigt ist ✅

### Server-Deployment
| Was | Status |
|---|---|
| Ubuntu 24.04, 4 vCPU, 7.6 GB RAM, 150 GB Disk | ✅ |
| Node.js v22, PostgreSQL 16, Redis 7 | ✅ installiert |
| OpenClaw 2026.3.13 als systemd-Service | ✅ läuft & Autostart |
| Caddy Reverse Proxy mit SSL (Let's Encrypt) | ✅ `marki.ds.activi.io` |
| Tailscale verbunden (`marki`, `dsphone`, `mac-ds`) | ✅ |
| DB Schema angewendet (`social_ai`) | ✅ alle Tabellen inkl. leads, lead_followups, error_logs |
| Repo geklont nach `/root/social-ai` | ✅ |

### OpenClaw Gateway
| Was | Status |
|---|---|
| Gateway bind: `loopback` (127.0.0.1:18789) | ✅ |
| Gateway mode: `local`, reload: `hybrid` | ✅ |
| `trustedProxies: ["127.0.0.1"]` | ✅ |
| `allowedOrigins`: nur 2 HTTPS-Domains | ✅ |
| Pairing: 2 Geräte genehmigt | ✅ |
| Caddy proxyt `https://marki.ds.activi.io` → `127.0.0.1:18789` | ✅ |
| Caddy proxyt `https://marki.tail47b17c.ts.net` → `127.0.0.1:18789` | ✅ |
| Caddy v2.11.2 (von 2.6.2 upgegraded) | ✅ |
| Caddy: `flush_interval -1`, `stream_timeout 24h`, `stream_close_delay 5m` | ✅ |
| Tailscale-Cert auto-renewal: systemd timer (Tag 10+20/Monat, 03:00 UTC) | ✅ |
| Systemd Linger root: `Linger=yes` | ✅ |
| Primär-Modell: `ollama/minimax-m2.5` (per-Skill-Routing) | ✅ |
| Fallback 1: `ollama/kimi-k2.5` | ✅ |
| Fallback 2: `ollama/qwen3.5:397b` | ✅ |
| Fallback 3: `ollama/qwen3.5:397b` | ✅ |
| Ollama Cloud API Key in systemd drop-in | ✅ |
| Auth-Token konfiguriert | ✅ |

### Agent (Ava) — Skills
| Skill | Status |
|---|---|
| planner | ✅ |
| writer | ✅ |
| reviewer | ✅ |
| publisher | ✅ |
| analytics | ✅ |
| optimizer | ✅ |
| inbox | ✅ |
| memory-critic | ✅ |
| escalation | ✅ |
| reflexion | ✅ |
| lead-nurturing | ✅ |
| ~~ads-manager~~ | ❌ bewusst entfernt (User will keine Ads) |

### Wichtige Commits (neueste zuerst)
| Commit | Was |
|---|---|
| `bd8f204` | Gateway hardening + Caddy v2.11.2 + cert auto-renewal docs |
| `c8a5eb7` | Self-Learning + Error Logging + Self-Healing |
| `e9857d1` | Ads Manager entfernt, IDENTITY + SOUL bereinigt |
| `8931e84` | bootstrap.sh fix: workspace-social-ai + PID-Files |
| `281a345` | Lead Nurturing Skill + 3 Crons + DB-Schema |

---

## Was noch NICHT fertig ist ⚠️

### Priorität 1 — Blockiert den echten Betrieb

**A) Meta-Tokens in `.env` eintragen**
```
/root/social-ai/services/meta-bridge/.env
```
Noch fehlende Werte:
- `META_APP_SECRET` → developers.facebook.com → App → Einstellungen → App-Geheimnis
- `META_VERIFY_TOKEN` → selbst wählen (beliebiger String, z.B. `ava-webhook-2026`)
- `META_PAGE_ACCESS_TOKEN` → Messenger → API-Einstellungen → Token generieren
- `ADMIN_PSID` → eigene Facebook PSID (erhält man wenn man dem Bot schreibt)

**B) meta-bridge Service starten**
```bash
ssh marki
cd /root/social-ai
bash scripts/start-meta-bridge.sh
```
Läuft auf Port `8085`, hört auf Webhook-Calls von Meta.

**C) Supermemory API Key**
```
/root/social-ai/services/mem0-api/.env
SUPERMEMORY_API_KEY=sm_...
```
Danach:
```bash
bash scripts/start-mem0-api.sh
```

**D) Facebook Webhook konfigurieren**
- URL: `https://marki.ds.activi.io/hooks/meta`
- Verify Token: (was du in META_VERIFY_TOKEN eingetragen hast)
- Feld abonnieren: `messages`, `messaging_postbacks`
- Konfigurieren unter: developers.facebook.com → App → Webhooks

### Priorität 2 — Verbesserungen

**E) Cron-Jobs im Gateway registrieren**
Die 7 Crons (planner, analytics, memory-critic, reflexion, lead-nurturing x3) wurden aus der Config entfernt weil das Format geändert hat. Müssen via Dashboard oder API neu eingerichtet werden:
- Dashboard → Agent → Scheduled Jobs

**F) Branch mergen**
```bash
# auf Server oder lokal
cd /root/social-ai
git checkout main
git merge refactor/openclaw-conform
git push origin main
```

**G) ADMIN_PSID herausfinden**
1. meta-bridge starten
2. Selbst eine Nachricht an die Facebook Page schreiben
3. Im meta-bridge Log die PSID ablesen
4. In `.env` als `ADMIN_PSID` eintragen
5. meta-bridge neu starten

---

## Architektur-Übersicht

```
Internet
  │
  ▼
marki.ds.activi.io:443  (Caddy v2.11.2, Let's Encrypt)
marki.tail47b17c.ts.net:443  (Caddy, Tailscale-Cert, auto-renewal Tag 10+20)
  │
  ▼ reverse_proxy (flush_interval -1, stream_timeout 24h, stream_close_delay 5m)
  │
  ▼
127.0.0.1:18789 — OpenClaw Gateway (loopback, hybrid-reload, trustedProxies)
  │
  ├─► Agent "Ava" (per-Skill-Routing: kimi/gemini/minimax/deepseek/nemotron)
  │     └─► ~/.openclaw/workspace-social-ai/ (11 Skills)
  │
  └─► /hooks/meta → :8085 meta-bridge  ⚠️ NOCH NICHT GESTARTET
        └─► Facebook/Instagram Webhook

Datenbank-Layer (localhost only):
  - Redis :6379 — Session-State
  - PostgreSQL :5432 — Logs, Leads, Audit (inkl. error_logs)

Memory:
  - memory-core (Workspace Markdown-Files)
  - Supermemory (wenn API Key gesetzt)  ⚠️ KEY FEHLT NOCH
```

---

## Credentials & Zugänge

| Was | Wert |
|---|---|
| **Server SSH** | `ssh marki` (Alias) oder `ssh root@178.104.64.120` |
| **Dashboard** | `https://marki.ds.activi.io/#token=4b2a2952dd46ab0c1bb4ada6568d655c7197f881eefa5f18` |
| **Gateway Token** | `4b2a2952dd46ab0c1bb4ada6568d655c7197f881eefa5f18` |
| **Ollama Cloud Key** | in `/root/social-ai/config/.env` + systemd drop-in |
| **Ollama Base URL** | `https://ollama.com/api` |
| **GitHub Repo** | `git@github.com:dsactivi-2/AgentsFinal.git` |

---

## Wichtige Befehle auf dem Server

```bash
# Gateway Status
systemctl --user status openclaw-gateway

# Gateway neu starten
systemctl --user restart openclaw-gateway

# Gateway Logs live
journalctl --user -u openclaw-gateway -f

# Agent Logs
tail -f /tmp/openclaw/openclaw-2026-03-17.log

# Caddy Status
systemctl status caddy

# Dashboard URL
openclaw dashboard --no-open

# meta-bridge starten
cd /root/social-ai && bash scripts/start-meta-bridge.sh

# mem0-api starten
cd /root/social-ai && bash scripts/start-mem0-api.sh
```

---

## Was in dieser Session (2026-03-18) erledigt wurde

| Was | Details |
|---|---|
| Gateway crash-loop behoben | `loginctl enable-linger root` → user@0.service permanent |
| Tailscale HTTPS-Cert | `tailscale cert` → `/etc/caddy/`, Caddy konfiguriert |
| Gateway: origin not allowed | `~/.openclaw/openclaw.json` → allowedOrigins ergänzt |
| Gateway: pairing required | `openclaw devices approve` → 2 Geräte genehmigt |
| Gateway auf optimal konfiguriert | bind=loopback, hybrid reload, trustedProxies |
| Caddy upgrade 2.6.2 → 2.11.2 | via offiziellem cloudsmith Repo |
| Caddy WebSocket-Optionen | flush_interval -1, stream_timeout 24h, stream_close_delay 5m |
| Tailscale cert auto-renewal | systemd timer (Tag 10+20/Monat) + Expiry-Check (nur wenn <30 Tage) |
| Self-Learning: ROLE:reflexion | config/skills/reflexion.md + Cron So 04:00 |
| Error Logging: error_logs | DB-Tabelle + meta-bridge _log_error_to_db() + /admin/errors |
| Self-Healing: Retry + Watchdog | tenacity in mem0-api, Retry in meta-bridge, watchdog.sh |
| Repo: strukturelle Änderungen | config/openclaw.json, HANDOFF.md, RUNBOOK.md aktualisiert |

---

## Offene Entscheidungen / Nächste Session

### Priorität 1 — Blockiert echten Betrieb

| # | Was | Wo | Aktion |
|---|---|---|---|
| A | Meta App Secret | developers.facebook.com → App → Einstellungen | Wert in `/root/social-ai/services/meta-bridge/.env` |
| B | Meta Verify Token | Selbst wählen (beliebiger String) | Wert in `.env` als `META_VERIFY_TOKEN` |
| C | Meta Page Access Token | Messenger → API-Einstellungen → Token | Wert in `.env` als `META_PAGE_ACCESS_TOKEN` |
| D | meta-bridge starten | Nach .env befüllt | `cd /root/social-ai && bash scripts/start-meta-bridge.sh` |
| E | Facebook Webhook | developers.facebook.com → Webhooks | URL: `https://marki.ds.activi.io/hooks/meta` |
| F | Supermemory API Key | supermemory.ai Dashboard | In `/root/social-ai/services/mem0-api/.env` als `SUPERMEMORY_API_KEY` |
| G | mem0-api starten | Nach .env befüllt | `bash scripts/start-mem0-api.sh` |

### Priorität 2 — Verbesserungen

| # | Was | Aktion |
|---|---|---|
| H | Cron-Jobs im Gateway | Dashboard → Agent → Scheduled Jobs (7 Jobs: planner, analytics, memory-critic, reflexion, lead-nurturing x3) |
| I | Branch mergen | `git checkout main && git merge refactor/openclaw-conform && git push origin main` |
| J | ADMIN_PSID | meta-bridge starten → Nachricht an Page schreiben → PSID aus Log lesen → in .env eintragen |
| K | Memory-Entscheidung | Offene Frage: Supermemory.ai behalten oder gegen mem0 tauschen? (Recherche noch offen) |
