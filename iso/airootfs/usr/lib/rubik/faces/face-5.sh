#!/usr/bin/env bash
# ───────────────────────────────────────────────
# Rubik OS — Face 5: Security
# Mandatory access control, audit, isolation
# ───────────────────────────────────────────────
set -euo pipefail

FACE_NAME="security"
FACE_CELLS=("apparmor" "sandbox-exec" "audit" "crypto"
            "integrity" "firejail" "hardened-kernel" "update-auth" "cell-isolation")

face_init() {
    echo "Face 5: Initializing Security layer"
    mkdir -p /run/rubik/face-5
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
