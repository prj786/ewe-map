---
tags:
  - ewe-map
  - decisions
title: Dock On Every Display
up: "[[Decision Index]]"
---

# Dock on every display — primary, all or none

**Decided 2026-11-20** (owner: "make doc to be visible none on primary and
all display. but on primary all tools will be available on secondary only
minized and active windows from this display"; decision 62). Built in
Dock 1.5.0 (`ewe-plugin-dock`), shipped in ewe 0.45.0-beta's payload.

- **Setting:** the Dock plugin's own `display` choice — **primary**
  (default, = 1.4.0) · **all** · **none** — "Show the dock on" in Komble →
  Plugins → Dock (a segmented control: three choices or fewer render so).
- **primary:** the full dock on the main display (the display profile's
  primary, else the first output — `Shell.primaryScreenName`); its
  workspace boxes follow the focused display, as 1.3.0 decided.
- **all:** the main display keeps the full dock and shows **its own**
  display's workspaces (otherwise both docks showed the focused display's
  and the main one's boxes appeared nowhere). Every other display gets a
  **reduced dock**: that display's workspace boxes with their windows, then
  the windows minimized from that display — no sheep, Overview, Komble,
  plugin items or Downloads.
- **none:** no dock window anywhere; the bottom inset is 0 (windows take
  the full height; Places shows its bar button).
- **Which display a minimized window belongs to:** Hyprland's
  `special:minimized` is ONE workspace, so `lastIpcObject.monitor` says
  whichever display that workspace last sat on. The dock remembers each
  window's display while it is on a normal workspace and keeps the record
  once minimized; in `all` the records persist for the Hyprland session in
  the plugin's state dir (`minimized.json`). Unknown or unplugged → the
  main dock.
- Restoring a minimized tile brings the window back to that dock's display.

> **Build guard:** the plugin's `stateDir` property must stay writable
> (not `readonly`) — the host injects it; a readonly one makes the inject
> throw before the settings arrive (`test.sh` checks it).

## Related

- [[Dock Plugin]] · [[Workspaces Per Display]] · [[Overview Spreads the Windows]]
