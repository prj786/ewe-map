---
tags:
  - ewe-map
  - decisions
title: ewe's Own Apps — Files, Player, Viewer
up: "[[Decision Index]]"
---

# ewe's own apps replace Nemo, Engrampa, imv, Zathura and mpv

**Decided 2026-11-19** (owner). Released as **ewe-apps 0.1.0-beta** with
**ewe 0.44.0-beta**, ewe Settings 0.24.0-beta and ewe Browser 0.8.4-beta
(decision 56). Repo `prj786/ewe-apps` — [[ewe-apps]].

The desktop's file manager, media player and viewer are now ewe's own:
**ewe Files** (`ewe-files-app`), **ewe Player** (`ewe-player`), **ewe
Viewer** (`ewe-viewer`) — one repo, one package, three Tauri 2 apps on the
system WebKitGTK with the UI ported from ewe Browser's file manager. They
are the defaults a fresh install gets and the defaults an upgrader is
**moved to once** (`default-apps-0.44.done`), with a Default-apps row for
every role in ewe Settings so a user can pick anything else.

## What it supersedes — honestly

[[Foundation Choices]] → *Traditional GTK apps* said: shipped first-party
apps are traditional GTK — **Nemo, Engrampa, imv, Zathura, mpv** (+ kitty,
Zed) — because a menubar + server-side decorations render borderless under
Hyprland, one `mimeapps.list` is the single source for defaults, and no
libadwaita headerbar. **For those five roles that decision is superseded
by this one.** What survives of it:

- **One `mimeapps.list`** is still the single source for defaults (GIO reads
  it; `ewe-setup` seeds it; the new apps register through it) — unchanged.
- **No libadwaita, no Qt/KDE first-party apps, no `plasma-integration`** —
  unchanged ([[Parked and Rejected Ideas]]). The new apps draw their own
  chrome from the design tokens; they are not GNOME-style either.
- **kitty and Zed** stay the terminal and the editor; **mpv stays installed**
  for `mpvpaper` and as ewe Browser's fallback player — it is no longer a
  default for anything.

Also amended: decision 33 ([[ewe browser replaces Helium]]) said *Nemo
keeps folders* — folders are ewe Files' now (`inode/directory`, Super+E,
ewe Browser's folder give-back `ewe-files-app.desktop`).

## Why

- **One look, live.** The GTK set needed `colorscheme.sh` to theme Zathura,
  imv and mpv and a dconf system db for Nemo; the new apps read the design
  tokens like ewe Browser does and follow dark/light at once.
- **One material across the product** (decision 50): the file manager
  people already used inside ewe Browser is the file manager, as a window
  of its own, with the same Synced group, Places and Recent.
- **Less to carry.** Nemo pulled cinnamon-desktop, Engrampa the MATE
  libraries, Zathura mupdf, imv its own stack, mpv + mpv-mpris + uosc from
  the AUR. GStreamer serves ewe Player and the thumbnailer alike
  ([[The Package Diet]]).
- **The actions the owner asked for** in the polish pass (Compress, Extract
  to…, Set as wallpaper, Open in terminal, Open with…) are the app's own,
  not `nemo-actions` files and dconf keys that reached only `install.sh`
  machines (0.43's lesson).

## Not Electron

[[ewe browser replaces Helium]] took Electron because a browser needs
Chromium (extensions, Widevine). A file manager, a player and a viewer do
not: WebKitGTK plays through GStreamer, pdf.js renders PDFs, and the
package stays small (no bundled runtime). [[Process Split — Shell vs Apps]]
holds: big UIs are separate Tauri apps, the shell stays one process.

## Not taken

Keeping Nemo for folders beside ewe Files (two `FileManager1` owners; Nemo
holds the name while installed, so the owner removes it). Shipping the three
apps as three packages (one release line is simpler; they share a core).
Qt/KDE apps (still rejected).

> **Build guard:** every new file-type default goes through `ewe-setup`'s
> `_mime` (seed-only) and gets a row in ewe Settings → Default apps; a
> migration from an old app is a one-time `_mime_take` behind a dated marker
> under `~/.local/state/ewe/`, never a blind overwrite. *Breaks if
> violated:* a user's explicit choice is silently replaced on every upgrade.

## Related

- [[Decision Index]] · [[ewe-apps]] · [[Foundation Choices]] ·
  [[The Package Diet]] · [[ewe browser replaces Helium]] · [[Contracts and Public API]]
