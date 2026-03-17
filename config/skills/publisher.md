# SKILL: Publisher — Post-Veröffentlichung via Postiz

## Aktivierung

Dieser Skill wird aktiviert durch:
- Übergabe von SKILL:reviewer nach Freigabe (🟢)
- Direkte Anfragen: "Veröffentliche den Post", "Plane den Post für..."
- Geplante Posts die ihren Veröffentlichungszeitpunkt erreichen

## Postiz-Integration

### API-Konfiguration

Postiz läuft lokal oder als Docker-Container:
- **URL:** `http://127.0.0.1:4200` (Standard)
- **API:** REST API mit Bearer Token

### Workflow

1. **Post-Daten vorbereiten:**
   - Caption (aus Writer-Output)
   - Hashtags anhängen
   - Medien-URLs (falls Bilder/Videos)
   - Plattform wählen (Instagram / Facebook)
   - Posting-Zeit setzen

2. **Postiz API aufrufen:**
   ```
   POST /api/posts
   {
     "platform": "instagram",
     "content": "[Caption + Hashtags]",
     "media": ["url1", "url2"],
     "scheduledAt": "2026-03-16T09:00:00Z"
   }
   ```

3. **Bestätigung erhalten:**
   - Post-ID speichern
   - Geplanten Zeitpunkt bestätigen
   - In Memory loggen

### Direkt-Posting vs. Geplantes Posting

**Direkt:** Wenn Posting-Zeit = jetzt (oder < 15 Minuten)
**Geplant:** Wenn Posting-Zeit in der Zukunft → Postiz übernimmt Scheduling

## Output-Format

```markdown
## Publishing-Ergebnis

**Status:** ✅ Veröffentlicht / 📅 Geplant / ❌ Fehler

**Post-ID:** [Postiz-ID]
**Plattform:** [Instagram/Facebook]
**Geplant für:** [Datum + Uhrzeit]
**Inhalt (Vorschau):** [Erste 100 Zeichen...]

**Memory-Log:** Gespeichert unter [post-id]
```

## Fehlerbehandlung

Bei API-Fehler:
1. Log Fehler mit Details in Memory
2. Retry nach 5 Minuten (max. 3 Versuche)
3. Bei dauerhaftem Fehler: Eskalation + manuelle Prüfung

## Qualitätssicherung beim Publishing

- Nochmals prüfen: Ist Reviewer-Freigabe vorhanden?
- Kein Publishing ohne `status: "approved"` in Memory
- Bei Zweifeln: SKILL:reviewer erneut aufrufen

## Memory-Nutzung

```
memory_search("postiz api token") → API-Credentials
memory_search("publishing log") → Letzte Veröffentlichungen
```

Nach erfolgreichem Posting:
```
Speichere: "Post [ID] veröffentlicht [Plattform] [Datum] [Uhrzeit] — [Caption-Preview]"
```
