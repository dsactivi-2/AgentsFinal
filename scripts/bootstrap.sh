#!/usr/bin/env bash
# =============================================================================
# bootstrap.sh — Social AI Stack Setup
# =============================================================================
# Setzt den kompletten Stack auf:
#   - Python venvs für meta-bridge und mem0-api
#   - PostgreSQL-Datenbank + Schema
#   - OpenClaw Installation und Konfiguration
#   - Umgebungsvariablen prüfen + .env Dateien
# =============================================================================

set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
LOG_FILE="${REPO_DIR}/logs/bootstrap.log"

# Farben
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# =============================================================================
# Hilfsfunktionen
# =============================================================================

log() { echo "[$(date '+%Y-%m-%d %H:%M:%S')] [$1] ${*:2}" >> "${LOG_FILE}" 2>/dev/null || true; }
info()    { echo -e "${BLUE}[INFO]${NC} $*";   log INFO "$*"; }
success() { echo -e "${GREEN}[OK]${NC}   $*";  log OK "$*"; }
warn()    { echo -e "${YELLOW}[WARN]${NC} $*"; log WARN "$*"; }
error()   { echo -e "${RED}[ERROR]${NC} $*";  log ERROR "$*"; }
die()     { error "$*"; exit 1; }

check_cmd() {
    if ! command -v "$1" &>/dev/null; then
        die "Benötigt: '$1' nicht gefunden. Bitte installieren."
    fi
}

# =============================================================================
# Setup-Schritte
# =============================================================================

setup_dirs() {
    info "Verzeichnisse anlegen..."
    mkdir -p "${REPO_DIR}/logs" "${REPO_DIR}/data"
    success "Verzeichnisse OK"
}

preflight_checks() {
    info "Preflight Checks..."
    check_cmd python3
    check_cmd pip3

    local py_ver
    py_ver=$(python3 -c "import sys; print(f'{sys.version_info.major}.{sys.version_info.minor}')")
    if ! python3 -c "import sys; sys.exit(0 if sys.version_info >= (3,11) else 1)"; then
        die "Python 3.11+ benötigt, gefunden: ${py_ver}"
    fi
    success "Python ${py_ver} OK"

    if command -v psql &>/dev/null; then
        success "PostgreSQL Client OK"
    else
        warn "psql nicht gefunden — DB-Setup wird übersprungen"
    fi

    if command -v node &>/dev/null; then
        success "Node.js $(node --version) OK"
    else
        warn "Node.js nicht gefunden — OpenClaw Setup wird übersprungen"
    fi
}

check_env() {
    info "Umgebungsvariablen prüfen..."
    local missing=0

    check_var() {
        if [[ -z "${!1:-}" ]]; then
            warn "Fehlend: $1 — $2"
            missing=$((missing + 1))
        else
            success "$1 OK"
        fi
    }

    check_var "SUPERMEMORY_API_KEY"    "Supermemory API Key"
    check_var "META_APP_SECRET"        "Meta App Secret"
    check_var "META_VERIFY_TOKEN"      "Meta Webhook Verify Token"
    check_var "META_PAGE_ACCESS_TOKEN" "Meta Page Access Token"

    if [[ $missing -gt 0 ]]; then
        warn "${missing} Variable(n) fehlen — .env Dateien nach dem Setup ausfüllen"
    fi
}

setup_env_files() {
    info ".env Dateien vorbereiten..."
    for svc in meta-bridge mem0-api; do
        local env="${REPO_DIR}/services/${svc}/.env"
        local example="${REPO_DIR}/services/${svc}/.env.example"
        if [[ ! -f "${env}" ]] && [[ -f "${example}" ]]; then
            cp "${example}" "${env}"
            warn "${svc}/.env erstellt — bitte ausfüllen: ${env}"
        else
            success "${svc}/.env vorhanden"
        fi
    done
}

setup_venv() {
    local svc="$1"
    local svc_dir="${REPO_DIR}/services/${svc}"
    info "Python venv: ${svc}..."

    [[ -d "${svc_dir}" ]] || die "Service-Verzeichnis fehlt: ${svc_dir}"

    cd "${svc_dir}"
    if [[ ! -d "venv" ]]; then
        python3 -m venv venv
    fi
    # shellcheck disable=SC1091
    source venv/bin/activate
    pip3 install --upgrade pip --quiet
    pip3 install -r requirements.txt --quiet
    deactivate
    cd "${REPO_DIR}"
    success "${svc} venv bereit"
}

