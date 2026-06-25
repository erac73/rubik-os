#!/usr/bin/env bash
# cell: F5.3 - Cryptographic module loading
CELL_NAME="crypto"
cell_start() {
    modprobe aesni_intel 2>/dev/null || true
    modprobe sha512_ssse3 2>/dev/null || true
    echo "Crypto modules loaded"
}
cell_stop() { return 0; }
cell_health() {
    lsmod | grep -q aesni_intel && return 0 || return 1
}
