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
