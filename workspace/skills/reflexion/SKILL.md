---
name: Reflexion
description: Wöchentliche Selbstanalyse aller 9 Rollen — Muster erkennen, Verbesserungen vorschlagen, Wochenbericht speichern
---

## Trigger

Cron: Sonntag 04:00 Europe/Berlin (`"0 4 * * 0"`)
Aktivierung via: `ROLE:reflexion`

## Zweck

Analysiert die Performance aller 9 Rollen der letzten 7 Tage.
Speichert strukturierte Verbesserungs-Vorschläge in Supermemory.
Erstellt einen Wochenbericht.

**Darf nicht:** Skill-Dateien selbst überschreiben. Nur Vorschläge — Mensch entscheidet.

---

## Ablauf

### Schritt 1 — Daten laden

```
memory_search("analytics report last 7 days")     → Performance-Daten
memory_search("optimizer rules current")           → aktive Regeln
memory_search("campaign learnings")                → bisherige Learnings
memory_search("escalation last week")              → Eskalationen der Woche
memory_search("inbox response quality")            → Inbox-Qualität
```

### Schritt 2 — Pro Rolle analysieren

Für jede Rolle folgende Fragen beantworten:

| Rolle | Leitfragen |
|---|---|
| planner | Waren Themen relevant? Timing korrekt? Kanal-Wahl nachvollziehbar? |
| writer | Natürliche Sprache? CTA-Qualität? Varianten sinnvoll differenziert? |
| reviewer | Echte Risiken erkannt? Falsch-Positiv-Rate? Freigaben nachvollziehbar? |
| publisher | Technische Fehler? Stille Fehler? Status-Referenzen vollständig? |
| analytics | Muster belastbar? Ausreißer überbewertet? |
| optimizer | Konkrete Verbesserungen entstanden? Pseudo-Optimierungen erkannt? |
| inbox | Sprache/Intent korrekt erkannt? Eskalationen rechtzeitig? |
| memory-critic | Nur Relevantes gespeichert? Speicherklassen sauber getrennt? |
| escalation | Handover klar und schnell? Folgefehler vermieden? |

### Schritt 3 — Verbesserungen speichern

Format pro Eintrag:
```
skill_improvement [rolle]: [konkrete Verbesserung, max 120 Zeichen] — Evidenz: [N Posts/Events, Datum]
```

Beispiele:
```
skill_improvement writer: Hooks mit Frage +40% Engagement vs Aussage-Hooks — Evidenz: 12 Posts, KW10 2026
skill_improvement reviewer: BS-Konjunktiv wird zu selten korrigiert — Evidenz: 3 Eskalationen, KW10 2026
skill_improvement inbox: Intent-Erkennung bei Preisfragen unsicher — Evidenz: 5 Eskalationen, KW10 2026
```

Nur speichern wenn:
- Evidenz aus ≥3 Ereignissen
- Konkrete, handlungsrelevante Erkenntnis
- Nicht bereits als Learning gespeichert (memory_search vor Speicherung)

### Schritt 4 — Wochenbericht

Format:
```
reflexion_report [YYYY-MM-DD]:
• [Erkenntnis 1]
• [Erkenntnis 2]
• [Erkenntnis 3]
• (optional) [Erkenntnis 4]
• (optional) [Erkenntnis 5]
```

Maximal 5 Bullet Points. Konkret, nicht allgemein.

---

## Speicher-Ziele

| Was | Wohin |
|---|---|
| `skill_improvement [rolle]: ...` | Supermemory (containerTag: social-ai-stack) |
| `reflexion_report [datum]: ...` | Supermemory (containerTag: social-ai-stack) |
| Rohdaten der Analyse | NICHT speichern |

---

## Fehlerverhalten

- Keine Daten verfügbar → Wochenbericht mit Hinweis "Keine ausreichenden Daten KW[X]", kein Crash
- Supermemory nicht erreichbar → Einträge lokal in `memory/reflexion-pending.md` zwischenspeichern
- Analyse dauert > 30 min → Abbrechen, Fehler loggen, nächste Woche erneut versuchen

---

## Qualitätskriterien

Reflexion ist gut, wenn:
- Vorschläge konkret und evidenzbasiert sind
- Kein Rolle unanalysiert bleibt
- Wochenbericht in < 5 Minuten lesbar ist
- Keine Duplikate in Supermemory entstehen
