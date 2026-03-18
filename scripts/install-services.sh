#!/usr/bin/env bash
# =============================================================================
# install-services.sh — Systemd-Autostart für meta-bridge + mem0-api
# =============================================================================
# Erstellt und aktiviert systemd-Units für:
#   - meta-bridge (Port 8085)
#   - mem0-api    (Port 8010)
#
# Voraussetzungen:
#   - venvs müssen vorhanden sein (bootstrap.sh ausführen)
#   - .env Dateien müssen ausgefüllt sein
#   - Root-Rechte (sudo) für systemd-Units in /etc/systemd/system/
#
# Verwendung:
#   sudo ./scripts/install-services.sh
#   sudo SERVICE_USER=ubuntu ./scripts/install-services.sh
# =============================================================================

set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SYSTEMD_DIR="/etc/systemd/system"
LOG_DIR="${REPO_DIR}/logs"

# User unter dem die Services laufen (Standard: aktueller User)
SERVICE_USER="${SERVICE_USER:-$(id -un)}"
SERVICE_GROUP="${SERVICE_GROUP:-$(id -gn)}"

# Farben
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

info()    { echo -e "${BLUE}[INFO]${NC} $*"; }
success() { echo -e "${GREEN}[OK]${NC}   $*"; }
warn()    { echo -e "${YELLOW}[WARN]${NC} $*"; }
error()   { echo -e "${RED}[ERROR]${NC} $*"; }
die()     { error "$*"; exit 1; }

# ─── Preflight ────────────────────────────────────────────────────────────────

preflight() {
    if [[ ${EUID} -ne 0 ]]; then
        die "Root-Rechte benötigt: sudo ${0}"
    fi

    if ! command -v systemctl &>/dev/null; then
        die "systemd nicht gefunden. Dieses Script benötigt systemd."
    fi

    for svc in meta-bridge mem0-api; do
        local venv="${REPO_DIR}/services/${svc}/venv/bin/uvicorn"
        if [[ ! -f "${venv}" ]]; then
            die "${svc}: venv nicht gefunden (${venv}). Bitte bootstrap.sh ausführen."
        fi
    done

    info "Service User: ${SERVICE_USER}"
    info "Service Group: ${SERVICE_GROUP}"
    info "Repo: ${REPO_DIR}"

    mkdir -p "${LOG_DIR}"
    chown "${SERVICE_USER}:${SERVICE_GROUP}" "${LOG_DIR}" 2>/dev/null || true
}

# ─── Unit-Datei erstellen ─────────────────────────────────────────────────────

create_meta_bridge_unit() {
    info "Erstelle meta-bridge.service..."

    cat > "${SYSTEMD_DIR}/meta-bridge.service" << EOF
[Unit]
Description=Meta Bridge — Facebook/Instagram Webhook-Empfänger
Documentation=file://${REPO_DIR}/docs/ARCHITECTURE.md
After=network.target postgresql.service
Wants=postgresql.service

[Service]
Type=simple
User=${SERVICE_USER}
Group=${SERVICE_GROUP}
WorkingDirectory=${REPO_DIR}/services/meta-bridge
EnvironmentFile=-${REPO_DIR}/services/meta-bridge/.env
ExecStart=${REPO_DIR}/services/meta-bridge/venv/bin/uvicorn \\
    app:app \\
    --host 127.0.0.1 \\
    --port 8085 \\
    --workers 1 \\
    --log-level info
ExecReload=/bin/kill -HUP \$MAINPID
Restart=on-failure
RestartSec=5
TimeoutStopSec=10
StandardOutput=append:${LOG_DIR}/meta-bridge.log
StandardError=append:${LOG_DIR}/meta-bridge.log
SyslogIdentifier=meta-bridge

[Install]
WantedBy=multi-user.target
EOF

    success "meta-bridge.service erstellt"
}

