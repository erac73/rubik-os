#!/usr/bin/env bash
# ───────────────────────────────────────────────
# Rubik OS — Face 4: UI & UX
# Display server, window management, desktop components
# ───────────────────────────────────────────────
set -euo pipefail

FACE_NAME="ui-ux"
FACE_CELLS=("wm-core" "bar-status" "launcher" "terminal"
            "compositor" "notifier" "wallpaper" "clipboard" "idle-manager")

face_init() {
    echo "Face 4: Initializing UI & UX layer"
    mkdir -p /run/rubik/face-4
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
