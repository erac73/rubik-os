# Rubik OS

> **Optimizada para memoria. Arquitectura descentralizada. Inspirada en el Cubo Rubik.**
> Una distribución Linux basada en Arch para equipos con pocos recursos.

[![License: GPL v3](https://img.shields.io/badge/License-GPLv3-blue.svg)](https://www.gnu.org/licenses/gpl-3.0)
[![Arch Linux](https://img.shields.io/badge/Base-Arch_Linux-1793D1?logo=arch-linux&logoColor=white)](https://archlinux.org)
[![RAM Idle](https://img.shields.io/badge/RAM_idle-80%E2%80%93120_MB-success)]()
[![CI](https://github.com/erac73/rubik-os/actions/workflows/ci.yml/badge.svg)](https://github.com/erac73/rubik-os/actions/workflows/ci.yml)

<p align="center">
  <img src="assets/logo.svg" alt="Rubik OS Logo" width="256" height="256">
</p>

---

## About — English

**Rubik OS** is an Arch Linux-based distribution optimized for low-memory hardware. It runs at **80-120 MB RAM idle** by reorganizing every component into independent cells — like the faces of a Rubik's Cube. Each cell has its own cgroup, AppArmor profile, and resource limits. Cells can be replaced at runtime without rebooting.

Target: old laptops, single-board computers, VMs, and anyone who wants a lean, modular Linux.

---

## Motivación

Los sistemas operativos modernos desperdician memoria. Un Linux promedio usa **300-400 MB** en idle solo con el sistema base. Rubik OS demuestra que se puede tener un sistema completo, funcional y seguro usando **80-120 MB** — sin sacrificar capacidad.

**¿Cómo?** Reorganizando cada componente como una celda independiente, como las caras de un Cubo Rubik. Cada celda tiene un propósito único, recursos limitados, y puede ser reemplazada sin afectar al resto.

---

## Las 6 Caras

```
        ┌─────┬─────┬─────┐
        │  F4 │  F4 │  F4 │
        │  UI  │  &  │  UX  │
        ├─────┼─────┼─────┤
   ┌────┼─────┼─────┼─────┼────┬─────┬─────┬─────┐
   │ F5 │ F5  │ F5  │ F3  │ F3 │ F3  │ F3  │ F3  │
   │Seg │ &   │Isla │Red  │ &  │Comu │nica │ción │
   ├────┼─────┼─────┼─────┼────┼─────┼─────┼─────┤
   │cur │idad │     │     │    │     │     │     │
   └────┴─────┴─────┴─────┴────┴─────┴─────┴─────┘
        │  F2 │  F2 │  F2 │
        │Alma │cena │miento│
        ├─────┼─────┼─────┤
        │  F1 │  F1 │  F1 │
        │Proce│sos  │& Svc│
        ├─────┼─────┼─────┤
        │  F0 │  F0 │  F0 │
        │Kernel│& Mem│oria │
        └─────┴─────┴─────┘
```

| Cara | Subsistema | Celdas | ¿Qué hace? |
|------|-----------|--------|------------|
| **F0** | Kernel & Memoria | 9 | ZRAM, earlyOOM, IRQ balance, CPU governor, predicción de memoria |
| **F1** | Procesos & Servicios | 9 | RubikD orchestrator, cgroups, scheduler tuning, init mínimo |
| **F2** | Almacenamiento | 9 | Btrfs subvolumes, tmpfs, trim, dedup, mount manager |
| **F3** | Red & Comunicación | 11 | iwd (wifi), nftables, DNS cache, chrony, bandwidth limiter, bluetooth |
| **F4** | Interfaz & Experiencia | 11 | River WM, waybar, foot terminal, mako notificaciones, pipewire |
| **F5** | Seguridad & Aislamiento | 9 | AppArmor, bubblewrap, LUKS, cell isolation, audit |

**56 celdas atómicas. 6 caras. 1 sistema.**

---

## Eficiencia vs Linux estándar

| Métrica | Linux promedio | Rubik OS | Mejora |
|---------|---------------|----------|--------|
| 💾 RAM idle (sin GUI) | ~300-400 MB | **~80-120 MB** | 60-70% |
| 🖥 RAM idle (con GUI) | ~800-1200 MB | **~250-400 MB** | 55-65% |
| 🚀 Arranque a shell | ~15-30s | **~5-10s** | 50-65% |
| 🚀 Arranque a GUI | ~30-60s | **~10-20s** | 55-65% |
| 🔄 Procesos en idle | ~400-600 | **~80-150** | 60-75% |
| 📦 Tamaño ISO (xz) | ~2-3 GB | **~2.8 GB** | — |

## Requisitos mínimos

| Componente | Mínimo | Recomendado |
|-----------|--------|-------------|
| RAM | **256 MB** | 1 GB |
| CPU | **x86_64, 1 core** | 2+ cores |
| Almacenamiento | **4 GB** | 8 GB+ |
| GPU | fbdev compatible | KMS/drm |

---

## Descargar

Descarga la última ISO desde [GitHub Releases](https://github.com/erac73/rubik-os/releases).

```bash
# Descargar partes
wget https://github.com/erac73/rubik-os/releases/download/v1.0.0/rubik-os-20260627-x86_64.iso.xz.part_aa
wget https://github.com/erac73/rubik-os/releases/download/v1.0.0/rubik-os-20260627-x86_64.iso.xz.part_ab

# Reconstruir
cat rubik-os-*.iso.xz.part_* > rubik-os-20260627-x86_64.iso.xz
xz -d rubik-os-20260627-x86_64.iso.xz

# Lista — ISO reconstruida
ls -lh rubik-os-*.iso
```

### O construir en Docker

```bash
git clone https://github.com/erac73/rubik-os.git
cd rubik-os
./scripts/docker-build.sh
```

### Bootear desde USB

```bash
# Una vez construida la ISO, grabarla en USB
# Linux:
dd if=out/rubik-os-*.iso of=/dev/sdX bs=4M status=progress && sync

# Windows (usando Rufus):
# 1. Seleccionar la ISO en out/
# 2. Modo: "DD Image" (NO "ISO Image")
# 3. Escribir

# macOS:
# sudo dd if=out/rubik-os-*.iso of=/dev/diskX bs=4m status=progress
```

> **Importante**: Usar siempre modo **DD Image** (Rufus) o `dd` directo. El modo "ISO Image" no bootea correctamente.

Una vez grabada:
1. Conectar USB y reiniciar
2. Bootear desde USB (F12/F2/F7/ESC según el equipo)
3. Seleccionar **"Rubik OS Live"** en GRUB
4. El sistema arranca en modo live → ejecutar `rubik-install` para instalar

### Gestionar el sistema

```bash
# Ver estado de todas las celdas
rubikctl status

# Health check
rubikctl health

# Reemplazar una celda en caliente
rubikctl cell rotate memory-compression

# Rotar una cara completa
rubikctl face rotate F0
```

---

## Arquitectura

Cada celda es un proceso/servicio independiente con:

```
📦 Celda
├── Propio cgroup (memoria, CPU, IO aislados)
├── Propio perfil AppArmor
├── Límite: 256 MB RAM, 32 procesos, 256 fds
├── Comunicación IPC vía D-Bus / Unix sockets
└── Ciclo de vida: REGISTERED → LOADED → ACTIVE → HEALTHY
```

### Stack tecnológico

```
┌─────────────────────────────────────────────┐
│              River WM / Waybar              │  ← UI minimalista
├─────────────────────────────────────────────┤
│         RubikD Orquestador (bash)           │  ← Gestiona celdas
├─────────────────────────────────────────────┤
│  systemd (minimal)  │  iwd  │  nftables     │  ← Servicios esenciales
├─────────────────────────────────────────────┤
│  ZRAM  │  earlyOOM  │  AppArmor  │  cgroups  │  ← Memoria + Seguridad
├─────────────────────────────────────────────┤
│            Linux Kernel LTS                 │  ← Optimizado para baja memoria
└─────────────────────────────────────────────┘
```

---

## Estructura del proyecto

```
rubik-os/
├── iso/                          # Perfil de ArchISO
│   ├── airootfs/                 # Sistema de archivos raíz del live ISO
│   │   ├── etc/                  # Configuración del sistema
│   │   │   ├── apparmor.d/       # Perfiles AppArmor
│   │   │   ├── rubik/            # Configuración de Rubik OS (cells.toml)
│   │   │   ├── rsyslog.d/        # Logging
│   │   │   ├── logrotate.d/      # Rotación de logs
│   │   │   └── sysctl.d/         # Parámetros del kernel
│   │   └── usr/
│   │       ├── bin/              # Scripts del sistema (rubikd, rubikctl, etc.)
│   │       ├── lib/
│   │       │   ├── rubik/
│   │       │   │   ├── cells/    # 36 scripts de celda
│   │       │   │   └── faces/    # 6 scripts de cara
│   │       │   └── systemd/
│   │       │       └── system/   # 8 units systemd
│   │       └── share/
│   │           ├── grub/         # Tema GRUB
│   │           └── rubik/        # Completions, assets
│   ├── grub/                     # Configuración GRUB para la ISO
│   ├── profiledef.sh             # Perfil de mkarchiso
│   ├── packages.x86_64           # Paquetes del live ISO
│   └── pacman.conf               # Configuración de pacman para la ISO
├── scripts/                      # Scripts del sistema
│   ├── rubik-orchestrator        # Orquestador de celdas (rubikd/rubikctl)
│   ├── rubik-install             # Instalador del sistema
│   ├── rubik-init                # Inicialización del sistema
│   ├── rubik-network             # Gestor de red
│   ├── rubik-recovery            # Herramientas de recuperación
│   ├── rubik-bench               # Benchmarks
│   ├── rubik-boot                # Bootloader helper
│   ├── rubik-configure           # Configuración post-instalación
│   ├── build-iso.sh              # Script de build ISO
│   ├── qemu-test.sh              # Test en QEMU
│   └── docker-build.sh           # Build ISO en Docker
├── packages/                     # PKGBUILDs
│   └── core/rubik-core/          # Paquete rubik-core
├── tests/                        # Tests bats
│   ├── orchestrator.bats         # 30+ tests
│   └── test-zram.sh
├── docs/                         # Documentación
│   ├── architecture/             # 7 documentos de arquitectura
│   └── faces/                    # Documentación por cara
├── assets/
│   └── logo.svg                  # Logo oficial (SVG vectorial)
├── .github/workflows/            # CI/CD (lint, tests, build-check, docker-build)
├── README.md
└── LICENSE
```

---

## Personalización

¿No te gusta River WM? Cambia la celda:

```bash
rubikctl cell stop F4.0
# Reemplaza /usr/lib/rubik/cells/F4.0.sh
rubikctl cell start F4.0
```

¿Quieres más espacio en ZRAM?

```bash
echo "200% de tu RAM" > /etc/rubik/overrides.toml
rubikctl cell rotate memory-compression
```

Cada celda es reemplazable sin reiniciar. Como un Cubo Rubik: gira la cara que quieras.

---

## Estado del proyecto

| Componente | v1.0.0 |
|---|---|---|
| Scripts de celda | **36** |
| Scripts de cara | **6/6** (100%) |
| Systemd units | **8** (rubikd, rubik-cell@, rubik-face@, rubik.target, rubik-bluetooth, rubik-pipewire, rubik-wireplumber, rubik-wifi) |
| AppArmor profiles | **3** (rubik-cell, rubik-cell-network, rubik-cell-security) |
| Scripts de sistema | **rubik-network**, **rubik-recovery**, **rubik-bench**, **rubik-configure**, **rubik-boot** |
| Orquestador | daemon mode, bootstrap, validate, health checks, shutdown, face ops |
| Tests | **30+** tests bats |
| CI/CD | GitHub Actions (shellcheck, validación, tests, integridad, build ISO en Docker) |
| Instalador | Interactivo + `--yes --disk=/dev/sda` + validación pre-instalación |
| Logging | rsyslog + logrotate por face |
| Shell completion | bash (rubikctl + rubikd) |
| QEMU test | `scripts/qemu-test.sh` para booteo UEFI/BIOS |
| Recovery | `rubik-recovery` con rollback, snapshot, fsck, fallback, initramfs |
| Benchmarks | `rubik-bench` (ZRAM, memoria, CPU, disco) |
| Post-install | `rubik-configure` (audio, BT, WiFi, GPU, power, printing, firewall) |
| Audio | PipeWire + WirePlumber + ALSA |
| Bluetooth | Bluez + cell script |
| WiFi | iwd + NetworkManager + wpa_supplicant |
| GPU | AMD/Intel/NVIDIA auto-detect |
| GNU Toolchain | gcc, make, autoconf, automake, binutils, glibc, python, go, rust |
| Firmware | linux-firmware, amd-ucode, intel-ucode, sof-firmware |
| Desktop | river, waybar, rofi, foot, dunst, swaybg, swaylock |
| Impresión | CUPS + HPLIP + SANE |
| Licencia | GPLv3 |

Próximo: v1.1.0

---

## Desarrollo

### Build ISO en Docker

```bash
./scripts/docker-build.sh
```

### Test ISO en QEMU

```bash
./scripts/qemu-test.sh              # UEFI
./scripts/qemu-test.sh out/rubik-os-*.iso bios 4096  # BIOS con 4GB
```

---

## Lo que falta para v1.1.0

- [ ] Repositorio de paquetes `[rubik]` en pacman.conf
- [ ] CI publish: subir ISO a release automáticamente
- [ ] Reducir tamaño de ISO

### ✅ v1.0.0 — Completado

- [x] ISO booteable construida y publicada en GitHub Releases
- [x] 8 celdas stub implementadas (cgroup-manager, crypto, dedup, firejail, initramfs, sandbox-exec, update-auth, cell-isolation)
- [x] `packages/faces/face-0` a `face-5` con PKGBUILDs
- [x] Issue/PR templates en `.github/`
- [x] `CONTRIBUTING.md` y `CODE_OF_CONDUCT.md`
- [x] Systemd units movidas a `system/` (path estándar)
- [x] `rubik-boot` creado y empaquetado en ISO + PKGBUILD
- [x] Face ops corregidas (leen cells.toml en vez de directorios)
- [x] Tests actualizados con paths correctos
- [x] Docker scripts limpiados (solo docker-build.sh)

---

## Licencia

**GNU General Public License v3.0** — Software libre para todos.
