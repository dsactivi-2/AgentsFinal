# HANDOFF — AgentsFinal / Session 2026-03-17

## Aktueller Stand (LIVE)

**Branch:** `refactor/openclaw-conform` — 13 Commits auf GitHub
**Repo:** `git@github.com:dsactivi-2/AgentsFinal.git`
**Server:** `178.104.64.120` (Hetzner) | Tailscale: `marki` (`100.88.196.1`)
**Dashboard:** `https://marki.ds.activi.io/#token=4b2a2952dd46ab0c1bb4ada6568d655c7197f881eefa5f18`

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
| Gateway läuft auf Tailscale-IP `100.88.196.1:18789` | ✅ |
| Caddy proxyt `https://marki.ds.activi.io` → Gateway | ✅ |
| Primär-Modell: `ollama/glm-5:cloud` | ✅ |
| Fallback 1: `ollama/minimax-m2.5:cloud` | ✅ |
| Fallback 2: `ollama/kimi-k2.5:cloud` | ✅ |
| Fallback 3: `ollama/leckminartor/qwen3.5-uncensored:397b-cloud` | ✅ |
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
| `e9857d1` | Ads Manager entfernt, IDENTITY + SOUL bereinigt |
| `b8b2766` | Ads Manager Skill (entfernt in nächstem Commit) |
| `8931e84` | bootstrap.sh fix: workspace-social-ai + PID-Files |
| `281a345` | Lead Nurturing Skill + 3 Crons + DB-Schema |
| `7f89baa` | Reflexion Skill + Cron So 04:00 |

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
marki.ds.activi.io:443 (Caddy + SSL)
  │
  ├─► :18789 OpenClaw Gateway (Tailscale)
  │     └─► Agent "Ava" (glm-5:cloud)
  │           └─► ~/.openclaw/workspace-social-ai/ (11 Skills)
  │
  └─► /hooks/meta → :8085 meta-bridge
        └─► Facebook/Instagram Webhook
              └─► OpenClaw Hook → Agent

Datenbank-Layer (localhost only):
  - Redis :6379 — Session-State
  - PostgreSQL :5432 — Logs, Leads, Audit

Memory:
  - memory-core (Workspace Markdown-Files)
  - Supermemory (wenn API Key gesetzt)
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

## Offene Entscheidungen

1. **Meta-Tokens** — User muss diese selbst aus dem Facebook Developer Portal holen
2. **Supermemory Key** — User muss diesen aus supermemory.ai Dashboard holen
3. **Cron-Jobs** — via Dashboard neu einrichten (7 Jobs: planner, analytics, memory-critic, reflexion, lead-nurturing x3)
4. **Branch mergen** — `refactor/openclaw-conform` → `main` (PR oder direkt)
