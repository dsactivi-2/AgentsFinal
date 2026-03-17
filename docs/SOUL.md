# SOUL.md

## Zweck

Dieses Dokument ist die zentrale Betriebs- und Architektur-Seele des Stacks. Es beschreibt **warum** der Stack existiert, **wie** er aufgebaut ist, **welche Regeln** gelten und **wie Entscheidungen** für Entwicklung, Betrieb, Sicherheit, Sprache, Memory und Social-Automation getroffen werden.

Der Stack ist ausgelegt für:

- OpenClaw als Agenten-Orchestrierung
- Postiz als Social-Publishing-, Scheduling- und Analytics-Layer
- mem0 als semantisches Langzeit-Memory
- Redis für Session-State, Queueing und kurzlebigen operativen Zustand
- Postgres als System of Record
- Meta-/Messenger-Bridge für eingehende Facebook-/Instagram-/Messenger-Nachrichten
- Bosnisch und Serbisch als Primärsprachen zusätzlich zu Deutsch/Englisch

---

## North Star

Der Stack soll **autonom, kontrollierbar, mehrsprachig, nachvollziehbar und sicher** Social-Media- und Messaging-Workflows ausführen.

### Kernziele

1. **Autonom planen**
   - Inhalte, Themen, Kampagnen und Reaktionsmuster selbstständig vorbereiten.
2. **Autonom schreiben**
   - Posts, Antworten, Varianten, CTAs und Follow-ups erzeugen.
3. **Autonom veröffentlichen**
   - Inhalte zuverlässig auf Facebook und Instagram veröffentlichen.
4. **Autonom analysieren**
   - Performance-Daten auswerten und daraus Muster erkennen.
5. **Autonom verbessern**
   - Sprache, Hooks, Zeitfenster und CTA-Strategien kontinuierlich optimieren.
6. **Nachrichten beantworten**
   - Facebook-/Messenger-/Instagram-Nachrichten in kontrollierter Form beantworten.
7. **Sprachlich lokal funktionieren**
   - Bosnisch und Serbisch sauber, natürlich und konsistent bedienen.
8. **Sicher und auditierbar bleiben**
   - Jede kritische Aktion muss nachvollziehbar, begrenzbar und kontrollierbar sein.

---

## Architektur-Prinzipien

### 1. Trennung der Zuständigkeiten

Jede Komponente hat eine klare Rolle:

- **OpenClaw** denkt, plant, entscheidet, orchestriert.
- **Postiz** publiziert, schedult, verwaltet Medien und Analytics.
- **mem0** erinnert semantisch relevante Langzeitinformationen.
- **Redis** hält heißen, flüchtigen Zustand.
- **Postgres** speichert belastbare Wahrheit und Historie.
- **Meta Bridge** verbindet externe Meta-Events mit internen Agenten.
- **Caddy** stellt öffentliche HTTPS-Endpunkte bereit.

Keine Komponente soll unnötig Funktionen einer anderen übernehmen.

### 2. Loopback-first, Public-only-when-needed

- Interne Dienste binden standardmäßig an `127.0.0.1`.
- Öffentlich exponiert werden nur Dienste, die öffentlich erreichbar sein müssen.
- Public Traffic läuft über Reverse Proxy mit TLS.

### 3. Deterministische Wahrheit statt implizites Gedächtnis

Es gibt drei Klassen von Wissen:

- **Hot State** → Redis
- **Semantic Long-Term Memory** → mem0
- **Transactional Truth / Audit** → Postgres

Niemals alles in ein einzelnes Memory-System schreiben.

### 4. Mensch vor Vollautomatik bei Risiko

Bei unklaren, kritischen oder rechtlich riskanten Fällen muss der Stack:

- abbrechen,
- eskalieren,
- oder auf Human Review umschalten.

### 5. Sprache ist Produktlogik

Bosnisch und Serbisch sind kein „nice to have“, sondern fester Bestandteil der Agentenlogik.

---

## Deployment Topology

## Betriebsmodus

Der Stack läuft im finalen Zielbild als **Hybrid-Modell**:

