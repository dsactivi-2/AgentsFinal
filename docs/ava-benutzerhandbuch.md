# AVA — Dein KI-Marketing-Assistent
## Vollständiges Benutzerhandbuch

**Für wen ist dieses Handbuch?**
Dieses Handbuch erklärt dir Schritt für Schritt, wie du mit Ava arbeitest.
Du brauchst kein technisches Wissen und kein Marketing-Studium.
Alles wird so einfach erklärt, dass du sofort loslegen kannst.

---

# INHALTSVERZEICHNIS

| Kapitel | Thema | Seite |
|---------|-------|-------|
| 1 | Was ist Ava? — Dein KI-Assistent vorgestellt | 3 |
| 2 | Die 4 Adressen deines Systems | 4 |
| 3 | Erster Login — So startest du | 5 |
| 4 | Das OpenClaw Dashboard — Ava steuern | 6 |
| 5 | Mit Ava chatten — Befehle & Beispiele | 8 |
| 6 | Content-Pläne — So plant Ava deine Posts | 10 |
| 7 | Einen Plan genehmigen oder ablehnen | 12 |
| 8 | Postiz — Deinen Content-Kalender verwalten | 14 |
| 9 | Social-Media-Accounts verbinden | 16 |
| 10 | Automatische Aufgaben (Cron-Jobs) einrichten | 18 |
| 11 | Lead-Management — Kundenanfragen mit Ava | 20 |
| 12 | Auswertungen — Was funktioniert gut? | 22 |
| 13 | Häufige Probleme & Lösungen | 23 |
| 14 | Wichtige Zugangsdaten — Übersicht | 25 |

---

---

# Seite 3 — Kapitel 1: Was ist Ava?

## Ava ist deine digitale Marketing-Mitarbeiterin

Stell dir vor, du hast eine Mitarbeiterin, die:
- **Rund um die Uhr** für dich arbeitet
- Automatisch **Instagram- und Facebook-Posts** plant und veröffentlicht
- Auf **Nachrichten von Kunden** antwortet
- **Wöchentliche Content-Pläne** erstellt und dir zur Genehmigung vorlegt
- Sich selbst verbessert und aus Fehlern lernt

Das ist Ava.

## Was Ava NICHT macht (ohne deine Erlaubnis)

Ava veröffentlicht **niemals** einen Post ohne dein OK.
Sie zeigt dir immer zuerst den Plan und wartet auf deine Genehmigung.
**Du hast immer das letzte Wort.**

## Wie kommunizierst du mit Ava?

Du hast zwei Möglichkeiten:
1. **Per Facebook Messenger** — schreib einfach an deine Page
2. **Per Dashboard** — über die Weboberfläche am Computer

---

---

# Seite 4 — Kapitel 2: Die 4 Adressen deines Systems

## Deine wichtigsten Links

---

### 🗓️ Link 1 — Postiz (Content-Kalender)
```
https://marki.ac.activi.io
```
**Was ist das?** Hier siehst du alle geplanten Posts in einem Kalender.
Wie ein digitaler Redaktionsplan.

---

### 🤖 Link 2 — Ava Dashboard (Steuerung)
```
https://oc.marki.ac.activi.io/#token=5d936f9c51be19d5d6b912092dd7dd2573e3a11f3d2c2d5de028f7c08804585f
```
**Was ist das?** Hier sprichst du direkt mit Ava, siehst ihre Aufgaben und steuerst das System.

---

### 📱 Link 3 — Facebook Webhook (nur für Meta)
```
https://meta.marki.ac.activi.io/webhook
```
**Was ist das?** Diese Adresse empfängt Nachrichten von Facebook/Instagram.
Du rufst diese Adresse **nicht selbst auf** — Facebook nutzt sie automatisch.

---

### 🔒 Link 4 — Ava Dashboard (sicher, nur im Büro-Netzwerk)
```
https://hetzner4-marki.tail47b17c.ts.net/#token=5d936f9c51be19d5d6b912092dd7dd2573e3a11f3d2c2d5de028f7c08804585f
```
**Was ist das?** Gleich wie Link 2, aber nur erreichbar wenn du im Tailscale-Netzwerk bist. Sicherer.

