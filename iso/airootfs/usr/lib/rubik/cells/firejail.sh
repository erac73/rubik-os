#!/usr/bin/env bash
# cell: F5.5 - Firejail sandbox profiles and defaults
CELL_NAME="firejail"
FIREJAIL_CONFIG="/etc/firejail"
RUBIK_FIREJAIL="$FIREJAIL_CONFIG/rubik"

cell_start() {
    if ! command -v firejail &>/dev/null; then
        echo "firejail not installed, enabling kernel user namespace support"
        echo "kernel.unprivileged_userns_clone=1" > /etc/sysctl.d/90-rubik-firejail.conf
        sysctl -w kernel.unprivileged_userns_clone=1 2>/dev/null || true
        return 0
    fi
    mkdir -p "$RUBIK_FIREJAIL"
    cat > "$RUBIK_FIREJAIL/rubik-default.local" << PROFILE
# Rubik OS default firejail profile
include /etc/firejail/default.local
caps.drop all
netfilter
noroot
seccomp
private-dev
private-tmp
PROFILE
    if command -v firecfg &>/dev/null; then
        firecfg 2>/dev/null || true
    fi
    echo "Firejail configured with Rubik default profile"
}

cell_stop() {
    rm -rf "$RUBIK_FIREJAIL" /etc/sysctl.d/90-rubik-firejail.conf 2>/dev/null || true
}

cell_health() {
    command -v firejail &>/dev/null && return 0
    [ -f /etc/sysctl.d/90-rubik-firejail.conf ] && return 0
    return 1
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