setup_postgres() {
    info "PostgreSQL Setup..."

    local db="${SOCIAL_AI_DB_NAME:-social_ai}"
    local user="${SOCIAL_AI_DB_USER:-postgres}"
    local host="${SOCIAL_AI_DB_HOST:-127.0.0.1}"
    local port="${SOCIAL_AI_DB_PORT:-5432}"

    if ! psql -h "${host}" -p "${port}" -U "${user}" -c '\q' 2>/dev/null; then
        warn "PostgreSQL nicht erreichbar auf ${host}:${port} — DB-Setup übersprungen"
        warn "Starte PostgreSQL und führe aus: psql -U ${user} -d ${db} -f services/db/schema.sql"
        return 0
    fi

    # DB erstellen falls nicht vorhanden
    if ! psql -h "${host}" -p "${port}" -U "${user}" -lqt 2>/dev/null \
         | cut -d '|' -f1 | grep -qw "${db}"; then
        psql -h "${host}" -p "${port}" -U "${user}" \
             -c "CREATE DATABASE ${db};" &>/dev/null
        success "Datenbank '${db}' erstellt"
    else
        info "Datenbank '${db}' vorhanden"
    fi

    psql -h "${host}" -p "${port}" -U "${user}" -d "${db}" \
         -f "${REPO_DIR}/services/db/schema.sql" --quiet 2>/dev/null
    success "Schema angewendet"
}

