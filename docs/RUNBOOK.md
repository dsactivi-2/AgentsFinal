# RUNBOOK.md

## Zweck

Dieses Dokument beschreibt den operativen Betrieb des Stacks.

Es deckt ab:

- Initial-Setup
- Start- und Restart-Reihenfolge
- Konfigurationsänderungen
- Deployments
- Healthchecks
- Incident Response
- Backup und Restore
- Routinebetrieb
- Fehlerbilder und Sofortmaßnahmen
- Sync-/Async-Pfade
- Timeouts und Safe-Fallbacks
- Postiz-MCP als Primärintegration

Der RUNBOOK-Fokus ist **Betrieb**, nicht Architektur. Architekturgrundsätze stehen in `SOUL.md`.

---

## Ziel-Topologie

## Integrationspriorität

Für die Agenten-Anbindung an Postiz gilt im Betrieb:

1. **Postiz MCP zuerst**
2. **Postiz API/CLI als Fallback**

MCP ist der primäre Integrationspfad für agentische Steuerung. CLI und direkte API-Zugriffe bleiben technische Alternativen für Sonderfälle, Recovery oder Skriptbetrieb.

## Host nativ

- Caddy
- OpenClaw
- mem0
- Meta Bridge
- optional zusätzliche lokale Hilfsdienste

## Docker Compose

- Postiz Hauptservice
- Postiz SQL Database
- Postiz Redis
- Postiz Temporal / Worker / zugehörige Stack-Komponenten
- Postiz Storage-Anbindung gemäß gewählter Betriebsform

## Eigene Datenhaltung

- eigener Postgres für Betriebs- und Konversationsdaten
- eigener Redis für Hot State und Queueing

---

## Betriebsprinzipien

1. Änderungen immer klein und nachvollziehbar ausrollen.
2. Vor Änderungen Backups sicherstellen.
3. Öffentliche Endpunkte nur über Caddy freigeben.
4. Interne Dienste standardmäßig nur lokal erreichbar halten.
5. Nach jeder Änderung Healthchecks fahren.
6. Bei Unsicherheit zuerst stoppen, dann prüfen, dann ändern.
7. Für agentische Social-Aktionen zuerst MCP testen und nur bei Bedarf auf CLI/API-Fallback ausweichen.

---

## Verzeichnis-Konventionen

## Host

Empfohlene Struktur:

- `/opt/agentops/`
- `/opt/agentops/apps/`
- `/opt/agentops/config/`
- `/opt/agentops/secrets/`
- `/opt/agentops/logs/`
- `/opt/agentops/backups/`
- `/opt/agentops/bin/`

## Docker Compose

Empfohlene Struktur:

- `/opt/postiz/`
- `/opt/postiz/.env`
- `/opt/postiz/docker-compose.yml`
- `/opt/postiz/data/` falls lokal nötig

---

## Dienste und Verantwortlichkeiten

| Dienst | Aufgabe | Betriebsform |
|---|---|---|
| Caddy | TLS, Reverse Proxy | nativ |
| OpenClaw | Orchestrierung, Agents, Hooks | nativ |
| mem0 | semantisches Langzeit-Memory | nativ |
| Meta Bridge | Webhook-Eingang und Routing | nativ |
| eigener Postgres | Konversations- und Betriebsdaten | nativ |
| eigener Redis | Hot State, Locks, Queueing | nativ |
| Postiz | Social Publishing/Analytics | Docker Compose |
| Postiz-DB/Redis/Worker | interne Postiz-Betriebsdienste | Docker Compose |

---

## Initial-Setup-Reihenfolge

## 1. Host vorbereiten

- Ubuntu 24.04 aktualisieren
- Zeitzone setzen
- Benutzer und Rechte anlegen
- Firewall aktivieren
- Basis-Pakete installieren
- Caddy installieren
- Docker und Compose installieren
- Python/venv installieren
- Node nur dort installieren, wo wirklich nötig

