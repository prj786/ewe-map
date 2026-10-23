---
tags:
  - ewe-map
  - decisions
title: Overview Spreads the Windows
up: "[[Decision Index]]"
---

# Overview Spreads the Windows

**Decided 2026-10-23 (owner): "i want mac like overview. exactly like it …
performance is the must."** Released the same day in **ewe 0.34.0-beta**
(ewe#70) with Dock 1.2.0. The Overview is rebuilt after macOS Mission
Control. It replaces the GNOME-style grid with search that
[[Overview Takes the Screen]] described; that note's full-screen rule still
holds, its timeline and its pager do not.

- **The windows fly.** Each card starts exactly over its real window, so the
  first frame looks like the desktop, flies to its place in the spread
  (`durSlow`), and flies back onto its window on close (`durBase`); the
  surface unmaps under the cards. One number, `progress` 0 → 1, drives every
  card, the backdrop, the strip and the bar/dock beat — one animation.
- **The spread** keeps each window's proportions **and** its size against
  the others (one scale for the workspace, never above 1), 1–4 rows ordered
  by where the windows sit.
- **Workspaces on top.** One label per workspace of that screen; pointing at
  the strip (or dragging a window up) slides it down into thumbnails and
  shrinks the spread toward the bottom (one transform — a relayout flipped
  3 rows to 2 under the pointer). **No "add workspace"** (owner: "no need").
  Drop a window on a workspace to move it there.
- **No search** (owner). The app launcher has it; the public
  `overview find <q>` verb (rule 4) now opens the launcher with `<q>`
  (`Globals.launcherFind`).
- **Performance, where something had to give:** each window is captured
  **once** on open (`live: false`) — the cards are not live video; no blur
  on the backdrop (wallpaper + half the scrim); RectangularShadow, not
  MultiEffect; workspace thumbnails draw windows as shapes + app icons (no
  extra captures); no `hyprctl` spawn on open (the group badges are gone);
  nothing exists while the Overview is closed (the per-screen windows build
  their cards and layout only while mapped).

## Timeline

| t | what |
|---|---|
| 0 | `overviewOpen = true`: the surface maps, **draws nothing**, `refreshToplevels()`, captures start |
| ≤ `durFast` | every card has its frame (or the wait runs out): `overviewCover = true` (bar up, dock down) and the flight 0 → 1 over `durSlow`; backdrop, dim (`progress / 2` of the scrim) and strip follow `progress` |
| close | `overviewCover = false`; flight 1 → 0 over `durBase`; unmap at 0. After a workspace switch: a `durBase` fade instead |

Reduce motion: nothing flies — the whole stage cross-fades at `durFast`.

> **Build guard:** under each window's **real** rectangle a wallpaper
> *patch* (opaque from the first frame, `spaceXs` wider for Hyprland's
> border) hides the live window behind the overlay; the backdrop itself
> fades with `progress` so the bar, dock and gaps go smoothly. Without the
> patches every window shows twice during the flight.

> **Build guard:** a window's geometry comes from `lastIpcObject.at/size`
> minus the monitor's `x/y`; the open calls `Hyprland.refreshToplevels()`
> because the scrolling layout moves windows without an IPC event.

> **Build guard:** the capture rules of [[Overview Takes the Screen]] still
> hold — captures only while mapped, ✕ drops the capture before closing.

## Minimize replaces the Pen (same day)

Super+Z **minimizes** (`special:minimized`, never toggled into view);
Super+Shift+Z brings back the one minimized last; **each minimized window
is its own tile in the dock** — its picture with the app's icon, a click
brings it back, exactly like macOS ([[Dock Plugin]] 1.2.1; the owner turned
down 1.2.0's group box + thumbnail panel the same day). The Pen
(`special:pen`, Super+S / grave / Z toggles, Super+Shift+S stash) is gone;
windows left in it count as minimized. A restored window comes to the
workspace you are on.

## Related

- [[Overview Takes the Screen]] · [[Dock Plugin]] · [[Keymap Reference]] · [[Decision Index]]
