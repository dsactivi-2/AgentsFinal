# MEMORY_POLICY.md

## Zweck

Dieses Dokument definiert verbindlich, **was gespeichert wird, wo es gespeichert wird, wann es gespeichert wird und wann nicht**.

Es ist die operative Policy für den Speicherstack aus:

- Redis
- mem0
- Postgres
- Postiz-Analytics als externe Ausführungs-/Leistungsquelle

Die wichtigste Regel lautet:

> Nicht alles, was gesagt, gesehen oder verarbeitet wird, ist erinnerungswürdig.

---

## Speicherklassen

## 1. Redis

### Rolle

Redis hält **heißen, flüchtigen Zustand**.

### Typische Inhalte

- aktive Sessions
- letzte Nachrichten eines laufenden Dialogs
- Locks
- Debounce-Status
- Queue-Zustände
- Retry-Marker
- kurzlebige Eskalationsmarker
- temporäre Sprach-/Intent-Zustände

### TTL-Regel

Redis-Einträge sollen grundsätzlich eine Ablaufzeit haben, außer es gibt einen klaren Grund dagegen.

### Niemals Redis als

- primäre Gesprächshistorie
- finale Audit-Wahrheit
- langfristiges Profilsystem

---

## 2. mem0

### Rolle

mem0 hält **semantisch verdichtete Langzeit-Erinnerung**.

### Typische Inhalte

- bevorzugte Sprache
- Schriftpräferenz
- Tonalitätspräferenzen
- wiederkehrende Interessen
- wiederkehrende Einwände
- stabile inhaltliche Präferenzen
- verdichtete Gesprächszusammenfassungen
- erkennbare wiederkehrende Ziele eines Kontakts
- Marketing-Learnings mit langfristigem Nutzen

### mem0 ist nicht

- das vollständige Chat-Archiv
- das einzige Profilsystem
- die einzige Wahrheit für kritische Geschäftsdaten

---

## 3. Postgres

### Rolle

Postgres ist das **transaktionale und auditierbare Gedächtnis**.

### Typische Inhalte

- rohe Nachrichten
- Conversation-Metadaten
- Zustellstatus
- Antwortstatus
- Handover-Zustände
- CRM-/Lead-Zuordnungen
- Consent / Opt-in / Opt-out
- Referenzen auf Kampagnen und Posts
- technische IDs
- Fehler- und Ereignisprotokolle, soweit geschäftlich relevant

### Vorrangregel

Wenn Redis, mem0 und Postgres widersprüchliche Informationen enthalten, gilt:

> **Postgres gewinnt** für geschäftsrelevante Wahrheit.

---

## 4. Postiz-Performance-Daten

### Rolle

Postiz ist die Quelle für:

- Publishing-Ergebnisse
- Scheduling-Zustände
- Social-Analytics
- Post-Performance

Diese Daten sollen **selektiv** in Postgres und/oder mem0 verdichtet übernommen werden, aber nicht blind und unkontrolliert gespiegelt werden.

---

## Speicherentscheidungslogik

## Frage 1: Ist die Information nur für die laufende Session wichtig?

- Ja → **Redis**
- Nein → nächste Frage

## Frage 2: Muss die Information vollständig, prüfbar und auditierbar erhalten bleiben?

- Ja → **Postgres**
- Nein → nächste Frage

## Frage 3: Verbessert die Information künftige Personalisierung oder Entscheidungsqualität über längere Zeit?

- Ja → **mem0**
- Nein → nicht speichern oder nur temporär halten

---

## Write Policy

Bevor etwas geschrieben wird, muss mindestens implizit diese Prüfung gelten:

1. **Nützlichkeit**
   - Wird die Information später wahrscheinlich gebraucht?
2. **Dauerhaftigkeit**
   - Ist sie in Tagen/Wochen noch relevant?
3. **Datentyp**
   - Rohdaten, Status, semantische Erkenntnis oder Audit?
4. **Speicherklasse**
   - Redis, mem0 oder Postgres?
5. **Sensibilität**
   - Darf sie überhaupt gespeichert werden?
6. **Rauschen**
   - Ist das nur temporärer Smalltalk oder operativer Lärm?

---

## Was explizit gespeichert werden soll

## In Redis

