#!/usr/bin/env bash
# cell: F1.7 - Initramfs one-shot setup
CELL_NAME="initramfs"
cell_start() {
    mkdir -p /run/rubik /var/log/rubik
    dmesg -n 3 2>/dev/null || true
    echo "Initramfs setup complete"
}
cell_stop() { return 0; }
cell_health() {
    [ -d /run/rubik ] && return 0 || return 1
}
