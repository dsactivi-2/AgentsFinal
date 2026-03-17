#!/usr/bin/env bash
# start-meta-bridge.sh — Startet meta-bridge auf Port 8085

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
SERVICE_DIR="${REPO_ROOT}/services/meta-bridge"
PID_FILE="/tmp/meta-bridge.pid"
LOG_FILE="${REPO_ROOT}/logs/meta-bridge.log"
PORT="${META_BRIDGE_PORT:-8085}"

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

# Pflicht-Prüfung
for var in META_VERIFY_TOKEN META_APP_SECRET META_PAGE_ACCESS_TOKEN; do
    if [[ -z "${!var:-}" ]]; then
        echo "FEHLER: ${var} ist nicht gesetzt. Bitte .env befüllen."
        exit 1
    fi
done

cd "${SERVICE_DIR}"

# Dependencies installieren (falls neu)
if [[ -f "requirements.txt" ]]; then
    pip install -q -r requirements.txt
fi

# Service starten
echo "Starte meta-bridge auf Port ${PORT}..."
nohup uvicorn app:app --host 0.0.0.0 --port "${PORT}" \
    >> "${LOG_FILE}" 2>&1 &

echo $! > "${PID_FILE}"
echo "meta-bridge gestartet — PID $(cat "${PID_FILE}"), Port ${PORT}"
echo "Logs: ${LOG_FILE}"
echo ""
echo "Webhook-URL: https://marki.ds.activi.io/hooks/meta"
echo "(Caddy muss /hooks/meta → localhost:${PORT}/webhook proxyen)"
