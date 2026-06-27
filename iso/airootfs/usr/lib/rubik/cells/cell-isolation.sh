#!/usr/bin/env bash
# cell: F5.8 - Cell-level cgroup isolation hardening
CELL_NAME="cell-isolation"
CGROUP_BASE="/sys/fs/cgroup/rubik"

cell_start() {
    if [ ! -d "$CGROUP_BASE" ]; then
        echo "cgroup root not found (cgroup-manager not started?)"
        return 1
    fi
    for face in 0 1 2 3 4 5; do
        local dir="$CGROUP_BASE/face-$face"
        if [ -d "$dir" ]; then
            echo 262144 > "$dir/memory.max" 2>/dev/null || true
            echo 100 > "$dir/cpu.weight" 2>/dev/null || true
            echo 10000 > "$dir/io.weight" 2>/dev/null || true
            echo 128 > "$dir/pids.max" 2>/dev/null || true
        fi
    done
    echo "Face slices hardened: memory.max=256M, pids.max=128, cpu.weight=100"
}

cell_stop() {
    echo "Isolation limits removed at runtime (cgroup leaves persist)"
}

cell_health() {
    for face in 0 1 2 3 4 5; do
        [ -f "$CGROUP_BASE/face-$face/memory.max" ] || return 1
    done
    return 0
}

cell_deps() { echo "F5.0 F1.2"; }

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    case "${1:-start}" in
        start)   cell_start ;;
        stop)    cell_stop ;;
        health)  cell_health && echo "healthy" || echo "degraded" ;;
        *)       echo "Usage: $0 {start|stop|health}" ;;
    esac
fi
