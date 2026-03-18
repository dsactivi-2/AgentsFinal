# TOOLS.md — Ava Stack Endpoints & Konfiguration

## Memory — Supermemory via mem0-api (Port 8010)

**Backend:** Supermemory.ai | **Container-Tag:** `social-ai-stack`

### Memory speichern
```bash
curl -s -X POST http://127.0.0.1:8010/memory/add \
  -H "Content-Type: application/json" \
  -d '{"user_id": "USER_ID", "content": "INHALT", "metadata": {"skill": "SKILL_NAME"}}'
```

### Memory suchen
```bash
curl -s -X POST http://127.0.0.1:8010/memory/search \
  -H "Content-Type: application/json" \
  -d '{"user_id": "USER_ID", "query": "SUCHANFRAGE", "limit": 10}'
```

### Alle Memories eines Nutzers
```bash
curl -s http://127.0.0.1:8010/memory/USER_ID
```

### Memory löschen
```bash
curl -s -X DELETE http://127.0.0.1:8010/memory/DOCUMENT_ID
```

### Health-Check
```bash
curl -s http://127.0.0.1:8010/health
```

**Regeln:**
- `user_id` = Facebook PSID des Nutzers (z.B. `1234567890`)
- Für globale Marken-Learnings: `user_id = "global"`
- JSON-Antwort enthält `{"ok": true, "results": [...]}`

---

## Interne Services

| Service | URL | Zweck |
|---------|-----|-------|
| mem0-api | http://127.0.0.1:8010 | Langzeit-Memory (Supermemory) |
| Meta Bridge | http://127.0.0.1:8085 | Facebook/Instagram Nachrichten |
| OpenClaw Hook | http://127.0.0.1:18789/hooks/meta | Eingehende Webhooks |
| Postiz | http://127.0.0.1:4200 | Social Media Scheduling |

---

## Postiz — Social Media Scheduling

API-Key und URL für Postiz-Verbindung (falls benötigt):
- URL: https://marki.ac.activi.io
- API via Postiz-Dashboard konfiguriert

---

## Plattformen

- **Facebook Page:** marki.ac (Bosnian/German community)
- **Instagram:** marki.ac
- **Zielregion:** DACH + Balkan (DE/BA/RS)
