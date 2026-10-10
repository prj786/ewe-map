---
tags:
  - ewe-map
  - plugin
title: Insomnia Plugin
up: "[[Plugin System]]"
---

# Insomnia — `ewe.insomnia`

`~/Projects/ewe/ewe-plugin-insomnia` ·
[github.com/prj786/ewe-plugin-insomnia](https://github.com/prj786/ewe-plugin-insomnia)
· v1.0.0 · API 3 · **plugin since 0.25** (was the shell's "keep awake" /
`Caffeine` — renamed by [[Insomnia — the name for keep awake]]).

Keeps the screen awake and stops sleep until you turn it off: while on,
the shell holds a Wayland idle inhibitor, so no auto-lock, no blank, no
auto-suspend (the lid and a manual lock still work).

| kind | file | shows |
|---|---|---|
| `quick-tile` (span 1, order 10) | `Tile.qml` | the tile — eye open while on; status counts down ("On · off in 25 min") |
| `bar-status` (order 10) | `Status.qml` | an eye in the Quick settings pill, only while on |
| `service` | `Service.qml` | the inhibitor + the `ewe.insomnia` IPC target |

## Facts

- **Install:** Komble → Plugins, or `ewe-plugin install ewe.insomnia`.
- **Setting:** `auto_off` (int, 0–1440 minutes, default 0 = never) —
  `ewe-plugin set ewe.insomnia auto_off 30`; a toast says when it fired.
- **IPC:** `qs ipc call ewe.insomnia toggle|on|off|status`; `status` →
  `{"on","autoOff","minutesLeft","until"}`.
- **Namespace kept:** `quickshell:caffeine` (layer rules match by name).
- Pattern worth copying: a **qmldir singleton** shares state between the
  three entry points.
- Needs nothing beyond ewe. The Screensaver's MPRIS hold-off stays core.

> **Build guard:** keep the namespace and the four verbs — Rule 4.

## Related

- [[Plugin System]] · [[Insomnia — the name for keep awake]] · [[ewe-settings]]
