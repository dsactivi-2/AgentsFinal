#!/usr/bin/env bash
# start-watchdog.sh — Startet den Watchdog im Hintergrund

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
PID_FILE="/tmp/watchdog.pid"
LOG_FILE="${REPO_ROOT}/logs/watchdog.log"

mkdir -p "${REPO_ROOT}/logs"

# Laufende Instanz stoppen
if [[ -f "${PID_FILE}" ]]; then
    OLD_PID=$(cat "${PID_FILE}")
    if kill -0 "${OLD_PID}" 2>/dev/null; then
        echo "Stoppe laufenden Watchdog (PID ${OLD_PID})..."
        kill "${OLD_PID}"
        sleep 1
    fi
    rm -f "${PID_FILE}"
fi

nohup bash "${SCRIPT_DIR}/watchdog.sh" >> "${LOG_FILE}" 2>&1 &
echo $! > "${PID_FILE}"

echo "Watchdog gestartet — PID $(cat "${PID_FILE}")"
echo "Logs: ${LOG_FILE}"
