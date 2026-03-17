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