## 2. Eigene Datenhaltung bereitstellen

- eigenen Postgres installieren und absichern
- eigenen Redis installieren und absichern
- Datenbank, Benutzer und Passwörter anlegen

## 3. OpenClaw installieren

- Installer ausführen
- Onboarding fertigstellen
- Gateway als Dienst einrichten
- Bind auf intern/loopback begrenzen

## 4. mem0 installieren

- venv anlegen
- Abhängigkeiten installieren
- Konfiguration mit eigenem Postgres verbinden
- lokalen Dienst einrichten

## 5. Meta Bridge installieren

- venv anlegen
- Env-Dateien pflegen
- lokalen Dienst einrichten
- nur via Caddy veröffentlichen

## 6. Postiz via Docker Compose aufsetzen

- Compose-Dateien und `.env` erstellen
- Domain- und URL-Werte sauber setzen
- Stack starten
- MCP-Endpunkt verifizieren
- OAuth-/Provider-Setup testen

## 7. Caddy konfigurieren

- Postiz-Domain veröffentlichen
- Meta-Webhook veröffentlichen
- TLS prüfen

## 8. Integrationstests fahren

- lokaler Healthcheck aller internen Dienste
- Postiz-Web-Zugriff prüfen
- Webhook-Verifikation testen
- MCP-Verbindung testen
- Publishing-Test
- Memory-Test

---

## Startreihenfolge nach Neustart

## Zuerst

1. eigener Postgres
2. eigener Redis
3. Docker
4. Postiz Compose Stack

## Dann

5. mem0
6. OpenClaw
7. Meta Bridge
8. Caddy

## Warum diese Reihenfolge?

- Datenhaltung zuerst
- danach Dienste mit Datenbank-/Cache-Abhängigkeit
- öffentliche Eintrittspunkte zuletzt

---

## Stoppreihenfolge

## Zuerst stoppen

1. Caddy
2. Meta Bridge
3. OpenClaw
4. mem0
5. Postiz Compose Stack

## Dann

6. Redis
7. Postgres

Damit werden zuerst öffentliche Eingänge geschlossen und erst danach interne Abhängigkeiten beendet.

---

## Healthchecks

## Basis-Checks

### Host

- CPU / RAM / Disk frei
- Zeitsynchronisation aktiv
- Firewall aktiv
- DNS-Auflösung funktioniert

### Dienste nativ

- `systemctl status caddy`
- `systemctl status openclaw`
- `systemctl status mem0`
- `systemctl status meta-bridge`
- `systemctl status redis`
- `systemctl status postgresql`

### Docker Compose

- `docker compose ps`
- `docker compose logs --tail=100`

### HTTP

- lokaler mem0 Healthcheck
- lokaler Meta-Bridge Healthcheck
- Postiz Login-Seite
- Postiz MCP-Endpunkt
- OAuth-Redirects erreichbar

## Funktions-Checks

- Test-Memory schreiben und suchen
- Test-Webhook empfangen
- Test-MCP `integrationList`
- Test-Post schedulen
- Test-Analytics abrufen
- Test-Nachricht bis zur Agentenlogik routen

---

## Konfigurationsänderungen

## Grundregel

Jede Konfigurationsänderung ist eine **produktive Änderung**.

### Vor jeder Änderung

1. betroffene Dienste identifizieren
2. Backup/Snapshot sicherstellen
3. alte Konfiguration sichern
4. Änderung dokumentieren

### Nach jeder Änderung

1. Dienst neu laden oder starten
2. Logs prüfen
3. Healthcheck fahren
4. realen End-to-End-Test machen

---

## Änderungstypen

## Postiz MCP / Integrationspfad

Nach Änderungen an Postiz oder an Agenten-Integrationen:

1. MCP-Verbindung testen
2. `integrationList` oder äquivalente Verbindung prüfen
3. nur bei Bedarf auf CLI/API-Fallback ausweichen

