---
name: Escalation
description: Human-Handover & Krisenmanagement
---
## Modell: ollama/nemotron-3-super:cloud
# SKILL: Escalation — Human-Handover & Krisenmanagement

## Aktivierung

Dieser Skill wird aktiviert durch:
- SKILL:inbox bei negativem/kritischem Sentiment
- Direkte Anfragen eines Nutzers: "Ich möchte einen Menschen sprechen"
- Automatische Trigger (siehe Trigger-Liste)
- Kein Lösungsweg gefunden nach 3 Versuchen

## Eskalations-Trigger

### Sofort-Eskalation (ohne Verzögerung)

- Erwähnung von Selbstverletzung, Suizid, Selbstgefährdung
- Drohungen gegen andere Personen
- Kinder in gefährlichen Situationen
- Medizinische Notfälle
- Strafbare Handlungen (Betrug, Missbrauch)

### Standard-Eskalation

- Nutzer fordert explizit menschliche Hilfe
- 3+ aufeinanderfolgende negative Nachrichten
- Beschwerde mit Forderung (Rückerstattung, Kompensation)
- Technisches Problem das Agent nicht lösen kann
- Rechtliche Fragen oder Drohungen
- Vertragsrelevante Anfragen

### Weiche Eskalation (Mensch informiert, Agent antwortet weiter)

- Starke Frustration ohne akuten Handlungsbedarf
- Wiederkehrende Probleme ohne Lösung
- VIP-Kunden (falls in Memory markiert)

## Eskalations-Prozess

### 1. Nutzer informieren

Antworte immer in der Sprache des Nutzers (BS/SR/DE/EN).

```
[Deutsch]
"Ich verstehe, wie wichtig das für dich ist. Ich leite dich jetzt an unser Team weiter, das sich persönlich um dich kümmert. In der Regel melden wir uns innerhalb von [X] Stunden."

[Bosnisch]
"Razumijem koliko je ovo važno za tebe. Preuzima naš tim koji će se lično pobrinuti za tebe. Obično se javljamo unutar [X] sati."

[Serbisch]
"Razumem koliko je ovo važno za tebe. Preuzima naš tim koji ce se lično pobrinuti za tebe. Obično se javljamo u roku od [X] sati."

[Englisch]
"I understand how important this is to you. I am connecting you with our team who will take care of you personally. We usually get back within [X] hours."
```

### 2. Kontext-Snapshot erstellen

Für das menschliche Team:
```markdown
## Eskalations-Briefing

**Nutzer:** [psid] ([platform])
**Sprache:** [Sprache]
**Datum/Uhrzeit:** [Zeitstempel]
**Grund:** [Eskalations-Grund]
**Trigger:** [Was hat die Eskalation ausgelöst]

**Gesprächs-Zusammenfassung:**
[Kurze Zusammenfassung der letzten 5-10 Nachrichten]

**Nutzer-Historie:**
[Aus Memory: Frühere Interaktionen, bekannte Präferenzen]

**Empfohlene nächste Schritte:**
[Konkrete Empfehlung für das Team]

**Priorität:** [Normal / Dringend / Sofort]
```

### 3. In Datenbank speichern

Neuen Eintrag in `escalations`-Tabelle anlegen (via Postgres direkt oder API).

### 4. Session-Status aktualisieren

Memory-Update:
```
Speichere: "nutzer [psid] status:eskaliert grund:[grund] datum:[datum] team-info-gesendet:ja"
```

## Verhaltensregeln während Eskalation

- Agent antwortet weiterhin empathisch bis Mensch übernimmt
- Keine Zusagen oder Versprechen machen
- Neutral bleiben, nicht verteidigen oder streiten
- Dokumentation ist priorität

## Wiederaufnahme nach Eskalation

Wenn Eskalation als "resolved" markiert:
- Nutzer freundlich zurückbegrüßen
- Sicherstellen dass das Problem gelöst ist
- Learnings in Memory speichern (anonymisiert)

## Output-Format

```markdown
## Eskalations-Report [request_id]

**Nutzer:** [psid] ([platform])
**Trigger:** [Grund]
**Priorität:** [Normal/Dringend/Sofort]
**Status:** Eskaliert ✅

**Nachricht an Nutzer:** [Gesendete Nachricht]
**Briefing erstellt:** Ja
**DB-Eintrag:** [escalation_id]

**Empfehlung an Team:** [Kurze Handlungsempfehlung]
```
