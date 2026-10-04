---
tags:
  - ewe-map
  - decisions
title: X11 Scale — smallest lit scale
up: "[[Decision Index]]"
---

# X11 scale = the smallest lit scale of the DRM-connected set

**Decided 2026-10-04** (ewe `fix/x11-scale-notes`, in 0.25.0-beta). X11
(XWayland) has **one** scale for all screens, decided once at login by
`start-hyprland.sh` (`GDK_SCALE`, `STEAM_FORCE_DESKTOPUI_SCALING`,
`EWE_X11_*`, `xwayland:force_zero_scaling`).

- **Before:** it took the PRIMARY display of the `lastKey` profile in
  `display-profiles.json`, and `lastKey` only moves when Settings → Displays
  saves — so a docked login sized X11 for the 1.8x laptop panel and Steam /
  Java apps were huge on the 1x external.
- **Now:** it reads the **connected set from `/sys/class/drm`**, picks that
  set's profile and takes the **smallest lit scale**. Soft on the laptop
  panel, the right size everywhere else — the lesser evil, since one scale
  must serve every screen.
- Docking **after** login still needs a re-login (the value is an
  environment variable). Test: `tests/x11-scale-test.sh` (9 checks).

> **Build guard:** the scale decision reads hardware (`/sys/class/drm`),
> never a last-saved key. *Breaks if violated:* a login on a different
> monitor set applies the previous set's scale.

## Related

- [[Decision Index]] · [[Shell Singletons]] · [[Troubleshooting Knowledge]]