---

### 🔑 Dein Dashboard-Token (Passwort)
```
5d936f9c51be19d5d6b912092dd7dd2573e3a11f3d2c2d5de028f7c08804585f
```
Diesen Token brauchst du, wenn du das Dashboard manuell öffnest (ohne den Link oben).

---

---

# Seite 5 — Kapitel 3: Erster Login

## Postiz zum ersten Mal öffnen

**Schritt 1:** Öffne im Browser: `https://marki.ac.activi.io`

**Schritt 2:** Du siehst die Postiz-Anmeldeseite. Klicke auf **"Create Account"**

**Schritt 3:** Gib deine E-Mail-Adresse und ein Passwort ein

**Schritt 4:** Klicke auf **"Create Account"**

**Schritt 5:** Du bist jetzt eingeloggt und siehst das Dashboard

> 💡 **Tipp:** Merk dir dein Passwort gut — du brauchst es bei jedem Login.

---

## OpenClaw Dashboard zum ersten Mal öffnen

**Schritt 1:** Öffne den Dashboard-Link aus Kapitel 2 (Link 2)

**Schritt 2:** Du siehst das Verbindungsfenster mit dem OpenClaw-Logo

**Schritt 3:** Der Token ist bereits eingetragen (Teil des Links)

**Schritt 4:** Klicke auf **"Verbinden"**

**Schritt 5:** Beim allerersten Mal erscheint "pairing required"
→ Das ist normal. Schreib deinem Administrator — er genehmigt dein Gerät.
→ Danach klappt die Verbindung sofort.

**Schritt 6:** Du siehst jetzt das Dashboard mit Ava

---

---

# Seite 6 — Kapitel 4: Das OpenClaw Dashboard — Übersicht

## So sieht das Dashboard aus

```
┌─────────────────┬──────────────────────────────────────┐
│  LINKE SEITE    │         RECHTE SEITE                 │
│  (Navigation)   │         (Inhalt)                     │
│                 │                                      │
│  OpenClaw       │  [Chat mit Ava]                      │
│  ──────────     │                                      │
│  📊 Übersicht   │  Du schreibst hier...                │
│  💬 Chat        │                                      │
│  📅 Kalender    │                                      │
│  👥 Kontakte    │                                      │
│  ⚙️ Einstellungen│                                     │
│                 │                                      │
└─────────────────┴──────────────────────────────────────┘
```

---

## Die wichtigsten Bereiche erklärt

---

### 📊 Übersicht
Was du siehst: Aktuelle System-Informationen, letzte Aktivitäten von Ava, Status der Verbindungen.

**Wann nutzt du das?** Wenn du schnell prüfen willst, ob alles läuft.

---

### Seite 7

### 💬 Chat
Was du siehst: Ein Chatfenster — wie WhatsApp, aber mit Ava.

**Wann nutzt du das?** Immer, wenn du Ava etwas fragen oder beauftragen möchtest.

**Beispiel:**
- Du: "Was posten wir diese Woche?"
- Ava: Erstellt sofort einen Vorschlag

---

### 📅 Geplante Aufgaben
Was du siehst: Alle automatischen Jobs (täglich, wöchentlich, stündlich).

**Wann nutzt du das?** Wenn du Ava sagen willst, wann sie bestimmte Aufgaben erledigen soll.

---

### ⚙️ Einstellungen → Communications (Kommunikation)
Was du siehst: Alle verbundenen Kanäle (Facebook, Instagram, Telegram, etc.)

**Wann nutzt du das?** Wenn du einen neuen Kanal verbinden willst.

---

### ⚙️ Einstellungen → Konfiguration
Was du siehst: Technische Einstellungen für Ava.

**Wann nutzt du das?** Selten — nur wenn du das Modell oder Gateway-Einstellungen ändern willst.

---

---

# Seite 8 — Kapitel 5: Mit Ava chatten

## So schreibst du mit Ava

Öffne das Dashboard → Klicke links auf **"Chat"**

