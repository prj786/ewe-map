---
tags:
  - ewe-map
  - decisions
title: Desktop Widgets — always movable, pin to a level
up: "[[Decision Index]]"
---

# Desktop widgets: always movable, pin to a level (D11)

**Decided 2026-10-10** (released in ewe 0.25.1-beta).
The user's words: *"addons for desktop should always have pin and always
should be able to move it freely. when i pin it goes top of all apps. now i
need settings for that."*

Before: dragging, Sticky and Hide existed only in arrange mode
(Super+Shift+W) — whose input mask was an EMPTY region, which Quickshell
reads as "click-through", so the mouse could not reach them.

Now, for every `desktop-widget`, with nothing in the plugin:

- **Hover toolbar** inside the card's top-right corner: a **grip** (drag;
  a lock glyph while locked — click unlocks) and the **pin**. A press on any
  part of the card the plugin's own controls do not take drags it too.
- **Pin = the widget's pin level**: `top` (above the windows; a fullscreen
  app still covers it) or `overlay` (above everything, fullscreen too).
  Unpinned = `desktop` (under the windows). Three layer windows per output
  (`quickshell:widgets-desktop|top|overlay`).
- **Lock position** stops dragging. **Settings** for all of it: Komble →
  Options → *On the desktop* (Pinned, When pinned, Lock position, Shown,
  Position: Reset / Arrange…).
- Arrange mode keeps its chips (Pinned · Lock · Hide); its mask is now the
  union of the cards and the chip rows.
- A drag re-binds x/y to the placement afterwards, so a move from Komble or
  `ewe-plugin place` shows live.

Stored in `[plugins.widgets]."<id>"`: `x y output layer visible pin_level
locked` (`layer` is the truth; `pinned` = `layer != desktop` in `list
--json`). CLI: `ewe-plugin place <id> --pinned on|off --pin-level
top|overlay --locked on|off` (and `--layer desktop|top|overlay`).

Verified in the nested harness: overlay stays above a fullscreen kitty, top
is covered by it; pin and level changes move the widget live.

> **Build guard:** the host owns the chrome (toolbar, pin, drag, lock) so
> every widget gets it; a layer window's mask must never be an empty Region
> while it should take input. *Breaks if violated:* widgets that cannot be
> moved or unpinned, or an invisible full-screen surface eating clicks.

## Related

- [[Decision Index]] · [[Plugin System]] · [[Plugin Manifest Reference]] ·
  [[EWE-CONF Schema Reference]]
