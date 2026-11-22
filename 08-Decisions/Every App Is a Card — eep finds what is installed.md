---
tags:
  - ewe-map
  - decisions
title: Every App Is a Card — eep finds what is installed
up: "[[Decision Index]]"
---

# Every app is a card — eep finds what is installed

**Decided 2026-11-22** (owner: "for now it would be great that every single
package will be an eep file even default ewe applications. also the apps i
am currently using … package manager is important part"). Built in
**eep 0.2.0-beta**, shipped with **ewe 0.49.0-beta** (which now depends on
eep) and **ewe-apps 0.3.1-beta** (decision 75; amends decision 74 and
[[Rules of the House]] → Rule 10). Contract: `eep/docs/CARD.md`.

`~/Applications` is **the whole app list**: not only the apps eep fetched
from the Nix cache, but every app the launcher shows — pacman packages,
Komble's AppImages, Steam games, the user's own launcher entries, ewe's
own apps (Files, Player, Viewer, Settings, Komble, Sync, Safe, Browser).

## How a found app works

| What | How |
|---|---|
| Found | every visible launcher entry (`$XDG_DATA_HOME` + `$XDG_DATA_DIRS`, first in line wins; not `NoDisplay`/`Hidden`, a `TryExec` that exists; `OnlyShowIn` is **not** checked because ewe's launcher shows those entries) gets a card `source = "system"`, id `sys-<desktop id>`, `from` = pacman / appimage / steam / flatpak / local / system, pacman's package + version (one `pacman -Qo` for all), and its icon (the icon theme spec: user theme → `Inherits` → hicolor → pixmaps; `magick` makes a 256 px PNG when the icon is over 96 KB) |
| Card leaves (Trash, delete) | the app is **hidden**: eep writes a full copy of its entry with `NoDisplay=true` and `X-Eep-Hides=<id>` into `~/.local/share/applications` — file types keep opening with it (`Hidden=true` would make GIO forget it: ewe Files would stop opening folders) |
| Card restored | shown again: eep's copy goes; a user-level entry it had copied aside to `~/.local/share/eep/hidden/` comes back byte for byte |
| App uninstalled (pacman, Komble) | its card goes by itself |
| An eep app takes the same desktop id | the found card goes (the eep card stands for it) |
| A new pacman app | its card appears within a second (the watcher follows the applications folders) |
| Double-click | GIO launches the entry (`eep open` → `gio launch`) |

Nothing is downloaded or uninstalled for a found app; pacman and Komble
still own those. `eep list` stays eep's own apps (Komble lists the others
under their own sources); `eep list --all` has every card. `find_apps =
false` in `config.toml` turns finding off. `found.json`
(`~/.local/state/eep/`) remembers what was found, so a hidden app is not
found again; if it is lost, eep's marks rebuild it.

## Why

- The owner tested eep on the real machine and wanted one place for every
  app, the iOS way — removing ewe's built-ins and his everyday apps the
  same way as an eep app.
- Hiding (not uninstalling) keeps it safe on a real machine: no root, no
  `pacman -R` from a background watcher, fully reversible, and the
  desktop's defaults (folders → ewe Files) never break.

## What changed with it

- **ewe depends on eep** (and so on `extra/nix`): Rule 10 no longer says
  "eep stays opt-in, nothing depends on it". It still holds that **no part
  of the system needs an eep (Nix) app**: the desktop, ewe's apps and
  drivers come from pacman; eep's *client* comes from `[ewe]` through
  pacman like every first-party app.
- ewe's launcher leaves `~/Applications/*.eep` out of its file results (the
  apps already are results); ewe Files says "update ewe" for a card when
  eep is missing instead of handing the TOML to the text editor — on the
  owner's machine, before eep was installed, "GIMP" opened as something
  other than GIMP that way.
- eep's catalog grew from 10 to 43 apps (the owner's free apps and popular
  ones), and Fable's review of eep 0.1 was fixed in the same release (see
  [[eep]] → Build-guard).

## Related

- [[eep]] · [[RFC-010 — eep]] · [[Rules of the House]] · [[ewe-apps]] · [[Komble]] · [[Troubleshooting Knowledge]]