- aktiver Sprachzustand einer Unterhaltung
- letzte relevante Dialogschritte
- temporäre Intent-Klassifikation
- offene Tool- oder Workflow-Zustände
- Rate-Limit-/Debounce-Zustand
- aktive Handover-Sperren

## In mem0

- `preferred_language`
- `script_preference`
- `brand_tone_preference`
- stabile Produktinteressen
- häufige Einwände
- bevorzugte Kommunikationsform
- nützliche Zusammenfassungen vergangener Gespräche
- Learnings, welche Antwortstile bei einer Person funktionieren
- Learnings, welche Content-Muster für definierte Zielgruppen funktionieren

## In Postgres

- vollständige Inbound-/Outbound-Nachrichten
- Konversations-IDs
- Plattform-/Kanalinformationen
- technische Zustellereignisse
- Eskalations- und Handover-Zustände
- Einwilligungen und Opt-outs
- Zuordnungen zu Kampagnen/Posts/Leads
- Fehlerprotokolle mit Geschäftsrelevanz

---

## Was nicht gespeichert werden soll

- irrelevanter Smalltalk ohne Wiederverwendungswert
- doppelte Speicherung desselben Inhalts ohne Zweck
- jede einzelne Roh-Nachricht zusätzlich in semantischem Memory
- hochsensible Informationen ohne klare Notwendigkeit und Legitimation
- spontane Vermutungen über Personen als dauerhafte Wahrheit

---

## Sprach- und Identitätsregeln

## Profilfelder

Für Kontakte sollen mindestens diese Felder modellierbar sein:

- `preferred_language`
- `script_preference`
- `formality_level`
- `fallback_language`
- `brand_tone`
- `last_confirmed_language`
- `language_confidence`

## Sprachspeicherung

- Sprache möglichst in der **tatsächlich bestätigten oder klar erkannten Form** speichern
- Bosnisch und Serbisch nicht unüberlegt zusammenwerfen
- Schriftpräferenz getrennt speichern

## Priorität bei Sprache

1. explizit bestätigte Nutzeraussage
2. `last_confirmed_language`
3. konsistente Postgres-Historie
4. mem0-Kontext
5. Redis nur für aktuelle Session

## Revalidierungsregel

Sprachpräferenzen sollen neu bestätigt oder neu bewertet werden, wenn:

- der Nutzer wiederholt in einer anderen Sprache schreibt
- die vorhandene Sprachannahme mehrfach nicht mehr passt
- längere Zeit vergangen ist und neue Interaktion anders aussieht

## Keine Identitätsfiktionen

Das System soll keine unbestätigten Annahmen als dauerhafte Profilwahrheit speichern.

---

## Gesprächszusammenfassungen

## Regel

Es soll nicht jeder Turn in mem0 landen.

Stattdessen:

1. Rohverlauf in Postgres
2. aktiver kurzer Verlauf in Redis
3. periodische oder ereignisbasierte Verdichtung in mem0

## Gute Zusammenfassungen enthalten

- Hauptanliegen
- stabile Präferenzen
- relevante Einwände
- bisher funktionierende Antwortmuster
- offene Themen mit längerem Nutzen

## Schlechte Zusammenfassungen enthalten

- unnötigen Smalltalk
- Rauschen
- zu viele wortwörtliche Zitate
- temporäre technische Zustände

---

## Marketing- und Performance-Memory

## Trennung von Personen-Memory und Kampagnen-Memory

Diese beiden Bereiche dürfen nicht vermischt werden.

### Personen-Memory

Bezieht sich auf einen konkreten Nutzer/Kontakt.

### Kampagnen-/Content-Memory

Bezieht sich auf:

- Hook-Performance
- CTA-Performance
- Timing-Learnings
- Sprachvarianten-Performance
- Format-Performance
- Zielgruppensignale

### Empfehlung

Kampagnen-Learnings zuerst in Postgres oder strukturierter Form halten und nur verdichtet in mem0 überführen.

### Aging-Regel für Kampagnen-Learnings

Nicht jedes frühere Performance-Muster bleibt dauerhaft gültig. Kampagnen-Learnings sollen regelmäßig auf Aktualität geprüft werden, besonders wenn:

- sich Zielgruppe oder Kanal ändert
- neue Kampagnenphasen beginnen
- saisonale Muster wechseln
- mehrere aktuelle Ergebnisse der alten Regel widersprechen

