# HEARTBEAT — Proaktiver Planungs-Zyklus

Dieser Prompt wird alle 60 Minuten ausgeführt (via openclaw.json heartbeat).
Er steuert das proaktive Verhalten des Agenten zwischen eingehenden Nachrichten.

## Heartbeat-Aufgaben (in Priorität)

### 1. Uhrzeit-basiertes Routing

```
WENN aktuelle Uhrzeit zwischen 08:00 und 10:00:
  → Prüfe ob Tagesplan bereits erstellt (memory_search "tagesplan heute")
  → Falls nicht: SKILL:planner → Erstelle Content-Plan für heute
  → Falls ja: Prüfe ob alle geplanten Posts für heute vorhanden sind

WENN aktuelle Uhrzeit zwischen 19:00 und 21:00:
  → SKILL:analytics → Analysiere Performance des heutigen Contents
  → Speichere Learnings für morgen

WENN aktuelle Uhrzeit zwischen 21:00 und 23:00:
  → SKILL:planner → Erstelle Entwürfe für den nächsten Tag
  → SKILL:reviewer → Prüfe ausstehende Entwürfe

SONST:
  → Prüfe ob offene Eskalationen vorliegen (memory_search "offene eskalation")
  → Prüfe ob geplante Posts für die nächsten 2 Stunden bereit sind
```

### 2. Inbox-Monitoring

- Prüfe ob unbearbeitete Nachrichten aus den letzten 30 Minuten vorliegen
- Priorität: Eskalationen > direkte Fragen > Kommentare

### 3. Kampagnen-Pulse

- Aktive Kampagnen prüfen (memory_search "aktive kampagne")
- Bevorstehende Deadlines checken
- Bei <24h bis Deadline: Alarm an Reviewer

### 4. Memory-Maintenance

- Einmal täglich (beim ersten Heartbeat nach 03:00):
  - Veraltete Session-Kontexte archivieren
  - Wichtige Learnings in Langzeit-Memory verdichten

## Heartbeat-Ausgabe-Format

Heartbeat-Aktionen werden NICHT an Nutzer gesendet.
Interne Logs werden in die Memory geschrieben:

```
memory_search("heartbeat log heute") → Prüfe ob bereits geloggt
Falls nicht: Schreibe kurzen Status in Memory:
  "Heartbeat HH:MM — [Aktion] — [Status]"
```

## Wichtig

- Der Heartbeat läuft auch nachts — halte Aktionen zwischen 00:00 und 07:00 minimal
- Keine API-Aufrufe an Meta außerhalb von 07:00-23:00 (außer bei Eskalationen)
- Bei Fehlern: Logge den Fehler und fahre fort (kein Absturz)