Du siehst oben **"main"** (das ist Ava) und das Modell **"minimax-m2.5:cloud"**

Schreibe deine Nachricht unten und drücke Enter.

---

## Die wichtigsten Befehle und was sie auslösen

### 📅 Content-Planung

| Was du schreibst | Was Ava macht |
|-----------------|---------------|
| `"Was posten wir diese Woche?"` | Erstellt sofort einen 7-Tage-Plan |
| `"Erstelle einen Plan für die nächsten 2 Wochen"` | Erstellt einen 14-Tage-Plan |
| `"Plane Content für Ramadan"` | Erstellt einen thematischen Ramadan-Plan |
| `"Erstelle einen Plan für [Thema]"` | Plan zu deinem Wunschthema |

---

### 📊 Auswertungen

| Was du schreibst | Was Ava macht |
|-----------------|---------------|
| `"Wie laufen unsere Posts?"` | Gibt dir eine Auswertung der letzten Posts |
| `"Was hat letzte Woche gut funktioniert?"` | Zeigt Top-Posts und Insights |
| `"Welche Hashtags performen am besten?"` | Hashtag-Analyse |

---

### Seite 9

### 👥 Kunden & Leads

| Was du schreibst | Was Ava macht |
|-----------------|---------------|
| `"Welche neuen Leads haben wir?"` | Zeigt alle neuen Kundenanfragen |
| `"Schreib [Kunde] eine Follow-up Nachricht"` | Sendet automatisch eine Nachricht |
| `"Wer hat noch keine Antwort bekommen?"` | Zeigt offene Anfragen |

---

### ✏️ Content erstellen

| Was du schreibst | Was Ava macht |
|-----------------|---------------|
| `"Schreib einen Instagram-Post über [Thema]"` | Erstellt Caption + Hashtags |
| `"Schreib das auf Bosnisch/Deutsch/Serbisch"` | Übersetzt den Post |
| `"Mach den Post kürzer"` | Kürzt den Text |
| `"Mach das formeller/lockerer"` | Passt den Ton an |

---

### 🔧 Steuerung

| Was du schreibst | Was Ava macht |
|-----------------|---------------|
| `/new` | Startet eine neue Unterhaltung (vergisst den bisherigen Kontext) |
| `/reset` | Setzt die Session zurück |
| `"Was hast du heute gemacht?"` | Ava gibt dir eine Zusammenfassung |

---

## Auch per Facebook Messenger!

Wenn deine Meta-Keys eingetragen sind, kannst du Ava auch direkt per Messenger auf deiner Facebook-Page anschreiben. Gleiche Befehle, gleiche Funktionen.

---

---

# Seite 10 — Kapitel 6: Content-Pläne mit Ava

## Wie funktioniert der automatische Content-Plan?

Ava erstellt automatisch jeden Montag morgen um 09:00 Uhr einen Plan für die nächsten 1-2 Wochen.

**Ablauf:**

```
Montag 09:00 Uhr
       ↓
Ava analysiert: letzte Posts, was hat gut funktioniert,
                Feiertage, aktuelle Trends
       ↓
Ava erstellt: Plan für 14 Posts (1 pro Tag)
       ↓
Ava schickt dir: Freigabe-Anfrage per Messenger
       ↓
Du antwortest: ✅ genehmigt / ✏️ ändern / ❌ ablehnen
       ↓
Bei Genehmigung: Ava postet automatisch nach Zeitplan
```

---

## So sieht eine Freigabe-Anfrage aus

Du bekommst im Facebook Messenger eine Nachricht von Ava:

```
📅 CONTENT-PLAN FREIGABE [18.03.2026 – 31.03.2026]

KW 12 – KW 13 — 14 Posts

Mo 18.03.: Instagram Bild — "Frühlingsangebote: 3 Tipps für..."
Di 19.03.: Instagram Reel — "Hinter den Kulissen bei uns"
Mi 20.03.: Facebook Text — "Warum unsere Kunden uns lieben"
Do 21.03.: Instagram Story-Idee — "Umfrage: Was wollt ihr sehen?"
Fr 22.03.: Instagram Bild — "Wochenend-Special: ..."
...

Antwort:
✅ "plan genehmigt" → Ava postet vollautomatisch
✏️ "ändern: [dein Feedback]" → Plan wird angepasst
❌ "plan ablehnen" → kein Posting diese Woche
```