## Caddy-Konfiguration

Nach Änderung:

1. Syntax prüfen: `caddy validate --config /etc/caddy/Caddyfile`
2. Caddy reload: `systemctl reload caddy`
3. HTTPS und Routing testen: `curl -sI https://marki.ds.activi.io/`

### Aktuelles Caddy-Setup (v2.11.2)

```
marki.ds.activi.io {
    reverse_proxy 127.0.0.1:18789 {
        flush_interval -1        # Low-Latency, kein Response-Buffering (WebSocket)
        stream_timeout 24h       # Zombie-WebSocket-Verbindungen automatisch beenden
        stream_close_delay 5m    # Graceful reload: aktive WS 5 min weiterlaufen lassen
    }
}

marki.tail47b17c.ts.net {
    tls /etc/caddy/marki.tail47b17c.ts.net.crt /etc/caddy/marki.tail47b17c.ts.net.key
    reverse_proxy 127.0.0.1:18789 {
        flush_interval -1
        stream_timeout 24h
        stream_close_delay 5m
    }
}
```

### Tailscale-Cert Auto-Renewal

Cert läuft nach 90 Tagen ab. Automatische Erneuerung via systemd-Timer:
- Läuft am 10. und 20. jeden Monats um 03:00 UTC
- Service: `/etc/systemd/system/tailscale-cert-renew.service`
- Script: `/usr/local/bin/tailscale-cert-renew.sh`
- Status: `systemctl list-timers tailscale-cert-renew.timer`
- Manuell: `systemctl start tailscale-cert-renew.service`

## OpenClaw-Konfiguration

Nach Änderung:

1. Dienst neu starten: `systemctl --user restart openclaw-gateway`
2. Gateway-/Hook-Erreichbarkeit testen: `curl -sI https://marki.ds.activi.io/`
3. Testworkflow laufen lassen

### Aktuelles Gateway-Setup

Config: `~/.openclaw/openclaw.json` (live, Secrets darin — NICHT ins Repo committen)
Referenz ohne Secrets: `config/openclaw.json` im Repo

Optimale Einstellungen (verifiziert 2026-03-18):
- `gateway.bind`: `loopback` — nur Caddy kann direkt zugreifen
- `gateway.mode`: `local`
- `gateway.reload.mode`: `hybrid` — hot-reload wenn sicher, sonst Neustart
- `gateway.trustedProxies`: `["127.0.0.1"]` — Caddy als Proxy vertrauen
- `gateway.auth.mode`: `token` — fester Token, kein Wechsel bei Neustart
- `gateway.controlUi.allowedOrigins`: nur explizite HTTPS-Domains

### Gateway Pairing

Neue Geräte (Browser) müssen genehmigt werden:
```bash
openclaw devices list       # ausstehende Requests anzeigen
openclaw devices approve <REQUEST_ID>
```

## mem0-Konfiguration

Nach Änderung:

1. Dienst neu starten
2. Test-Memory schreiben
3. Test-Suche prüfen

## Meta-Bridge-Konfiguration

Nach Änderung:

1. Dienst neu starten
2. Webhook-Verifikation testen
3. Inbound-Test mit kontrolliertem Payload fahren

## Postiz-Konfiguration

Nach Änderung:

1. Compose-Umgebung neu laden
2. Stack neu starten
3. UI/MCP/API prüfen
4. Provider-Verbindung testen

---

## Deployments

## Ziel

Deployments sollen klein, reversibel und testbar sein.

## Regeln

- keine gemischten Großänderungen in einem Schritt
- Infrastruktur und Applogik möglichst getrennt ausrollen
- vor produktiven Änderungen Staging oder Testpfad nutzen, wenn möglich

## Deployment-Ablauf

1. Änderung vorbereiten
2. Backup/Snapshot prüfen
3. Konfiguration validieren
4. betroffene Dienste einzeln neu starten
5. Healthchecks
6. End-to-End-Test
7. Logs für 15–30 Minuten beobachten

