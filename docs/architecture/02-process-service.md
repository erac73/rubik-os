# Process & Service Architecture

## Cell Lifecycle

Each cell (component) follows a strict lifecycle managed by rubikd:

```
        ┌─────────────────────────────────────┐
        │           REGISTERED                 │
        │  (defined in cells.toml)             │
        └─────────────┬───────────────────────┘
                      │
                      ▼
        ┌─────────────────────────────────────┐
        │            LOADED                    │
        │  (dependencies resolved)             │
        └─────────────┬───────────────────────┘
                      │
                      ▼
        ┌─────────────────────────────────────┐
        │            ACTIVE                    │
        │  (process running)                   │
        └─────────────┬───────────────────────┘
                      │
              ┌───────┴───────┐
              ▼               ▼
    ┌──────────────┐   ┌──────────────┐
    │   HEALTHY    │   │  DEGRADED    │
    │  (responds)  │   │  (slow/high  │
    └───────┬──────┘   │   mem usage) │
            │          └───────┬──────┘
            │                  │
            │          ┌───────▼───────┐
            │          │    RETRY      │
            │          │  (restart)    │
            │          └───────┬───────┘
            │                  │
            ▼                  ▼
        ┌─────────────────────────────────────┐
        │            STOPPED                   │
        │  (intentional or after max retries)  │
        └─────────────────────────────────────┘
```

## Dependency Resolution

Cells declare dependencies via `cell_deps()` function. The orchestrator
resolves them topologically using Kahn's algorithm:

```
Input: cell definitions with dependency lists
Output: ordered execution list

1. Calculate in-degree for each cell
2. Process cells with in-degree 0 first
3. Decrement in-degree of dependents
4. Repeat until all cells processed
```

If a circular dependency is detected, rubikd logs an error and ignores
the lowest-priority cell in the cycle.

## IPC Between Cells

Cells never import each other. Communication happens through:

1. **D-Bus** — system bus for high-level coordination
2. **Unix sockets** — `/run/rubik/<cell>.sock` for cell-to-cell
3. **Shared memory** — `/run/rubik/shm/` for performance-critical data
4. **Files** — `/run/rubik/state/` for persistent state

A cell may only access:
- Its own directory: `/run/rubik/cells/<name>/`
- Face shared directory: `/run/rubik/faces/<face>/`
- Global read-only: `/run/rubik/state/`

## Resource Limits Per Cell

Each cell is constrained by systemd/cgroup:

| Resource | Default Limit | Critical Cells |
|----------|--------------|----------------|
| Memory (soft) | 192 MB | 384 MB |
| Memory (hard) | 256 MB | 512 MB |
| CPU weight | 100 | 200 |
| IO weight | 50 | 100 |
| Tasks (PIDs) | 32 | 64 |
| File descriptors | 256 | 1024 |