---

### Seite 11

## Was Ava bei der Planung berücksichtigt

### Die 70/30-Regel
- **70% der Posts:** Mehrwert, Tipps, Geschichten, Community-Inhalte
- **30% der Posts:** Produkte, Angebote, direkte Werbung

**Warum?** Zu viel Werbung nervt Follower. Die Mischung sorgt für echtes Engagement.

---

### Feiertage und Events
Ava kennt automatisch:
- Ramadan, Eid al-Fitr, Bairam
- Weihnachten, Ostern
- Nationale Feiertage (Deutschland, Bosnien, Serbien)

An diesen Tagen erstellt Ava passende thematische Posts.

---

### Content-Typen
Ava wechselt automatisch zwischen:

| Typ | Beschreibung |
|-----|-------------|
| **Bild-Post** | Foto mit Caption und Hashtags |
| **Reel-Konzept** | Idee für ein kurzes Video (Skript) |
| **Story-Idee** | Vorschlag für eine 24h-Story |
| **Text-Post** | Längerer informativer Text (gut für Facebook) |
| **Karussell-Idee** | Mehrere Bilder mit Story-Struktur |

---

### Sprachen
Ava schreibt Posts in:
- **Deutsch**
- **Bosnisch/Serbisch (Lateinschrift)**
- Auf Wunsch: Englisch oder andere Sprachen

---

---

# Seite 12 — Kapitel 7: Plan genehmigen oder ablehnen

## Antwort per Facebook Messenger

Wenn du die Freigabe-Anfrage per Messenger bekommst, hast du 3 Optionen:

---

### Option 1 — ✅ Plan genehmigen

**Schreibe:** `plan genehmigt`

**Was passiert dann:**
- Ava beginnt sofort mit dem Ausformulieren aller Posts
- Posts werden in Postiz eingeplant
- Jeden Tag zur geplanten Zeit wird automatisch gepostet
- Du musst nichts weiter tun

---

### Option 2 — ✏️ Plan ändern

**Schreibe:** `ändern: [dein Feedback]`

**Beispiele:**
- `ändern: Montag soll ein Reel sein, kein Bild`
- `ändern: Weniger Werbeposts, mehr Tipps`
- `ändern: Bitte auf Bosnisch schreiben`
- `ändern: Den Post über Ramadan verschieben auf Freitag`

**Was passiert dann:**
- Ava passt den Plan an
- Du bekommst den überarbeiteten Plan zur erneuten Genehmigung

---

### Seite 13

### Option 3 — ❌ Plan ablehnen

**Schreibe:** `plan ablehnen`

**Was passiert dann:**
- Diese Woche werden keine Posts veröffentlicht
- Nächste Woche erstellt Ava automatisch einen neuen Plan

---

## Was passiert wenn du nicht antwortest?

| Zeitraum | Was Ava macht |
|----------|---------------|
| Nach 48 Stunden ohne Antwort | Ava schickt eine Erinnerung |
| Nach 96 Stunden ohne Antwort | Plan wird verworfen, neue Planung nächste Woche |

---

## Plan manuell anfordern

Du musst nicht auf Montag warten. Schreibe Ava jederzeit:

`"Erstelle sofort einen neuen Content-Plan"`

Ava erstellt den Plan und schickt dir direkt die Freigabe-Anfrage.

---

## Post nachträglich bearbeiten

Auch nach der Genehmigung kannst du einzelne Posts anpassen:
1. Öffne `https://marki.ac.activi.io` (Postiz)
2. Klicke auf den Post im Kalender
3. Bearbeite Text, Bild oder Zeitpunkt
4. Klicke **"Save"**

---

---

# Seite 14 — Kapitel 8: Postiz — Dein Content-Kalender

## Was ist Postiz?