## Zeitouts und Rollback

### Richtlinie

- Änderungen an öffentlichen Endpunkten müssen schnell rücknehmbar sein
- Inbox-kritische Pfade brauchen Safe-Fallback statt langes Hängen
- nach fehlgeschlagenem Change auf letzten stabilen Zustand zurückgehen

### Safe-Fallback

- keine automatische Chat-Antwort, wenn Kernpfade nicht gesund sind
- Webhooks dürfen angenommen, aber kontrolliert gepuffert werden
- riskante Publishing-Aktionen dürfen nicht auf halbgaren Zustand weiterlaufen

---

## Logs und Beobachtung

## Mindeststandard

- jeder Dienst schreibt nachvollziehbare Logs
- Fehler müssen zeitlich zuordenbar sein
- Logs dürfen keine Secrets enthalten

## Zu beobachten

### Caddy

- TLS-Fehler
- Routing-Fehler
- 4xx/5xx Peaks

### OpenClaw

- Hook-Fehler
- Tool-/Agentenfehler
- Timeouts

### Meta Bridge

- Webhook-Fehler
- Verification-Probleme
- Meta API Fehlercodes

### mem0

- Search-/Add-Fehler
- Verbindungsfehler zu Postgres

### Postiz

- Worker-Fehler
- OAuth-/Provider-Fehler
- Scheduling-/Publishing-Fehler
- Analytics-Fehler
- MCP-Verbindungsfehler

---

## Backup-Strategie

## Pflicht-Backups

1. eigener Postgres
2. Postiz-Datenbank
3. relevante `.env`- und Konfigurationsdateien
4. Caddy-Konfiguration
5. OpenClaw-/Bridge-/mem0-Konfiguration

## Nicht nur verlassen auf

- laufende Container
- vorhandene Volumes ohne Test-Restore

## Mindestfrequenz

- tägliches Datenbank-Backup
- Konfig-Backup bei jeder Änderung
- wöchentlich ein Restore-Test auf Testsystem oder isoliertem Pfad

---

## Restore-Reihenfolge

1. frische Maschine oder gesicherte Zielumgebung vorbereiten
2. Konfigurationsdateien zurückspielen
3. Datenbanken wiederherstellen
4. Redis nur bei Bedarf aus Backup, meist nicht primär nötig
5. Postiz Stack starten
6. OpenClaw starten
7. mem0 starten
8. Meta Bridge starten
9. Caddy aktivieren
10. End-to-End-Test fahren

---

## Sync- vs. Async-Pfade

## Sync-kritisch

- Meta Webhook Annahme
- grundlegende Inbound-Normalisierung
- schnelle Inbox-Entscheidung für Antwort, Eskalation oder Safe-Hold

## Async-geeignet

- tiefere Analytics-Auswertung
- Kampagnenoptimierung
- periodische Memory-Verdichtung
- nicht zeitkritische Content-Planung

## Timeout-Regeln

### Inbox-Pfad

- kurze harte Timeouts
- bei Überschreitung: keine unsichere Antwort senden
- stattdessen Safe-Hold, Eskalation oder manuelle Prüfung

### Publishing-Pfad

- technische Timeouts klar loggen
- bei Fehlern Queue/Retry statt stiller Verlust

---

## Incident Response

## Prioritäten

### P1

- öffentlicher Ausfall
- Webhooks laufen nicht
- Publishing komplett gestört
- keine eingehenden/ausgehenden Nachrichten mehr

### P2

- Analytics gestört
- Memory ausgefallen
- einzelne Integrationen gestört

### P3

- geringfügige Sprachfehler
- nichtkritische Logging-Probleme
- sporadische UI-Fehler

---

## Standardvorgehen bei Incidents

