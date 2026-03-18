---
name: Memory Critic
description: Speicherentscheidungen & Memory-Hygiene via Supermemory
---
## Modell: ollama/deepseek-v3.2:cloud
# SKILL: Memory Critic — Langzeit-Memory Management

## Aktivierung

- Cron-Job wöchentlich 03:00 ("SKILL:memory_critic")
- Direkte Anfragen: "Bereinige das Memory", "Was soll ich speichern?"
- Nach jedem Gespräch mit wichtigen Erkenntnissen

## Memory-Operationen (konkrete Befehle)

### Suchen
```bash
curl -s -X POST http://127.0.0.1:8010/memory/search \
  -H "Content-Type: application/json" \
  -d '{"user_id": "global", "query": "DEINE_SUCHANFRAGE", "limit": 10}'
```

### Nutzer-spezifisch suchen
```bash
curl -s -X POST http://127.0.0.1:8010/memory/search \
  -H "Content-Type: application/json" \
  -d '{"user_id": "PSID_DES_NUTZERS", "query": "SUCHANFRAGE", "limit": 5}'
```

### Speichern (global — Marken-Learnings)
```bash
curl -s -X POST http://127.0.0.1:8010/memory/add \
  -H "Content-Type: application/json" \
  -d '{"user_id": "global", "content": "INHALT", "metadata": {"skill": "SKILL_NAME", "type": "learning"}}'
```

### Speichern (nutzer-spezifisch)
```bash
curl -s -X POST http://127.0.0.1:8010/memory/add \
  -H "Content-Type: application/json" \
  -d '{"user_id": "PSID", "content": "PRÄFERENZ ODER KONTEXT", "metadata": {"skill": "inbox", "type": "preference"}}'
```

### Löschen
```bash
curl -s -X DELETE http://127.0.0.1:8010/memory/DOCUMENT_ID
```

## Speicher-Entscheidungs-Framework

### Was IMMER gespeichert wird
- Nutzer-Präferenzen (Sprache, Ton, Themen) → `user_id: PSID`
- Wichtige Kampagnen-Learnings mit Zahlen → `user_id: global`
- Regel-Änderungen vom Optimizer → `user_id: global`
- Eskalations-Muster (anonymisiert) → `user_id: global`
- Erfolgreiche Post-Strukturen → `user_id: global`
- Posting-Zeit-Erkenntnisse mit Daten → `user_id: global`

### Was NICHT gespeichert wird
- Einzelne Konversations-Smalltalk
- Temporäre Debugging-Infos
- Duplikate von bestehenden Einträgen
- Informationen die nach 7 Tagen nicht mehr relevant sind
- Personenbezogene Daten ohne Consent (Name, Telefon, Adresse)

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

1. Suche nach ähnlichen Einträgen → Duplikate zusammenführen
2. Prüfe Einträge > 90 Tage → Noch relevant? Behalten, sonst löschen
3. Qualitäts-Check: Klar? Korrekte Zahlen? Quellen?

## Output-Format

```markdown
## Memory-Audit [Datum]

### Statistik
- Geprüfte Einträge: [N]
- Neue Einträge: [N]
- Aktualisierte Einträge: [N]
- Gelöschte Einträge: [N]

### Memory-Gesundheit: [Score 0-10]
Begründung: [Kurze Einschätzung]
```

## Sicherheits-Regeln

- Niemals Nachrichten-Inhalte mit personenbezogenen Daten speichern
- PSIDs dürfen gespeichert werden (keine persönlichen Infos)
- Bei Unsicherheit: NICHT speichern
- Löschungen immer loggen