Postiz ist dein visueller Redaktionsplan. Hier siehst du auf einen Blick:
- Welche Posts wann veröffentlicht werden
- Was bereits gepostet wurde
- Was noch als Entwurf wartet

Adresse: `https://marki.ac.activi.io`

---

## Die Hauptbereiche in Postiz

### 📅 Kalender-Ansicht
Zeigt alle Posts in einer Monatsübersicht.
- **Grün** = Veröffentlicht
- **Blau** = Geplant
- **Grau** = Entwurf

**So öffnest du den Kalender:**
Dashboard → linke Sidebar → **"Calendar"**

---

### 📋 Listen-Ansicht (Posts)
Zeigt alle Posts als Liste.
Dashboard → linke Sidebar → **"Posts"**

---

### Seite 15

## Manuell einen Post erstellen

**Schritt 1:** Klicke oben rechts auf **"+ New Post"**

**Schritt 2:** Schreibe deinen Text in das große Textfeld

**Schritt 3:** Lade ein Bild oder Video hoch (optional)
→ Klicke auf das Bild-Symbol

**Schritt 4:** Wähle die Plattform(en) aus
→ Instagram, Facebook, oder beide gleichzeitig

**Schritt 5:** Wähle Datum und Uhrzeit
→ Klicke auf **"Schedule for"** und wähle den Zeitpunkt

**Schritt 6:** Klicke auf **"Schedule"**
→ Der Post erscheint jetzt im Kalender

---

## Einen geplanten Post bearbeiten

**Schritt 1:** Öffne den Kalender

**Schritt 2:** Klicke auf den Post den du ändern willst

**Schritt 3:** Bearbeite was du möchtest (Text, Bild, Zeit)

**Schritt 4:** Klicke **"Save"**

---

## Einen Post löschen

**Schritt 1:** Klicke auf den Post im Kalender

**Schritt 2:** Klicke auf die drei Punkte (**...**) oder das Papierkorb-Symbol

**Schritt 3:** Bestätige die Löschung

---

## Einen Post sofort veröffentlichen

**Schritt 1:** Erstelle den Post wie oben beschrieben

**Schritt 2:** Statt "Schedule" klicke auf **"Post Now"**

---

---

# Seite 16 — Kapitel 9: Social-Media-Accounts verbinden

## Warum musst du Accounts verbinden?

Ohne Verbindung kann Postiz nicht automatisch posten.
Die Verbindung machst du einmalig — danach läuft alles automatisch.

---

## Instagram verbinden

**Voraussetzung:** Du brauchst ein **Instagram Business-Konto** (kein privates Konto).

**Schritt 1:** Öffne Postiz (`https://marki.ac.activi.io`)

**Schritt 2:** Gehe zu **Settings → Channels**

**Schritt 3:** Klicke auf **"Add Channel"**

**Schritt 4:** Wähle **"Instagram"**

**Schritt 5:** Du wirst zu Facebook/Instagram weitergeleitet

**Schritt 6:** Logge dich mit deinen Facebook-Zugangsdaten ein

**Schritt 7:** Erlaube Postiz den Zugriff (alle Häkchen setzen)

**Schritt 8:** Wähle deine Instagram-Seite aus

**Schritt 9:** Klicke **"Connect"**

✅ Instagram ist jetzt verbunden.

---

### Seite 17

## Facebook verbinden

**Schritt 1:** Gehe zu **Settings → Channels → Add Channel**

**Schritt 2:** Wähle **"Facebook"**

**Schritt 3:** Logge dich mit Facebook ein

**Schritt 4:** Wähle deine Facebook-Seite (Page) aus

**Schritt 5:** Klicke **"Connect"**

✅ Facebook ist jetzt verbunden.

---

## Weitere Plattformen verbinden

Gleicher Ablauf für:
- **TikTok** → TikTok-Login nötig
- **LinkedIn** → LinkedIn-Login nötig
- **X (Twitter)** → Twitter/X-Login nötig
- **YouTube** → Google-Login nötig
- **Pinterest** → Pinterest-Login nötig

---

## Verbindung prüfen