create_mem0_api_unit() {
    info "Erstelle mem0-api.service..."

    cat > "${SYSTEMD_DIR}/mem0-api.service" << EOF
[Unit]
Description=mem0-API — Semantisches Langzeit-Memory via Supermemory.ai
Documentation=file://${REPO_DIR}/docs/ARCHITECTURE.md
After=network.target

[Service]
Type=simple
User=${SERVICE_USER}
Group=${SERVICE_GROUP}
WorkingDirectory=${REPO_DIR}/services/mem0-api
EnvironmentFile=-${REPO_DIR}/services/mem0-api/.env
ExecStart=${REPO_DIR}/services/mem0-api/venv/bin/uvicorn \\
    app:app \\
    --host 127.0.0.1 \\
    --port 8010 \\
    --workers 1 \\
    --log-level info
ExecReload=/bin/kill -HUP \$MAINPID
Restart=on-failure
RestartSec=5
TimeoutStopSec=10
StandardOutput=append:${LOG_DIR}/mem0-api.log
StandardError=append:${LOG_DIR}/mem0-api.log
SyslogIdentifier=mem0-api

[Install]
WantedBy=multi-user.target
EOF

    success "mem0-api.service erstellt"
}

# ─── Services aktivieren + starten ───────────────────────────────────────────

enable_services() {
    info "systemd daemon-reload..."
    systemctl daemon-reload
    success "daemon-reload OK"

    for svc in meta-bridge mem0-api; do
        info "Aktiviere ${svc}..."
        systemctl enable "${svc}.service"
        success "${svc}: Autostart aktiviert"
    done
}

start_services() {
    local restart_flag="${1:-start}"  # start | restart

    for svc in meta-bridge mem0-api; do
        if systemctl is-active --quiet "${svc}.service" 2>/dev/null; then
            info "${svc} läuft bereits — führe restart durch..."
            systemctl restart "${svc}.service"
            success "${svc}: neu gestartet"
        else
            info "Starte ${svc}..."
            systemctl start "${svc}.service"
            success "${svc}: gestartet"
        fi

        # Kurz warten und Status prüfen
        sleep 2
        if systemctl is-active --quiet "${svc}.service"; then
            success "${svc}: aktiv (PID: $(systemctl show -p MainPID "${svc}.service" | cut -d= -f2))"
        else
            warn "${svc}: konnte nicht gestartet werden"
            warn "Status: systemctl status ${svc}.service"
            warn "Logs:   journalctl -u ${svc}.service -n 50"
        fi
    done
}

print_summary() {
    echo ""
    echo -e "${GREEN}══════════════════════════════════════════════${NC}"
    echo -e "${GREEN}  Systemd-Services installiert und aktiv${NC}"
    echo -e "${GREEN}══════════════════════════════════════════════${NC}"
    echo ""
    echo "Services:"
    echo "  systemctl status meta-bridge          # Port 8085"
    echo "  systemctl status mem0-api             # Port 8010"
    echo "  systemctl --user status openclaw-gateway  # OpenClaw (user-service)"
    echo ""
    echo "Logs:"
    echo "  journalctl -u meta-bridge -f"
    echo "  journalctl -u mem0-api -f"
    echo "  journalctl --user -u openclaw-gateway -f"
    echo "  tail -f ${LOG_DIR}/meta-bridge.log"
    echo "  tail -f ${LOG_DIR}/mem0-api.log"
    echo ""
    echo "Steuerung:"
    echo "  systemctl restart meta-bridge"
    echo "  systemctl restart mem0-api"
    echo "  systemctl --user restart openclaw-gateway"
    echo ""
    echo "Autostart deaktivieren:"
    echo "  systemctl disable meta-bridge mem0-api"
    echo ""
}

# ─── Main ─────────────────────────────────────────────────────────────────────

main() {
    echo ""
    echo -e "${BLUE}══════════════════════════════════════════════${NC}"
    echo -e "${BLUE}  Social AI Stack — Systemd-Installation${NC}"
    echo -e "${BLUE}══════════════════════════════════════════════${NC}"
    echo ""

    preflight
    create_meta_bridge_unit
    create_mem0_api_unit
    enable_services
    start_services
    print_summary
}

main "$@"
