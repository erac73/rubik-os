#!/usr/bin/env bash
# ───────────────────────────────────────────────
# Rubik OS — Face 2: Storage
# Filesystem layout, mounts, I/O optimization
# ───────────────────────────────────────────────
set -euo pipefail

FACE_NAME="storage"
FACE_CELLS=("fs-layout" "mount-manager" "cache-io" "tmpfs-manager"
            "trim-scheduler" "dedup" "fs-notify" "snapper" "defrag-lite")

face_init() {
    echo "Face 2: Initializing Storage layer"
    mkdir -p /run/rubik/face-2
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
