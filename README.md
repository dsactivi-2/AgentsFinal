# AgentsFinal

Dokumentations- und Scaffold-Repo für einen hybriden Stack aus:

- OpenClaw (nativ)
- Postiz (Docker Compose)
- mem0 (nativ)
- PostgreSQL (Primary DB — Messages, Logging, Deduplizierung, Dedup)
- Meta Bridge
- Caddy

## Inhalt

- `docs/` – Architektur-, Betriebs-, Memory- und Agentenleitdokumente
- `deploy/postiz/` – Compose- und Env-Beispiele
- `deploy/caddy/` – Caddyfile-Vorlage
- `deploy/systemd/` – Beispiel-Units für native Dienste
- `services/` – Beispielcode für Meta Bridge und mem0 API
- `scripts/` – Hilfsskripte für Bootstrap, Healthchecks und Backups

## Hinweis

Dieses Repo ist ein **technischer Scaffold**, kein vollständig produktionsfertiges Setup.
Vor produktiver Nutzung müssen Domains, Tokens, Secrets, OAuth-Parameter und Systempfade angepasst werden.
