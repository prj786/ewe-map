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

## Timeline (D8, 2026-10-04 — "snappier")

Sequenced by `Globals.overviewCover` and `root.stageShown` in
`Overview.qml`, with **one** `Timer` of `Theme.durFast` — on the way **out**
only. `t = 0` is the frame `Globals.overviewOpen` changes.

**Open — one step** (D8, the user asked for "snappier"; replaces the
two-step open of 2026-09-21)

| t | what |
|---|---|
| 0 | `overviewCover = true` **and** `stageShown = true` — the backdrop fades in at `durFast`; the bar slides up and the dock slides down at `durBase`; the cards, search and pager fade and zoom in at `durBase` (`Theme.ease`). The backdrop reads first only because its fade is shorter |

**Close**

| t | what |
|---|---|
| 0 | `stageShown = false` — the cards go (`durBase`) |
| `durFast` | `overviewCover = false` — the backdrop fades out at `durFast`; the bar and dock slide back at `durBase` |

The window unmaps at `durFast + durBase + durFast`. Reduce motion:
cross-fades at `durFast`, nothing slides or zooms.

- **Measured** (nested harness): trigger → half-visible **130 ms** (was
  nothing visible at 222 ms); settled + focused **≈240 ms** (was 500–650 ms);
  trigger process cost 17 ms (was 44–160 ms via `qs ipc`).
- **Trigger:** the **`ewe:overview` global shortcut** (Hyprland `global`,
  bound to Super as a *release* bind) — a public name users may bind in
  `user.lua`; the 3-finger swipe stays IPC (`overview toggle`).
  `ewe-globalshortcuts` ignores `ewe:*` names (test 12/12).
- **Keyboard:** only the output focused at open time takes it
  (`Exclusive` while open, `None` otherwise); the other outputs show cards
  + pager without a search field. Since 0.25 the dock half of the slide is
  the [[Dock Plugin]]'s, driven by `Shell.overviewOpen`.

> **Build guard:** `Behavior on y` on an item whose `y` depends on
> `parent.height` inside a lazily-mapped PanelWindow animates the map. Put
> the motion on a `transform: Translate`, or drop it.

> **Build guard:** window cards capture (`ScreencopyView.captureSource`) only
> while the Overview window is visible, and ✕ drops the capture before it
> closes the window. A toplevel capture racing a window close gets the whole
> shell disconnected by Hyprland 0.56 (`invalid object N`, 0.24.1-beta) — see
> [[Troubleshooting Knowledge]].

> **Build guard:** per-screen layer windows must not all request keyboard
> focus (last-mapped wins); a root `FocusScope` with `focus: true` plus a
> `Keys.onPressed` fallback is what keeps keys alive without an
> `activeFocusItem`. Hyprland 0.56 `global` signal matrix: a *release* bind
> fires `released` only, a *press* bind `pressed` + `released`, a dispatch
> `pressed` only — toggle on `released`. See [[Troubleshooting Knowledge]].

## Related

- [[Decision Index]] · [[Design System]] · [[Desktop Shell]] · [[Dock Plugin]]
