---
name: Analytics
description: Performance-Analyse & Insights für Social Media
---
## Modell: ollama/deepseek-v3.2:cloud
# SKILL: Analytics — Performance-Analyse & Insights

## Aktivierung

Dieser Skill wird aktiviert durch:
- Cron-Job täglich 20:00 ("SKILL:analytics")
- Direkte Anfragen: "Wie laufen unsere Posts?", "Analysiere die Performance"
- Nach Beendigung einer Kampagne

## Datenquellen

### Postiz Analytics
- Reach, Impressions, Engagements pro Post
- Follower-Wachstum
- Story-Views
- Link-Klicks

### Meta Insights (via Graph API — optional)
- Detaillierte Demografie
- Reach per Audience-Segment
- Peak-Zeiten der Zielgruppe

## Analyse-Framework

### Tägliche Analyse (20:00 Uhr)

1. **Posts des heutigen Tages:**
   - Wie viele Posts wurden veröffentlicht?
   - Welcher Post hat am besten/schlechtesten performt?
   - Warum? (Timing? Format? Inhalt? Hook?)

2. **Engagement-Metriken:**
   - Engagement Rate = (Likes + Comments + Shares) / Reach × 100
   - Benchmark: Instagram >3% = gut, >5% = sehr gut
   - Benchmark: Facebook >1% = gut, >3% = sehr gut

3. **Trend-Analyse:**
   - Vergleich zur Vorwoche
   - Vergleich zum Vormonat
   - Wachstumskurve Follower

### Wöchentliche Analyse (Sonntag)

1. **Top 3 Posts der Woche** mit Begründung
2. **Flop 3 Posts der Woche** mit Lessons Learned
3. **Content-Mix-Analyse:** War der 70/30-Mix eingehalten?
4. **Zeitpunkt-Analyse:** Welche Posting-Zeiten performten am besten?
5. **Sprach-Analyse:** DE vs. BS/SR Performance

## Output-Format

```markdown
## Analytics-Report [Datum]

### Heute im Überblick
- Posts: [Anzahl]
- Gesamt-Reach: [Zahl]
- Gesamt-Engagements: [Zahl]
- Ø Engagement Rate: [%]

### Top Post
**[Post-ID/Titel]**
- Reach: [Zahl] | Engagements: [Zahl] | ER: [%]
- Warum gut: [Analyse]

### Learnings für morgen
1. [Konkretes Learning]
2. [Konkretes Learning]

### Empfehlung an Planner
→ [Konkrete Empfehlung basierend auf Daten]
```

## Learnings speichern

Nach jeder Analyse → SKILL:optimizer aufrufen mit den Findings.

## Memory-Nutzung

```
memory_search("analytics [datum]") → Historische Daten
memory_search("posting time performance") → Zeitpunkt-Learnings
memory_search("content type performance") → Format-Learnings
```

Nach Analyse:
```
Speichere: "analytics [datum] reach:[zahl] er:[%] top-post:[id] learning:[text]"
```
