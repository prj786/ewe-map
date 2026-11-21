---
tags:
  - ewe-map
  - decisions
title: The Bar's Fold
up: "[[Decision Index]]"
---

# The bar's fold — extras behind a chevron (optional)

**Decided 2026-11-20** (owner: "topbar is overloaded, we can add somekind of
minimizer like on omarchy, but its optional also in topbar settings";
decision 61). Built for ewe 0.45.0-beta + ewe Settings 0.25.0-beta.

- **Setting:** Settings → Layout → Top bar → **Fold the extras**
  (`[desktop.bar] collapse`, ewe-conf THEME_MAP ↔ `barCollapse`), **off by
  default** — nobody's bar changes until they turn it on.
- **Folds:** the system tray, the plugins' right-section bar widgets
  (clipboard, camera, System monitor readout, Music, Places…) and the tiling
  switch. **Never folds:** the workspace chip, the focused app, updates, the
  keyboard layout and the Quick settings pill (status + clock).
- **Behaviour:** a `chevron-left` `BarModule` ahead of the group; a click
  slides the group out to its right (`durBase`, `Theme.ease`; a fade only
  under Reduce motion) and the chevron turns `chevron-right`. Open/closed
  is per session (`Globals.barExtrasOpen`), every display's bar alike.
  IPC: `qs ipc call bar extras` (additive).
- **Plugins:** manifest `barWidget.collapsible: false` keeps a widget out
  of the fold, beside the chevron (`BarPluginSlots { fold: "pinned" }`);
  default true. Validated by `ewe-plugin`.
- Off = pixel-identical to 0.44 (checked in the nest).

Like Omarchy's Waybar tray expander, but click-to-reveal and covering the
plugin buttons too — on the owner's bar those were most of the crowding.

> **Build guard:** a new setting the Settings app writes goes into
> ewe-conf's THEME_MAP (`desktop.bar.collapse` is there). *Breaks if
> violated:* `absorb` drops it — the 0.12.7 "Top bar settings do nothing".

## Related

- [[One Bar Card — BarPopup]] · [[Plugin System]] · [[ewe-settings]]
