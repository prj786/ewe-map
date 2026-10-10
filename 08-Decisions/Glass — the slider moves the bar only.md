---
tags:
  - ewe-map
  - decisions
title: Glass — the slider moves the bar only
up: "[[Decision Index]]"
---

# Glass: the slider moves the bar, the dock and the lock card only (D13)

**Decided 2026-10-10** (released in ewe 0.25.1-beta).
The user's words: *"glass and transparency level works weirdly."*

What was weird, and what it is now:

| was | now |
|---|---|
| `glass-base`/`glass-raised` carried the bar slider: the Overview chips and desktop widget cards sat at 80 % with Glass *off*, 99 % at 99, nearly invisible at 25 | they are the **Glass material at `opacity-glass` (0.8)**, always; `Theme.barGround`/`dockGround` = `surfaceBase`/`surfaceRaised` at `barAlpha` |
| the dock's float shadow showed through the translucent pill (darker than the bar) and got blurred into a frosted rim | no shadow on a glass dock or lock card |
| `decoration.blur.xray = true`: the blur showed the wallpaper, not the window under an auto-hidden dock or a floating window | `xray = false` |
| Glass switched blur on for every window with alpha (kitty's 0.95) | without App blur, a `no_blur` window rule (`ewe-no-app-blur`) |
| App blur's 85 % windows applied on VMs/NVIDIA too (sharp, unreadable) | inside the `EWE_NO_BLUR` guard |
| Window transparency live-evaluated `active_opacity = 1.0` (every window solid while App blur was on) and wrote through `absorb` | one `ewe-conf set desktop.theme.window_transparency`; dimmed with a note while App blur is on |
| Settings showed Glass/App blur "on" while Reduce transparency / Increase contrast forced them solid | the controls dim with a note saying which mode and what it covers |
| the slider snapped back on release; 1–9 % was "Glass" with no blur; Glass on always reset to 80 | the released value holds until the write lands; range 10–100; Glass on returns to your last level |
| `ewe-conf` and `ewe-theme` disagreed on truthiness (`1.0`, `"yes"`) | one rule (`_on` / `_truthy`) |

> **Build guard:** only `barGround`/`dockGround` (and the lock card) take
> `barAlpha`; any other surface that wants glass uses
> `glassBase`/`glassRaised`. *Breaks if violated:* the Overview and widgets
> follow a slider labelled "Bar opacity".

## Related

- [[Decision Index]] · [[Theming Pipeline]] · [[ewe-settings]] · [[Dock Plugin]]