**Settings → Channels** zeigt dir alle verbundenen Accounts.

Grüner Punkt = Verbindung aktiv ✅
Roter Punkt = Verbindung unterbrochen — erneut verbinden

---

## Was tun wenn die Verbindung abbricht?

Social-Media-Plattformen beenden manchmal die Verbindung aus Sicherheitsgründen.

**Lösung:**
1. **Settings → Channels**
2. Klicke auf das betroffene Konto
3. Klicke **"Reconnect"**
4. Logge dich erneut ein

---

---

# Seite 18 — Kapitel 10: Automatische Aufgaben (Cron-Jobs)

## Was sind automatische Aufgaben?

Ava erledigt bestimmte Aufgaben automatisch zu festen Zeiten — ohne dass du etwas tun musst. Du kannst diese Zeiten anpassen oder Aufgaben manuell starten.

---

## Übersicht der automatischen Aufgaben

| Aufgabe | Wann | Was Ava macht |
|---------|------|---------------|
| **Tagesplanung** | Täglich 09:00 Uhr | Prüft ob Tagesplan vorhanden, erstellt falls nötig |
| **Wochenplanung** | Montag 09:00 Uhr | Erstellt 2-Wochen Content-Plan, schickt Freigabe-Anfrage |
| **Lead Follow-up** | Täglich 10:00 Uhr | Schickt Follow-up-Nachrichten an Interessenten |
| **Wochenauswertung** | Montag 08:00 Uhr | Analysiert letzte Woche, gibt Empfehlungen |
| **Selbstreflexion** | Täglich 23:00 Uhr | Ava analysiert ihren Tag, verbessert sich selbst |
| **Memory-Pflege** | Sonntag 02:00 Uhr | Bereinigt und organisiert das Gedächtnis |
| **Heartbeat** | Jede 60 Minuten | Systemcheck — stellt sicher, dass alles läuft |
| **Inbox-Check** | Alle 15 Minuten | Prüft neue Nachrichten auf Facebook/Instagram |

---

### Seite 19

## Aufgaben im Dashboard verwalten

**Schritt 1:** Öffne das Dashboard (`https://oc.marki.ac.activi.io/...`)

**Schritt 2:** Klicke links auf **"Geplante Aufgaben"**

**Schritt 3:** Du siehst eine Liste aller automatischen Aufgaben

---

### Aufgabe aktivieren/deaktivieren

Klicke auf den **Toggle-Schalter** neben der Aufgabe:
- Schalter grün = Aufgabe aktiv ✅
- Schalter grau = Aufgabe deaktiviert ⏸️

---

### Aufgabe sofort manuell starten

Klicke auf das **▶️ Play-Symbol** neben der Aufgabe.

Beispiel: Du willst sofort eine Wochenauswertung — klicke Play neben "Wochenauswertung".

---

### Zeitpunkt einer Aufgabe ändern

> ⚠️ Achtung: Zeitpunkte ändert du am besten per Chat.

Schreibe Ava:
`"Ändere die Wochenplanung auf Freitag um 15:00 Uhr"`

---

## Eine Aufgabe manuell per Chat auslösen

Statt auf Play zu klicken, kannst du Ava auch per Chat beauftragen:

| Was du schreibst | Was Ava startet |
|-----------------|-----------------|
| `"Erstelle jetzt einen Content-Plan"` | Wochenplanung |
| `"Analysiere unsere Posts der letzten Woche"` | Wochenauswertung |
| `"Prüfe neue Kundennachrichten"` | Inbox-Check |
| `"Führe die Selbstreflexion durch"` | Reflexion |

---

---

# Seite 20 — Kapitel 11: Lead-Management

## Was ist ein Lead?

Ein **Lead** ist ein potenzieller Kunde — jemand, der deiner Facebook-Page oder Instagram schreibt und Interesse an deinen Produkten/Dienstleistungen zeigt.

---

## Wie Ava mit Leads umgeht

