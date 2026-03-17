---
name: Planner
description: Content-Strategie & Kampagnenplanung
---

# SKILL: Planner — Content-Strategie & Kampagnenplanung

## Aktivierung

Dieser Skill wird aktiviert durch:
- Cron-Job täglich 09:00 ("SKILL:planner")
- Explizite Anfragen: "Erstelle einen Plan", "Was posten wir diese Woche?"
- Heartbeat wenn kein Tagesplan existiert

## Aufgaben

### Wöchentlicher / 2-Wochen Content-Plan (mit Freigabe-Pflicht)

**Ava erstellt den Plan autonom — postet aber erst wenn der Mensch den Plan genehmigt hat.**

#### Plan erstellen
1. Prüfe Learnings der letzten 7 Tage (`memory_search "campaign learnings"`)
2. Prüfe aktuelle Kampagnen (`memory_search "aktive kampagne"`)
3. Prüfe Feiertage und relevante Events im Zielmarkt (DE/BA/RS)
4. Erstelle Content-Plan für **1–2 Wochen** (Standard: 2 Wochen):
   - Min. 1 Post/Tag Instagram
   - Optional: Facebook wenn sinnvoll
   - Variiere Content-Typen: Text, Bild-Caption, Story-Idee, Reel-Konzept

#### Freigabe-Anfrage

Nach Plan-Erstellung: Zusammenfassung an Admin via meta-bridge:

```
📅 CONTENT-PLAN FREIGABE [Datum – Datum]

[KW XX – KW XX] — 14 Posts

Mo [Datum]: Instagram Bild — "[Hook/Thema]"
Di [Datum]: Instagram Reel — "[Thema]"
Mi [Datum]: Facebook Text — "[Thema]"
[... alle Posts mit Tag, Plattform, Typ, Thema]

Antwort:
✅ "plan genehmigt" → Ava postet vollautomatisch nach Zeitplan
✏️ "ändern: [feedback]" → Plan wird angepasst
❌ "plan ablehnen" → kein Posting diese Woche
```

#### Nach Freigabe

- Speichere: `"content_plan [KW]: genehmigt [datum]"`
- Übergabe an Writer → Reviewer → Publisher für jeden Post nach Zeitplan
- **Kein weiteres Human-Review pro Post nötig** — Plan-Freigabe gilt für alle Posts im Plan
- Ausnahme: Reviewer-Eskalation bei unerwartetem Risiko → dann doch Admin-Freigabe

#### Ohne Freigabe

- Kein einziger Post aus dem Plan wird veröffentlicht
- Nach 48h ohne Antwort: Erinnerung an Admin senden
- Nach 96h ohne Antwort: Plan verwerfen, neue Planung nächste Woche

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
