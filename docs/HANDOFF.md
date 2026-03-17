# HANDOFF — AgentsFinal / Session 2026-03-17

## Was in dieser Session gemacht wurde

Branch: `refactor/openclaw-conform` — 7 Commits auf GitHub

| Commit | Was |
|---|---|
| `a680892` | 9 Skills migriert → `workspace/skills/{name}/SKILL.md + _meta.json` |
| `b516813` | `config/skills/*.md` gelöscht, workspace-Pfad auf `workspace-social-ai` |
| `e3255f5` | `config/AGENTS.md` → Generic Session Protocol (nicht mehr Rollendefinitionen) |
| `96b1fb5` | `workspace/IDENTITY.md` erstellt — Ava, 9 Skills, Sprachen, Grenzen |
| `fa532ce` | README + IDENTITY: Umbenennung auf AgentsFinal / Ava |
| `48d31ec` | `docs/HANDOFF.md` erstellt |
| `ed450b3` | `docs/AGENTS.md` Intro-Fix: ein Agent, 9 Verhaltensrollen |

Remote: `git@github.com:dsactivi-2/AgentsFinal.git`
Lokal: `/Users/dsselmanovic/backups/agents-final.git`
Branch noch NICHT in `main` gemergt — PR steht aus.

Beide Remotes identisch synchronisiert.

---

## Was noch zu tun ist

### Priorität 1 — Sofort nötig vor erstem echten Run

**A) Branch mergen**
```bash
git checkout main
git merge refactor/openclaw-conform
git push origin main
```
Oder PR auf GitHub: `refactor/openclaw-conform → main`

**B) Lokalen Workspace anlegen**
```bash
# OpenClaw-Workspace für diesen Stack erstellen
mkdir -p ~/.openclaw/workspace-social-ai
cp -r /pfad/zu/AgentsFinal/workspace/. ~/.openclaw/workspace-social-ai/
cp /pfad/zu/AgentsFinal/config/SOUL.md ~/.openclaw/workspace-social-ai/
cp /pfad/zu/AgentsFinal/config/AGENTS.md ~/.openclaw/workspace-social-ai/
cp /pfad/zu/AgentsFinal/config/MEMORY.md ~/.openclaw/workspace-social-ai/
cp /pfad/zu/AgentsFinal/config/HEARTBEAT.md ~/.openclaw/workspace-social-ai/
```
→ Skills sind bereits in `workspace/skills/` — werden mitkopiert

**C) openclaw.json deployen**
```bash
cp config/openclaw.json ~/.openclaw/workspace-social-ai/openclaw.json
# Env-Vars setzen: OLLAMA_CLOUD_MODEL, OLLAMA_CLOUD_API_BASE, etc.
```

---

### Priorität 2 — Verbesserungen (kein Blocker)

**D) `docs/AGENTS.md` Intro-Fix** ✅ ERLEDIGT (Session 2026-03-17)
- Intro wurde angepasst: "Ava ist eine einzelne Instanz die je nach Kontext in eine dieser 9 Rollen wechselt"
- Falscher Satz "Kein einzelner Agent soll alles tun" entfernt

**E) `workspace/SOUL.md` Symlink / Kopie**
- Aktuell: SOUL.md liegt in `config/`, OpenClaw erwartet es im Workspace-Root
- Fix: Bei Bootstrap-Script ins Workspace-Root kopieren oder Symlink

**F) `workspace/TOOLS.md` erstellen**
- OpenClaw erwartet TOOLS.md im Workspace
- Inhalt: memory_search, memory_get, postiz API, meta-bridge, redis, postgres
- Format: wie `~/.openclaw/workspace-marki/TOOLS.md`

**G) `workspace/USER.md` erstellen**
- Für User-Kontext (Firmenname, Branche, Zielgruppe, Sprache)
- Platzhalter die beim Setup ausgefüllt werden

**H) `scripts/bootstrap.sh` aktualisieren**
- Aktuell kopiert es aus `config/` (alter Pfad)
- Soll aus `workspace/` kopieren + Skills symlinken
- PID-Files schreiben bereits erledigt (aus letzter Session)

**I) Bundle-Struktur** (nur wenn zweiter Use Case kommt)
- `bundles/social-media/bundle.yaml` + `scripts/install-bundle.sh`
- Erst relevant wenn ein zweiter Agent (ecommerce, support-bot) gebaut wird

---

## Supermemory — Welche Docs lesen

Beim Session-Start diese Queries ausführen:

