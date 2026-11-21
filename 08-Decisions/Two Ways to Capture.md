---
tags:
  - ewe-map
  - decisions
title: Two Ways to Capture
up: "[[Decision Index]]"
---

# Two ways to take a screenshot — the bar's camera and the Print keys

**Decided 2026-11-20** (owner: "we have screen capture in three places
lets make it simple and remove from control center"; decision 64). Built
in ewe 0.45.0-beta.

The screenshot plugin (`ewe.screenshot`) owns capture. Its two entry
points stay: the **camera in the bar** and the **Print keys** (manifest
keybinds → `generated/plugin-keybinds.lua`). Quick settings' head lost its
camera button — it is **Settings · Lock · Power** now, nothing fills the
slot.

Same pass, Quick settings' home grid: the last half-width tile of an odd
run takes the whole row (`Tile.wide`, additive), so no tile row is ever
half empty; with one or two shortcuts the shortcut row shows full tiles
with names instead of a lone square; "No notifications" is a muted bell
and one line.

## Related

- [[Screenshot Plugin]] · [[One Bar Card — BarPopup]]
