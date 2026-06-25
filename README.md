# Rubik OS

**Una distribución Linux basada en Arch Linux, optimizada para memoria y con arquitectura descentralizada inspirada en el Cubo Rubik.**

Rubik OS no es solo un tema visual — es una reorganización fundamental de cómo los componentes del sistema interactúan. Cada componente es una "celda" independiente que puede ser intercambiada, rotada y optimizada sin afectar al resto del sistema.

## Filosofía

- **Cada cara resuelve una función**: 6 caras = 6 subsistemas esenciales
- **Cada celda es independiente**: 9 celdas por cara = 54 componentes atómicos
- **El centro conecta todo**: el kernel y el orquestador Rubik son el eje central
- **Rotación**: los componentes pueden reemplazarse/actualizarse sin reiniciar
- **Eficiencia sobre features**: cada celda hace una cosa y la hace bien

## Las 6 Caras

| Cara | Subsistema | Función principal |
|------|-----------|-------------------|
| **F0** | Kernel & Memoria | Kernel optimizado, gestión de RAM/swap, compresión ZRAM |
| **F1** | Procesos & Servicios | Systemd modular, planificación de procesos, cgroups |
| **F2** | Almacenamiento | Filesystem optimizado, montajes lazy, caché inteligente |
| **F3** | Red & Comunicación | Network stack ligero, DNS local, firewall minimal |
| **F4** | Interfaz & Experiencia | WM minimal (River/Hyprland), terminal, launcher |
| **F5** | Seguridad & Aislamiento | Sandboxing, MAC (AppArmor), cifrado, aislamiento de celdas |

## Requisitos mínimos

| Componente | Mínimo | Recomendado |
|-----------|--------|-------------|
| RAM | 256 MB | 1 GB |
| CPU | x86_64, 1 core | x86_64, 2 cores |
| Almacenamiento | 4 GB | 8 GB |
| GPU | Cualquier compatible con fbdev | Cualquier con KMS/drm |

## Arranque rápido

```bash
# Construir la ISO
./scripts/build-iso.sh

# La ISO queda en: out/rubik-os-YYYYMMDD-x86_64.iso
```

## Estructura del proyecto

```
rubik-os/
├── docs/
│   ├── architecture/        # Documentos de arquitectura
│   │   ├── 00-overview.md
│   │   ├── 01-kernel-memory.md
│   │   ├── 02-process-service.md
│   │   ├── 03-storage.md
│   │   ├── 04-network.md
│   │   ├── 05-ui-ux.md
│   │   └── 06-security.md
│   └── faces/               # Documentación por cara
│       ├── face-0.md
│       ├── face-1.md
│       ├── face-2.md
│       ├── face-3.md
│       ├── face-4.md
│       └── face-5.md
├── iso/
│   ├── airootfs/            # Sistema de archivos raíz de la ISO
│   │   ├── etc/
│   │   └── usr/
│   ├── archiso/             # Configuración de ArchISO
│   └── profiledef.sh        # Perfil de construcción
├── packages/
│   ├── core/                # PKGBUILDs del núcleo Rubik
│   └── faces/               # PKGBUILDs de componentes por cara
├── scripts/
│   ├── build-iso.sh         # Construye la ISO completa
│   ├── rubik-orchestrator   # Orquestador central (bash)
│   └── rubik-init           # Init script del sistema
├── tests/
│   └── ...                  # Tests de componentes
└── README.md
```

## Licencia

GNU General Public License v3.0
