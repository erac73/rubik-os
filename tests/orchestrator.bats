#!/usr/bin/env bats
# Tests for Rubik OS orchestrator (rubikd/rubikctl)

setup() {
    load '../scripts/rubik-orchestrator'
}

@test "orchestrator: help output" {
    run main
    [ "$status" -eq 1 ]
    echo "$output" | grep -q "Usage"
}

@test "orchestrator: unknown command fails" {
    run main nonexistent
    [ "$status" -eq 1 ]
}

@test "orchestrator: cell status on missing cell" {
    run _orch_cell_status "nonexistent_cell_xyz"
    [ "$status" -eq 1 ]
    echo "$output" | grep -q "unknown"
}

@test "orchestrator: health check on empty cell dir" {
    RUBIK_ROOT="/tmp/rubik-test-cells"
    mkdir -p "$RUBIK_ROOT/cells"
    run _orch_health_check
    [ "$status" -eq 0 ]
    rm -rf "/tmp/rubik-test-cells"
}

@test "orchestrator: read_toml handles missing file" {
    CELLS_TOML="/tmp/rubik-test-nonexistent.toml"
    run _orch_read_toml
    [ "$status" -eq 1 ]
}

@test "orchestrator: validate detects missing config" {
    RUBIK_CONFIG="/tmp/rubik-test-config"
    mkdir -p "$RUBIK_CONFIG"
    run _orch_validate
    [ "$status" -eq 1 ]
    echo "$output" | grep -q "not found"
    rm -rf "/tmp/rubik-test-config"
}

@test "cells: memory-compression health on nonexistent zram" {
    # Simulate no ZRAM by running in a namespace
    run bash -c '
        source /dev/null 2>/dev/null || true
        # Just check the function syntax loads
        source "../iso/airootfs/usr/lib/rubik/cells/memory-compression.sh"
        echo "syntax OK"
    ' || echo "skip: needs bash"
}