```
Kunde schreibt an deine Facebook-Page
           ↓
Ava empfängt die Nachricht automatisch
           ↓
Ava analysiert: Was will diese Person?
           ↓
┌──────────────────────────────────────┐
│  Einfache Frage → Ava antwortet direkt│
│  Interesse an Produkt → Lead speichern│
│  Beschwerden → Ava informiert dich   │
└──────────────────────────────────────┘
           ↓
Ava schickt Follow-up nach 24h, 48h, 7 Tagen
```

---

### Seite 21

## Leads ansehen

Schreibe Ava im Chat:
`"Zeige mir alle neuen Leads"`
`"Welche Leads haben noch keine Antwort?"`
`"Zeige mir Leads vom letzten Monat"`

---

## Manuelle Nachricht an einen Lead senden

Schreibe Ava:
`"Schick [Name oder PSID] eine Nachricht: [dein Text]"`

Beispiel:
`"Schick dem Kunden vom Montag eine Nachricht: Danke für dein Interesse, wir melden uns morgen"`

---

## Follow-up-Nachrichten anpassen

Standardmäßig schickt Ava Follow-ups nach 24h, 48h und 7 Tagen.

Du kannst Ava im Chat anweisen:
`"Schick keine automatischen Follow-ups mehr an [Name]"`
`"Ändere den Follow-up-Text auf: [dein Wunschtext]"`

---

## Heißer Lead — sofortige Benachrichtigung

Wenn Ava erkennt, dass jemand stark interessiert ist (mehrere Nachrichten, konkrete Fragen nach Preis), informiert sie dich **sofort** per Messenger:

```
⚠️ HEISSER LEAD
Name/PSID: 123456789
Interesse: [Produkt]
Letzte Nachricht: "Was kostet das genau?"
→ Empfehlung: Jetzt persönlich antworten
```

---

---

# Seite 22 — Kapitel 12: Auswertungen

## Was kann Ava auswerten?

Ava analysiert automatisch die Performance deiner Posts und gibt dir verständliche Einblicke.

---

## Wochenauswertung (automatisch jeden Montag)

Du bekommst jeden Montag eine Zusammenfassung:

```
📊 WOCHENAUSWERTUNG KW 11

Top-Post: "Frühlingstipps" → 432 Likes, 89 Kommentare
Schwächster Post: "Produktvorstellung" → 23 Likes
Reichweite gesamt: 8.400 Personen
Neue Follower: +47

Empfehlung für KW 12:
• Mehr Bilder-Posts (performen 3x besser als Texte)
• Posting-Zeit ändern: 11:00 Uhr statt 09:00 Uhr
• Hashtag #frühjahr2026 hinzufügen
```

---

## Manuelle Auswertung anfordern

Schreibe Ava:
- `"Wie laufen unsere Posts diese Woche?"`
- `"Was sind unsere 3 besten Posts aller Zeiten?"`
- `"Welche Posting-Zeit bringt die meisten Likes?"`
- `"Vergleiche Instagram mit Facebook Performance"`

---

---

# Seite 23 — Kapitel 13: Häufige Probleme & Lösungen

## Problem: "Ava antwortet nicht"

**Mögliche Ursache 1:** Modell-Verbindung unterbrochen

**Lösung:** Schreibe erneut. Falls mehrfach kein Ergebnis:
1. Öffne Dashboard → Übersicht
2. Prüfe ob Gateway-Status grün ist
3. Kontaktiere deinen Administrator

---

### Seite 24

## Problem: "Post wurde nicht veröffentlicht"

**Mögliche Ursache 1:** Social-Media-Verbindung abgelaufen

**Lösung:**
1. Öffne Postiz (`https://marki.ac.activi.io`)
2. Gehe zu Settings → Channels
3. Prüfe ob alle Accounts grünen Punkt haben
4. Bei rotem Punkt: Klicke "Reconnect"

**Mögliche Ursache 2:** Plan nicht genehmigt

**Lösung:** Prüfe ob du die Freigabe-Anfrage beantwortet hast.

---

## Problem: "Ich sehe keine neuen Leads"

**Mögliche Ursache:** Facebook-Webhook nicht eingerichtet

