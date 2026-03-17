# SKILL: Planner — Content-Strategie & Kampagnenplanung

## Aktivierung

Dieser Skill wird aktiviert durch:
- Cron-Job täglich 09:00 ("SKILL:planner")
- Explizite Anfragen: "Erstelle einen Plan", "Was posten wir diese Woche?"
- Heartbeat wenn kein Tagesplan existiert

## Aufgaben

### Täglicher Content-Plan
1. Prüfe Learnings der letzten 7 Tage (`memory_search "campaign learnings"`)
2. Prüfe aktuelle Kampagnen (`memory_search "aktive kampagne"`)
3. Prüfe Feiertage und relevante Events im Zielmarkt (DE/BA/RS)
4. Erstelle Content-Plan für die nächsten 7 Tage:
   - Min. 1 Post/Tag Instagram
   - Optional: Facebook wenn sinnvoll
   - Variiere Content-Typen: Text, Bild-Caption, Story-Idee, Reel-Konzept

### Kampagnen-Management
1. Prüfe Kampagnen-Ziele (KPIs, Budget, Laufzeit)
2. Erstelle Kampagnen-Brief mit:
   - Ziel (Reichweite / Engagement / Conversions)
   - Zielgruppe + Sprache
   - Kernbotschaft + Tonalität
   - Content-Varianten (min. 3)
   - Posting-Zeitplan

### Output-Format

```markdown
## Content-Plan [Datum]

### [Tag, Datum]
**Plattform:** Instagram
**Typ:** Bild-Post
**Hook:** [Erster Satz / Frage]
**Caption-Entwurf:** [Text in Zielsprache]
**Hashtags:** #tag1 #tag2 ...
**Posting-Zeit:** 09:00 Uhr
**Ziel:** Engagement / Reichweite

---
```

### Übergabe an Writer
Nach dem Plan: SKILL:writer übergeben für ausformulierte Captions.

## Strategische Regeln

- **70/30-Regel:** 70% organischer Content, 30% Produkt/Werbung
- **Content-Vielfalt:** Keine zwei identischen Formate in Folge
- **Saisonalität:** Religiöse Feiertage (BS/SR: Ramadan, Eid, Weihnachten, Ostern, Bairam)
- **Trends:** Prüfe aktuelle Social-Media-Trends wöchentlich
- **A/B-Gedanke:** Immer 2 Varianten für wichtige Posts vorschlagen

## Memory-Nutzung

```
memory_search("kampagne [monat]") → Aktuelle Kampagnen
memory_search("top performing posts") → Was funktioniert
memory_search("feiertage [monat]") → Relevante Termine
```
