#!/usr/bin/env bash
# ───────────────────────────────────────────────
# Build script for Rubik OS ISO
# Requires: archiso
# ───────────────────────────────────────────────
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
ISO_DIR="$PROJECT_DIR/iso"
OUT_DIR="$PROJECT_DIR/out"
BUILD_DATE="$(date +%Y%m%d)"

RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; CYAN='\033[0;36m'; NC='\033[0m'
log()   { echo -e "${GREEN}[✓]${NC} $1"; }
warn()  { echo -e "${YELLOW}[!]${NC} $1"; }
error() { echo -e "${RED}[✗]${NC} $1"; exit 1; }
header(){ echo -e "${CYAN}═══════════════════════════════════════════════${NC}"; echo -e "${CYAN}  $1${NC}"; echo -e "${CYAN}═══════════════════════════════════════════════${NC}"; }

check_prereqs() {
    header "Checking prerequisites"
    if [[ $EUID -ne 0 ]]; then
        error "This script must be run as root (for chroot)"
    fi
    for cmd in mkarchiso pacman; do
        if ! command -v "$cmd" &>/dev/null; then
            error "$cmd is required. Install archiso: pacman -S archiso"
        fi
    done
    log "All prerequisites met"
}

build_iso() {
    header "Building Rubik OS ISO"
    mkdir -p "$OUT_DIR"
    mkarchiso -v -w "$OUT_DIR/work" -o "$OUT_DIR" "$ISO_DIR"
    local iso_file="$OUT_DIR/rubik-os-${BUILD_DATE}-x86_64.iso"
    if [[ -f "$iso_file" ]]; then
        log "ISO built successfully: $iso_file"
        log "Size: $(du -h "$iso_file" | cut -f1)"
    else
        # mkarchiso names the file differently
        local found
        found=$(ls "$OUT_DIR/"*.iso 2>/dev/null | head -1)
        if [[ -n "$found" ]]; then
            log "ISO built successfully: $found"
            log "Size: $(du -h "$found" | cut -f1)"
        else
            error "ISO not found in $OUT_DIR"
        fi
    fi
}

clean() {
    header "Cleaning build artifacts"
    rm -rf "$OUT_DIR/work" "$OUT_DIR/out"
    log "Cleaned"
}

main() {
    header "Rubik OS Build System"
    case "${1:-iso}" in
        iso)
            check_prereqs
            build_iso
            ;;
        clean)
            clean
            ;;
        *)
            echo "Usage: $0 {iso|clean}"
            exit 1
            ;;
    esac
    header "Build complete"
}

main "$@"
