# UI/UX Architecture

## Design Principles

1. **No eye candy** — No animations, no transparency, no blur
2. **Keyboard-first** — Every action accessible via keyboard
3. **Minimal pixels** — No title bars, no unnecessary chrome
4. **Dark theme** — Default dark theme saves battery on OLED
5. **Monospace everywhere** — Developer-focused aesthetics

## Window Manager Configuration

Rubik OS uses River (Wayland) with the following approach:

```
riverctl → config (no config files, all via commands on boot)
  ├── layout: master-stack (no tabbed/stacked modes)
  ├── gaps: 0 (no window gaps, waste of pixels)
  ├── border: 2px (thin, colored by urgency)
  └── master_factor: 0.55
```

The WM is started via `river-cell.sh` which is a systemd user service,
allowing the WM to be restarted without rebooting.

## Color Palette

```
Background: #1a1a1a  (near-black)
Foreground: #d4d4d4  (light gray)
Accent:     #4ec9b0  (teal — Rubik brand)
Warning:    #ce9178  (orange)
Error:      #f44747  (red)
Success:    #6a9955  (green)
Selection:  #264f78  (blue-gray)
Comment:    #6a9955  (muted green)
```

## Application Selection

Each application is chosen for minimal resource usage:

| Category | Application | RAM (idle) | Notes |
|----------|-------------|-----------|-------|
| Browser | qutebrowser | ~150 MB | WebEngine-based, vim keys |
| Editor | micro / neovim | ~10 MB | Terminal-based, no GUI |
| File manager | lf (terminal) / pcmanfm (GUI) | ~5 / ~30 MB | Minimal |
| Image viewer | imv | ~15 MB | Wayland native |
| PDF reader | zathura | ~20 MB | Minimal, vim keys |
| Music player | mpd + ncmpcpp | ~15 MB | Daemon + client |
| Video player | mpv | ~30 MB | Minimal, GPU decode |
| Screenshot | grim + slurp | ~2 MB | Wayland native |
