#!/usr/bin/env bash
# ───────────────────────────────────────────────
# Rubik OS — ArchISO Profile Definition
# ───────────────────────────────────────────────
set -euo pipefail

iso_name="rubik-os"
iso_label="RUBIK_$(date +%Y%m)"
iso_publisher="Rubik OS <https://rubik-os.org>"
iso_application="Rubik OS Live/Rescue System"
iso_version="$(date +%Y%m%d)"
install_dir="rubik"
buildmodes=('iso')
bootmodes=('bios.syslinux.mbr' 'bios.syslinux.eltorito' 'uefi-ia32.grub.esp' 'uefi-x64.grub.esp' 'uefi-ia32.grub.eltorito' 'uefi-x64.grub.eltorito')
arch="x86_64"
pacman_conf="pacman.conf"
airootfs_image_type="squashfs"
airootfs_image_tool_options=('-comp' 'zstd' '-Xcompression-level' '19')
file_permissions=(
  ["/etc/shadow"]="0:0:400"
  ["/etc/gshadow"]="0:0:400"
  ["/usr/lib/rubik/faces/face-0.sh"]="0:0:755"
  ["/usr/lib/rubik/faces/face-1.sh"]="0:0:755"
  ["/usr/lib/rubik/faces/face-2.sh"]="0:0:755"
  ["/usr/lib/rubik/faces/face-3.sh"]="0:0:755"
  ["/usr/lib/rubik/faces/face-4.sh"]="0:0:755"
  ["/usr/lib/rubik/faces/face-5.sh"]="0:0:755"
  ["/usr/lib/rubik/cells/memory-compression.sh"]="0:0:755"
  ["/usr/lib/rubik/cells/oom-guard.sh"]="0:0:755"
  ["/usr/lib/rubik/cells/cache-tune.sh"]="0:0:755"
  ["/usr/lib/rubik/cells/cpu-gov.sh"]="0:0:755"
  ["/usr/lib/rubik/cells/swap-manager.sh"]="0:0:755"
  ["/usr/lib/rubik/cells/mem-forecast.sh"]="0:0:755"
  ["/usr/lib/rubik/cells/irq-balance.sh"]="0:0:755"
  ["/usr/lib/rubik/cells/hugepages.sh"]="0:0:755"
  ["/usr/lib/rubik/cells/cgroup-manager.sh"]="0:0:755"
  ["/usr/lib/rubik/cells/sched-tune.sh"]="0:0:755"
  ["/root"]="0:0:750"
  ["/root/.automated_script.sh"]="0:0:755"
)