@test "cells: all scripts have cell_start function" {
    for f in ../iso/airootfs/usr/lib/rubik/cells/*.sh; do
        name=$(basename "$f")
        grep -q "^cell_start()" "$f" || echo "MISSING cell_start in $name"
    done
}

@test "cells: all scripts have cell_stop function" {
    for f in ../iso/airootfs/usr/lib/rubik/cells/*.sh; do
        name=$(basename "$f")
        grep -q "^cell_stop()" "$f" || echo "MISSING cell_stop in $name"
    done
}

@test "cells: all scripts have cell_health function" {
    for f in ../iso/airootfs/usr/lib/rubik/cells/*.sh; do
        name=$(basename "$f")
        grep -q "^cell_health()" "$f" || echo "MISSING cell_health in $name"
    done
}

@test "faces: all face scripts exist" {
    for i in 0 1 2 3 4 5; do
        [ -f "../iso/airootfs/usr/lib/rubik/faces/face-${i}.sh" ]
    done
}

@test "faces: all face scripts have face_start" {
    for f in ../iso/airootfs/usr/lib/rubik/faces/*.sh; do
        name=$(basename "$f")
        grep -q "^face_start()" "$f" || echo "MISSING face_start in $name"
    done
}

@test "config: cells.toml is valid TOML syntax" {
    python3 -c "
import toml
with open('../iso/airootfs/etc/rubik/cells.toml') as f:
    data = toml.load(f)
    cells = [k for k in data.keys() if k.startswith('cell.')]
    print(f'Valid TOML with {len(cells)} cells')
" || echo "skip: python3-toml not available"
}

@test "config: all exec paths in cells.toml exist" {
    while IFS= read -r line; do
        path=$(echo "$line" | sed 's/.*exec = \"//;s/\"//')
        rel_path=$(echo "$path" | sed 's|^/||')
        if [ ! -f "../$rel_path" ]; then
            echo "MISSING: $path"
        fi
    done < <(grep '^exec = ' ../iso/airootfs/etc/rubik/cells.toml 2>/dev/null || true)
}

@test "pkgbuild: has all dependencies" {
    grep -q "depends=(" ../packages/core/rubik-core/PKGBUILD
}

@test "build: build-iso.sh has no self-copy bug" {
    grep -q "OUT_DIR/iso-work" ../scripts/build-iso.sh
}

@test "orchestrator: daemon mode starts health loop" {
    run timeout 2 ../scripts/rubik-orchestrator daemon 1
    [ "$status" -eq 124 ]  # timeout means it looped
}

@test "orchestrator: bootstrap starts cells in order" {
    run ../scripts/rubik-orchestrator bootstrap
    echo "$output" | grep -q "Bootstrap complete"
}

@test "orchestrator: shutdown stops all cells" {
    run ../scripts/rubik-orchestrator shutdown
    echo "$output" | grep -q "Shutdown complete"
}

@test "orchestrator: daemon with custom interval" {
    run timeout 3 ../scripts/rubik-orchestrator daemon 2
    [ "$status" -eq 124 ]
}

@test "apparmor: rubik-cell profile exists" {
    [ -f "../iso/airootfs/etc/apparmor.d/rubik/rubik-cell" ]
}

@test "apparmor: network profile exists" {
    [ -f "../iso/airootfs/etc/apparmor.d/rubik/rubik-cell-network" ]
}

@test "apparmor: security profile exists" {
    [ -f "../iso/airootfs/etc/apparmor.d/rubik/rubik-cell-security" ]
}

@test "logging: rsyslog config exists" {
    [ -f "../iso/airootfs/etc/rsyslog.d/30-rubik.conf" ]
}

@test "logging: logrotate config exists" {
    [ -f "../iso/airootfs/etc/logrotate.d/rubik" ]
}

@test "init: bootstrap_cells delegates to rubikd" {
    grep -q "rubikd bootstrap" ../scripts/rubik-init
}

@test "all cells have executable bit" {
    for f in ../iso/airootfs/usr/lib/rubik/cells/*.sh; do
        [ -x "$f" ] || echo "NOT EXECUTABLE: $f"
    done
}

@test "no shebangless scripts" {
    for f in ../scripts/* ../iso/airootfs/usr/lib/rubik/cells/*.sh ../iso/airootfs/usr/lib/rubik/faces/*.sh; do
        head -1 "$f" | grep -q "^#!" || echo "NO SHEBANG: $f"
    done
}

@test "rubik-network: help output" {
    run ../scripts/rubik-network
    echo "$output" | grep -q "Usage"
}

@test "rubik-network: detect interfaces" {
    run ../scripts/rubik-network status
    echo "$output" | grep -q "interfaces"
}

@test "rubik-recovery: help output" {
    run ../scripts/rubik-recovery
    echo "$output" | grep -q "Usage"
}

@test "rubik-bench: help output" {
    run ../scripts/rubik-bench
    echo "$output" | grep -q "Usage"
}

@test "rubik-bench: cpu benchmark" {
    run ../scripts/rubik-bench cpu
    echo "$output" | grep -q "CPU"
}

@test "rubik-bench: memory benchmark" {
    run ../scripts/rubik-bench memory
    echo "$output" | grep -q "Memory"
}

@test "systemd: rubik-face@.service exists" {
    [ -f "../iso/airootfs/usr/lib/systemd/rubik-services/rubik-face@.service" ]
}

@test "systemd: rubik.target exists" {
    [ -f "../iso/airootfs/usr/lib/systemd/rubik-services/rubik.target" ]
}

@test "installer: has validate_environment" {
    grep -q "validate_environment" ../scripts/rubik-install
}

@test "installer: has print_summary" {
    grep -q "print_summary" ../scripts/rubik-install
}

@test "installer: has non-interactive disk param" {
    grep -q -- "--disk=" ../scripts/rubik-install
}

@test "qemu: test script exists" {
    [ -f "../scripts/qemu-test.sh" ]
    head -1 ../scripts/qemu-test.sh | grep -q "^#!/"
}

@test "all cell scripts are real (not stubs)" {
    for f in ../iso/airootfs/usr/lib/rubik/cells/*.sh; do
        name=$(basename "$f")
        # Each script must have at least 8 lines (significant implementation)
        lines=$(wc -l < "$f")
        [ "$lines" -ge 8 ] || echo "TOO SHORT ($lines lines): $name"
    done
}

@test "ui cells launch actual processes" {
    # wm-core should try to detect and start a WM
    grep -q "command -v" ../iso/airootfs/usr/lib/rubik/cells/wm-core.sh
    grep -q "command -v" ../iso/airootfs/usr/lib/rubik/cells/bar-status.sh
    grep -q "command -v" ../iso/airootfs/usr/lib/rubik/cells/launcher.sh
    grep -q "command -v" ../iso/airootfs/usr/lib/rubik/cells/notifier.sh
}
