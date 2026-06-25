#!/usr/bin/env bash
set -euo pipefail

echo "STEP 1: System update"
pacman -Syu --noconfirm 2>&1 | tail -5 || echo "UPDATE FAILED"

echo "STEP 2: Install build tools"
pacman -S --noconfirm archiso squashfs-tools grub dosfstools mtools 2>&1 | tail -5 || echo "INSTALL FAILED"

echo "STEP 3: mkarchiso check"
command -v mkarchiso && mkarchiso --version || echo "MKARCHISO NOT FOUND"

echo "STEP 4: Prepare build environment"
mkdir -p /rubik-os/out/{iso-work,iso/boot/grub}
ISO_DIR="/rubik-os/iso"
WORK_ROOT="/rubik-os/out/iso-work"
OUT_ISO="/rubik-os/out/iso"

echo "STEP 5: Copy airootfs"
cp -r "$ISO_DIR/airootfs/etc/"* "$WORK_ROOT/etc/" 2>/dev/null && echo "  etc copied" || echo "  etc copy failed"
cp -r "$ISO_DIR/airootfs/usr/"* "$WORK_ROOT/usr/" 2>/dev/null && echo "  usr copied" || echo "  usr copy failed"

echo "STEP 6: Copy scripts"
cp /rubik-os/scripts/rubik-network "$WORK_ROOT/usr/bin/" 2>/dev/null || true
cp /rubik-os/scripts/rubik-recovery "$WORK_ROOT/usr/bin/" 2>/dev/null || true
cp /rubik-os/scripts/rubik-bench "$WORK_ROOT/usr/bin/" 2>/dev/null || true

echo "STEP 7: Set permissions"
chmod 755 "$WORK_ROOT/usr/lib/rubik/faces/"* 2>/dev/null || true
chmod 755 "$WORK_ROOT/usr/lib/rubik/cells/"* 2>/dev/null || true
chmod 755 "$WORK_ROOT/usr/bin/rubik-network" "$WORK_ROOT/usr/bin/rubik-recovery" "$WORK_ROOT/usr/bin/rubik-bench" 2>/dev/null || true
chmod 644 "$WORK_ROOT/etc/rubik/"* 2>/dev/null || true
chmod 644 "$WORK_ROOT/etc/apparmor.d/rubik/"* 2>/dev/null || true
chmod 644 "$WORK_ROOT/etc/rsyslog.d/"* 2>/dev/null || true
chmod 644 "$WORK_ROOT/etc/logrotate.d/"* 2>/dev/null || true
chmod 644 "$WORK_ROOT/usr/lib/systemd/rubik-services/"* 2>/dev/null || true

echo "STEP 8: GRUB config"
cat > "$OUT_ISO/boot/grub/grub.cfg" << 'GRUBEOF'
set default="0"
set timeout=10
menuentry "Rubik OS Live" {
    linux /boot/vmlinuz-linux-lts archisobasedir=rubik
    initrd /boot/initramfs-linux-lts.img
}
menuentry "Rubik OS (Safe Mode)" {
    linux /boot/vmlinuz-linux-lts archisobasedir=rubik nomodeset
    initrd /boot/initramfs-linux-lts.img
}
menuentry "Boot from hard disk" {
    chainloader (hd0)+1
}
GRUBEOF
echo "  GRUB config written"

echo "STEP 9: Generate validation report"
{
    echo "=== Rubik OS Build Validation Report ==="
    echo "Date: $(date -Iseconds)"
    echo "Kernel: $(uname -r)"
    echo ""

    echo "=== File Structure ==="
    find "$WORK_ROOT" -type f | sort

    echo ""
    echo "=== Cell Scripts ==="
    for f in /rubik-os/iso/airootfs/usr/lib/rubik/cells/*.sh; do
        name=$(basename "$f")
        has_start=$(grep -c "^cell_start()" "$f" 2>/dev/null || echo "0")
        has_stop=$(grep -c "^cell_stop()" "$f" 2>/dev/null || echo "0")
        has_health=$(grep -c "^cell_health()" "$f" 2>/dev/null || echo "0")
        lines=$(wc -l < "$f")
        echo "  $name: ${lines}L cell_start=${has_start} cell_stop=${has_stop} cell_health=${has_health}"
    done

    echo ""
    echo "=== System Scripts ==="
    for f in /rubik-os/scripts/*; do
        [ -f "$f" ] || continue
        name=$(basename "$f")
        lines=$(wc -l < "$f")
        echo "  $name: ${lines}L"
    done

    echo ""
    echo "=== Systemd Units ==="
    ls -la /rubik-os/iso/airootfs/usr/lib/systemd/rubik-services/

    echo ""
    echo "=== AppArmor Profiles ==="
    ls -la /rubik-os/iso/airootfs/etc/apparmor.d/rubik/

    echo ""
    echo "=== Logging Config ==="
    ls -la /rubik-os/iso/airootfs/etc/rsyslog.d/
    ls -la /rubik-os/iso/airootfs/etc/logrotate.d/

    echo ""
    echo "=== Sysctl Config ==="
    ls -la /rubik-os/iso/airootfs/etc/sysctl.d/

    echo ""
    echo "=== ISO GRUB Config ==="
    cat "$OUT_ISO/boot/grub/grub.cfg"
} > /rubik-os/out/build-report.txt

echo "STEP 10: Report generated"
ls -la /rubik-os/out/
echo "DONE: /rubik-os/out/build-report.txt"
wc -l /rubik-os/out/build-report.txt
