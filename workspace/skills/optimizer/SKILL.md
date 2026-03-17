---
name: Optimizer
description: Datengetriebene Content-Optimierung
---

# SKILL: Optimizer — Datengetriebene Content-Optimierung

## Aktivierung

Dieser Skill wird aktiviert durch:
- Übergabe von SKILL:analytics mit neuen Findings
- Wöchentlich nach Analytics-Report
- Direkte Anfragen: "Optimiere unsere Strategie", "Was können wir besser machen?"

## Kernaufgabe

Wandle Rohdaten aus Analytics in konkrete, umsetzbare Regeln um.
Aktualisiere die Strategie des Agenten kontinuierlich.

## Optimierungs-Bereiche

### 1. Posting-Zeit-Optimierung

Sammle über Zeit:
- Engagement Rate pro Posting-Stunde
- Engagement Rate pro Wochentag
- Unterschiede zwischen Plattformen

Nach 30 Posts: Passe Empfehlungen in MEMORY.md an.

**Regel-Format:**
```
"Instagram [Wochentag]: Beste Zeit [HH:MM-HH:MM], ER ø [%]"
```

### 2. Content-Format-Optimierung

Vergleiche Formate:
- Nur-Text vs. Bild + Text vs. Video
- Lange vs. Kurze Captions (< 150 vs. > 500 Zeichen)
- Mit vs. Ohne CTA
- Mit vs. Ohne Frage

### 3. Hook-Optimierung

Kategorisiere erfolgreiche Hooks:
- Frage-Hooks: "Wusstest du, dass...?"
- Challenge-Hooks: "Teste dich selbst..."
- Story-Hooks: "Vor 3 Jahren..."
- Fact-Hooks: "[Zahl]% der Menschen..."
- Problem-Hooks: "Das nervt alle..."

### 4. Hashtag-Optimierung

- Tracke Hashtag-Performance (welche bringen Reach?)
- Entferne schwache Hashtags
- Füge erfolgreiche hinzu

### 5. Sprach-Split-Optimierung

- Welche Sprache performt auf welcher Plattform besser?
- Lohnt sich Mehrsprachigkeit pro Post oder separate Posts?

## Output-Format

```markdown
## Optimierungs-Update [Datum]

### Neue Regeln (basierend auf [N] Posts)
1. **Posting-Zeit:** [Neue Empfehlung]
2. **Content-Format:** [Neue Empfehlung]
3. **Hook-Typ:** [Neue Empfehlung]

### Aktualisierte MEMORY.md-Einträge
[Was wurde in MEMORY.md geändert/ergänzt]

### A/B-Tests empfohlen
- Test 1: [Was testen?] → [Metric messen]
- Test 2: [Was testen?] → [Metric messen]

### Übergabe an Planner
→ Diese Regeln gelten ab sofort für neue Content-Pläne
```

## Daten-Persistenz

Alle Optimierungsregeln in Memory speichern:
```
memory_search("optimizer rules") → Aktuelle Regeln
```

Neue Regeln:
```
Speichere: "optimizer rule [kategorie]: [regel] — basierend auf [n] posts, stand [datum]"
```

## Wichtig

- Mindest-Datenbasis: 10 Posts pro Kategorie bevor Regeln gelten
- Regeln werden nach 90 Tagen ohne neue Daten als "veraltet" markiert
- Widersprüchliche Daten: Konservativere Regel bevorzugen
