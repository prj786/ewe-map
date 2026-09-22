---
tags:
  - ewe-map
  - decisions
title: Overview Takes the Screen
up: "[[Decision Index]]"
---

# Overview Takes the Screen

**Decided 2026-09-21.** The Overview takes the whole screen, wallpaper first.
This reverses the earlier read that the Overview was a *mode of the desktop*
— that the bar and dock stayed put and the cards sat under a bar-shaped
backdrop. Now the wallpaper owns the full output, edge to edge.

- **Wallpaper first, full screen.** The backdrop is the point of the
  Overview, so it lands before the cards and fills the whole output
  (`ExclusionMode.Ignore`, no `margins.top`). It decodes once at shell start
  (warmed in `Wallpaper.qml`) and never again on open.
- **The bar slides up, the dock slides down.** Both translate out of view
  while the Overview is open and come back after the cards have gone.
- **Exclusive zones are NOT released.** Bar and dock keep their reserved
  strips; only their visuals translate, so windows underneath never relayout
  — position and size are identical before, during and after the Overview.

## Timeline

Sequenced by two flags — `Globals.overviewCover` (bool) and `root.stageShown`
in `Overview.qml` — with one `Timer` of `Theme.durFast` between them. `t = 0`
is the frame `Globals.overviewOpen` changes.

**Open**

| t | what |
|---|---|
| 0 | `overviewCover = true` — the backdrop fades in at `durFast`; the bar slides up and the dock slides down at `durBase` |
| `durFast` | `stageShown = true` — the cards, search and pager fade and zoom in at `durSlow` |

**Close**

| t | what |
|---|---|
| 0 | `stageShown = false` — the cards go |
| `durFast` | `overviewCover = false` — the backdrop fades out at `durFast`; the bar and dock slide back at `durBase` |

Reduce motion: everything cross-fades at `durFast`; nothing slides.

> **Build guard:** `Behavior on y` on an item whose `y` depends on
> `parent.height` inside a lazily-mapped PanelWindow animates the map. Put
> the motion on a `transform: Translate`, or drop it.

## Related

- [[Decision Index]] · [[Design System]] · [[Desktop Shell]]
