#!/usr/bin/env bash
# =============================================================================
# run-tests.sh — Test-Runner für Social AI Stack
# =============================================================================
# Verwendung:
#   ./scripts/run-tests.sh          # nur Mock-Tests (kein Server benötigt)
#   ./scripts/run-tests.sh --live   # zusätzlich Live-Tests gegen laufende Server
# =============================================================================

set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TESTS_DIR="${REPO_DIR}/tests"

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

# ─── Abhängigkeiten prüfen ────────────────────────────────────────────────────

check_deps() {
    if ! command -v pytest &>/dev/null; then
        # Versuche venv aus meta-bridge
        if [[ -f "${REPO_DIR}/services/meta-bridge/venv/bin/pytest" ]]; then
            export PATH="${REPO_DIR}/services/meta-bridge/venv/bin:${PATH}"
        else
            error "pytest nicht gefunden."
            error "Installieren:"
            error "  pip install -r tests/requirements-dev.txt"
            error "  oder: pip install pytest pytest-asyncio httpx respx"
            exit 1
        fi
    fi
}

# ─── Mock-Tests (kein Server nötig) ──────────────────────────────────────────

run_mock_tests() {
    echo ""
    info "── Mock-Tests ──────────────────────────────────────────────────────"
    info "Testpfad: tests/ (ohne tests/live/)"
    echo ""

    cd "${REPO_DIR}"

    if pytest "${TESTS_DIR}" \
        --ignore="${TESTS_DIR}/live" \
        -v \
        --tb=short \
        "$@"; then
        echo ""
        success "Mock-Tests: alle bestanden"
        return 0
    else
        echo ""
        error "Mock-Tests: Fehler"
        return 1
    fi
}

# ─── Live-Tests (Server muss laufen) ─────────────────────────────────────────

run_live_tests() {
    echo ""
    info "── Live-Tests ──────────────────────────────────────────────────────"
    info "meta-bridge: ${META_BRIDGE_URL:-http://127.0.0.1:8085}"
    info "mem0-api:    ${MEM0_API_URL:-http://127.0.0.1:8010}"
    echo ""

    cd "${REPO_DIR}"

    if pytest "${TESTS_DIR}/live" \
        -v \
        --tb=short; then
        echo ""
        success "Live-Tests: alle bestanden (oder übersprungen)"
        return 0
    else
        echo ""
        warn "Live-Tests: einige fehlgeschlagen"
        return 1
    fi
}

# ─── Main ─────────────────────────────────────────────────────────────────────

main() {
    echo ""
    echo -e "${BLUE}══════════════════════════════════════════════${NC}"
    echo -e "${BLUE}  Social AI Stack — Test Suite${NC}"
    echo -e "${BLUE}══════════════════════════════════════════════${NC}"

    check_deps

    local run_live=false
    for arg in "$@"; do
        [[ "${arg}" == "--live" ]] && run_live=true
    done

    local exit_code=0

    run_mock_tests || exit_code=1

    if [[ "${run_live}" == "true" ]]; then
        run_live_tests || exit_code=$((exit_code + 10))
    else
        echo ""
        warn "Live-Tests übersprungen. Mit --live ausführen:"
        warn "  ./scripts/run-tests.sh --live"
    fi

    echo ""
    if [[ ${exit_code} -eq 0 ]]; then
        success "Alle Tests bestanden."
    else
        error "Tests mit Fehlern abgeschlossen (exit: ${exit_code})."
    fi

    exit ${exit_code}
}

main "$@"
