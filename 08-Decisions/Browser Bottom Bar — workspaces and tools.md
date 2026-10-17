---
tags:
  - ewe-map
  - decisions
title: Browser Bottom Bar — workspaces and tools
up: "[[Decision Index]]"
---

# ewe browser: workspaces and tools live in a bottom bar (#38)

**Decided 2026-10-17** by the owner (released in ewe browser 0.3.0-beta).
The owner's words: *"workspaces and actions like downloads and bookmarks
can't be visible on this small area … totally remove them from there. add
bottom always visible full widthed bar, very small heighted one."*

| was | now |
|---|---|
| workspaces as colour dots at the rail's foot, the active one's name as an overline above its tabs | named chips at the left of a 32px bar across the whole window, under the page card |
| Bookmarks / Downloads / History, Music, Files, Settings squeezed next to the dots in 264px | the bar's right end |
| a hidden rail took workspaces and tools with it (only the peek showed them) | the bar stays when the rail is hidden; only fullscreen hides it |
| `+` opened "Workspace N" on the new-tab page | `+` opens "Workspace N" (N = count + 1, next free colour) on Home; any empty workspace falls back to Home |
| extension buttons under the address field, pinned tiles below them | pinned tiles under the address field, extension buttons at the rail foot |

Rename and colour stay where they were: double-click a chip to rename it
inline, right-click for the workspace menu (Rename, colours, Move tabs here,
Remove). A tab dragged from the rail onto a chip moves there; the rail
*peek* cannot (it is the overlay document; its tab menu has Move to
workspace).

> **Build guard:** the sidebar and the rail peek end `BOTTOM_BAR_HEIGHT`
> (32, mirrored by `--bottom-bar-height`) above the window bottom outside
> fullscreen (`WindowController.barHeight()` → `sidebarBounds`,
> `overlayBounds`). *Breaks if violated:* an open sidebar covers the bar's
> Bookmarks / Downloads / History buttons, so it cannot be closed from them.

## Related

- [[Decision Index]] · [[ewe-browser]] · [[ewe browser replaces Helium]]
