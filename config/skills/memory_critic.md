# SKILL: Memory Critic — Speicherentscheidungen & Memory-Hygiene

## Aktivierung

Dieser Skill wird aktiviert durch:
- Cron-Job wöchentlich 03:00 ("SKILL:memory_critic")
- Direkte Anfragen: "Bereinige das Memory", "Was soll ich speichern?"
- Vor wichtigen Entscheidungen die Memory-Qualität erfordern

## Kernaufgabe

Entscheidet was im Langzeit-Memory (Supermemory) gespeichert, aktualisiert oder gelöscht wird.
Verhindert Memory-Pollution und sichert Daten-Qualität.

## Speicher-Entscheidungs-Framework

### Was IMMER gespeichert wird

- [ ] Nutzer-Präferenzen (Sprache, Ton, Themen)
- [ ] Wichtige Kampagnen-Learnings mit Zahlen
- [ ] Regel-Änderungen vom Optimizer
- [ ] Eskalations-Muster (anonymisiert)
- [ ] Erfolgreiche Post-Strukturen
- [ ] Posting-Zeit-Erkenntnisse mit Daten

### Was NICHT gespeichert wird

- [ ] Einzelne Konversations-Smalltalk
- [ ] Temporäre Debugging-Infos
- [ ] Duplikate von bestehenden Einträgen
- [ ] Informationen die nach 7 Tagen nicht mehr relevant sind
- [ ] Personenbezogene Daten ohne Consent

### Entscheidungsbaum

```
Ist die Information:
├── Einmalig nutzbar? → NICHT speichern
├── Wiederverwendbar? → Weiter prüfen:
│   ├── Schon vorhanden (ähnlich)? → Bestehenden Eintrag aktualisieren
│   ├── Neu und relevant? → Speichern mit Kontext
│   └── Veraltet (> 90 Tage + nicht bestätigt)? → Löschen
```

## Wöchentliche Memory-Hygiene

### 1. Duplikat-Erkennung

```
memory_search("optimizer rules") → Vergleiche ähnliche Einträge
→ Doppeltes zusammenführen, älteres löschen
```

### 2. Relevanz-Check

Einträge älter als 90 Tage prüfen:
- Noch relevant? → Behalten + Datum aktualisieren
- Veraltet? → Archivieren oder löschen

### 3. Qualitäts-Check

- Sind Einträge klar und verständlich?
- Sind Zahlen/Daten korrekt referenziert?
- Sind Quellen angegeben?

## Output-Format

```markdown
## Memory-Audit [Datum]

### Statistik
- Geprüfte Einträge: [N]
- Neue Einträge: [N]
- Aktualisierte Einträge: [N]
- Gelöschte Einträge: [N]
- Zusammengeführte Duplikate: [N]

### Wichtigste Änderungen
1. [Beschreibung]
2. [Beschreibung]

### Memory-Gesundheit: [Score 0-10]
Begründung: [Kurze Einschätzung]

### Empfehlungen
→ [Konkrete Handlungsempfehlung]
```

## Sicherheits-Regeln

- Niemals Nachrichten-Inhalte mit personenbezogenen Daten speichern
- PSIDs dürfen gespeichert werden (keine persönlichen Infos)
- Bei Unsicherheit: NICHT speichern
- Löschungen immer loggen (wann, warum, was)
