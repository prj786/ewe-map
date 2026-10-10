---
tags:
  - ewe-map
  - plugin
title: System Monitor Plugin
up: "[[Plugin System]]"
---

# System monitor — `ewe.sysmon`

`~/Projects/ewe/ewe-plugin-sysmon` ·
[github.com/prj786/ewe-plugin-sysmon](https://github.com/prj786/ewe-plugin-sysmon)
· v1.1.0 (in ewe 0.25.1; 1.0.0 in 0.25.0) · API 3 · **plugin since 0.25** (was the CPU + memory meters in
Quick settings).

| kind | file | shows |
|---|---|---|
| `quick-tile` (**span 2**, order 20) | `Tile.qml` | the full-width CPU and memory meters on the home grid |
| `bar-widget` (right, opt-in) | `Widget.qml` | a compact "cpu % · mem %" readout; click opens Quick settings |

## Facts

- **Install:** Komble → Plugins, or `ewe-plugin install ewe.sysmon`.
- **The bar readout = the host's Show in bar** (1.1.0): manifest
  `barWidget.defaultShown: false` — off because a bar widget polls for the
  whole session. 1.0's own `show_in_bar` setting is gone; a value it stored
  still counts until Show in bar is set (`ewe-plugin bar ewe.sysmon on`,
  Komble → Options → In the bar).
- **Sampling only while held:** `hold()`-based — the tile samples while
  `panelOpen`, the bar readout while shown; nobody holds → no process.
  Every 1.5 s, **3 s on battery** (`Shell.lowPower`).
- `sample.sh` reads `/proc/stat` + `/proc/meminfo` in one process per tick
  and prints one JSON object; `./test.sh` (18 checks) pins the contract.
- No IPC. Needs only `sh`.

> **Build guard:** never sample without a holder — a bar widget that polls
> unconditionally costs battery on every machine that installed it.

## Related

- [[Plugin System]] · [[Plugin Manifest Reference]]