- **OpenClaw** läuft **nativ auf dem Host**.
- **Postiz** läuft **per Docker Compose** in seiner offiziell vorgesehenen Self-Hosting-Form.
- **Caddy** läuft **nativ auf dem Host**.
- **Meta Bridge** läuft **nativ auf dem Host**.
- **mem0** läuft **nativ auf dem Host**.
- **eigene Betriebsdaten** liegen außerhalb des Postiz-Containers in klar getrennten Datenräumen.

## Netzwerkprinzip

### Öffentlich erreichbar

Nur die Endpunkte, die öffentlich erreichbar sein müssen:

- Caddy auf 80/443
- die darüber freigegebenen Webhook- und OAuth-Endpunkte
- die öffentliche Postiz-Domain für Social-Integrationen

### Nur intern erreichbar

- OpenClaw Gateway
- mem0 API
- interne Betriebsdatenbanken
- Redis für Hot State
- interne Service-Endpunkte

## Public Endpoints vs Internal Endpoints

### Public

- `https://postiz.<domain>`
- `https://meta.<domain>/webhook`

### Internal

- `127.0.0.1`-gebundene OpenClaw-Endpunkte
- lokale mem0-Endpunkte
- interne Redis- und Postgres-Verbindungen
- interne Bridge-zu-Agent-Kommunikation

## Source of Truth Matrix

| Bereich | Primäre Wahrheit |
|---|---|
| Agenten-Orchestrierung | OpenClaw |
| Social Publishing / Scheduling / Upload / Analytics | Postiz |
| Langfristige semantische Erinnerung | mem0 |
| Flüchtiger Session- und Queue-Zustand | Redis |
| Gesprächsprotokolle, Audit, Consent, CRM-Zustand | Postgres |
| Öffentliche Meta-Ereignisse und deren technische Annahme | Meta Bridge |

## Komponentenübersicht

## OpenClaw

### Rolle

OpenClaw ist der zentrale Agenten- und Workflow-Orchestrator.

### Aufgaben

- Themenplanung
- Redaktionslogik
- Nachrichtenauswertung
- Routing zwischen Agents
- Tool-Aufrufe
- Hooks und zeitgesteuerte Abläufe
- Steuerung von Publikations- und Analysezyklen

### Nicht die Aufgabe von OpenClaw

- kein eigener Social-Publishing-Layer
- keine endgültige Source of Truth für Nachrichtenhistorie
- kein Ersatz für Analytics-Speicherung

---

## Postiz

### Rolle

Postiz ist der Social-Media-Ausführungslayer.

### Betriebsform

Postiz läuft im Zielbild **per Docker Compose**. Das ist die bewusst gewählte und dokumentationsnahe Self-Hosting-Variante.

### Aufgaben

- Facebook-/Instagram-Anbindung
- Scheduling
- Publishing
- Medien-Upload
- Analytics
- Integration/Channel-Verwaltung
- API/CLI/MCP-Zugriff für Agenten

### Grenzen

Postiz ist **nicht** der primäre Inbox- oder Messenger-Core für eingehende Facebook-/Instagram-Nachrichten. Dafür existiert im Stack eine eigene Meta Bridge mit nachgelagerter Agentenlogik.

### Warum Postiz im Stack ist

Weil Publishing, OAuth, Uploads und Analytics nicht neu erfunden werden sollen.

---

## mem0

### Rolle

mem0 ist der semantische Langzeit-Memory-Layer.

### Geeignet für

- Sprachpräferenzen
- Tonalität
- Nutzerprofile
- Einwände
- Interessen
- frühere erfolgreiche Antwortmuster
- verdichtete Gesprächszusammenfassungen
- Kampagnen-Learnings

### Nicht in mem0 speichern

- vollständige Roh-Chats als einziges Archiv
- flüchtige Session-Zustände
- Queue-Zustand
- technische Delivery-Ereignisse als alleinige Wahrheit

---

## Redis

### Rolle

Redis ist der Hot-State- und Queue-Layer.

### Topologie

Es wird logisch zwischen Redis für den Postiz-Stack und Redis für eigene operative Zustände unterschieden.

### Geeignet für

- aktive Session-Kontexte
- Debouncing
- Rate-Limits
- Locks
- temporäre Eskalationsmarker
- offene Conversation-Flows
- Retry-Queues

### Nicht geeignet für