setup_openclaw() {
    info "OpenClaw Setup..."

    if command -v openclaw &>/dev/null; then
        success "OpenClaw bereits installiert"
    else
        if command -v npm &>/dev/null; then
            npm install -g openclaw --quiet 2>/dev/null \
                && success "OpenClaw installiert" \
                || warn "OpenClaw npm-Install fehlgeschlagen — manuell: https://openclaw.dev"
        else
            warn "npm fehlt — OpenClaw manuell installieren: https://openclaw.dev"
            return 0
        fi
    fi

    local oc_dir="${HOME}/.openclaw"
    local workspace="${oc_dir}/workspace-social-ai"
    mkdir -p "${oc_dir}" "${workspace}"

    # openclaw.json: Symlink (damit Änderungen im Repo sofort wirksam sind)
    if [[ ! -f "${oc_dir}/openclaw.json" ]]; then
        ln -sf "${REPO_DIR}/config/openclaw.json" "${oc_dir}/openclaw.json"
        success "openclaw.json verlinkt"
    else
        # Force-Update: neuere Version aus Repo gewinnt
        ln -sf "${REPO_DIR}/config/openclaw.json" "${oc_dir}/openclaw.json"
        success "openclaw.json aktualisiert"
    fi

    # Workspace-Root-Dateien aus workspace/ kopieren (IDENTITY, MEMORY)
    for ws_file in IDENTITY.md; do
        local src="${REPO_DIR}/workspace/${ws_file}"
        if [[ -f "${src}" ]]; then
            ln -sf "${src}" "${workspace}/${ws_file}"
            success "Workspace: ${ws_file} verlinkt"
        fi
    done

    # Config-Dateien aus config/ in Workspace-Root verlinken
    for cfg_file in SOUL.md AGENTS.md MEMORY.md HEARTBEAT.md; do
        local src="${REPO_DIR}/config/${cfg_file}"
        if [[ -f "${src}" ]]; then
            ln -sf "${src}" "${workspace}/${cfg_file}"
            success "Workspace: ${cfg_file} verlinkt"
        fi
    done

    # Skills: workspace/skills/{name}/ → workspace-social-ai/skills/{name}/
    local skills_src="${REPO_DIR}/workspace/skills"
    local skills_dst="${workspace}/skills"
    mkdir -p "${skills_dst}"

    if [[ -d "${skills_src}" ]]; then
        local skill_count=0
        for skill_dir in "${skills_src}"/*/; do
            [[ -d "${skill_dir}" ]] || continue
            local skill_name
            skill_name="$(basename "${skill_dir}")"
            local dst_dir="${skills_dst}/${skill_name}"
            mkdir -p "${dst_dir}"
            # SKILL.md + _meta.json einzeln verlinken
            for skill_file in SKILL.md _meta.json; do
                if [[ -f "${skill_dir}${skill_file}" ]]; then
                    ln -sf "${skill_dir}${skill_file}" "${dst_dir}/${skill_file}"
                fi
            done
            skill_count=$((skill_count + 1))
        done
        success "Workspace: skills/ verlinkt (${skill_count} Skills)"
    else
        warn "workspace/skills/ nicht gefunden — Skills werden nicht geladen"
    fi

    success "OpenClaw Workspace eingerichtet: ${workspace}"
}

create_start_scripts() {
    info "Start-Scripts erstellen..."

    cat > "${REPO_DIR}/scripts/start-mem0-api.sh" << 'SCRIPT'
#!/usr/bin/env bash
set -euo pipefail
SVC_DIR="$(cd "$(dirname "$0")/../services/mem0-api" && pwd)"
REPO_DIR="$(cd "$(dirname "$0")/.." && pwd)"
PID_FILE="/tmp/mem0-api.pid"
LOG_FILE="${REPO_DIR}/logs/mem0-api.log"
mkdir -p "${REPO_DIR}/logs"
cd "$SVC_DIR"
[[ -f .env ]] && set -o allexport && source .env && set +o allexport
source venv/bin/activate
uvicorn app:app --host 127.0.0.1 --port 8010 --workers 1 --log-level info >> "${LOG_FILE}" 2>&1 &
echo $! > "${PID_FILE}"
echo "[mem0-api] gestartet — PID $(cat ${PID_FILE}) — Port 8010"
SCRIPT

    cat > "${REPO_DIR}/scripts/start-meta-bridge.sh" << 'SCRIPT'
#!/usr/bin/env bash
set -euo pipefail
SVC_DIR="$(cd "$(dirname "$0")/../services/meta-bridge" && pwd)"
REPO_DIR="$(cd "$(dirname "$0")/.." && pwd)"
PID_FILE="/tmp/meta-bridge.pid"
LOG_FILE="${REPO_DIR}/logs/meta-bridge.log"
mkdir -p "${REPO_DIR}/logs"
cd "$SVC_DIR"
[[ -f .env ]] && set -o allexport && source .env && set +o allexport
source venv/bin/activate
uvicorn app:app --host 127.0.0.1 --port 8085 --workers 1 --log-level info >> "${LOG_FILE}" 2>&1 &
echo $! > "${PID_FILE}"
echo "[meta-bridge] gestartet — PID $(cat ${PID_FILE}) — Port 8085"
SCRIPT

    cat > "${REPO_DIR}/scripts/start-openclaw.sh" << 'SCRIPT'
#!/usr/bin/env bash
set -euo pipefail
REPO_DIR="$(cd "$(dirname "$0")/.." && pwd)"
PID_FILE="/tmp/openclaw.pid"
LOG_FILE="${REPO_DIR}/logs/openclaw.log"
mkdir -p "${REPO_DIR}/logs"
cd "${REPO_DIR}"
openclaw start --config config/openclaw.json >> "${LOG_FILE}" 2>&1 &
echo $! > "${PID_FILE}"
echo "[openclaw] gestartet — PID $(cat ${PID_FILE})"
SCRIPT

    chmod +x "${REPO_DIR}/scripts/start-mem0-api.sh" \
             "${REPO_DIR}/scripts/start-meta-bridge.sh" \
             "${REPO_DIR}/scripts/start-openclaw.sh"
    success "Start-Scripts erstellt (mit PID-Files)"
}

syntax_checks() {
    info "Syntax-Checks..."

    if python3 -m json.tool "${REPO_DIR}/config/openclaw.json" > /dev/null 2>&1; then
        success "openclaw.json valide"
    else
        error "openclaw.json hat JSON-Fehler!"
    fi

    for svc in meta-bridge mem0-api; do
        local app="${REPO_DIR}/services/${svc}/app.py"
        if [[ -f "${app}" ]]; then
            if python3 -m py_compile "${app}" 2>/dev/null; then
                success "${svc}/app.py Syntax OK"
            else
                error "${svc}/app.py hat Syntax-Fehler"
            fi
        fi
    done
}

print_summary() {
    echo ""
    echo -e "${GREEN}================================================${NC}"
    echo -e "${GREEN}  Social AI Stack — Bootstrap abgeschlossen!${NC}"
    echo -e "${GREEN}================================================${NC}"
    echo ""
    echo "Nächste Schritte:"
    echo ""
    echo "1. .env Dateien ausfüllen:"
    echo "   nano services/meta-bridge/.env"
    echo "   nano services/mem0-api/.env"
    echo ""
    echo "2. Services starten:"
    echo "   ./scripts/start-mem0-api.sh     # Port 8010 — PID: /tmp/mem0-api.pid"
    echo "   ./scripts/start-meta-bridge.sh  # Port 8085 — PID: /tmp/meta-bridge.pid"
    echo "   ./scripts/start-openclaw.sh     # OpenClaw Agent — PID: /tmp/openclaw.pid"
    echo ""
    echo "   Oder alle auf einmal:"
    echo "   for s in mem0-api meta-bridge openclaw; do ./scripts/start-\${s}.sh; done"
    echo ""
    echo "3. Workspace:"
    echo "   ~/.openclaw/workspace-social-ai/   ← 11 Skills verlinkt"
    echo "   ~/.openclaw/openclaw.json           ← Symlink auf config/openclaw.json"
    echo ""
    echo "4. Healthcheck:"
    echo "   ./scripts/healthcheck.sh"
    echo ""
    echo "5. Meta Webhook:"
    echo "   Callback URL: https://[deine-domain]/webhook"
    echo "   Verify Token: \$META_VERIFY_TOKEN"
    echo ""
    echo "6. Logs:"
    echo "   tail -f logs/bootstrap.log"
    echo "   tail -f logs/mem0-api.log"
    echo "   tail -f logs/meta-bridge.log"
    echo "   tail -f logs/openclaw.log"
    echo ""
}

# =============================================================================
# Main
# =============================================================================

main() {
    echo ""
    echo -e "${BLUE}============================================${NC}"
    echo -e "${BLUE}  Social AI Stack v2 — Bootstrap${NC}"
    echo -e "${BLUE}============================================${NC}"
    echo ""

    setup_dirs
    preflight_checks
    check_env
    setup_env_files
    setup_venv "meta-bridge"
    setup_venv "mem0-api"
    setup_postgres
    setup_openclaw
    create_start_scripts
    syntax_checks
    print_summary
}

main "$@"
