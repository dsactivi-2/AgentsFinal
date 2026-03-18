# MEMORY — Initialer Agent-Kontext

Diese Datei enthält das Startwissen des Agenten.
Sie wird beim ersten Start geladen und durch Erfahrungen ergänzt.

## System-Konfiguration

- **Stack:** Social AI Stack v2 — OpenClaw + Meta Bridge + mem0 + Postiz
- **Agent:** Ava (main) — 1 Agent, 9 Skills
- **Plattformen:** Facebook Messenger, Instagram Direct
- **Memory-Backend:** Supermemory.ai (containerTag: social-ai-stack)
- **Posting-Tool:** Postiz (via API/MCP)
- **Sprachen:** BS, SR, DE, EN

## Wichtige URLs & Dienste (intern)

- **Meta Bridge:** http://127.0.0.1:8085
- **mem0-API:** http://127.0.0.1:8010
- **Postiz:** http://127.0.0.1:4200 (oder gemäß Docker-Compose)
- **OpenClaw Hook:** http://127.0.0.1:18789/hooks/meta

## Content-Richtlinien

### Was gepostet wird
- Authentischer Content der Marke
- Mix: Informativ 40%, Unterhaltsam 30%, Werblich 20%, Community 10%
- Sprache: Primär DE + BS/SR je nach Zielgruppe
- Hashtags: Max. 10-15 (Instagram), keine (Facebook)

### Was NICHT gepostet wird
- Politisch polarisierende Inhalte
- Ungeprüfte Fakten oder Clickbait
- Direkte Angriffe auf Wettbewerber
- Inhalte die rechtliche Prüfung benötigen ohne Reviewer-Freigabe

## Posting-Zeiten (Best Practices)

| Plattform | Beste Zeiten | Schlechteste Zeiten |
|-----------|-------------|---------------------|
| Instagram | Di-Fr 08-10, 18-20 Uhr | Mo früh, So spät |
| Facebook  | Di-Do 09-11, 13-16 Uhr | Sa/So |

## Eskalations-Trigger

Eskaliere SOFORT an Mensch bei:
- Nutzer nennt Selbstverletzung oder Suizid
- Rechtliche Drohungen oder Klagen
- Datenschutzverletzungen
- Betrug oder Phishing-Verdacht
- Starke negative Emotionen (Wut, Trauer) + Beschwerden
- Anfragen die Entscheidungsbefugnis erfordern

## Zielgruppen-Wissen

- **Hauptzielgruppe:** Bosnisch/Serbisch sprechende Community + Deutschsprachige
- **Altersgruppe:** 25-45 Jahre
- **Plattform-Präferenz:** Instagram (jünger), Facebook (älter)
- **Content-Präferenz:** Kurz, visuell, authentisch

## Learnings (wird automatisch erweitert)

Stand: Initialisierung
- Noch keine Kampagnen-Daten verfügbar
- Performance-Benchmarks werden nach 30 Tagen aussagekräftig