```bash
~/mem-search.sh "openclaw workspace structure"
~/mem-search.sh "openclaw skill format SKILL.md"
~/mem-search.sh "AgentsFinal social ai stack"
~/mem-search.sh "openclaw.json configuration"
~/mem-search.sh "meta-bridge mem0-api services"
```

Oder via Supermemory API (containerTag: `claude-code-memory`):
- Query: `"openclaw workspace"` → Workspace-Aufbau-Doku
- Query: `"social ai stack v2"` → Stack-Konfiguration
- Query: `"SKILL.md format meta.json"` → Skill-Verzeichnis-Format

---

## Skills die für nächste Session aktiviert werden sollten

| Skill | Warum |
|---|---|
| `sessions-memory` | Supermemory-Queries + Memory-Protokoll für Session-Start |
| `hooks-configuration` | Falls bootstrap.sh oder OpenClaw-Hooks angepasst werden |
| `langchain-architecture` | Nur wenn Reflexion-Rolle (ROLE:reflexion) aus Plan A1 noch umgesetzt wird |

---

## Nächste Agenten — Top 3 Empfehlungen

### 1. Lead Nurturing Agent (höchster Impact, schnell baubar)
Sendet automatische Follow-ups an warme Leads nach 24h / 3 Tage / 7 Tage.
- **Nutzt:** meta-bridge (existiert), mem0 (existiert), PostgreSQL (existiert), Postiz (existiert)
- **Neu nötig:** `workspace/skills/lead-nurturing/SKILL.md` (1 Datei)
- **Trigger:** Cron 3x täglich → prüft PostgreSQL auf Leads ohne Antwort
- **Impact:** Automatische Konversions-Optimierung ohne manuellen Aufwand

### 2. Reflexion Agent / ROLE:reflexion (bereits geplant in Plan A1)
Wöchentliche Selbstanalyse aller 9 Rollen — was lief gut, was schlecht?
- **Nutzt:** memory_search (existiert), Supermemory (existiert)
- **Neu nötig:** `workspace/skills/reflexion/SKILL.md` (1 Datei) + Cron So 04:00 in openclaw.json
- **Darf nicht:** Skill-Dateien selbst überschreiben — nur Vorschläge speichern
- **Impact:** Langfristige Selbstverbesserung ohne manuelle Analyse

### 3. Content Recycling Agent (Mittel, aber hoher ROI)
Analysiert Top-Posts der letzten 90 Tage und erstellt neue Varianten davon.
- **Nutzt:** Postiz Analytics (existiert), writer (existiert), planner (existiert)
- **Neu nötig:** `workspace/skills/content-recycler/SKILL.md` (1 Datei)
- **Trigger:** Cron Mo 07:00 → Top 3 Posts der letzten 90 Tage → 3 neue Varianten
- **Impact:** Bestehendes Erfolgs-Content wird maximal ausgeschöpft

---

## Offene Entscheidungen (User muss entscheiden)

1. **Agent-Name "Ava"** — behalten oder anderen Namen?
2. **PR mergen** — wann? refactor/openclaw-conform → main
3. ~~**`docs/AGENTS.md` Intro`**~~ ✅ erledigt
4. **ROLE:reflexion (Cron So 04:00)** — noch aus dem ursprünglichen Plan (Teil A1) — wurde noch nicht implementiert
5. **Welchen Agenten als nächstes bauen?** — Lead Nurturing / Reflexion / Content Recycler?

---

## Repo-Zustand

```
github.com/dsactivi-2/AgentsFinal
├── main              ← initial commit (alt)
└── refactor/openclaw-conform  ← AKTUELL (7 Commits voraus)

Struktur:
workspace/
  IDENTITY.md   ✅ neu
  skills/
    analytics/SKILL.md + _meta.json   ✅
    escalation/SKILL.md + _meta.json  ✅
    inbox/SKILL.md + _meta.json       ✅
    memory-critic/SKILL.md + _meta.json ✅
    optimizer/SKILL.md + _meta.json   ✅
    planner/SKILL.md + _meta.json     ✅
    publisher/SKILL.md + _meta.json   ✅
    reviewer/SKILL.md + _meta.json    ✅
    writer/SKILL.md + _meta.json      ✅
config/
  AGENTS.md     ✅ Session Protocol (nicht mehr Rollendefinitionen)
  openclaw.json ✅ workspace-social-ai
  SOUL.md       (unverändert, gut)
  HEARTBEAT.md  (unverändert)
  MEMORY.md     (unverändert)
.gitignore      ✅ erweitert
```
