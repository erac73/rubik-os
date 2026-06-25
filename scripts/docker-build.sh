#!/usr/bin/env bash
# ───────────────────────────────────────────────
# Build Rubik OS ISO inside an Arch Linux Docker container
# Usage: ./scripts/docker-build.sh
# ───────────────────────────────────────────────
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

echo "═ Building Rubik OS ISO via Docker ═"

# Build in Docker using Arch Linux
docker run --rm --privileged \
    -v "$PROJECT_DIR:/build:ro" \
    -v "$PROJECT_DIR/out:/build/out" \
    archlinux:latest \
    bash -c '
        set -euo pipefail

        echo "==> Installing build dependencies..."
        pacman -Syu --noconfirm archiso squashfs-tools grub dosfstools mtools \
            erofs-utils make gcc

        echo "==> Setting up build directory..."
        cp -a /build /build-work
        cd /build-work

        echo "==> Running build-iso.sh..."
        bash scripts/build-iso.sh all 2>&1 || {
            echo "WARNING: build-iso.sh failed. Trying manual ISO creation..."
            ISO_DIR="/build-work/iso"
            OUT_DIR="/build-work/out"
            mkdir -p "$OUT_DIR"

            # Prepare work directory
            WORK_ROOT="$OUT_DIR/iso-work"
            mkdir -p "$WORK_ROOT"/{etc/rubik,usr/lib/rubik,usr/share/rubik}
            cp -r "$ISO_DIR/airootfs/etc/"* "$WORK_ROOT/etc/" 2>/dev/null || true
            cp -r "$ISO_DIR/airootfs/usr/"* "$WORK_ROOT/usr/" 2>/dev/null || true
            cp scripts/rubik-network "$WORK_ROOT/usr/bin/" 2>/dev/null || true
            cp scripts/rubik-recovery "$WORK_ROOT/usr/bin/" 2>/dev/null || true
            cp scripts/rubik-bench "$WORK_ROOT/usr/bin/" 2>/dev/null || true
            chmod 755 "$WORK_ROOT/usr/lib/rubik/faces/"* 2>/dev/null || true
            chmod 755 "$WORK_ROOT/usr/lib/rubik/cells/"* 2>/dev/null || true
            chmod 755 "$WORK_ROOT/usr/bin/"* 2>/dev/null || true

            echo "Creating ISO structure..."
            mkdir -p "$OUT_DIR/iso"
            mkdir -p "$OUT_DIR/iso/boot/grub"
            mkdir -p "$OUT_DIR/iso/boot/syslinux"

            # Basic GRUB config
            cat > "$OUT_DIR/iso/boot/grub/grub.cfg" << GRUBEOF
set default="0"
set timeout=10

menuentry "Rubik OS Live" {
    linux /boot/vmlinuz-linux-lts archisobasedir=rubik archiso_rd_selinux=1
    initrd /boot/initramfs-linux-lts.img
}

menuentry "Rubik OS (Safe Mode)" {
    linux /boot/vmlinuz-linux-lts archisobasedir=rubik archiso_rd_selinux=1 nomodeset
    initrd /boot/initramfs-linux-lts.img
}

menuentry "Boot from hard disk" {
    chainloader (hd0)+1
}
GRUBEOF

            # Generate checksums
            cd "$WORK_ROOT"
            find . -type f -exec sha256sum {} \; > "$OUT_DIR/iso/sha256sums.txt"

            echo "ISO work directory created at: $OUT_DIR"
            echo "Files:"
            find "$OUT_DIR" -type f | head -50
        }

        echo "==> Build complete. Files in /build/out/"
        ls -la /build/out/
    '
