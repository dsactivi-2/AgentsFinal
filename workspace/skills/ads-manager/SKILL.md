---
name: Ads Manager
description: Erstellt, verwaltet und optimiert Meta Ads vollständig via Marketing API — aktiviert sie aber erst nach expliziter menschlicher Freigabe
---

## Trigger

- Übergabe vom Planner mit `type: paid_campaign`
- Direkte Anfragen: "Erstelle eine Ads-Kampagne", "Schalte eine Anzeige für..."
- Cron-basierte Kampagnen-Reviews (wöchentlich)

## Prinzip: Human-in-the-Loop vor Aktivierung

```
Planner → Writer → Reviewer → Ads Manager (Draft erstellen)
                                        ↓
                              Freigabe-Anfrage an Admin
                                        ↓
                         Admin: "genehmigt" / "abgelehnt"
                                        ↓
                    Aktivieren (ACTIVE) ODER Verwerfen/Anpassen
```

**Ava erstellt alles — aber aktiviert nie ohne "genehmigt" vom Admin.**

---

## Approval-Mechanismus

Freigabe läuft über Facebook Messenger an die konfigurierte Admin-PSID:

```
ENV: ADMIN_PSID = [Facebook-PSID des Eigentümers]
```

### Freigabe-Nachricht (von Ava an Admin)

```
📋 ADS-FREIGABE ANFRAGE

Kampagne: [Name]
Ziel: [Conversions / Reichweite / Leads]
Zielgruppe: [Beschreibung]
Budget: [X€/Tag] × [N Tage] = [Gesamt €]
Laufzeit: [Datum] – [Datum]
Plattform: [Facebook / Instagram / Beide]

Headline: [Ad Headline]
Text: [Ad Copy Vorschau, erste 100 Zeichen...]

Draft-ID: [marketing_api_campaign_id]

Antwort:
✅ "genehmigt" → Kampagne wird aktiviert
❌ "abgelehnt" → Kampagne wird gelöscht
✏️ "ändern: [feedback]" → Anpassungen + erneute Anfrage
```

### Admin-Antwort erkennen (Inbox Agent)

Inbox Agent erkennt Intent `admin_approval` wenn:
- Absender = `ADMIN_PSID`
- Text enthält: "genehmigt" / "abgelehnt" / "ändern:"
- Kontext: offene `pending_approval` in Memory

---

## Ablauf im Detail

### Schritt 1 — Kampagne in Meta Draft erstellen

```
POST https://graph.facebook.com/v19.0/act_{AD_ACCOUNT_ID}/campaigns
{
  "name": "[Kampagnenname]",
  "objective": "OUTCOME_LEADS",   // oder OUTCOME_AWARENESS, OUTCOME_SALES
  "status": "PAUSED",             // IMMER PAUSED — nie direkt ACTIVE
  "special_ad_categories": []
}
```

### Schritt 2 — Ad Set erstellen (Targeting + Budget)

```
POST https://graph.facebook.com/v19.0/act_{AD_ACCOUNT_ID}/adsets
{
  "name": "[Ad Set Name]",
  "campaign_id": "[campaign_id]",
  "daily_budget": [budget_in_cents],
  "billing_event": "IMPRESSIONS",
  "optimization_goal": "LEAD_GENERATION",
  "targeting": {
    "geo_locations": {"countries": ["DE", "BA", "RS", "HR"]},
    "age_min": [zielgruppe_alter_min],
    "age_max": [zielgruppe_alter_max],
    "languages": [6, 9]            // Deutsch, Englisch
  },
  "start_time": "[ISO8601]",
  "end_time": "[ISO8601]",
  "status": "PAUSED"
}
```

### Schritt 3 — Ad Creative + Ad erstellen

```
POST https://graph.facebook.com/v19.0/act_{AD_ACCOUNT_ID}/adcreatives
POST https://graph.facebook.com/v19.0/act_{AD_ACCOUNT_ID}/ads
{ ..., "status": "PAUSED" }
```

### Schritt 4 — Freigabe-Anfrage senden

Speichere in Memory:
```
pending_approval [campaign_id]: budget=[X]€ ziel=[Ziel] laufzeit=[Datum]
```

Sende Freigabe-Nachricht via meta-bridge an `ADMIN_PSID`.
Warte auf Inbox-Agent-Signal (Intent: admin_approval).

### Schritt 5a — Bei "genehmigt"

```
POST https://graph.facebook.com/v19.0/[campaign_id]
{ "status": "ACTIVE" }

POST https://graph.facebook.com/v19.0/[adset_id]
{ "status": "ACTIVE" }

POST https://graph.facebook.com/v19.0/[ad_id]
{ "status": "ACTIVE" }
```

Speichere: `"Kampagne [name] aktiviert [datum] budget=[X]€"`
Bestätige an Admin: "✅ Kampagne '[Name]' ist jetzt live."

### Schritt 5b — Bei "abgelehnt"

```
DELETE https://graph.facebook.com/v19.0/[campaign_id]
```

Speichere: `"Kampagne [name] abgelehnt [datum]"`

### Schritt 5c — Bei "ändern: [feedback]"

- Anpassungen entsprechend Feedback vornehmen
- Zurück zu Schritt 1 (Draft updaten)
- Neue Freigabe-Anfrage senden

---

## Kampagnen-Review (wöchentlich)

Laufende Kampagnen wöchentlich prüfen:
- CTR, CPC, CPL der letzten 7 Tage
- Budget-Verbrauch vs. Plan
- Wenn Performance < Erwartung: Budget anpassen oder pausieren
- Wenn Budget erschöpft: Admin-Benachrichtigung

Budget-Anpassungen (bis ±20%) darf Ava ohne Freigabe machen.
Über ±20% oder Kampagnen-Reaktivierung: Freigabe erforderlich.

---

## Umgebungsvariablen (in .env)

```
AD_ACCOUNT_ID=act_XXXXXXXXX     # Facebook Ad Account ID
META_ACCESS_TOKEN=[long-lived]  # Page/User Token mit ads_management Permission
ADMIN_PSID=XXXXXXXXX            # Facebook PSID des Eigentümers (für Approval)
```

---

## Darf nicht

- Kampagne jemals mit `status: ACTIVE` direkt erstellen
- Budget über 500€/Tag ohne explizite Freigabe setzen
- Sonderwerbekategorien (Kredit, Wohnen, Arbeit, Politik) ohne manuelle Überprüfung

---

## Qualitätskriterien

Gut, wenn:
- 0 Kampagnen ohne Freigabe aktiviert
- Freigabe-Anfrage klar, vollständig und in <30 Sekunden lesbar
- Draft-zu-Live-Zeit nach Freigabe < 2 Minuten
