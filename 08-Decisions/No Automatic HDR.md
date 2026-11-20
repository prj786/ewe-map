---
tags:
  - ewe-map
  - decisions
title: No Automatic HDR
up: "[[Decision Index]]"
---

# No automatic HDR or wide colour in fullscreen

**Decided 2026-11-20** (owner: "making something on fullscreen makes
external monitor turn on and off", with Hyprland's notice "Monitor DP-1:
wide color gamut is enabled but the display is not in 10-bit mode";
decision 63). Built in ewe 0.45.0-beta (`dotfiles/hypr/hyprland.lua`).

- **Cause (verified on the owner's box, Hyprland 0.57.2):**
  `render:cm_auto_hdr` defaults to **1** — when a fullscreen client
  publishes an HDR / wide-gamut image description (a video, a game),
  Hyprland switches that output's colour management. The output is
  committed again (aquamarine logs `Modesetting DP-1 with
  2560x1440@59.95Hz` twice, no hotplug), the external Samsung drops its
  signal for a second, and on an 8-bit output the notice appears.
- **Fix:** `hl.config({ render = { cm_auto_hdr = 0 } })`. ewe's display
  profiles write `bitdepth = 8` and no `cm` (sRGB) explicitly, so the
  switch only ever cost a blink. `ewe-game` (Ultra) sets
  `render.direct_scanout` only — no conflict.
- **Not now:** a per-display "HDR in fullscreen" switch in Settings →
  Displays (shown only for `hdr: yes` outputs, writing `cm = "hdr"` +
  `bitdepth = 10`) — parked until someone with an HDR monitor asks.

> **Build guard:** do not remove `cm_auto_hdr = 0` without an HDR opt-in
> per display. *Breaks if violated:* every fullscreen video blanks an
> external monitor.

## Related

- [[Troubleshooting Knowledge]] · [[ewe Desktop]]
