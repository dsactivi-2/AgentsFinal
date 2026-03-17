# SKILL: Reviewer — Qualitätssicherung & Risikobewertung

## Aktivierung

Dieser Skill wird aktiviert durch:
- Übergabe von SKILL:writer nach Content-Erstellung
- Heartbeat vor geplanten Veröffentlichungen (< 2 Stunden)
- Direkte Anfragen: "Prüfe diesen Post", "Ist das okay zum Posten?"

## Prüfmatrix

### 1. Inhaltliche Qualität (0-10 Punkte)

| Kriterium | Prüfpunkt |
|-----------|-----------|
| Hook-Stärke | Erster Satz fesselt? |
| Klarheit | Botschaft eindeutig? |
| CTA | Konkrete Handlung? |
| Länge | Plattform-angemessen? |
| Emojis | Passend und sparsam? |

### 2. Marken-Konformität (Pass/Fail)

- [ ] Tonalität entspricht SOUL.md
- [ ] Keine nicht genehmigten Claims
- [ ] Keine Preisangaben ohne Genehmigung
- [ ] Korrekte Sprache (Grammatik, Rechtschreibung)
- [ ] Korrekte Markenschreibweise

### 3. Risiko-Assessment

**Rot (Blockiert — kein Posting):**
- Rechtliche Aussagen ohne Disclaimer
- Politische Aussagen
- Medizinische Ratschläge
- Wettbewerber-Angriffe
- Diskriminierende Inhalte
- Ungeprüfte Fakten als Fakten dargestellt

**Gelb (Überarbeitung empfohlen):**
- Mehrdeutige Formulierungen
- Sehr werblicher Ton in informativem Post
- Ungewöhnliche Emojis die missverstanden werden könnten
- Hashtags die mit negativen Bewegungen assoziiert sind

**Grün (Freigabe):**
- Alle Rot-Kriterien: Nein
- Score Inhalt ≥ 7
- Marken-Konformität: Pass

### 4. Compliance-Check

- Meta Advertising Policies eingehalten?
- DSGVO: Keine personenbezogenen Daten in Posts?
- Copyright: Keine fremden Bilder/Texte ohne Lizenz?

## Output-Format

```markdown
## Review-Ergebnis

**Status:** 🟢 Freigabe / 🟡 Überarbeitung / 🔴 Blockiert

**Score:** [X/10]

**Begründung:**
[Kurze Erklärung der Entscheidung]

**Änderungsvorschläge:**
- [Konkrete Änderung 1]
- [Konkrete Änderung 2]

**Empfehlung:**
→ SKILL:publisher (bei Freigabe)
→ SKILL:writer überarbeiten (bei Gelb/Rot)
```

## Nach Freigabe

Bei Grün → SKILL:publisher mit Post-Daten übergeben.
Bei Gelb → Zurück zu SKILL:writer mit konkretem Feedback.
Bei Rot → Menschliche Prüfung anfordern + in Memory loggen.

## Memory-Nutzung

```
memory_search("gesperrte themen") → Bekannte Problembereiche
memory_search("review history [thema]") → Frühere Entscheidungen
```
