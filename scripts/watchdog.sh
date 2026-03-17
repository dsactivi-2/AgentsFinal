#!/usr/bin/env bash
# watchdog.sh — Health-Check + Auto-Restart für mem0-api und meta-bridge
#
# Prüft alle 30s ob die Services erreichbar sind.
# Boot-Loop-Schutz: max 3 Restarts pro Service pro Stunde.
# Logs: logs/watchdog.log (max 10MB, dann Rotation)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
LOG_FILE="${REPO_ROOT}/logs/watchdog.log"
LOG_MAX_BYTES=10485760  # 10 MB

MEM0_PORT="${MEM0_API_PORT:-8010}"
BRIDGE_PORT="${META_BRIDGE_PORT:-8085}"
MEM0_PID_FILE="/tmp/mem0-api.pid"
BRIDGE_PID_FILE="/tmp/meta-bridge.pid"
CHECK_INTERVAL=30

# Restart-Zähler (pro Service) — Reset stündlich
declare -A restart_count=( [mem0]=0 [bridge]=0 )
declare -A last_reset_ts=( [mem0]=$(date +%s) [bridge]=$(date +%s) )
MAX_RESTARTS_PER_HOUR=3

mkdir -p "${REPO_ROOT}/logs"

log() {
    local ts
    ts="$(date '+%Y-%m-%dT%H:%M:%S')"
    local line="${ts} [watchdog] $*"

    # Log-Rotation
    if [[ -f "${LOG_FILE}" ]]; then
        local size
        size=$(wc -c < "${LOG_FILE}")
        if (( size > LOG_MAX_BYTES )); then
            mv "${LOG_FILE}" "${LOG_FILE}.1"
        fi
    fi

    echo "${line}" >> "${LOG_FILE}"
    echo "${line}"
}

check_service() {
    local name="$1"
    local port="$2"
    local health_url="http://127.0.0.1:${port}/health"

    local response
    response=$(curl -sf --max-time 5 "${health_url}" 2>/dev/null) || return 1

    local ok
    ok=$(echo "${response}" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('ok','false'))" 2>/dev/null) || return 1
    [[ "${ok}" == "True" || "${ok}" == "true" ]]
}

restart_service() {
    local name="$1"
    local script="$2"

    local now
    now=$(date +%s)

    # Stündlicher Reset des Zählers
    local elapsed=$(( now - last_reset_ts[${name}] ))
    if (( elapsed >= 3600 )); then
        restart_count[${name}]=0
        last_reset_ts[${name}]=${now}
        log "INFO ${name}: Restart-Zähler zurückgesetzt"
    fi

    # Boot-Loop-Schutz
    if (( restart_count[${name}] >= MAX_RESTARTS_PER_HOUR )); then
        log "WARN ${name}: Max Restarts (${MAX_RESTARTS_PER_HOUR}/h) erreicht — kein weiterer Restart"
        return
    fi

    restart_count[${name}]=$(( restart_count[${name}] + 1 ))
    log "WARN ${name}: Service down — starte neu (Versuch ${restart_count[${name}]}/${MAX_RESTARTS_PER_HOUR})"

    bash "${SCRIPT_DIR}/${script}" >> "${LOG_FILE}" 2>&1 && \
        log "INFO ${name}: Neustart erfolgreich" || \
        log "ERROR ${name}: Neustart fehlgeschlagen"
}

log "INFO watchdog gestartet — Interval: ${CHECK_INTERVAL}s"

while true; do
    # mem0-api
    if check_service "mem0-api" "${MEM0_PORT}"; then
        : # ok
    else
        log "WARN mem0-api: Health-Check fehlgeschlagen"
        restart_service "mem0" "start-mem0-api.sh"
    fi

    # meta-bridge
    if check_service "meta-bridge" "${BRIDGE_PORT}"; then
        : # ok
    else
        log "WARN meta-bridge: Health-Check fehlgeschlagen"
        restart_service "bridge" "start-meta-bridge.sh"
    fi

    sleep "${CHECK_INTERVAL}"
done
