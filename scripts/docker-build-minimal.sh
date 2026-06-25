#!/usr/bin/env bash
set -euo pipefail
echo "START $(date -Iseconds)"
pacman -Syu --noconfirm 2>&1 | tail -1
pacman -S --noconfirm archiso squashfs-tools grub dosfstools mtools erofs-utils 2>&1 | tail -1
command -v mkarchiso
cd /rubik-os
echo "Building ISO..."
mkarchiso -v -w /tmp/work -o /rubik-os/out iso/ 2>&1
echo "ISO_BUILD_OK"
ls -lh /rubik-os/out/*.iso 2>/dev/null || echo "NO_ISO_FOUND"
echo "END $(date -Iseconds)"
