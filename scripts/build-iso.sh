#!/usr/bin/env bash
# ───────────────────────────────────────────────
# Build script for Rubik OS ISO
# Requires: archiso, makechrootpkg
# ───────────────────────────────────────────────
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
ISO_DIR="$PROJECT_DIR/iso"
OUT_DIR="$PROJECT_DIR/out"
BUILD_DATE="$(date +%Y%m%d)"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

log()   { echo -e "${GREEN}[✓]${NC} $1"; }
warn()  { echo -e "${YELLOW}[!]${NC} $1"; }
error() { echo -e "${RED}[✗]${NC} $1"; exit 1; }
header(){ echo -e "${CYAN}═══════════════════════════════════════════════${NC}"; echo -e "${CYAN}  $1${NC}"; echo -e "${CYAN}═══════════════════════════════════════════════${NC}"; }

# ── Prerequisites Check ─────────────────────────
check_prereqs() {
    header "Checking prerequisites"

    if [[ $EUID -ne 0 ]]; then
        error "This script must be run as root (for chroot)"
    fi

    commands=("mkarchiso" "pacman")
    for cmd in "${commands[@]}"; do
        if ! command -v "$cmd" &>/dev/null; then
            error "$cmd is required. Install archiso: pacman -S archiso"
        fi
    done

    log "All prerequisites met"
}

# ── Prepare ISO Root ────────────────────────────
prepare_iso_root() {
    header "Preparing ISO root filesystem"

    local work_root="$OUT_DIR/iso-work"
    rm -rf "$work_root"
    mkdir -p "$work_root"/{etc/rubik,usr/lib/rubik,usr/share/rubik}

    # Copy Rubik configuration from airootfs to work directory
    cp -r "$ISO_DIR/airootfs/etc/"* "$work_root/etc/"
    cp -r "$ISO_DIR/airootfs/usr/"* "$work_root/usr/"

    # Copy system scripts
    cp "$SCRIPT_DIR/rubik-network" "$work_root/usr/bin/rubik-network"
    cp "$SCRIPT_DIR/rubik-recovery" "$work_root/usr/bin/rubik-recovery"
    cp "$SCRIPT_DIR/rubik-bench" "$work_root/usr/bin/rubik-bench"
    cp "$SCRIPT_DIR/qemu-test.sh" "$work_root/usr/bin/qemu-test-rubik"

    # Set correct permissions
    chmod 755 "$work_root/usr/lib/rubik/faces/"* 2>/dev/null || true
    chmod 755 "$work_root/usr/lib/rubik/cells/"* 2>/dev/null || true
    chmod 755 "$work_root/usr/bin/rubik-network" 2>/dev/null || true
    chmod 755 "$work_root/usr/bin/rubik-recovery" 2>/dev/null || true
    chmod 755 "$work_root/usr/bin/rubik-bench" 2>/dev/null || true
    chmod 644 "$work_root/etc/rubik/"* 2>/dev/null || true

    log "ISO root prepared at $work_root"
}

# ── Build Packages ──────────────────────────────
build_packages() {
    header "Building Rubik OS packages"

    local pkg_dir="$PROJECT_DIR/packages"

    for pkg in "$pkg_dir/core/"*; do
        if [[ -f "$pkg/PKGBUILD" ]]; then
            log "Building: $(basename "$pkg")"
            (cd "$pkg" && makepkg -si --noconfirm) || warn "Failed to build $(basename "$pkg")"
        fi
    done

    log "Core packages built"
}

# ── Build ISO ───────────────────────────────────
build_iso() {
    header "Building Rubik OS ISO"

    mkdir -p "$OUT_DIR"

    # Use archiso's mkarchiso
    mkarchiso -v -w "$OUT_DIR/work" -o "$OUT_DIR" "$ISO_DIR"

    local iso_file="$OUT_DIR/rubik-os-${BUILD_DATE}-x86_64.iso"
    if [[ -f "$iso_file" ]]; then
        log "ISO built successfully: $iso_file"
        log "Size: $(du -h "$iso_file" | cut -f1)"
    else
        error "ISO not found at $iso_file"
    fi
}

# ── Clean Build Artifacts ───────────────────────
clean() {
    header "Cleaning build artifacts"
    rm -rf "$OUT_DIR/work" "$OUT_DIR/out"
    log "Cleaned"
}

# ── Main ─────────────────────────────────────────
main() {
    header "Rubik OS Build System"

    case "${1:-all}" in
        all)
            check_prereqs
            prepare_iso_root
            build_packages
            build_iso
            ;;
        iso)
            check_prereqs
            prepare_iso_root
            build_iso
            ;;
        packages)
            build_packages
            ;;
        clean)
            clean
            ;;
        *)
            echo "Usage: $0 {all|iso|packages|clean}"
            exit 1
            ;;
    esac

    header "Build complete"
}

main "$@"
