---
tags:
  - ewe-map
  - decisions
title: Four Fingers — ewe browser's workspaces
up: "[[Decision Index]]"
---

# A four-finger swipe switches ewe browser's workspaces (#41)

**Decided 2026-10-18** by the owner (wave 2), **released in ewe
0.30.0-beta** (ewe#62) with **ewe browser 0.4.0-beta** (the `workspace`
verb, ewe-browser#13).

| fingers | where | does |
|---|---|---|
| 3, left / right | anywhere | the **desktop's** workspaces (unchanged, Hyprland's own `workspace` gesture) |
| 3, up / down | anywhere | Overview / a new empty desktop (unchanged) |
| **4, left / right** | **only while ewe browser is the focused window** | the **browser's** next / previous workspace (fingers left → next, the same sense as three) |
| 4, left / right | any other window | nothing |
| 2, sideways | inside ewe browser's pages | back / forward — the browser's own gesture (wheel events in the page), not Hyprland's |

How: two `hl.gesture({ fingers = 4, direction = "left" | "right" })` in
`dotfiles/hypr/hyprland.lua` whose action checks
`hl.get_active_window().class == "ewe-browser"` and then runs
`ewe-browser workspace next|prev` (the browser's CLI, about 45 ms through
its socket). An older browser answers `unknown-verb` and nothing happens.

## Why

- Three fingers are the desktop's and stay that way: the owner's muscle
  memory, and GNOME's.
- The browser's workspaces (the bottom bar's chips,
  [[Browser Bottom Bar — workspaces and tools]]) are a second level of the
  same idea; one more finger for the inner level, only where it means
  something.
- The command line is already public API (rule 5, `docs/CLI.md`), so the
  compositor needs no new IPC: the gesture is one more caller.

> **Build guard:** the gesture calls `ewe-browser workspace next|prev`,
> which is now part of the browser's public CLI (only added to, never
> renamed). Hyprland's Lua `hl.gesture` accepts **any** direction string
> when the config loads — no validation, no `configerrors` — so a typo
> silently does nothing: use only the documented words (`left`, `right`,
> `up`, `down`, `horizontal`, …) and try the gesture on a real touchpad.
> *Breaks if violated:* four fingers do nothing, with no error anywhere.

Not verified: "left"/"right" on a real touchpad (the nested Hyprland loads
the config with no errors; it has no touchpad).

## Related

- [[Decision Index]] · [[ewe-browser]] · [[Keymap Reference]] ·
  [[ewe Desktop]] · [[Overview Takes the Screen]]
