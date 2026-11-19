---
tags:
  - ewe-map
  - decisions
title: Apps Are Not Resident
up: "[[Decision Index]]"
---

# Apps are not resident — a window costs RAM only while it is on screen

**Decided 2026-11-19** (owner, after the second idle-RAM measurement; released
in Komble 0.23.0-beta and ewe Sync 0.17.0-beta). The resource diet of 0.41
([[Memory Tuning — match zram]]) cut the churn; what was left on an idle
desktop was two Tauri apps keeping a live WebKit page nobody looked at:
`ewe-sync --hidden` (~181 MB) because the page's Svelte store derived the
bar's sync glyph, and Komble (~250 MB after every `komble --updates`)
because "Minimize to tray on close" was on by default.

- **Komble quits when its window closes.** It has no tray and no duty the
  desktop relies on — the bar's update indicator is the shell's own
  (`updates-check.sh`), Komble only pokes `qs ipc call updates refresh`
  after a transaction. "Minimize to tray" is gone (the setting and the
  switch). The one exception: a transaction in flight (`util::Working` —
  pacman under pkexec, makepkg, an AppImage download/extraction) finishes
  windowless, then the process leaves. A second launch meanwhile rebuilds
  the window (`show_main`); routes and opened files are stashed and the page
  told to take them ([[Komble]]).
- **ewe Sync's window exists only while it is shown.** The bar glyph's state
  machine moved into Rust (`src-tauri/src/bar.rs`: `ewe-cloud status` +
  `ewe-conf sync-status` every 2 min, the folder runner's reports, a busy
  guard for Sync now / Bring everything back) so the hidden process needs no
  page. The window is built on demand (not declared in `tauri.conf.json`),
  destroyed on close with its web process terminated
  (`terminate_web_process` — WebKitGTK would otherwise park the page-less
  process for 30 min), and the process stays alive (`prevent_exit`) for the
  glyph, the watchers and the folder runner. Idle: 181 → **19 MB**. A deep
  link (`--pane`, `--add-folder`, the conflict notification) is stored first
  and the page told to take it, so a window built for it opens on the right
  pane ([[ewe-sync]]).
- **The rule going forward:** a first-party app may stay resident only for a
  duty the desktop needs between windows (ewe Sync's glyph and folders; a
  Komble transaction), and then **without a web page**. Everything the bar
  shows is computed in Rust or the shell, never derived in a hidden page.

## Not taken

A single shared WebKit process (`WEBKIT_USE_SINGLE_WEB_PROCESS` no longer
exists). Hiding instead of destroying (a hidden page still polls and holds
its DOM). A tray for Komble (decision 50 removed the trays; the bar's
indicator already exists).

> **Build guard:** no Tauri app keeps a hidden `WebviewWindow` for a
> background duty. *Breaks if violated:* ~100–250 MB per app on every idle
> desktop, and a page that polls (`setInterval`) all session. Measure with
> the `Pss` sum over `/proc/<pid>/smaps_rollup` of the app's process tree
> ([[Troubleshooting Knowledge]]).

## Related

- [[Decision Index]] · [[Komble]] · [[ewe-sync]] · [[Memory Tuning — match zram]]
  · [[Process Split — Shell vs Apps]] · [[Troubleshooting Knowledge]]