---

## Sensibilitätsregeln

## Grundsatz

Je sensibler die Information, desto höher die Hürde zur Speicherung.

## Regel

Nicht speichern ohne klaren Zweck:

- besonders sensible persönliche Details
- unnötige Identitätsattribute
- Daten ohne Personalisierungs- oder Geschäftsnutzen

## Eskalation

Wenn unklar ist, ob etwas gespeichert werden darf:

- nicht in mem0 schreiben
- ggf. nur in kontrolliertem operativem Kontext halten
- Human Review anfordern

---

## Lösch- und Vergessensregeln

## Redis

- standardmäßig mit TTL
- abgelaufene Zustände automatisch löschen

## mem0

- veraltete oder falsche Präferenzen korrigierbar halten
- bei bestätigter Falschheit überschreiben oder entfernen
- keine ewige Speicherung ohne Relevanzprüfung

## Postgres

- Löschungen nur kontrolliert und nachvollziehbar
- Audit- und Compliance-Anforderungen berücksichtigen
- Opt-out-Status darf nicht versehentlich entfernt werden

---

## Konfliktregeln

## Wenn Daten widersprüchlich sind

### Sprache

1. explizit bestätigte aktuelle Aussage des Nutzers gewinnt
2. danach `last_confirmed_language`
3. danach konsistente Postgres-Historie
4. danach mem0
5. Redis nur für aktuelle Session

### Gesprächsstatus

1. Postgres gewinnt
2. Redis nur für Live-Orchestrierung

### Präferenzen

1. explizite aktuelle Aussage des Nutzers gewinnt
2. danach mem0
3. ältere Historie nur als Kontext

---

## Qualitätskontrolle vor Memory-Schreiben

Vor dem Schreiben in mem0 soll ein Review stattfinden – durch Regelwerk oder Agent:

### Prüffragen

- ist die Information längerfristig nützlich?
- ist sie sprachlich korrekt genug?
- ist sie bestätigt oder nur vermutet?
- gehört sie wirklich in Langzeit-Memory?
- ist sie datenschutzseitig vertretbar?

Wenn eine dieser Fragen kritisch ist, nicht schreiben.

---

## Beispiele

## Beispiel 1: Nutzer schreibt auf Bosnisch und fragt wiederholt nach Preisen

- Rohnachrichten → Postgres
- aktueller Dialogzustand → Redis
- stabile Präferenz `preferred_language=bs` → mem0
- wiederkehrendes Thema „preisfokussiert“ → mem0, wenn mehrfach bestätigt

## Beispiel 2: Nutzer sagt nur „ok hvala“

- Rohnachricht → Postgres
- Redis kurz für Session
- nicht in mem0 speichern

## Beispiel 3: Kampagne zeigt, dass bosnische Hooks am Abend besser performen

- Performance-Daten → Postiz / Postgres
- verdichtetes Learning → mem0 oder strukturierte Regelbasis

## Beispiel 4: Nutzer möchte keine weiteren Nachrichten

- Opt-out → Postgres als harte Wahrheit
- Redis ggf. sofortige Sperre
- mem0 optional nur als abgeleitete Erinnerung, aber nicht als alleinige Wahrheit

---

## TTL- und Retention-Empfehlungen

## Redis

- Session-State: kurz
- Locks: sehr kurz
- Retry-Marker: nur so lang wie operativ nötig

## mem0

- keine ungeprüfte unendliche Speicherung
- periodische Relevanzprüfung
- veraltete Präferenzen bereinigen

## Postgres

- gemäß Betriebs-, Audit- und Compliance-Anforderungen
- nicht willkürlich aufräumen

---

## Definition of Good Memory

Gutes Memory ist:

- nützlich
- knapp
- korrekt
- wiederverwendbar
- zustandsklar
- nicht redundant
- nicht spekulativ

Schlechtes Memory ist:

- laut
- doppelt
- unklar
- unbestätigt
- überempfindlich
- voller Smalltalk

---

## Schlussregel

Wenn unklar ist, ob etwas gespeichert werden soll:

- zuerst **nicht** in Langzeit-Memory schreiben,
- lieber in Postgres protokollieren,
- oder nur kurzzeitig in Redis halten,
- und erst nach Bestätigung oder Verdichtung in mem0 übernehmen.
