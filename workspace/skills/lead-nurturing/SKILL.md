---
name: Lead Nurturing
description: Automatische Follow-up-Nachrichten an warme Leads nach 24h, 3 Tagen und 7 Tagen ohne Antwort
---
## Modell: ollama/minimax-m2.5:cloud
## Trigger

Cron: Täglich 3x — 09:00 / 13:00 / 17:00 Europe/Berlin
Aktivierung via: `ROLE:lead_nurturing`

## Zweck

Erkennt Leads die nicht auf eine Antwort reagiert haben.
Sendet zeitgesteuerte Follow-up-Nachrichten in der richtigen Sprache.
Verhindert, dass warme Kontakte verloren gehen ohne manuellen Aufwand.

**Darf nicht:** An Leads senden die opted_out = TRUE haben (consent-Tabelle prüfen).
**Darf nicht:** Mehr als 3 Follow-ups pro Lead senden.
**Darf nicht:** Ohne Reviewer-Prüfung senden.

---

## Datenbasis

Tabellen: `leads`, `lead_followups`, `consent` (PostgreSQL)

Ein Lead entsteht wenn:
- Inbox Agent einen eingehenden Kontakt als Intent=lead_interest oder Intent=offer_request klassifiziert
- und `sessions.state` auf `active` gesetzt wurde
- und der Nutzer nach der ersten Antwort nicht mehr schreibt

---

## Follow-up Timing

| Schritt | Zeitpunkt | Nachrichtentyp |
|---|---|---|
| 1 | +24h ohne Antwort | Sanfte Erinnerung + Mehrwert (Tipp, relevante Info) |
| 2 | +3 Tage ohne Antwort | Konkretes Angebot + klarer CTA |
| 3 | +7 Tage ohne Antwort | Letzter Versuch — respektvoller Abschluss |
| — | Danach | `lead_status = 'cold'` — kein weiteres Follow-up |

Wenn Nutzer antwortet: `lead_status = 'responded'` — Inbox Agent übernimmt, kein weiteres Follow-up.

---

## Ablauf (pro Cron-Run)

### Schritt 1 — Fällige Leads laden

```sql
SELECT l.*, c.opted_out
FROM leads l
JOIN consent c ON (l.psid = c.psid AND l.platform = c.platform)
WHERE l.status = 'warm'
  AND l.next_followup_at <= NOW()
  AND l.followup_count < 3
  AND c.opted_out = FALSE
ORDER BY l.next_followup_at ASC
LIMIT 50
```

Wenn 0 Leads → Cron-Run beenden, nichts tun.

### Schritt 2 — Kontext laden (pro Lead)

```
mem0: memory_search("lead [psid] preferences language interest")
PostgreSQL: letzte 5 messages WHERE psid = [psid] ORDER BY created_at DESC
```

### Schritt 3 — Nachricht erstellen

ROLE:writer aufrufen mit:
- Briefing: Follow-up Schritt [1/2/3], erkanntes Intent, Sprache des Leads
- Ton: warm und persönlich, kein Spam-Gefühl
- Sprache: aus Profil (BS/SR/DE/EN) — letzte bestätigte Sprache verwenden
- Inhalt je Schritt:
  - Schritt 1: "Hey, ich wollte nur kurz nachfragen..." + relevanter Tipp
  - Schritt 2: Konkretes Angebot mit Preis/Paket wenn vorhanden + CTA
  - Schritt 3: "Ich möchte dich nicht stören — falls du Fragen hast, bin ich da."

### Schritt 4 — Reviewer-Prüfung

ROLE:reviewer prüft:
- Kein Spam-Signal (keine 3 Ausrufezeichen, keine CAPS-Lock-Phrasen)
- Sprache korrekt (BS/SR nicht vermischt)
- Tonalität passt (nicht aufdringlich)
- Policy: kein ungeprüftes Preis-Versprechen

Bei Ablehnung: Lead überspringen, Fehler in `lead_followups` loggen, weiter zum nächsten.

### Schritt 5 — Senden via meta-bridge

```
POST /send
{ psid, platform, message }
```

### Schritt 6 — Status aktualisieren

```sql
-- Followup loggen
INSERT INTO lead_followups (lead_id, step, message_content, sent_at, delivered)
VALUES ([id], [1/2/3], [text], NOW(), TRUE);

-- Lead aktualisieren
UPDATE leads SET
  followup_count = followup_count + 1,
  last_followup_at = NOW(),
  next_followup_at = CASE
    WHEN followup_count + 1 = 1 THEN NOW() + INTERVAL '3 days'
    WHEN followup_count + 1 = 2 THEN NOW() + INTERVAL '4 days'  -- total 7 Tage
    ELSE NULL
  END,
  status = CASE
    WHEN followup_count + 1 >= 3 THEN 'cold'
    ELSE 'warm'
  END
WHERE id = [id];
```

---

## Lead-Erstellung (durch Inbox Agent)

Inbox Agent fügt Lead ein wenn Intent=lead_interest oder Intent=offer_request erkannt:

```sql
INSERT INTO leads (psid, platform, language, first_contact_at, next_followup_at, context)
VALUES (
  [psid], [platform], [erkannte_sprache],
  NOW(),
  NOW() + INTERVAL '24 hours',
  '{"intent": "[erkannter_intent]", "topic": "[thema]"}'
)
ON CONFLICT (psid, platform) DO UPDATE SET
  status = 'warm',
  next_followup_at = LEAST(leads.next_followup_at, EXCLUDED.next_followup_at),
  updated_at = NOW();
```

---

## Lead-Status-Übergänge

```
                 Inbox Agent erkennt Lead
                           ↓
                         warm  ←──────── erneuter Kontakt
                           │
              ┌────────────┼────────────┐
              ↓            ↓            ↓
         responded      cold         opted_out
     (Inbox übernimmt)  (3x kein     (consent-Tabelle)
                        Follow-up)
```

---

## Fehlerverhalten

- meta-bridge nicht erreichbar → Lead überspringen, `next_followup_at = NOW() + 2h` (Retry)
- Reviewer lehnt ab → Lead überspringen, Fehler in `lead_followups.error` loggen
- PostgreSQL nicht erreichbar → Cron-Run komplett abbrechen, Fehler in Logs
- Lead hat bereits geantwortet (neue Nachricht seit `last_followup_at`) → Status auf `responded` setzen, kein Followup

---

## Qualitätskriterien

Gut, wenn:
- 0 Follow-ups an opted_out Leads
- 0 Follow-ups an bereits antwortenden Leads
- Reviewer-Ablehnungsrate < 10%
- Antwortrate auf Follow-ups > 5% (Signal für Tone-Optimierung)
