# Face 4 — UI & Experience

La cara visible de Rubik OS. Minimalista, funcional, eficiente. Sin efectos innecesarios, sin animaciones que consumen CPU/RAM.

## Celdas

### [F4.0] wm-core
Window Manager:
- **River** en Wayland (recomendado) — < 10 MB RAM, config VGA dinámica
- Alternativa: **Hyprland** si se desean más efectos (aún ligero, < 50 MB RAM)
- Sin compositor separado (el WM actúa como compositor)
- Config: `/etc/rubik/cells/face-4/wm.conf`

### [F4.1] bar-status
Barra de estado minimal:
- **waybar** con módulos esenciales: CPU, RAM, fecha, red
- Sin animaciones, sin gráficos
- Pool de actualización: cada 2 segundos
- `< 15 MB RAM`

### [F4.2] launcher
Lanzador de aplicaciones:
- **fuzzel** (Wayland nativo, < 5 MB RAM)
- Alternativa: **rofi** si se necesita más funcionalidad
- Cache de aplicaciones pre-construido (no escanear PATH cada vez)

### [F4.3] terminal
Terminal:
- **foot** (Wayland nativo, renderizado GPU, < 10 MB RAM)
- Scrollback: 1000 líneas (no 10000)
- Sin barra de título (ahorra ~1 MB)
- Fuente: monospace 10pt (menos renderizado)

### [F4.4] compositor
Compositor (solo si X11):
- **picom** con vsync opcional
- Sin sombras, sin fade, sin animaciones
- Si Wayland: no se necesita celda separada

### [F4.5] notifier
Notificaciones:
- **mako** (Wayland nativo, < 2 MB RAM)
- Timeout por defecto: 3 segundos
- Sin historial de notificaciones
- Reglas: solo notificaciones críticas en modo fullscreen

### [F4.6] wallpaper
Gestor de wallpaper:
- **swaybg** en Wayland (< 5 MB RAM)
- Sin slideshow, sin efectos
- Imagen única PNG (no JPG, no GIF animado)

### [F4.7] clipboard
Portapapeles:
- **wl-clipboard** (Wayland)
- Sin gestor de clipboard en segundo plano
- Clipboards: solo primario y normal
- Sin persistencia entre reinicios

### [F4.8] idle-manager
Gestión de inactividad:
- **swayidle** + **swaylock**
- Lock screen después de 5 min
- Suspend después de 30 min
- Sin fondo de pantalla en lockscreen (solo color sólido)
- DPMS: 5 min blank, 10 min suspend

## Esquema de Teclas (Rubik)

| Tecla | Acción |
|-------|--------|
| `Super+Enter` | Terminal |
| `Super+Space` | Launcher |
| `Super+Q` | Cerrar ventana |
| `Super+1..9` | Cambiar workspace |
| `Super+Shift+1..9` | Mover ventana a workspace |
| `Super+H/J/K/L` | Movimiento VIM entre ventanas |
| `Super+F` | Fullscreen |
| `Super+T` | Float toggle |
| `Ctrl+Alt+T` | Terminal (alternativa) |
| `Print` | Screenshot (grim) |

## Requisitos de RAM (GUI)

| Componente | RAM |
|-----------|-----|
| River WM | ~8 MB |
| Waybar | ~15 MB |
| Foot (idle) | ~5 MB |
| Mako | ~2 MB |
| Swaybg | ~5 MB |
| Fuzzel (cuando se usa) | ~5 MB |
| **Total GUI idle** | **~40 MB** |