- langfristige Business-Historie
- dauerhafte Profilwahrheit

---

## Postgres

### Rolle

Postgres ist das belastbare System of Record.

### Topologie

Es wird logisch zwischen Postgres für den Postiz-Stack und Postgres für eigene App-, Bridge-, CRM-, Audit- und Memory-nahe Daten unterschieden.

Postiz darf seine eigene Datenhaltung behalten. Eigene Betriebsdaten dürfen nicht unstrukturiert in dieselbe Verantwortung geschoben werden.

### Speichert

- eingehende Nachrichten
- ausgehende Nachrichten
- Conversation-Metadaten
- Zustellstatus
- Kampagnenzuordnung
- Consent/Opt-in/Opt-out
- Human-Handover-Zustand
- Audit-Trail
- gespeicherte Entscheidungen
- Analytics-Historie

Postgres ist die letzte Wahrheit, wenn Memory und Live-State widersprüchlich sind.

---

## Meta Bridge

### Rolle

Die Meta Bridge verbindet Meta Webhooks mit OpenClaw und den internen Speicherschichten.

### Aufgaben

- Webhook-Verifikation
- Inbound Event Processing
- Normalisierung eingehender Nachrichten
- Weitergabe an OpenClaw Hooks
- optionale Rücksendung von Antworten über Meta APIs
- Logging technischer Zustände

### Abgrenzung

Die Meta Bridge ist der Messaging-Eingang für Facebook Messenger und Instagram-bezogene Inbound-Ereignisse. Sie ersetzt weder Postiz noch OpenClaw.

### Prinzip

Die Bridge selbst soll möglichst dünn bleiben. Geschäftslogik gehört nicht hier hinein, sondern in Agenten und Services.

---

## Caddy

### Rolle

Öffentlicher TLS- und Reverse-Proxy-Layer.

### Aufgaben

- HTTPS-Termination
- Routing für öffentliche Endpunkte
- Weiterleitung an Meta Bridge und ggf. weitere öffentliche Komponenten

---

## Sprachmodell und Sprachregeln

## Primärsprachen

- Bosnisch (`bs`)
- Serbisch (`sr`)
- Deutsch (`de`)
- Englisch (`en`)

## Sprachpolitik

### Grundregeln

1. Die Antwortsprache folgt primär der Sprache des Nutzers.
2. Wenn ein Nutzerprofil existiert, überschreibt die Profilsprache die spontane Vermutung.
3. Serbisch und Bosnisch dürfen nicht unnötig vermischt werden.
4. Standardmäßig wird **lateinische Schrift** genutzt, sofern nichts anderes gespeichert ist.
5. Für Serbisch kann optional eine Präferenz für **kyrillisch** gespeichert werden.

### Profilfelder

Für Kontakte sollen mindestens diese Felder führbar sein:

- `preferred_language`
- `script_preference`
- `formality_level`
- `brand_tone`
- `fallback_language`
- `last_high_quality_response_language`

### Qualitätsregel

Wenn die Ausgabe in Bosnisch oder Serbisch sprachlich unsicher ist:

- Antwort vereinfachen,
- nicht unnötig idiomatisch werden,
- oder Human Review anfordern.

---

## Wahrheits- und Verantwortungsmatrix

### OpenClaw

- denkt
- plant
- routet
- orchestriert
- ist **nicht** die dauerhafte Audit-Wahrheit

### Postiz

- ist Wahrheit für Social-Publishing-Ausführung, Uploads, Scheduling und Analytics-Rückgaben
- ist **nicht** die alleinige Wahrheit für Messenger-Konversationen

### Postgres

- ist Wahrheit für eigene Geschäfts- und Konversationsdaten
- hat Vorrang vor Redis und mem0, wenn Zustände widersprüchlich sind

### Redis

- ist nur temporärer Zustand
- verliert gegen Postgres, wenn Konflikte auftreten

### mem0

- ist abgeleitete semantische Erinnerung
- darf nie alleinige Wahrheit für geschäftskritische Daten sein

## Betriebsregeln

## Observability

Mindestens nötig:

- strukturierte Logs pro Dienst
- Healthchecks
- Restart-Strategien
- klare Trennung von App-Logs und Proxy-Logs
- Fehler- und Retry-Sichtbarkeit

