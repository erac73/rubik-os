# Contributing to Rubik OS

## Células

Cada celda es un script en `iso/airootfs/usr/lib/rubik/cells/` con tres funciones:

- `cell_start()` — Inicia el servicio
- `cell_stop()` — Lo detiene limpiamante
- `cell_health()` — Retorna 0 si funciona

Toda celda nueva debe:
1. Crear el script con esas 3 funciones
2. Registrarla en `iso/airootfs/etc/rubik/cells.toml`
3. Agregar permisos en `iso/profiledef.sh`
4. Agregar al source del PKGBUILD en `packages/core/rubik-core/PKGBUILD`

## Caras

Cada cara es un orquestador en `iso/airootfs/usr/lib/rubik/faces/face-N.sh`.
Agrupa las celdas de un subsistema y expone una función `main()`.

## Tests

```bash
# Instalar bats
sudo pacman -S bats

# Correr tests
bats tests/
```

## CI

El CI corre en GitHub Actions en cada push a main y PR:
- shellcheck en todos los scripts
- Validación de cells.toml
- Tests bats
- Build ISO en Docker

## Convenciones

- Bash estricto: `set -euo pipefail`
- Nombres en kebab-case para celdas
- Sin comentarios superfluos
- `cell_deps()` debe listar las dependencias separadas por espacio
