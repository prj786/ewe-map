---
tags:
  - ewe-map
  - decisions
title: Workspaces Per Display
up: "[[Decision Index]]"
---

# Workspaces Per Display

**Decided 2026-10-23 (owner): "separated workspaces for each monitor, again
like in mac … like shared workspaces or separated workspaces toggler."**
Asked which "shared" means, the owner chose **macOS's** (one set spanning every
display — switching one switches all), and **separate** as the default.

**Released 2026-10-23:** ewe 0.35.0-beta (`v0.35.0-beta` on `d1cca36`, ewe#72),
Dock 1.3.0 (ewe-plugin-dock `c88fdc4`), ewe-settings 0.20.0-beta
(`v0.20.0-beta` on `14b72a8`, ewe-settings#21). Two real monitors: not yet
tried (owner).

- **One data model, two modes.** Every display owns a block of ten Hyprland
  workspace ids: the first 1–10, the second 11–20, … (block k = k·10+1 …
  k·10+10). They are always *shown* as 1, 2, 3 … (`Globals.wsNumber`,
  `Shell.workspaceNumber` for plugins). One display = the ids 1–10 of before.
  - **separate** (default) — macOS "Displays have separate Spaces": Super+N,
    Super+Shift+N, Super+wheel and the swipes act on the display you are on.
  - **shared** — one set across every display: a `workspace.active` hook
    moves every other display to its own part of the same number, whatever
    switched (a key, a swipe, the dock, the Overview).
  Switching modes moves no window.
- **ewe.conf** `[desktop.workspaces] mode = "separate" | "shared"` — its own
  ewe-conf domain `workspaces`: `user-theme.json` `workspacesMode` for the
  shell, one line `_G.ewe_workspaces_mode = "shared"` in `generated/user.lua`
  (nothing when separate), `hyprctl reload`; no theme rebuild. Settings →
  Displays → **Workspaces** (Separate | Shared), shown with two or more
  displays (ewe-settings).
- **Inside the compositor.** `dotfiles/hypr/workspaces.lua` (Hyprland 0.56 Lua
  API: `hl.bind` with a Lua function, `hl.get_monitors`, `hl.on`). No process
  per key — Super+wheel no longer spawns `sh`+`hyprctl`+`jq` per notch either.
- **Displays come and go (macOS):** a new display gets the lowest free block
  and starts on its workspace 1; a display that leaves frees its block and its
  workspaces (moved by Hyprland) give their windows to the same-numbered
  workspace of the display they landed on. The same pass migrates the old
  global numbering (workspace 4 living on the second display → its own 4,
  id 14) once, on upgrade.

> **Build guard:** never show a raw workspace id (the bar chip, the dock, the
> Overview strip all use the number). The bar chip shows ITS screen's
> workspace, not the focused one.

> **Build guard:** Hyprland has no "switch that display to a workspace that
> does not exist yet" (`HLMonitor:set_workspace` needs an existing one), and
> `hl.dsp.focus({ monitor, warp = false })` still warps on the way back. The
> shared sync focuses each display, focuses the workspace there, focuses back,
> re-focuses the window and puts the pointer back — in one Lua call, so
> nothing is drawn between.

> **Build guard:** never start an `hl.timer` from `config.reloaded` — it also
> fires while the config is first parsed, before the event loop exists
> (`Hyprland --verify-config` segfaulted). The reload settles at once.

Test: `ewe/tests/ewe-workspaces-test.sh` (the module against a fake `hl`, the
ewe.conf key; 21 checks). In the run-ewe nest a second display is
`hyprctl output create headless HEADLESS-2`, and `HS_EXTRA_LUA` can load the
module into the minimal config.

## Related

- [[Decision Index]] · [[Keymap Reference]] · [[EWE-CONF Schema Reference]] · [[Dock Plugin]] · [[Overview Spreads the Windows]]
