#!/usr/bin/env bash
# ───────────────────────────────────────────────
# Rubik OS — Face 1: Process & Services
# Manages service lifecycle and process scheduling
# ───────────────────────────────────────────────
set -euo pipefail

FACE_NAME="process-service"
FACE_CELLS=("rubikd" "systemd-minimal" "cgroup-manager" "sched-tune"
            "service-watcher" "cron-minimal" "log-forwarder" "initramfs" "power-manager")

face_init() {
    echo "Face 1: Initializing Process & Services layer"
    mkdir -p /run/rubik/face-1
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

main() {
    case "${1:-}" in
        rotate) face_rotate ;;
        stop)   face_stop ;;
        health) face_health && echo "healthy" || echo "degraded" ;;
        status) face_health && echo "active" || echo "inactive" ;;
        *)      face_init; face_start ;;
    esac
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
