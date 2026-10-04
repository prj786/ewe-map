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
· v1.0.0 · API 3 · **add-on since 0.25** (was the CPU + memory meters in
Quick settings).

| kind | file | shows |
|---|---|---|
| `quick-tile` (**span 2**, order 20) | `Tile.qml` | the full-width CPU and memory meters on the home grid |
| `bar-widget` (right, opt-in) | `Widget.qml` | a compact "cpu % · mem %" readout; click opens Quick settings |

## Facts

- **Install:** Komble → Add-ons, or `ewe-plugin install ewe.sysmon`.
- **Setting:** `show_in_bar` (bool, default false) — off because a bar
  widget polls for the whole session.
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
