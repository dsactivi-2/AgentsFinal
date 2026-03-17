---
name: Inbox
description: Eingehende Nachrichten verarbeiten und routen
---

# SKILL: Inbox — Eingehende Nachrichten verarbeiten

## Aktivierung

Dieser Skill wird aktiviert durch:
- Eingehende Nachricht via Meta Bridge (Webhook)
- Heartbeat-Check auf unbearbeitete Nachrichten
- Direkte Anfragen: "Bearbeite Nachricht von [psid]"

## Kernaufgabe

Erste Anlaufstelle für alle eingehenden Nachrichten.
Klassifiziert, priorisiert und routet Nachrichten an die richtige Stelle.

## Verarbeitungs-Pipeline

### 1. Nachricht empfangen

```
Input:
- psid (Nutzer-ID)
- platform (messenger/instagram)
- text (Nachrichteninhalt)
- request_id (für Tracing)
```

### 2. Nutzer-Kontext laden

```
memory_search("nutzer [psid]") → Frühere Interaktionen
```

- Erster Kontakt oder bekannter Nutzer?
- Offene Eskalation vorhanden?
- Opt-out vorhanden? → Nicht antworten, informieren

### 3. Nachrichten-Klassifikation

| Kategorie | Beispiele | Routing |
|-----------|-----------|---------|
| Frage/Info | "Was kostet...?", "Wie lange...?" | → Direkte Antwort |
| Beschwerde | "Das funktioniert nicht", "Ich bin unzufrieden" | → SKILL:escalation prüfen |
| Lob | "Danke!", "Super Service" | → Kurze Dankesantwort |
| Bestellung | "Ich möchte..." | → Klären oder Eskalation |
| Spam/Test | "test", "hallo hallo" | → Kurze neutrale Antwort |
| Privat | Persönliche Probleme | → Empathisch + ggf. Eskalation |
| Unverständlich | Kryptischer Text | → Höflich nachfragen |

### 4. Sentiment-Analyse

Schnell-Einschätzung:
- **Positiv:** Freundlich, Dankbar → Normaler Flow
- **Neutral:** Informations-Anfrage → Normaler Flow
- **Negativ:** Frustration, Wut → SKILL:escalation evaluieren
- **Kritisch:** Selbstverletzung, Drohung → Sofort SKILL:escalation

### 5. Antwort-Generierung

Für einfache Anfragen: Direkte Antwort basierend auf Memory
Für komplexe Anfragen: Recherche → Antwort
Für sensible Anfragen: SKILL:escalation

### Antwort-Regeln

- Max. 3-4 Sätze (Social-Media-Format)
- Immer in der Sprache des Nutzers
- Persönlich und freundlich (SOUL.md)
- Am Ende: Frage oder CTA wenn sinnvoll
- Response-Zeit-Ziel: < 60 Sekunden

## Memory-Aktualisierung

Nach jeder Interaktion:
```
Speichere: "nutzer [psid] platform:[platform] sprache:[lang] letzte-interaktion:[datum] kategorie:[kategorie]"
```

## Output-Format

```markdown
## Inbox-Verarbeitung [request_id]

**Nutzer:** [psid] ([platform])
**Kategorie:** [Kategorie]
**Sentiment:** [Positiv/Neutral/Negativ/Kritisch]
**Sprache:** [DE/BS/SR/EN]
**Bekannter Nutzer:** [Ja/Nein]

**Antwort:**
[Die tatsächliche Antwort die an den Nutzer gesendet wird]

**Routing:** [Direkte Antwort / SKILL:escalation / etc.]
```
