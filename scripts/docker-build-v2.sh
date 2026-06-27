#!/usr/bin/env bash
set -euo pipefail

echo "==> Installing build deps..."
pacman -Sy --noconfirm
pacman -S --noconfirm archiso squashfs-tools grub dosfstools mtools

echo "==> Ensuring working mirrorlist..."
curl -fsSLo /etc/pacman.d/mirrorlist "https://archlinux.org/mirrorlist/?country=all&protocol=https&use_mirror_status=on"
sed -i 's/^#Server/Server/' /etc/pacman.d/mirrorlist
head -3 /etc/pacman.d/mirrorlist

echo "==> Building ISO..."
cd /rubik-os
rm -rf /tmp/work /rubik-os/out/iso /rubik-os/out/iso-work
mkdir -p /rubik-os/out
mkarchiso -v -w /tmp/work -o /rubik-os/out iso/

EXIT_CODE=$?
echo "=== BUILD DONE. EXIT CODE: $EXIT_CODE ==="
ls -lh /rubik-os/out/*.iso 2>/dev/null || echo "NO_ISO"
ls -lh /rubik-os/out/