1. betroffenen Endpunkt identifizieren
2. prüfen, ob der Fehler intern oder extern ist
3. öffentliche Eingänge ggf. begrenzen
4. Logs der direkt beteiligten Dienste prüfen
5. Gesundheitszustand abhängiger Dienste prüfen
6. nur kleinste nötige Korrektur ausrollen
7. nach Stabilisierung Root Cause dokumentieren

---

## Häufige Fehlerbilder

## 1. Meta Webhook kommt nicht an

Prüfen:
- DNS korrekt?
- Caddy erreichbar?
- TLS gültig?
- korrekter Webhook-Pfad?
- Verify Token korrekt?
- Bridge-Dienst aktiv?

## 2. Postiz veröffentlicht nicht

Prüfen:
- Compose Stack gesund?
- Provider-Token gültig?
- Postiz-Domain korrekt?
- Media erreichbar?
- Worker aktiv?
- MCP/API zeigt Integrationen korrekt?

## 3. OpenClaw reagiert nicht auf Hooks

Prüfen:
- Dienst aktiv?
- Hook-URL korrekt?
- intern erreichbar?
- Auth/Config geändert?

## 4. mem0 liefert leere oder schlechte Treffer

Prüfen:
- richtige Datenbank?
- Embedding-/LLM-Konfiguration korrekt?
- wurde überhaupt etwas sinnvoll gespeichert?
- Query zu breit oder zu eng?

## 5. Redis-Probleme

Prüfen:
- Speichergrenze?
- Verbindung lokal erreichbar?
- falsche DB/Namespace-Nutzung?

## 6. Postgres-Probleme

Prüfen:
- Verbindungen erschöpft?
- Disk voll?
- Backups intakt?
- Migration/Schema konsistent?

---

## Sicherheitsbetrieb

## Grundregeln

- Secrets nie in Logs
- `.env` restriktiv speichern
- Tokens regelmäßig rotieren
- nicht benötigte Ports schließen
- öffentliche Angriffsfläche klein halten

## Regelmäßige Aufgaben

- Security Updates einspielen
- TLS-Zertifikatsstatus prüfen
- Benutzer und SSH-Zugänge prüfen
- alte Tokens entfernen
- Meta-/Provider-Berechtigungen überprüfen

---

## Routinebetrieb

## Täglich

- Logs überfliegen
- Fehlerraten prüfen
- veröffentlichte Inhalte und Analytics kurz prüfen
- Webhook-/Inbox-Fluss prüfen

## Wöchentlich

- Backups prüfen
- Restore-Test oder Stichprobe
- Disk/RAM/CPU-Entwicklung prüfen
- Token-/Berechtigungszustand prüfen
- Queue-/Retry-Verhalten prüfen

## Monatlich

- Systemupdates
- Docker-/Base-Image-Review
- Secrets/Tokens-Rotation prüfen
- Architekturdrift dokumentieren

---

## Definition of Healthy State

Ein gesunder Stack bedeutet:

- öffentliche Endpunkte antworten korrekt
- interne Dienste sind erreichbar
- OpenClaw kann Workflows ausführen
- Postiz kann veröffentlichen und Analytics liefern
- Postiz MCP ist erreichbar
- Meta Bridge nimmt Events an
- mem0 kann schreiben und suchen
- Postgres und Redis sind stabil
- keine dauerhaften Fehler-Schleifen oder Crash-Restarts

---

## Freigabekriterium nach Änderungen

Ein Change gilt erst als erfolgreich, wenn:

1. Healthchecks grün sind
2. Logs sauber sind
3. ein Test-Webhook funktioniert
4. ein Test-Post erstellt werden kann
5. Memory-Schreiben und -Suche funktionieren
6. MCP-Verbindung geprüft wurde
7. keine unbeabsichtigten öffentlichen Freigaben entstanden sind

---

## Schlussregel

Wenn unklar ist, ob ein Eingriff sicher ist:

- nicht improvisieren,
- zuerst Zustand sichern,
- dann minimalen Change durchführen,
- danach kontrolliert validieren.
