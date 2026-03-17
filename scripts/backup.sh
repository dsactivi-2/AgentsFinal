#!/usr/bin/env bash
# =============================================================================
# backup.sh — Social AI Stack Backup
# =============================================================================
# Sichert:
#   - PostgreSQL Datenbank (pg_dump)
#   - Konfigurationen (config/, services/*/.env)
#   - OpenClaw Memory & Workspace
#
# Aufruf: ./backup.sh [backup-verzeichnis]
# Default: ./data/backups/
# =============================================================================

set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BACKUP_BASE="${1:-${REPO_DIR}/data/backups}"
TIMESTAMP=$(date '+%Y-%m-%d_%H-%M-%S')
BACKUP_DIR="${BACKUP_BASE}/${TIMESTAMP}"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

info()    { echo -e "${BLUE}[INFO]${NC} $*"; }
success() { echo -e "${GREEN}[OK]${NC}   $*"; }
warn()    { echo -e "${YELLOW}[WARN]${NC} $*"; }
error()   { echo -e "${RED}[ERROR]${NC} $*"; }
die()     { error "$*"; exit 1; }

# =============================================================================

echo ""
echo -e "${BLUE}==========================================${NC}"
echo -e "${BLUE}  Social AI Stack — Backup${NC}"
echo -e "${BLUE}==========================================${NC}"
echo -e "  Timestamp: ${TIMESTAMP}"
echo -e "  Ziel:      ${BACKUP_DIR}"
echo ""

mkdir -p "${BACKUP_DIR}"

# =============================================================================
# PostgreSQL Backup
# =============================================================================

backup_postgres() {
    info "PostgreSQL Backup..."

    local db="${SOCIAL_AI_DB_NAME:-social_ai}"
    local user="${SOCIAL_AI_DB_USER:-postgres}"
    local host="${SOCIAL_AI_DB_HOST:-127.0.0.1}"
    local port="${SOCIAL_AI_DB_PORT:-5432}"
    local out="${BACKUP_DIR}/postgres_${db}_${TIMESTAMP}.dump"

    if ! command -v pg_dump &>/dev/null; then
        warn "pg_dump nicht gefunden — PostgreSQL Backup übersprungen"
        return 0
    fi

    if ! psql -h "${host}" -p "${port}" -U "${user}" -c '\q' 2>/dev/null; then
        warn "PostgreSQL nicht erreichbar — Backup übersprungen"
        return 0
    fi

    pg_dump -h "${host}" -p "${port}" -U "${user}" \
            -Fc --no-acl --no-owner \
            "${db}" > "${out}" 2>/dev/null

    local size
    size=$(du -sh "${out}" | cut -f1)
    success "PostgreSQL: ${out} (${size})"
}

# =============================================================================
# Konfiguration Backup
# =============================================================================

backup_config() {
    info "Konfiguration Backup..."
    local out="${BACKUP_DIR}/config_${TIMESTAMP}.tar.gz"

    tar -czf "${out}" \
        -C "${REPO_DIR}" \
        config/ \
        --exclude="*.pyc" \
        --exclude="__pycache__" \
        2>/dev/null

    local size
    size=$(du -sh "${out}" | cut -f1)
    success "Konfiguration: ${out} (${size})"
}

# =============================================================================
# .env Dateien sichern (verschlüsselt falls gpg vorhanden)
# =============================================================================

