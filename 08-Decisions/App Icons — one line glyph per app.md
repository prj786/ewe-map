---
tags:
  - ewe-map
  - decisions
title: App Icons — one line glyph per app
up: "[[Decision Index]]"
---

# App Icons — one line glyph per app

**Decided 2026-09-21.** Each first-party app's launcher icon is one Lucide
line glyph on a dark tile, drawn from a single committed SVG per app.

- The tile is `--surface-raised` **`#151411`** and the glyph is
  `--text-primary` **`#faf9f6`** — the same dark tile / white glyph as the
  dock pill and every other mark.
- The glyphs are the Lucide icons the shell already uses: **store** (Komble,
  `Theme.icStore`), **settings** (ewe-settings, `Theme.icCog`) and **cloud**
  (ewe-sync).
- One committed SVG per app (`packaging/*.svg`) is rasterised by
  `scripts/gen-icons.sh` with `rsvg-convert` into the PNGs Tauri and the
  package need; the PNGs are committed so a checkout builds without librsvg.
- ewe-sync's tray icons stay transparent monochrome — a tray icon must not
  get a dark tile, the panel tints it — and have been dormant since 0.13.

## Related

- [[Decision Index]] · [[One Mark — the line-art logo]] · [[Design System]]
