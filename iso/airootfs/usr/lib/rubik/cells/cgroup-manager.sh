#!/usr/bin/env bash
# cell: F1.2 - Cgroup v2 hierarchy manager
CELL_NAME="cgroup-manager"
CGROUP_ROOT="/sys/fs/cgroup"
RUBIK_CG="$CGROUP_ROOT/rubik"

cell_start() {
    if [ ! -d "$CGROUP_ROOT" ]; then
        echo "cgroup v2 not available"
        return 1
    fi
    mkdir -p "$RUBIK_CG"
    mkdir -p "$RUBIK_CG/system"
    for face in 0 1 2 3 4 5; do
        mkdir -p "$RUBIK_CG/face-$face"
        echo 512 > "$RUBIK_CG/face-$face/memory.max" 2>/dev/null || true
        echo 100 > "$RUBIK_CG/face-$face/cpu.weight" 2>/dev/null || true
    done
    echo "500M" > "$RUBIK_CG/memory.max" 2>/dev/null || true
    echo "system" > "$RUBIK_CG/system/cgroup.type" 2>/dev/null || true
    echo "Cgroup v2 hierarchy ready with 6 face slices"
}

cell_stop() {
    for face in 5 4 3 2 1 0; do
        rmdir "$RUBIK_CG/face-$face" 2>/dev/null || true
    done
    rmdir "$RUBIK_CG/system" 2>/dev/null || true
    rmdir "$RUBIK_CG" 2>/dev/null || true
}

cell_health() {
    [ -d "$RUBIK_CG/face-0" ] && [ -d "$RUBIK_CG/face-5" ] && return 0
    return 1
}

cell_deps() { echo "F1.0"; }

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    case "${1:-start}" in
        start)   cell_start ;;
        stop)    cell_stop ;;
        health)  cell_health && echo "healthy" || echo "degraded" ;;
        *)       echo "Usage: $0 {start|stop|health}" ;;
    esac
fi
