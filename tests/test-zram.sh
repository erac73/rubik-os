#!/usr/bin/env bash
# ───────────────────────────────────────────────
# Test: ZRAM Configuration
# Verifies that ZRAM is properly set up with
# correct algorithm, size, and priority.
# ───────────────────────────────────────────────
set -euo pipefail

PASS=0
FAIL=0

test_name() {
    echo -n "  [ ] $1 ... "
}

pass() {
    echo -e "\e[32mPASS\e[0m"
    PASS=$((PASS + 1))
}

fail() {
    echo -e "\e[31mFAIL\e[0m"
    echo "       $1"
    FAIL=$((FAIL + 1))
}

# ── Tests ──────────────────────────────────────

test_zram_device_exists() {
    test_name "ZRAM device exists"
    if [[ -e /dev/zram0 ]]; then
        pass
    else
        fail "/dev/zram0 not found"
    fi
}

test_zram_compression_algorithm() {
    test_name "ZRAM compression algorithm is zstd"
    if [[ -f /sys/block/zram0/comp_algorithm ]]; then
        local algo
        algo=$(cat /sys/block/zram0/comp_algorithm)
        if echo "$algo" | grep -q "\[zstd\]"; then
            pass
        else
            fail "Expected [zstd], got: $algo"
        fi
    else
        fail "comp_algorithm not available"
    fi
}

test_zram_active_as_swap() {
    test_name "ZRAM is active as swap with priority 100"
    if grep -q "zram0" /proc/swaps; then
        local priority
        priority=$(awk '/zram0/ {print $5}' /proc/swaps)
        if [[ "$priority" == "100" ]]; then
            pass
        else
            fail "Expected priority 100, got: $priority"
        fi
    else
        fail "zram0 not in /proc/swaps"
    fi
}

test_zram_has_size() {
    test_name "ZRAM has non-zero size"
    if [[ -f /sys/block/zram0/disksize ]]; then
        local size
        size=$(cat /sys/block/zram0/disksize)
        if [[ "$size" -gt 0 ]]; then
            pass
        else
            fail "ZRAM disksize is 0"
        fi
    else
        fail "disksize not available"
    fi
}

test_swapfile_exists() {
    test_name "Swapfile exists at /swapfile"
    if [[ -f /swapfile ]]; then
        local size
        size=$(stat -c%s /swapfile 2>/dev/null || echo 0)
        if [[ "$size" -gt 0 ]]; then
            pass
        else
            fail "Swapfile is empty"
        fi
    else
        # Not a failure — may be using swap partition
        echo -e "\e[33mSKIP\e[0m (no swapfile, using partition)"
    fi
}

test_memory_parameters() {
    test_name "Memory sysctl parameters are set"
    local swappiness
    swappiness=$(cat /proc/sys/vm/swappiness 2>/dev/null || echo "")
    if [[ "$swappiness" == "10" ]]; then
        pass
    else
        fail "Expected vm.swappiness=10, got: $swappiness"
    fi
}

# ── Run All Tests ──────────────────────────────
echo "Rubik OS — Cell Tests: F0 (Kernel & Memory)"
echo "═══════════════════════════════════════════"
echo ""

test_zram_device_exists
test_zram_compression_algorithm
test_zram_active_as_swap
test_zram_has_size
test_swapfile_exists
test_memory_parameters

echo ""
echo "═══════════════════════════════════════════"
echo "Results: $PASS passed, $FAIL failed"

if [[ $FAIL -gt 0 ]]; then
    exit 1
fi
exit 0