backup_env() {
    info ".env Dateien Backup..."
    local env_dir="${BACKUP_DIR}/env"
    mkdir -p "${env_dir}"

    local found=0
    for svc in meta-bridge mem0-api; do
        local env_file="${REPO_DIR}/services/${svc}/.env"
        if [[ -f "${env_file}" ]]; then
            if command -v gpg &>/dev/null && [[ -n "${BACKUP_GPG_KEY:-}" ]]; then
                gpg --quiet --batch --yes \
                    --recipient "${BACKUP_GPG_KEY}" \
                    --output "${env_dir}/${svc}.env.gpg" \
                    --encrypt "${env_file}"
                success "${svc}/.env (GPG verschlüsselt)"
            else
                # Nur kopieren (sensitiv — Backup-Verzeichnis schützen!)
                cp "${env_file}" "${env_dir}/${svc}.env"
                chmod 600 "${env_dir}/${svc}.env"
                warn "${svc}/.env kopiert (nicht verschlüsselt — Backup schützen!)"
            fi
            found=$((found+1))
        fi
    done

    [[ $found -eq 0 ]] && warn "Keine .env Dateien gefunden"
}

# =============================================================================
# OpenClaw Memory Backup
# =============================================================================

backup_openclaw_memory() {
    info "OpenClaw Memory Backup..."
    local oc_dir="${HOME}/.openclaw"

    if [[ ! -d "${oc_dir}" ]]; then
        warn "~/.openclaw nicht gefunden — übersprungen"
        return 0
    fi

    local out="${BACKUP_DIR}/openclaw_memory_${TIMESTAMP}.tar.gz"
    tar -czf "${out}" \
        -C "${HOME}" \
        ".openclaw/" \
        --exclude=".openclaw/node_modules" \
        --exclude=".openclaw/logs" \
        2>/dev/null || true

    local size
    size=$(du -sh "${out}" | cut -f1)
    success "OpenClaw Memory: ${out} (${size})"
}

# =============================================================================
# Alte Backups aufräumen (> 30 Tage)
# =============================================================================

cleanup_old_backups() {
    info "Alte Backups aufräumen (> 30 Tage)..."

    local count=0
    while IFS= read -r -d '' dir; do
        rm -rf "${dir}"
        count=$((count+1))
    done < <(find "${BACKUP_BASE}" -maxdepth 1 -type d -mtime +30 -print0 2>/dev/null)

    if [[ $count -gt 0 ]]; then
        success "${count} alte Backups gelöscht"
    else
        info "Keine alten Backups zum Löschen"
    fi
}

# =============================================================================
# Backup-Manifest
# =============================================================================

write_manifest() {
    local manifest="${BACKUP_DIR}/MANIFEST.txt"
    {
        echo "Social AI Stack Backup"
        echo "======================"
        echo "Timestamp: ${TIMESTAMP}"
        echo "Hostname:  $(hostname)"
        echo "User:      $(whoami)"
        echo "Repo:      ${REPO_DIR}"
        echo ""
        echo "Inhalt:"
        ls -lh "${BACKUP_DIR}/"
        echo ""
        echo "DB:"
        echo "  Name: ${SOCIAL_AI_DB_NAME:-social_ai}"
        echo "  Host: ${SOCIAL_AI_DB_HOST:-127.0.0.1}:${SOCIAL_AI_DB_PORT:-5432}"
    } > "${manifest}"

    success "Manifest: ${manifest}"
}

# =============================================================================
# Gesamtgröße
# =============================================================================

print_summary() {
    local total_size
    total_size=$(du -sh "${BACKUP_DIR}" | cut -f1)

    echo ""
    echo -e "${GREEN}==========================================${NC}"
    echo -e "${GREEN}  Backup abgeschlossen!${NC}"
    echo -e "${GREEN}==========================================${NC}"
    echo -e "  Verzeichnis: ${BACKUP_DIR}"
    echo -e "  Größe:       ${total_size}"
    echo ""

    # Restore-Hinweis
    echo "Wiederherstellen:"
    echo "  PostgreSQL: pg_restore -h HOST -U USER -d DB backup.dump"
    echo "  Konfig:     tar -xzf config_*.tar.gz -C \${REPO_DIR}"
    echo ""
}

# =============================================================================
# Main
# =============================================================================

main() {
    backup_postgres
    backup_config
    backup_env
    backup_openclaw_memory
    cleanup_old_backups
    write_manifest
    print_summary
}

main "$@"
