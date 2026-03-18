#!/usr/bin/env bash
# =============================================================================
# backup-postiz-uploads.sh — Postiz Uploads-Volume Backup
# =============================================================================
# Sichert den Docker-Volume postiz_uploads auf den Host.
# Kann standalone oder als Teil von backup.sh aufgerufen werden.
#
# Aufruf: ./backup-postiz-uploads.sh [backup-verzeichnis]
# Default: ./data/backups/postiz-uploads/
#
# Voraussetzung: Docker muss laufen, postiz_uploads Volume muss existieren
# =============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP_BASE="${1:-${SCRIPT_DIR}/../data/backups/postiz-uploads}"
TIMESTAMP=$(date '+%Y-%m-%d_%H-%M-%S')
VOLUME_NAME="postiz_uploads"
OUT_FILE="${BACKUP_BASE}/postiz_uploads_${TIMESTAMP}.tar.gz"

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

info()    { echo -e "${BLUE}[INFO]${NC} $*"; }
success() { echo -e "${GREEN}[OK]${NC}   $*"; }
warn()    { echo -e "${YELLOW}[WARN]${NC} $*"; }
error()   { echo -e "${RED}[ERROR]${NC} $*"; }
die()     { error "$*"; exit 1; }

# =============================================================================
# Prüfungen
# =============================================================================

check_docker() {
    if ! command -v docker &>/dev/null; then
        die "docker nicht gefunden — Docker muss installiert sein"
    fi
    if ! docker info &>/dev/null; then
        die "Docker-Daemon nicht erreichbar — ist Docker gestartet?"
    fi
}

check_volume() {
    if ! docker volume inspect "${VOLUME_NAME}" &>/dev/null; then
        warn "Volume '${VOLUME_NAME}' nicht gefunden — wurde Postiz je gestartet?"
        warn "Starten mit: cd deploy/postiz && docker compose up -d"
        exit 0
    fi
}

# =============================================================================
# Backup
# =============================================================================

backup_volume() {
    mkdir -p "${BACKUP_BASE}"

    info "Sichere Docker-Volume '${VOLUME_NAME}' → ${OUT_FILE}"

    # Alpine-Container mounted das Volume und erstellt ein tar.gz auf dem Host
    docker run --rm \
        -v "${VOLUME_NAME}:/uploads:ro" \
        -v "${BACKUP_BASE}:/backup" \
        alpine \
        tar -czf "/backup/postiz_uploads_${TIMESTAMP}.tar.gz" -C / uploads

    if [[ ! -f "${OUT_FILE}" ]]; then
        die "Backup-Datei nicht erzeugt: ${OUT_FILE}"
    fi

    local size
    size=$(du -sh "${OUT_FILE}" | cut -f1)
    success "Postiz Uploads: ${OUT_FILE} (${size})"
}

# =============================================================================
# Alte Backups aufräumen (> 14 Tage)
# =============================================================================

cleanup_old() {
    local count=0
    while IFS= read -r -d '' f; do
        rm -f "${f}"
        count=$((count + 1))
    done < <(find "${BACKUP_BASE}" -maxdepth 1 -name "postiz_uploads_*.tar.gz" \
                   -mtime +14 -print0 2>/dev/null)

    [[ $count -gt 0 ]] && info "${count} alte Postiz-Backups gelöscht (> 14 Tage)"
}

# =============================================================================
# Restore-Hilfe
# =============================================================================

print_restore_hint() {
    echo ""
    echo "Wiederherstellen:"
    echo "  docker volume create ${VOLUME_NAME}"
    echo "  docker run --rm \\"
    echo "    -v ${VOLUME_NAME}:/uploads \\"
    echo "    -v \$(dirname ${OUT_FILE}):/backup \\"
    echo "    alpine \\"
    echo "    tar -xzf /backup/$(basename "${OUT_FILE}") -C /"
    echo ""
}

# =============================================================================
# Main
# =============================================================================

main() {
    echo ""
    echo -e "${BLUE}==========================================${NC}"
    echo -e "${BLUE}  Postiz Uploads — Backup${NC}"
    echo -e "${BLUE}==========================================${NC}"
    echo -e "  Timestamp: ${TIMESTAMP}"
    echo -e "  Volume:    ${VOLUME_NAME}"
    echo -e "  Ziel:      ${OUT_FILE}"
    echo ""

    check_docker
    check_volume
    backup_volume
    cleanup_old
    print_restore_hint

    echo -e "${GREEN}Backup abgeschlossen.${NC}"
}

main "$@"
