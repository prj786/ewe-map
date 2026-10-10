---
tags:
  - ewe-map
  - plugin
title: Dock Plugin
up: "[[Plugin System]]"
---

# Dock — `ewe.dock`

`~/Projects/ewe/ewe-plugin-dock` ·
[github.com/prj786/ewe-plugin-dock](https://github.com/prj786/ewe-plugin-dock)
· v1.1.0 (in ewe 0.25.1; 1.0.1 in 0.25.0) · API 3 · **a first-party
plugin since 0.25** (was `Dock.qml` + `PinnedApps.qml` / `LauncherPanel`).
**Not installed on a fresh machine** — a new ewe has no dock until you add
it; upgraders keep theirs
([[Add-ons — one-time migration for upgraders]]: migrated unless
`[desktop.dock] enabled = false`).

A small centred dock at the bottom of the main screen:

`[ sheep → pinned-apps popup ] [ Overview ] [ Komble ] [ plugin dock items: Music, Places … ] | [ the Pen ] [ workspace boxes ]`

| piece | what |
|---|---|
| `panel` kind — its **own PanelWindows**, namespaces **`quickshell:dock`** and **`quickshell:launcher`** | the dock + the pinned-apps popup (type to search every app; pin badge → `ewe-conf apps.pinned` via `Shell.setPinned`) |
| dock items | renders `Shell.dockItems` (manifest `dockItem`s) filtered by `Shell.dockItemShown`; click → `Shell.runAction(action, anchor)`; lit while `Shell.isActive(action)` |
| the Pen | `special:pen` (Super+Z) — shown only while something is stashed |
| Overview | slides out on `Shell.overviewOpen` (local `durFast` close beat), back when the cards have gone; the button calls `Shell.toggleOverview()` |
| auto-hide | ducks when the workspace has a tiled/fullscreen window; returns at the bottom edge, while any dock popup is open (`Shell.activeCount > 0`), and for a moment after the pointer leaves |

## What it tells the shell

`Shell.setBottomInset("ewe.dock", cell + 2·spaceS + windowGap, !autohide)`
— reserved as an exclusive zone when auto-hide is off; **0** when
destroyed (the plugin switched off or removed), so toasts, the OSD and
every bottom-anchored popup read `Shell.bottomInset` and leave no gap
without a dock. Primary screen from `Shell.primaryScreenName`.

## Settings (its own since 1.1.0 — [[Plugin Settings Live With the Plugin]])

`autohide` (bool) and `icon_size` (`small` · `normal` · `large` → cell
40/48/64 via `Theme.dockCellFor(size)`), in `[plugins.settings]."ewe.dock"`
— Komble → Plugins → Dock → Options, or `ewe-plugin set ewe.dock …`. Each
declares `legacy: "desktop.dock.<key>"`: until set, the old `[desktop.dock]`
value stands (a `medium` there falls back to the default `normal`, same
size). `Shell.dockPrefs` is only the fallback for a host that hands no
settings. The soft `enabled` hide is gone — off is the plugin's own switch.

## Facts

- **Install:** Komble → Plugins → Dock, or `ewe-plugin install ewe.dock`.
  ewe-settings → Layout has one row: "Dock options" (opens `komble
  --options=ewe.dock`), or "Get plugins" when it is missing.
- **IPC:** `qs ipc call launcher toggle|show|hide` (legacy target, kept —
  hyprland.lua and ewe-conf match it by name) and `ewe.dock
  launcher|showLauncher|hideLauncher|isLauncherOpen`.
- `requires` empty. Theme dock roles kept: `dockCell` (the legacy-keyed
  size), `dockCellFor(size)`, `dockGround`, `dockOutline`,
  `dockSelectedFill`, `dockOpenFill`. On Glass the pill draws no float
  shadow ([[Glass — the slider moves the bar only]]).
- Rule 8 deltas vs the old built-in: close-grace 280 ms → `durSlow`; held
  time → `durSlow + durFast`.
- Verified side by side with the built-in dock in the nested harness:
  identical placement, height, style, Overview slide, launcher, toast/OSD
  inset, prefs.
- Design: `design/system/components/Dock` + `LauncherPanel` READMEs say the
  dock is this plugin; launchers = sheep, Overview, Komble, then plugin
  items.

> **Build guard:** never rename `quickshell:dock`, `quickshell:launcher` or
> the `launcher` target; always withdraw the inset (`setBottomInset(id, 0)`)
> on disable/destroy. *Breaks if violated:* layer rules and blur stop
> matching, Super+D's pinned popup dies, and every popup floats above a
> dock that is not there.

## Related

- [[Plugin System]] · [[Music Plugin]] · [[Places Plugin]] ·
  [[Overview Takes the Screen]] · [[Design System]] · [[Quick Answers]]
