#!/usr/bin/env bash
# ───────────────────────────────────────────────
# Rubik OS — Face 3: Network
# Network stack, firewall, DNS, connectivity
# ───────────────────────────────────────────────
set -euo pipefail

FACE_NAME="network"
FACE_CELLS=("networkd" "firewall" "dns-cache" "routing"
            "proxy-tun" "net-monitor" "wifi-manager" "bandwidth-limiter" "ntp-sync")

face_init() {
    echo "Face 3: Initializing Network layer"
    mkdir -p /run/rubik/face-3
}

face_start() {
    for cell in "${FACE_CELLS[@]}"; do
        systemctl start "rubik-cell@$cell" 2>/dev/null || true
    done
}

face_stop() {
    for cell in "${FACE_CELLS[@]}"; do
        systemctl stop "rubik-cell@$cell" 2>/dev/null || true
    done
}

face_health() {
    for cell in "${FACE_CELLS[@]}"; do
        systemctl is-active "rubik-cell@$cell" &>/dev/null || return 1
    done
    return 0
}

face_rotate() {
    face_stop
    sleep 1
    face_start
}
