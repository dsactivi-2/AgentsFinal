# Marki-Stack — Vollständiges Benutzerhandbuch
**Version:** 1.0 | **Stand:** 2026-03-18 | **Server:** hetzner4 (91.98.26.220)

---

## Inhaltsverzeichnis

1. [Systemübersicht](#1-systemübersicht)
2. [Alle URLs & Zugänge](#2-alle-urls--zugänge)
3. [Postiz — Social Media Scheduler](#3-postiz--social-media-scheduler)
4. [OpenClaw Dashboard — KI-Agent Ava](#4-openclaw-dashboard--ki-agent-ava)
5. [Meta-Bridge — Facebook/Instagram Webhook](#5-meta-bridge--facebookinstagram-webhook)
6. [mem0-api — Langzeit-Memory](#6-mem0-api--langzeit-memory)
7. [Ava's Skills im Detail](#7-avas-skills-im-detail)
8. [Geplante Jobs (Crons)](#8-geplante-jobs-crons)
9. [API Keys die noch fehlen](#9-api-keys-die-noch-fehlen)
10. [Server-Administration](#10-server-administration)
11. [Troubleshooting](#11-troubleshooting)

---

## 1. Systemübersicht

Der Marki-Stack ist ein vollautomatisches Social-Media-System bestehend aus:

```
┌─────────────────────────────────────────────────────────────┐
│                    hetzner4 (91.98.26.220)                   │
│                                                             │
│  ┌──────────┐  ┌─────────────┐  ┌──────────┐  ┌─────────┐  │
│  │  Postiz  │  │  OpenClaw   │  │  meta-   │  │  mem0-  │  │
│  │  :5000   │  │  Gateway    │  │  bridge  │  │   api   │  │
│  │ (Scheduler│  │  :18789     │  │  :8085   │  │  :8010  │  │
│  └──────────┘  └─────────────┘  └──────────┘  └─────────┘  │
│                        │                                     │
│                   [Ava — KI-Agent]                           │
│              Skills: planner, writer,                        │
│              reviewer, publisher, inbox, ...                 │
└─────────────────────────────────────────────────────────────┘
         ↑                              ↑
   Facebook/Instagram              Caddy (SSL)
   Webhooks                        Let's Encrypt
```

**Datenfluss:**
1. Facebook/Instagram schickt Nachrichten → meta-bridge
2. meta-bridge leitet weiter an → OpenClaw (Ava)
3. Ava analysiert, plant, schreibt Content → speichert in mem0-api
4. Genehmigte Pläne → Postiz → automatisches Posting

---

## 2. Alle URLs & Zugänge

### Öffentliche URLs

| URL | Dienst | Zweck |
|-----|--------|-------|
| `https://marki.ac.activi.io` | Postiz | Social Media Scheduler UI |
| `https://meta.marki.ac.activi.io/webhook` | meta-bridge | Facebook/Instagram Webhook |
| `https://oc.marki.ac.activi.io` | OpenClaw Dashboard | KI-Agent Steuerung (öffentlich) |

### Private URLs (Tailscale)

| URL | Dienst | Zweck |
|-----|--------|-------|
| `https://hetzner4-marki.tail47b17c.ts.net` | OpenClaw Dashboard | KI-Agent Steuerung (sicher) |

### Dashboard-Token

```
Token: 5d936f9c51be19d5d6b912092dd7dd2573e3a11f3d2c2d5de028f7c08804585f
```

**Vollständige Dashboard-URLs (direkt mit Token):**
- Öffentlich: `https://oc.marki.ac.activi.io/#token=5d936f9c51be19d5d6b912092dd7dd2573e3a11f3d2c2d5de028f7c08804585f`
- Tailscale: `https://hetzner4-marki.tail47b17c.ts.net/#token=5d936f9c51be19d5d6b912092dd7dd2573e3a11f3d2c2d5de028f7c08804585f`

### Server-Zugang

```bash
SSH (direkt):    ssh root@91.98.26.220
SSH (Alias):     ssh hetzner4
SSH (Tailscale): ssh root@100.84.189.53
```

---

## 3. Postiz — Social Media Scheduler

### Was ist Postiz?

Postiz ist das UI zum Planen und Verwalten von Social-Media-Posts. Ava (KI-Agent) erstellt Content-Pläne und nach deiner Freigabe werden Posts automatisch über Postiz veröffentlicht.

### Erster Start

1. Öffne `https://marki.ac.activi.io`
2. Klicke **"Create Account"** — registriere dich mit deiner E-Mail
3. Bestätige die E-Mail (falls aktiviert)
4. Verbinde deine Social-Media-Accounts

### Social-Media-Accounts verbinden

Nach dem Login:
1. **Settings → Channels** → "Add Channel"
2. Unterstützte Plattformen: **Instagram, Facebook, X (Twitter), LinkedIn, TikTok, YouTube, Pinterest**
3. Für Instagram/Facebook: Meta Business Account nötig

### Content-Kalender

- **Dashboard → Calendar**: Alle geplanten Posts in Kalenderansicht
- **Dashboard → Posts**: Listenansicht aller Posts (geplant, veröffentlicht, Entwürfe)
- Post klicken → bearbeiten, Zeitpunkt ändern, löschen

### Manuell posten

1. Klicke **"+ New Post"**
2. Text eingeben, Medien hochladen
3. Plattform(en) auswählen
4. Datum/Uhrzeit festlegen
5. **"Schedule"** klicken

### Automatische Posts von Ava

- Ava erstellt wöchentliche Content-Pläne
- Du erhältst eine Freigabe-Anfrage via Facebook Messenger
- Nach `✅ plan genehmigt` postet Ava automatisch über Postiz
- Alle Posts erscheinen im Kalender

---

## 4. OpenClaw Dashboard — KI-Agent Ava

### Zugang

Öffne einen der Dashboard-Links mit Token (Abschnitt 2). Beim ersten Aufruf erscheint "pairing required" — das wird automatisch genehmigt (oder manuell via SSH: `openclaw devices approve <id>`).

### Hauptbereiche des Dashboards

#### Chat (linke Sidebar → Chat)
- **Direkter Chat mit Ava**
- Schreibe Befehle wie: `"Was posten wir diese Woche?"`, `"Erstelle einen Plan für Ramadan"`
- Ava antwortet und führt Aktionen aus
- Modell: `minimax-m2.5:cloud` (Standard)

#### Übersicht (Dashboard)
- Zeigt aktive Sessions, letzte Nachrichten, Systemstatus

#### Agents
- Agent **"main"** = Ava
- Workspace: `~/.openclaw/workspace-social-ai`
- Modell wechseln: Dropdown oben im Chat

#### Einstellungen → Konfiguration
- Gateway-Einstellungen (Port, Auth-Modus)
- Modell-Konfiguration

#### Einstellungen → Communications
- **Kanäle verbinden**: Facebook Messenger, Telegram, Discord, WhatsApp
- Nach Verbindung: Nachrichten an deine Page → Ava antwortet

#### Geplante Aufgaben (Cron-Jobs)
- **Dashboard → Geplante Aufgaben**
- Zeigt alle automatischen Jobs (Planner, Heartbeat, etc.)
- Jobs aktivieren/deaktivieren

### Ava per Messenger steuern

Sobald Meta-Credentials eingetragen sind (Abschnitt 9), kannst du Ava direkt per Facebook Messenger steuern:

| Befehl | Aktion |
|--------|--------|
| `plan genehmigt` | Wochplan wird aktiviert, Posting beginnt |
| `ändern: [feedback]` | Plan wird angepasst |
| `plan ablehnen` | Kein Posting diese Woche |
| `/new` | Neue Session starten |
| `/reset` | Session zurücksetzen |

---

## 5. Meta-Bridge — Facebook/Instagram Webhook

### Was ist meta-bridge?

meta-bridge ist der Empfänger für Nachrichten von Facebook/Instagram. Wenn jemand deiner Facebook-Page schreibt, wird die Nachricht hier empfangen und an Ava weitergeleitet.

### Webhook bei Meta registrieren

1. Gehe zu `developers.facebook.com` → deine App → **Messenger → Settings**
2. **Webhooks → Add Callback URL:**
   ```
   https://meta.marki.ac.activi.io/webhook
   ```
3. **Verify Token:** (dein gewählter Wert aus `.env` → `META_VERIFY_TOKEN`)
4. Abonniere: `messages`, `messaging_postbacks`, `message_deliveries`

### Bilder

- Empfangene Bilder werden automatisch gespeichert unter:
  ```
  /root/social-ai/data/images/YYYYMMDD/uuid.jpg
  ```
- Ava beschreibt Bilder via Vision-Modell (`qwen3.5:cloud`)

### Health Check

```
https://meta.marki.ac.activi.io/health
→ {"ok": true, "service": "meta-bridge", "version": "2.3.0", "postgres": true}
```

### Reply API (intern)

```bash
POST https://meta.marki.ac.activi.io/reply
{
  "psid": "PSID_DES_NUTZERS",
  "text": "Antworttext",
  "image_url": "https://..." (optional)
}
```

---

## 6. mem0-api — Langzeit-Memory

### Was ist mem0-api?

mem0-api ist die Langzeit-Gedächtnis-API für Ava. Hier werden Konversationen, Lead-Infos, Kampagnen-Learnings und andere wichtige Daten gespeichert.

### Backend

Aktuell: **Supermemory.ai Cloud** (Variant B)
- API Key: `SUPERMEMORY_API_KEY` (noch Placeholder — Abschnitt 9)

### Endpunkte

| Methode | Endpunkt | Funktion |
|---------|----------|----------|
| `GET` | `/health` | Status-Check |
| `POST` | `/memory/add` | Memory speichern |
| `POST` | `/memory/search` | Semantisch suchen |
| `GET` | `/memory/{user_id}` | Alle Memories eines Users |
| `DELETE` | `/memory/{doc_id}` | Memory löschen |

### Beispiel: Memory suchen

```bash
curl -X POST http://localhost:8010/memory/search \
  -H "Content-Type: application/json" \
  -d '{"user_id": "psid_123", "query": "Kampagne Ramadan", "limit": 5}'
```

---

## 7. Ava's Skills im Detail

### Planner — Content-Strategie

**Trigger:** Täglich 09:00 Uhr (Cron) oder manuell

**Was er macht:**
1. Analysiert letzte 7 Tage Learnings
2. Prüft aktive Kampagnen
3. Berücksichtigt Feiertage (DE/BA/RS: Ramadan, Eid, Weihnachten, Bairam)
4. Erstellt 1-2 Wochen Content-Plan
5. Schickt Freigabe-Anfrage an Admin (du) per Messenger

**Plan-Format:**
```
📅 CONTENT-PLAN FREIGABE [Datum – Datum]
Mo [Datum]: Instagram Bild — "Hook/Thema"
Di [Datum]: Instagram Reel — "Thema"
...
Antwort: ✅ "plan genehmigt" / ✏️ "ändern: [feedback]" / ❌ "plan ablehnen"
```

**Regeln:**
- 70/30-Regel: 70% organischer Content, 30% Werbung
- Keine zwei identischen Formate in Folge
- A/B-Varianten für wichtige Posts

---

### Writer — Caption-Texte

**Trigger:** Nach Planner-Freigabe automatisch

**Was er macht:**
1. Nimmt Plan vom Planner
2. Schreibt vollständige Captions in Zielsprache (DE/BS/SR)
3. Fügt Hashtags hinzu
4. Gibt an Reviewer weiter

**Output-Format:**
```
Plattform: Instagram
Typ: Bild-Post
Hook: [Erster Satz]
Caption: [vollständiger Text]
Hashtags: #tag1 #tag2 ...
Posting-Zeit: 09:00 Uhr
```

---

### Reviewer — Qualitätskontrolle

**Trigger:** Nach Writer automatisch

**Was er prüft:**
- Tonalität und Markenstimme
- Rechtschreibung/Grammatik
- Compliance (keine problematischen Inhalte)
- Hashtag-Relevanz
- Bei Risiko: Eskalation an Admin

**Ergebnis:** Freigabe → Publisher | Ablehnung → zurück an Writer

---

### Publisher — Posting

**Trigger:** Nach Reviewer-Freigabe, zum geplanten Zeitpunkt

**Was er macht:**
1. Prüft Posting-Zeit
2. Postet via Postiz API
3. Loggt Ergebnis
4. Speichert Posting-Bestätigung in Memory

**Wichtig:** Nur Posts aus genehmigten Plänen werden veröffentlicht.

---

### Inbox — Nachrichten-Verarbeitung

**Trigger:** Jede eingehende Facebook/Instagram-Nachricht

**Was er macht:**
1. Klassifiziert Nachricht (Lead, Frage, Support, Spam)
2. Antwortet automatisch bei einfachen Anfragen
3. Escaliert komplexe Anfragen an Admin
4. Speichert Lead-Infos in Memory
5. Leitet zu Lead-Nurturing bei Interesse

---

### Lead-Nurturing

**Trigger:** Nach Inbox-Klassifizierung als "Lead"

**Was er macht:**
1. Speichert Lead-Daten (Name, Interesse, Kontaktzeit)
2. Sendet Follow-up nach 24h/48h/7 Tagen
3. Trackt Konversions-Status
4. Informiert Admin bei heißen Leads

---

### Analytics

**Trigger:** Wöchentlich (Cron) oder manuell

**Was er macht:**
1. Liest Post-Performance aus Postiz
2. Analysiert Engagement-Raten
3. Identifiziert Top-Posts
4. Gibt Empfehlungen für nächste Woche
5. Speichert Learnings in Memory für Planner

---

### Memory-Critic

**Trigger:** Wöchentlich

**Was er macht:**
1. Prüft gespeicherte Memories auf Relevanz
2. Entfernt veraltete Einträge
3. Verdichtet ähnliche Einträge
4. Verbessert Suchqualität

---

### Escalation

**Trigger:** Bei Reviewer-Risiko oder unklaren Nachrichten

**Was er macht:**
- Sendet Admin-Benachrichtigung per Messenger
- Wartet auf Antwort
- Führt Anweisung aus

---

### Reflexion

**Trigger:** Täglich 23:00 Uhr (Cron)

**Was er macht:**
1. Analysiert heutige Aktionen
2. Identifiziert Fehler und Verbesserungen
3. Aktualisiert eigene Regeln (Self-Learning)
4. Speichert Erkenntnisse in Memory

---

## 8. Geplante Jobs (Crons)

Zu konfigurieren unter: **OpenClaw Dashboard → Geplante Aufgaben**

| Job | Zeitplan | Skill | Beschreibung |
|-----|----------|-------|--------------|
| `daily-plan` | Täglich 09:00 | planner | Tages/Wochen-Plan erstellen |
| `weekly-analytics` | Mo 08:00 | analytics | Wochenauswertung |
| `daily-reflexion` | Täglich 23:00 | reflexion | Selbstreflexion |
| `memory-cleanup` | So 02:00 | memory-critic | Memory bereinigen |
| `heartbeat` | Alle 60 Min | — | System-Heartbeat |
| `lead-followup` | Täglich 10:00 | lead-nurturing | Lead Follow-ups |
| `inbox-check` | Alle 15 Min | inbox | Neue Nachrichten prüfen |

### Crons aktivieren

Im OpenClaw Dashboard → Geplante Aufgaben → Job aktivieren/deaktivieren per Toggle.

Oder via SSH:
```bash
openclaw cron list
openclaw cron enable daily-plan
openclaw cron disable daily-plan
```

---

## 9. API Keys die noch fehlen

**⚠️ Ohne diese Keys funktioniert das System nicht vollständig.**

### Meta-Bridge — Facebook/Instagram

Datei: `/root/social-ai/services/meta-bridge/.env`

```bash
# Zu finden: developers.facebook.com → App → Settings → Basic
META_APP_SECRET=<dein-app-secret>

# Selbst gewählt (gleicher Wert bei Webhook-Registrierung)
META_VERIFY_TOKEN=<dein-verify-token>

# developers.facebook.com → App → Messenger → Access Tokens
META_PAGE_ACCESS_TOKEN=<dein-page-access-token>

# Deine eigene PSID (schreib einmal an deine Page, sieh im Log nach)
ADMIN_PSID=<deine-facebook-psid>

# Ollama Cloud für Bildverarbeitung
OLLAMA_CLOUD_API_KEY=d04d0976eaf042788a60095e970adaf5.6kI9d8IAEgijM3E5DIsh_ibJ
```

### mem0-api — Supermemory

Datei: `/root/social-ai/services/mem0-api/.env`

```bash
# supermemory.ai → Dashboard → API Keys
SUPERMEMORY_API_KEY=<dein-supermemory-api-key>
```

### Nach dem Eintragen — Services neu starten

```bash
ssh hetzner4
systemctl restart meta-bridge mem0-api
```

---

## 10. Server-Administration

### Services Status prüfen

```bash
ssh hetzner4 "systemctl status meta-bridge mem0-api openclaw caddy"
```

Schnell-Check aller Services:
```bash
ssh hetzner4 "
systemctl is-active meta-bridge mem0-api openclaw caddy postiz 2>/dev/null
docker ps --format 'table {{.Names}}\t{{.Status}}' -a | grep postiz
"
```

### Services neu starten

```bash
ssh hetzner4 "systemctl restart meta-bridge"
ssh hetzner4 "systemctl restart mem0-api"
ssh hetzner4 "systemctl restart openclaw"
ssh hetzner4 "systemctl restart caddy"
ssh hetzner4 "cd /root/social-ai/deploy/postiz && docker compose restart"
```

### Logs lesen

```bash
# meta-bridge
ssh hetzner4 "tail -50 /root/social-ai/logs/meta-bridge.log"

# mem0-api
ssh hetzner4 "tail -50 /root/social-ai/logs/mem0-api.log"

# OpenClaw Gateway
ssh hetzner4 "openclaw logs --follow"
# oder:
ssh hetzner4 "tail -50 /root/social-ai/logs/openclaw.log"

# Postiz
ssh hetzner4 "cd /root/social-ai/deploy/postiz && docker compose logs -f postiz"

# Caddy
ssh hetzner4 "journalctl -u caddy -f"
```

### Postiz Container

```bash
# Status
ssh hetzner4 "cd /root/social-ai/deploy/postiz && docker compose ps"

# Starten
ssh hetzner4 "cd /root/social-ai/deploy/postiz && docker compose up -d"

# Stoppen
ssh hetzner4 "cd /root/social-ai/deploy/postiz && docker compose down"

# Update (neues Image)
ssh hetzner4 "cd /root/social-ai/deploy/postiz && docker compose pull && docker compose up -d"
```

### OpenClaw CLI Befehle

```bash
# Gateway-Status
ssh hetzner4 "openclaw health"

# Dashboard-URL anzeigen
ssh hetzner4 "openclaw dashboard --no-open"

# Geräte verwalten
ssh hetzner4 "openclaw devices list"
ssh hetzner4 "openclaw devices approve <request-id>"

# Cron-Jobs
ssh hetzner4 "openclaw cron list"
ssh hetzner4 "openclaw cron run daily-plan"

# Memory durchsuchen
ssh hetzner4 "openclaw memory search 'kampagne'"

# Agent direkt ansprechen
ssh hetzner4 "openclaw agent --message 'Erstelle einen Content-Plan für diese Woche'"
```

### Datenbank (PostgreSQL)

```bash
ssh hetzner4 "psql -U postgres -d social_ai"

# Wichtige Tabellen:
# processed_events  — alle verarbeiteten Events
# messages          — alle Nachrichten mit Media-Paths
# error_logs        — Fehlerprotokoll
```

### Backup

```bash
# Manuelles Backup
ssh hetzner4 "bash /root/social-ai/scripts/backup.sh"

# Postiz Uploads Backup
ssh hetzner4 "bash /root/social-ai/scripts/backup-postiz-uploads.sh"
```

### Firewall

Erlaubte Ports: **22 (SSH), 80 (HTTP), 443 (HTTPS)**
Alle anderen Ports sind gesperrt.

```bash
ssh hetzner4 "ufw status"
```

---

## 11. Troubleshooting

### Dashboard zeigt "pairing required"

```bash
ssh hetzner4 "openclaw devices list"
ssh hetzner4 "openclaw devices approve <request-id>"
```

### Ava antwortet nicht (All models failed)

```bash
# OLLAMA_API_KEY prüfen
ssh hetzner4 "cat /etc/systemd/system/openclaw.service.d/ollama.conf"

# Service neu starten
ssh hetzner4 "systemctl restart openclaw"
```

### meta-bridge: postgres_unavailable

```bash
# PostgreSQL-Status prüfen
ssh hetzner4 "systemctl status postgresql"

# .env prüfen
ssh hetzner4 "grep DB_PASSWORD /root/social-ai/services/meta-bridge/.env"
```

### Postiz nicht erreichbar (502)

```bash
# Container-Status prüfen
ssh hetzner4 "cd /root/social-ai/deploy/postiz && docker compose ps"

# Neu starten
ssh hetzner4 "cd /root/social-ai/deploy/postiz && docker compose up -d"
```

### SSL-Fehler auf meta.marki.ac.activi.io

```bash
# Certifikat prüfen
ssh hetzner4 "openssl x509 -in /etc/caddy/certs/hetzner4-marki.tail47b17c.ts.net.crt -noout -dates"

# Tailscale-Cert erneuern
ssh hetzner4 "tailscale cert hetzner4-marki.tail47b17c.ts.net"
```

### Services nach Server-Reboot

Alle Services sind auf **Autostart** konfiguriert:
- `systemctl enable meta-bridge mem0-api openclaw caddy`
- Docker Compose: `restart: unless-stopped`

Nach Reboot sollte alles automatisch starten. Prüfen mit:
```bash
ssh hetzner4 "systemctl is-active meta-bridge mem0-api openclaw caddy"
```

---

## Schnell-Referenz

```
SERVER:    91.98.26.220 | ssh hetzner4
TAILSCALE: 100.84.189.53

POSTIZ:    https://marki.ac.activi.io
WEBHOOK:   https://meta.marki.ac.activi.io/webhook
DASHBOARD: https://oc.marki.ac.activi.io/#token=5d936f9c...
TAILSCALE: https://hetzner4-marki.tail47b17c.ts.net/#token=5d936f9c...

DASHBOARD TOKEN: 5d936f9c51be19d5d6b912092dd7dd2573e3a11f3d2c2d5de028f7c08804585f

LOGS:      /root/social-ai/logs/
CONFIG:    /root/social-ai/config/openclaw.json
ENV MB:    /root/social-ai/services/meta-bridge/.env
ENV MEM:   /root/social-ai/services/mem0-api/.env
```

---

*Erstellt: 2026-03-18 | Marki-Stack v1.0 | hetzner4*
