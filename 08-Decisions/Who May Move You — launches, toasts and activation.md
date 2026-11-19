---
tags:
  - ewe-map
  - decisions
title: Who May Move You — launches, toasts and activation
up: "[[Decision Index]]"
---

# Who may move you — your launches do, an app's own windows do not

**Decided 2026-11-19** (owner: "notification from steam makes me to goe on the
workspace where steam is while i dont want that … we need ubuntu level
polishment"). Built for ewe 0.43.0-beta.

**Why Steam dragged the owner around:** a Settings → Window Rules entry "Steam →
workspace 4" tags every `steam` window `ewe-ws-4`, and `workspaces.lua` moved each
one there — Steam's toasts (`notificationtoasts_N_desktop`) are `steam` windows
too. `follow = false` on that move did not help: Hyprland focuses a new window
when it maps and switches to its workspace to do it.

- **A rule-placed window opens without focus.** `hyprland.lua` defines
  `ewe-ws-quiet-1..10` (`match = { tag = "ewe-ws-N" }, no_initial_focus = true`)
  AFTER the generated `windowrules.lua`: a rule matches the tags earlier rules
  set in the same pass, but only by the exact tag (a pattern does not match),
  and a tag added at `window.open_early` comes too late for a static rule.
- **You launched it → you go with it.** A launch is marked with the app's class
  hint and spent only by a window of that app (30 s): `ws.launch(cmd[, hint])`
  for binds, `(ewe_launch or hl.dsp.exec_cmd)("…")` in ewe-conf's generated
  `keybinds.lua`, `Globals.markLaunch(hint)` in the shell — a Lua function sent
  through `Hyprland.dispatch` (`hl.dispatch` accepts one; no process). The
  window is focused on `window.open`, and the view goes with it. A window that
  opens on the workspace you are on (the app's own dialog) is focused too.
- **Steam's toasts** are pinned, never focused, never focused by the pointer
  passing over them, and `M.place` leaves them (and any pinned window) where
  they open.
- **Activation:** `misc.focus_on_activate = true` — Hyprland honours a request
  only with a valid xdg-activation token, i.e. one that came from a click (a
  link in kitty or Slack brings the browser forward). Every XWayland window is
  urgent-only (`x11-activate-urgent-only`), and urgent windows show a dot on
  the bar's chip and the dock (raw `urgent` events — Quickshell 0.3.2 never
  raises `HyprlandToplevel.urgent`).
- **Focus-or-launch keeps working:** clicking an app that has a window focuses
  it by address (its workspace comes along); a minimized one comes back to the
  workspace you are on (`special:minimized` no longer opens as an overlay;
  `binds.hide_special_on_workspace_change`); Super+B brings the open browser
  forward; a notification with no window and no action opens its app.

## Not taken

A blanket "never switch workspaces" (launching Steam from workspace 1 should
show Steam). Matching Steam toasts only by title in the user's rule (titles
come late, and the problem is any app's self-opened window). `follow_mouse = 2`
(click to focus) — the owner's call, still open.

## Related

- [[Decision Index]] · [[Workspaces Per Display]] · [[Troubleshooting Knowledge]]
  · [[Contracts and Public API]]