**Lösung:** Kontaktiere deinen Administrator — der Webhook `https://meta.marki.ac.activi.io/webhook` muss bei Facebook eingetragen sein.

---

## Problem: "Dashboard zeigt 'pairing required'"

**Lösung:**
1. Klicke auf "Verbinden"
2. Kontaktiere deinen Administrator
3. Er genehmigt dein Gerät innerhalb weniger Minuten
4. Danach klappt die Verbindung sofort

---

## Problem: "Ava hat den falschen Ton getroffen"

**Lösung:** Schreibe Ava direkt:
`"Der letzte Post war zu formal. Schreib lockerer und freundlicher."`

Oder für dauerhafte Änderung:
`"Merke dir: Schreib immer locker und auf Augenhöhe mit unserer Community"`

---

## Problem: "Plan kommt nicht per Messenger"

**Mögliche Ursache:** Meta-Verbindung nicht konfiguriert (API Keys fehlen)

**Lösung:** Alternative — öffne Dashboard → Chat und schreibe:
`"Zeige mir den aktuellen Content-Plan"`

---

## Wichtige Kontakte

Bei technischen Problemen die du selbst nicht lösen kannst:
- Systemadministrator kontaktieren
- SSH-Zugang zum Server nötig (für Admin)

---

---

# Seite 25 — Kapitel 14: Wichtige Zugangsdaten

## Alle Zugangsdaten auf einen Blick

> ⚠️ **Sicherheitshinweis:** Teile diese Daten nur mit Personen, denen du vertraust.

---

### System-URLs

| Dienst | URL |
|--------|-----|
| Postiz (Content-Kalender) | `https://marki.ac.activi.io` |
| OpenClaw Dashboard | `https://oc.marki.ac.activi.io` |
| Dashboard (Tailscale) | `https://hetzner4-marki.tail47b17c.ts.net` |
| Meta Webhook | `https://meta.marki.ac.activi.io/webhook` |

---

### Dashboard-Token

```
5d936f9c51be19d5d6b912092dd7dd2573e3a11f3d2c2d5de028f7c08804585f
```

---

### Server

| Was | Wert |
|-----|------|
| Server-IP | `91.98.26.220` |
| Tailscale-IP | `100.84.189.53` |
| SSH-Befehl | `ssh hetzner4` |

---

### Noch einzutragende Keys (an Administrator übergeben)

| Key | Wo finden |
|-----|-----------|
| `META_APP_SECRET` | developers.facebook.com → App → Settings → Basic |
| `META_VERIFY_TOKEN` | Selbst wählen (beliebiger Text) |
| `META_PAGE_ACCESS_TOKEN` | developers.facebook.com → Messenger → Access Tokens |
| `ADMIN_PSID` | Einmal an Page schreiben → im Log erscheint die ID |
| `SUPERMEMORY_API_KEY` | supermemory.ai → Dashboard → API Keys |

---

---

# Schnell-Referenz (zum Ausdrucken)

```
╔══════════════════════════════════════════════════════╗
║           AVA — SCHNELL-REFERENZ                     ║
╠══════════════════════════════════════════════════════╣
║ POSTIZ:     https://marki.ac.activi.io               ║
║ DASHBOARD:  https://oc.marki.ac.activi.io            ║
║             /#token=5d936f9c...585f                  ║
╠══════════════════════════════════════════════════════╣
║ PLAN GENEHMIGEN:  "plan genehmigt"                   ║
║ PLAN ÄNDERN:      "ändern: [feedback]"               ║
║ PLAN ABLEHNEN:    "plan ablehnen"                    ║
╠══════════════════════════════════════════════════════╣
║ NEUER PLAN:  "Erstelle einen Content-Plan"           ║
║ AUSWERTUNG:  "Wie laufen unsere Posts?"              ║
║ LEADS:       "Zeige mir neue Leads"                  ║
║ RESET:       /new oder /reset                        ║
╚══════════════════════════════════════════════════════╝
```

---

*AVA Benutzerhandbuch v1.0 | Stand: März 2026 | Marki-Stack*
*Alle Seiten: 25 | Dieses Dokument ist vertraulich.*
