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
· v1.0.0 · API 3 · **add-on since 0.25** (was `Dock.qml` + `PinnedApps.qml`
/ `LauncherPanel`). **Not installed on a fresh machine** — a new ewe has
no dock until you add it; upgraders keep theirs
([[Add-ons — one-time migration for upgraders]]: migrated unless
`[desktop.dock] enabled = false`).

A small centred dock at the bottom of the main screen:

`[ sheep → pinned-apps popup ] [ Overview ] [ Komble ] [ add-on dock items: Music, Places … ] | [ the Pen ] [ workspace boxes ]`

| piece | what |
|---|---|
| `panel` kind — its **own PanelWindows**, namespaces **`quickshell:dock`** and **`quickshell:launcher`** | the dock + the pinned-apps popup (type to search every app; pin badge → `ewe-conf apps.pinned` via `Shell.setPinned`) |
| dock items | renders `Shell.dockItems` (manifest `dockItem`s) filtered by `Shell.dockItemShown`; click → `Shell.runAction(action, anchor)`; lit while `Shell.isActive(action)` |
| the Pen | `special:pen` (Super+Z) — shown only while something is stashed |
| Overview | slides out on `Shell.overviewOpen` (local `durFast` close beat), back when the cards have gone; the button calls `Shell.toggleOverview()` |
| auto-hide | ducks when the workspace has a tiled/fullscreen window; returns at the bottom edge, while any dock popup is open (`Shell.activeCount > 0`), and for a moment after the pointer leaves |

## What it tells the shell

`Shell.setBottomInset("ewe.dock", dockCell + 2·spaceS + windowGap, enabled
&& !autohide)` — reserved as an exclusive zone when auto-hide is off; **0**
when disabled or destroyed, so toasts, the OSD and every bottom-anchored
popup read `Shell.bottomInset` and leave no gap without a dock. Prefs come
from `Shell.dockPrefs` (`enabled`, `autohide`, `iconSize` — Settings →
Layout → Dock, ewe.conf `[desktop.dock]`; fallback `Globals`). Primary
screen from `Shell.primaryScreenName`.

## Facts

- **Install:** Komble → Add-ons → Dock, or `ewe-plugin install ewe.dock`.
  ewe-settings → Layout shows a note + "Get add-ons" when it is missing.
- **IPC:** `qs ipc call launcher toggle|show|hide` (legacy target, kept —
  hyprland.lua and ewe-conf match it by name) and `ewe.dock
  launcher|showLauncher|hideLauncher|isLauncherOpen`.
- No settings of its own; `requires` empty. Theme dock roles kept:
  `dockCell`, `dockGround`, `dockOutline`, `dockSelectedFill`,
  `dockOpenFill`.
- Rule 8 deltas vs the old built-in: close-grace 280 ms → `durSlow`; held
  time → `durSlow + durFast`.
- Verified side by side with the built-in dock in the nested harness:
  identical placement, height, style, Overview slide, launcher, toast/OSD
  inset, prefs.
- Design: `design/system/components/Dock` + `LauncherPanel` READMEs say the
  dock is this add-on; launchers = sheep, Overview, Komble, then add-on
  items.

> **Build guard:** never rename `quickshell:dock`, `quickshell:launcher` or
> the `launcher` target; always withdraw the inset (`setBottomInset(id, 0)`)
> on disable/destroy. *Breaks if violated:* layer rules and blur stop
> matching, Super+D's pinned popup dies, and every popup floats above a
> dock that is not there.

## Related

- [[Plugin System]] · [[Music Plugin]] · [[Places Plugin]] ·
  [[Overview Takes the Screen]] · [[Design System]] · [[Quick Answers]]
