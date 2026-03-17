#!/usr/bin/env bash
# start-mem0-api.sh — Startet mem0-api auf Port 8010

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
SERVICE_DIR="${REPO_ROOT}/services/mem0-api"
PID_FILE="/tmp/mem0-api.pid"
LOG_FILE="${REPO_ROOT}/logs/mem0-api.log"
PORT="${MEM0_API_PORT:-8010}"

# Logs-Verzeichnis
mkdir -p "${REPO_ROOT}/logs"

# Laufende Instanz stoppen
if [[ -f "${PID_FILE}" ]]; then
    OLD_PID=$(cat "${PID_FILE}")
    if kill -0 "${OLD_PID}" 2>/dev/null; then
        echo "Stoppe laufende Instanz (PID ${OLD_PID})..."
        kill "${OLD_PID}"
        sleep 2
    fi
    rm -f "${PID_FILE}"
fi

# .env laden
if [[ -f "${SERVICE_DIR}/.env" ]]; then
    set -a
    source "${SERVICE_DIR}/.env"
    set +a
fi

cd "${SERVICE_DIR}"

# Dependencies installieren (falls neu)
if [[ -f "requirements.txt" ]]; then
    pip install -q -r requirements.txt
fi

# Service starten
echo "Starte mem0-api auf Port ${PORT}..."
nohup uvicorn app:app --host 127.0.0.1 --port "${PORT}" \
    >> "${LOG_FILE}" 2>&1 &

echo $! > "${PID_FILE}"
echo "mem0-api gestartet — PID $(cat "${PID_FILE}"), Port ${PORT}"
echo "Logs: ${LOG_FILE}"
