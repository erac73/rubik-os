#!/usr/bin/env bash
# cell: F5.3 - Cryptographic module loading and kernel params
CELL_NAME="crypto"
SYSCTL_CRYPTO="/etc/sysctl.d/90-rubik-crypto.conf"

cell_start() {
    modprobe aesni_intel 2>/dev/null || true
    modprobe sha512_ssse3 2>/dev/null || true
    modprobe crct10dif_pclmul 2>/dev/null || true
    modprobe crc32_pclmul 2>/dev/null || true
    modprobe polyval_clmulni 2>/dev/null || true
    modprobe dm_crypt 2>/dev/null || true
    modprobe dm_integrity 2>/dev/null || true
    cat > "$SYSCTL_CRYPTO" << SYSCTL
kernel.random.write_wakeup_threshold = 64
kernel.random.read_wakeup_threshold = 64
kernel.keys.maxkeys = 2000
kernel.keys.maxbytes = 20000
SYSCTL
    sysctl -p "$SYSCTL_CRYPTO" 2>/dev/null || true
    echo "Crypto modules: aesni, sha512, crct10dif, dm_crypt, dm_integrity"
}

cell_stop() {
    rm -f "$SYSCTL_CRYPTO" 2>/dev/null || true
}

cell_health() {
    for m in aesni_intel sha512_ssse3 dm_crypt; do
        lsmod | grep -q "$m" 2>/dev/null || return 1
    done
    return 0
}

cell_deps() { echo "F5.0"; }

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    case "${1:-start}" in
        start)   cell_start ;;
        stop)    cell_stop ;;
        health)  cell_health && echo "healthy" || echo "degraded" ;;
        *)       echo "Usage: $0 {start|stop|health}" ;;
    esac
fi
