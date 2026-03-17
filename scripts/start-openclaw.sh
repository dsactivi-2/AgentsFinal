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
