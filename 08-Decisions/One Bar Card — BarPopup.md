---
tags:
  - ewe-map
  - decisions
title: One Bar Card — BarPopup
up: "[[Decision Index]]"
---

# One bar card — every top-bar dropdown looks like the System monitor's

**Decided 2026-11-20** (owner: "lets make all topbar dropdowns same visuals,
like we have clipboard and monitor dropdowns different. we can make it both
look like system monitor"; decision 60). Built for ewe 0.45.0-beta with
System monitor 2.1.0, Music 1.1.0, Clipboard 1.3.0, Places 1.2.0 and
Dock 1.5.0 (its Downloads card).

## What it is

Two shell components, additive to plugin API 3 (`apiVersion` stays 3):

- **`BarPopup`** — an `AnchoredPopup` with the layout filled in: one width
  for every bar card (`Theme.grow(Theme.panelSm)`), 12 px padding
  (`spaceS + spaceXs`) around and between head, body and footer, the head,
  a body Column (or a capped Flickable with `scrollable`), a `footer`, and
  `exclusiveKeyboard` for a card you type into first.
- **`PopupHead`** — the head row on its own: `glyph` in `accentText`,
  `title` semibold, an optional `subtitle`, actions on the right. The System
  monitor card's head, lifted out of `ewe-plugin-sysmon/Card.qml`.

| card | before | now |
|---|---|---|
| System monitor | the reference (AnchoredPopup + its own head) | BarPopup, the cog in `headActions` |
| Music | AnchoredPopup, `panelSm`, no head, the player name as a caption | BarPopup "Now playing", the player's name as the head's subtitle |
| Clipboard | its own PanelWindow (API 2): `grow(panelMd)` × `panelLg`, flush under the bar with square top corners, a slide, opened by `qs ipc call … toggleAt <x>` per click | BarPopup (API 3): the widget is a `BarModule` that runs `ewe.clipboard.toggle` with its anchor; Clear in the head; tabs are `QsSegmented`; the search has the keys at once (`exclusiveKeyboard`) |
| Places | its own PanelWindow, `panelMd`, an address row | still its own window (**the box-only input mask is what lets a file be dragged out**), restyled: `grow(panelSm)`, a `PopupHead` (folder name over its path; back · home · pin) |
| Dock → Downloads | AnchoredPopup with its own head | BarPopup "Downloads" |

Not bar cards, unchanged: tray menus (Menu card), the Shaun notch, the
screenshot preview stack, Quick settings (its pages are one look already).

## Why one component, not a restyle per plugin

Six plugins each re-drew the same card with drifting widths (panelSm,
grow(panelSm), panelMd, grow(panelMd)), paddings and heads. A shared
component keeps the next plugin honest for free, and API 3 already had the
pattern (`AnchoredPopup`, `BarModule`, the promoted Qs* kit).

## Found on the way

- `cliphist list` exits 1 ("please store something first") until the first
  copy — the old card said "cliphist isn't installed" on every fresh
  install. Now only a missing binary (exit 127 through a `command -v`
  wrapper) says that.
- The Clipboard keeps the public IPC verbs `toggle`, `toggleAt <x>`, `hide`,
  `isOpen`; an IPC toggle opens under the bar at the scissors' last x.

> **Build guard:** a bar widget's popup is a `BarPopup` (or a `PopupHead`
> in a plugin that must own its window). *Breaks if violated:* the bar's
> cards drift apart again — the owner's 2026-11-20 complaint.

## Related

- [[Plugin System]] · [[Clipboard Plugin]] · [[System Monitor Plugin]] ·
  [[Music Plugin]] · [[Places Plugin]] · [[Dock Plugin]] ·
  [[The Bar's Fold]]
