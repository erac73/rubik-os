#!/usr/bin/env bash
# ───────────────────────────────────────────────
# QEMU test launcher for Rubik OS ISO
# Usage: ./scripts/qemu-test.sh [path/to/rubik-os-*.iso]
# Requires: qemu, qemu-system-x86_64, ovmf (UEFI)
# ───────────────────────────────────────────────
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
ISO_DIR="$PROJECT_DIR/out"

RED='\e[31m'; GREEN='\e[32m'; YELLOW='\e[33m'; CYAN='\e[36m'; NC='\e[0m'
log()   { echo -e "${GREEN}[✓]${NC} $1"; }
error() { echo -e "${RED}[✗]${NC} $1"; }
header(){ echo -e "\n${CYAN}══ $1 ══${NC}\n"; }

check_prereqs() {
    header "Checking prerequisites"
    for cmd in qemu-system-x86_64; do
        command -v "$cmd" &>/dev/null || error "$cmd not installed (pacman -S qemu-full)"
    done
    log "Prerequisites met"
}

find_iso() {
    local iso="${1:-}"
    if [[ -z "$iso" ]]; then
        iso=$(ls -t "$ISO_DIR"/rubik-os-*.iso 2>/dev/null | head -1)
    fi
    if [[ -z "$iso" || ! -f "$iso" ]]; then
        error "No ISO found. Build first: sudo ./scripts/build-iso.sh"
    fi
    echo "$iso"
}

boot_uefi() {
    local iso="$1"
    local mem="${2:-2048}"
    local uefi_code="/usr/share/ovmf/x64/OVMF_CODE.fd"
    local uefi_vars="/usr/share/ovmf/x64/OVMF_VARS.fd"

    header "Booting Rubik OS in QEMU (UEFI)"
    echo "  ISO:  $iso"
    echo "  RAM:  ${mem}M"
    echo ""
    log "Starting QEMU (CTRL+ALT+G to release mouse)"
    echo ""

    qemu-system-x86_64 \
        -enable-kvm \
        -m "$mem" \
        -smp cores=2 \
        -cpu host \
        -cdrom "$iso" \
        -drive if=pflash,format=raw,readonly=on,file="$uefi_code" \
        -drive if=pflash,format=raw,file="$uefi_vars" \
        -netdev user,id=net0 \
        -device e1000,netdev=net0 \
        -vga virtio \
        -display gtk \
        -machine type=q35,accel=kvm
}

boot_bios() {
    local iso="$1"
    local mem="${2:-2048}"

    header "Booting Rubik OS in QEMU (BIOS)"
    qemu-system-x86_64 \
        -enable-kvm \
        -m "$mem" \
        -smp cores=2 \
        -cpu host \
        -cdrom "$iso" \
        -netdev user,id=net0 \
        -device e1000,netdev=net0 \
        -vga virtio \
        -display gtk \
        -machine type=q35,accel=kvm
}

main() {
    local iso
    iso=$(find_iso "${1:-}")
    check_prereqs

    case "${2:-uefi}" in
        uefi)  boot_uefi "$iso" "${3:-2048}" ;;
        bios)  boot_bios "$iso" "${3:-2048}" ;;
        *)
            echo "Usage: $0 [iso-path] [uefi|bios] [ram-mb]"
            echo ""
            echo "Examples:"
            echo "  $0                          # Boot latest ISO (UEFI)"
            echo "  $0 out/rubik-os-20250101.iso bios 4096  # BIOS with 4GB RAM"
            exit 1
            ;;
    esac
}

main "$@"
