#!/usr/bin/env bash
# =============================================================================
# healthcheck.sh — Social AI Stack Healthcheck
# =============================================================================

set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

PASS=0
FAIL=0
WARN=0

ok()   { echo -e "  ${GREEN}✓${NC} $*"; PASS=$((PASS+1)); }
fail() { echo -e "  ${RED}✗${NC} $*"; FAIL=$((FAIL+1)); }
warn() { echo -e "  ${YELLOW}!${NC} $*"; WARN=$((WARN+1)); }

check_http() {
    local name="$1"
    local url="$2"
    local timeout="${3:-5}"

    if curl -fsS --max-time "${timeout}" "${url}" > /dev/null 2>&1; then
        ok "${name} erreichbar (${url})"
        return 0
    else
        fail "${name} nicht erreichbar (${url})"
        return 1
    fi
}

check_http_json() {
    local name="$1"
    local url="$2"
    local field="$3"
    local expected="$4"

    local response
    response=$(curl -fsS --max-time 5 "${url}" 2>/dev/null) || { fail "${name} nicht erreichbar"; return 1; }

    if echo "${response}" | python3 -c "import sys,json; d=json.load(sys.stdin); sys.exit(0 if str(d.get('${field}','')) == '${expected}' else 1)" 2>/dev/null; then
        ok "${name} — ${field}=${expected}"
    else
        local actual
        actual=$(echo "${response}" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('${field}','?'))" 2>/dev/null || echo "?")
        warn "${name} — ${field}=${actual} (erwartet: ${expected})"
    fi
}

# =============================================================================

echo ""
echo -e "${BLUE}==========================================${NC}"
echo -e "${BLUE}  Social AI Stack — Healthcheck${NC}"
echo -e "${BLUE}==========================================${NC}"
echo ""

# --- mem0-api ---
echo -e "${BLUE}[mem0-api :8010]${NC}"
if curl -fsS --max-time 5 "http://127.0.0.1:8010/health" > /dev/null 2>&1; then
    response=$(curl -fsS --max-time 5 "http://127.0.0.1:8010/health" 2>/dev/null)
    ok "mem0-api erreichbar"

    api_status=$(echo "${response}" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('api','?'))" 2>/dev/null || echo "?")
    if [[ "${api_status}" == "ok" ]]; then
        ok "Supermemory API verbunden"
    else
        warn "Supermemory API: ${api_status} (API-Key prüfen)"
    fi
else
    fail "mem0-api nicht erreichbar — start: ./scripts/start-mem0-api.sh"
fi
echo ""

# --- meta-bridge ---
echo -e "${BLUE}[meta-bridge :8085]${NC}"
if curl -fsS --max-time 5 "http://127.0.0.1:8085/health" > /dev/null 2>&1; then
    response=$(curl -fsS --max-time 5 "http://127.0.0.1:8085/health" 2>/dev/null)
    ok "meta-bridge erreichbar"

    sig_ok=$(echo "${response}" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('signature_verification','?'))" 2>/dev/null || echo "?")
    [[ "${sig_ok}" == "enabled" ]] && ok "HMAC Signatur-Verifikation aktiv" || warn "Signatur-Status: ${sig_ok}"

    oc_reachable=$(echo "${response}" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('openclaw_reachable','?'))" 2>/dev/null || echo "?")
    if [[ "${oc_reachable}" == "True" ]] || [[ "${oc_reachable}" == "true" ]]; then
        ok "OpenClaw Hook erreichbar"
    else
        warn "OpenClaw Hook nicht erreichbar (openclaw gestartet?)"
    fi
else
    fail "meta-bridge nicht erreichbar — start: ./scripts/start-meta-bridge.sh"
fi
echo ""

# --- OpenClaw ---
echo -e "${BLUE}[OpenClaw :18789]${NC}"
if curl -fsS --max-time 3 "http://127.0.0.1:18789/health" > /dev/null 2>&1; then
    ok "OpenClaw erreichbar"
elif curl -fsS --max-time 3 "http://127.0.0.1:18789/" > /dev/null 2>&1; then
    ok "OpenClaw erreichbar (kein /health Endpoint)"
else
    fail "OpenClaw nicht erreichbar — start: ./scripts/start-openclaw.sh"
fi
echo ""

# --- PostgreSQL ---
echo -e "${BLUE}[PostgreSQL]${NC}"
DB="${SOCIAL_AI_DB_NAME:-social_ai}"
DB_USER="${SOCIAL_AI_DB_USER:-postgres}"
DB_HOST="${SOCIAL_AI_DB_HOST:-127.0.0.1}"
DB_PORT="${SOCIAL_AI_DB_PORT:-5432}"

if command -v psql &>/dev/null; then
    if psql -h "${DB_HOST}" -p "${DB_PORT}" -U "${DB_USER}" -c '\q' 2>/dev/null; then
        ok "PostgreSQL verbunden (${DB_HOST}:${DB_PORT})"

        # Tabellen prüfen
        table_count=$(psql -h "${DB_HOST}" -p "${DB_PORT}" -U "${DB_USER}" -d "${DB}" \
                          -tAc "SELECT COUNT(*) FROM information_schema.tables WHERE table_schema='public'" 2>/dev/null || echo "0")
        if [[ "${table_count}" -ge 5 ]]; then
            ok "Schema vorhanden (${table_count} Tabellen)"
        else
            warn "Schema unvollständig (${table_count}/6 Tabellen) — schema.sql anwenden?"
        fi
    else
        fail "PostgreSQL nicht erreichbar (${DB_HOST}:${DB_PORT})"
    fi
else
    warn "psql nicht installiert — PostgreSQL-Check übersprungen"
fi
echo ""

# --- Postiz ---
echo -e "${BLUE}[Postiz]${NC}"
POSTIZ_PORT="${POSTIZ_PORT:-4200}"
if curl -fsS --max-time 3 "http://127.0.0.1:${POSTIZ_PORT}" > /dev/null 2>&1; then
    ok "Postiz erreichbar (Port ${POSTIZ_PORT})"
else
    warn "Postiz nicht erreichbar (Port ${POSTIZ_PORT}) — optional, aber für Publishing nötig"
fi
echo ""

# --- .env Dateien ---
echo -e "${BLUE}[Konfiguration]${NC}"
for svc in meta-bridge mem0-api; do
    env_file="${REPO_DIR}/services/${svc}/.env"
    if [[ -f "${env_file}" ]]; then
        # Prüfe ob Platzhalter noch drin sind
        if grep -q "your_" "${env_file}" 2>/dev/null; then
            warn "${svc}/.env hat noch Platzhalter — bitte ausfüllen"
        else
            ok "${svc}/.env konfiguriert"
        fi
    else
        fail "${svc}/.env fehlt — cp ${svc}/.env.example ${svc}/.env"
    fi
done

# openclaw.json prüfen
if python3 -m json.tool "${REPO_DIR}/config/openclaw.json" > /dev/null 2>&1; then
    ok "openclaw.json valide"
else
    fail "openclaw.json hat JSON-Fehler"
fi
echo ""

# --- Zusammenfassung ---
TOTAL=$((PASS + FAIL + WARN))
echo -e "${BLUE}==========================================${NC}"
echo -e "Ergebnis: ${GREEN}${PASS} OK${NC} | ${RED}${FAIL} FEHLER${NC} | ${YELLOW}${WARN} WARNUNGEN${NC}"
echo -e "${BLUE}==========================================${NC}"
echo ""

if [[ $FAIL -gt 0 ]]; then
    exit 1
fi
exit 0