## Backups

Pflicht:

- Postgres-Backups
- Konfigurations-Backups
- Secret-Management außerhalb des Repos
- Wiederherstellungstests

## Deployments

- kleine, nachvollziehbare Changes
- Konfigurationsänderungen versionieren
- keine ad-hoc-Änderungen direkt auf Produktion ohne Dokumentation

## Service-Starts

- interne Dienste zuerst
- Bridge und öffentliche Komponenten zuletzt
- nach Änderungen Healthchecks ausführen

---

## Content- und Antwortqualität

## Content-Regeln

- Hooks müssen klar und relevant sein
- CTAs dürfen nicht beliebig sein, sondern zur Funnel-Stufe passen
- sprachliche Versionen dürfen nicht nur wörtlich übersetzt sein
- Performance-Learnings sollen zurück in Regeln und Memory fließen

## Antwortregeln im Chat

- zuerst Sprache sauber erkennen
- dann Intent bestimmen
- dann relevanten Kontext laden
- dann kurz, präzise und natürlich antworten
- nur bei Mehrwert Personalisierung verwenden

## Mehrsprachigkeit

Für Bosnisch/Serbisch gelten:

- keine erzwungene Lokalkolorierung
- keine unnötig künstlichen Slang-Elemente
- eher klar und natürlich als zu kreativ

---

## Fail-Safe-Regeln

Wenn eine Komponente ausfällt:

### OpenClaw fällt aus
- keine autonomen Entscheidungen mehr
- Webhooks puffern oder in Retry-Queue legen

### Postiz fällt aus
- keine Veröffentlichung
- Posts nur in Queue halten, nicht verlieren

### mem0 fällt aus
- Antworten weiter erlauben, aber ohne Langzeitpersonalisierung

### Redis fällt aus
- keine parallele Session-Orchestrierung ohne Schutz
- notfalls auf vereinfachten Modus schalten

### Postgres fällt aus
- keine bestätigte Business-Aktion ohne Speicherung
- riskante Aktionen stoppen

---

## Entscheidungsregeln für Architekturänderungen

Eine Änderung ist gut, wenn sie mindestens zwei der folgenden Punkte verbessert, ohne die anderen stark zu verschlechtern:

- Sicherheit
- Nachvollziehbarkeit
- Sprachqualität
- Wartbarkeit
- Time-to-Production
- Fehlertoleranz
- Beobachtbarkeit
- Datenklarheit

Keine Änderung nur einführen, weil sie „cool“ ist.

---

## Definition of Done

Eine Funktion ist erst fertig, wenn:

1. sie fachlich funktioniert,
2. sie geloggt wird,
3. sie bei Fehlern kontrolliert scheitert,
4. sie in BS/SR keine sprachliche Katastrophe erzeugt,
5. sie die richtige Speicherklasse nutzt,
6. sie keine unnötigen Daten schreibt,
7. sie im Audit nachvollziehbar ist.

---

## Nicht-Ziele

Dieser Stack soll **nicht** sein:

- ein monolithisches All-in-One-System
- ein ungeprüfter Full-Autopilot ohne Eskalation
- ein ungeordnetes Sammelbecken für alle Daten in einem Vector Store
- ein Setup, das Plattformrichtlinien ignoriert

---

## Praktische Kurzform

### Wenn unklar ist, wohin etwas gehört:

- **aktive Session?** → Redis
- **dauerhafte Wahrheit?** → Postgres
- **nützliche langfristige semantische Erinnerung?** → mem0
- **Publishing / Scheduling / Analytics?** → Postiz
- **Denken / Planen / Routing?** → OpenClaw
- **öffentliche Meta-Ereignisse?** → Meta Bridge über Caddy

---

## Schlussprinzip

Der Stack soll nicht maximal komplex, sondern **maximal klar** sein.

Jede Komponente muss einen eindeutigen Zweck haben. Jede gespeicherte Information muss begründbar sein. Jede autonome Antwort muss kontrollierbar bleiben. Jede Sprachversion muss bewusst erzeugt werden. Jede Optimierung muss messbar zu besserer Qualität, Stabilität oder Conversion führen.
