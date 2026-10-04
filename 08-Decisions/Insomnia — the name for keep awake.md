---
tags:
  - ewe-map
  - decisions
title: Insomnia — the name for keep awake
up: "[[Decision Index]]"
---

# "Keep awake" is called **Insomnia** (D5)

**Decided 2026-10-04** (ewe 0.25.0-beta). The feature that holds a Wayland
idle inhibitor (no auto-lock, no blank, no auto-suspend until you turn it
off) is named **Insomnia** everywhere user-facing — the add-on
([[Insomnia Plugin]], `ewe.insomnia`), ewe-settings' Screensaver pane
(commit 265b0cc), the Welcome tour and the writing guide
(`design/system/guidelines/30-writing.md:81`: *Insomnia (the keep-awake
add-on)* — not "keep awake", "caffeine", "inhibit").

- The **layer namespace stays `quickshell:caffeine`** — Hyprland layer
  rules and the Glass blur list match it by name; plumbing is not renamed.
- IPC: `qs ipc call ewe.insomnia toggle|on|off|status`.

> **Build guard:** one name in copy, the old name in plumbing. *Breaks if
> violated:* "keep awake" in one pane and "Insomnia" in another reads as
> two features; renaming the namespace breaks every user's layer rules.

## Related

- [[Decision Index]] · [[Insomnia Plugin]] · [[Conventions]]
