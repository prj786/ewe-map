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
· **v2.0.0 (in ewe 0.39.0-beta, the UI revamp)**; 1.1.0 in 0.25.1, 1.0.0 in 0.25.0 · API 3 ·
**plugin since 0.25** (was the CPU + memory meters in Quick settings).

**2.0.0 (owner, 2026-11-01): "plugin for ram usages should have one more section for
internet speed. Totally remove it from control center."** It left Quick settings
entirely; it lives in the bar, with a card, and optionally on the desktop.

| kind | file | shows |
|---|---|---|
| `bar-widget` (right, **shown by default**) | `Widget.qml` | "CPU % · Memory % · ↓ speed" (per `bar_shows`); a click opens the card |
| `panel` | `Panel.qml` + `Card.qml` | the card as an `AnchoredPopup` under the readout: CPU % + one-minute sparkline, Memory "8.4 GB of 30.8 GB" + meter + swap, **Internet** ↓/↑ with sparklines and the link ("Wi-Fi · <name>", "Ethernet", "VPN", "Offline"), a **Show on desktop** switch, a cog → Komble's Plugins |
| `desktop-widget` (off until turned on) | `Desk.qml` | the same card on the host's Glass card; pin / lock / layer / arrange are the host's |

There is **no `quick-tile`** any more (1.x's span-2 tile and `Tile.qml` are gone).

## Facts

- **Install:** Komble → Plugins, or `ewe-plugin install ewe.sysmon`. Not seeded on a
  fresh machine (bundle `default: false`, like every add-on); "shown by default"
  means: once installed, the readout is in the bar without a second step.
- **Settings** (manifest schema, live): `bar_shows` = "All three" | "CPU + memory" |
  "Speed" (Speed shows ↓ and ↑); `speed_unit` = "MB/s" (1024-based, like downloads) |
  "Mbit/s" (1000-based, like speed tests). The values ARE the labels — Komble shows a
  choice's value.
- **Show in the bar / Show on the desktop are the host's**, not plugin settings:
  `ewe-plugin bar ewe.sysmon on|off`, `ewe-plugin place ewe.sysmon --visible on|off`
  (the card's switch calls `PluginHost.setWidgetVisible`, CLI fallback). Komble's
  plugin sheet shows the same two switches.
- **`desktopWidget.visible: false`** in the manifest — the host's manifest default for
  a widget's visibility (ewe 0.39); a stored `place --visible` wins.
- **Sampling only while held** (`hold()` ref-count): the readout while shown, the card
  while open, the widget while visible. Every 1.5 s, **3 s on battery**
  (`Shell.lowPower`). With the readout on by default that is one `sh` per tick for the
  whole session (~5 ms).
- `sample.sh` (one process per tick, one JSON object): `/proc/stat`, `/proc/meminfo`
  (+ swap, core count), and the **default-route interface** (lowest metric of the UP
  routes in `/proc/net/route`) with its `/proc/net/dev` byte counters. The rate is a
  delta over real elapsed time; **no rate** on the first sample, after an interface
  change, after a counter reset, or with no time passed. Wi-Fi vs Ethernet from
  `/sys/class/net/<if>/wireless`; the Wi-Fi name is NetworkManager's connection
  profile name (trimmed) via `NetState`, not a scanned SSID. Fixture env:
  `SYSMON_STAT`, `SYSMON_MEMINFO`, `SYSMON_NETDEV`, `SYSMON_ROUTE`. `./test.sh`
  (46 checks) pins the contract.
- **IPC (public, 2.0.0):** `qs ipc call ewe.sysmon toggle|hide` (the card).
- Reads through `import qs`, each with a fallback: `PluginHost.placement`,
  `PluginHost.setWidgetVisible`, `PluginHost.tool`, `NetState.wifi.connection`; the
  glyphs `icActivity`/`icArrowDown`/`icArrowUp` if Theme has them, else Lucide
  codepoints.

> **Build guard:** never sample without a holder — the readout is on by default now,
> so a stray poll costs battery on every machine that installed it. And never put the
> monitor back into Quick settings (owner, 2026-11-01).

## Related

- [[Plugin System]] · [[Plugin Manifest Reference]] · [[UI Revamp — one product]]
