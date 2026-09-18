---
tags:
  - ewe-map
  - decisions
title: Komble — Arch Forced Decisions
up: "[[Home]]"
---

# Komble — the four things Arch forced

Komble-arch is a rewrite of an earlier Debian-targeted build, and the
differences are **structural, not stylistic** — Arch is not Debian with
different command names. These decisions exist because the platform says
so; do not "simplify" them away.

## 1. There is no per-package upgrade

Upgrading one package against a newer sync database is a **partial
upgrade** — unsupported on Arch. So Komble's Updates means: refresh the
databases, upgrade everything. No "update just this one" flow can exist.

## 2. AUR installs are PKGBUILD-first, built as you

The security model for the AUR path:

- Komble fetches and **displays the PKGBUILD**; the build button does not
  exist until you have it on screen. That is the whole security model.
- `makepkg` runs **as you**; only the final `pacman -U` is privileged.

## 3. One polkit action, one path, no shell

```
/usr/lib/komble/komble-helper      ← polkit authorises this
```

The helper's `case` statement is the **complete definition** of what Komble
may do as root: `install-repo`, `install-file`, `remove`, `sysupgrade`.
Every branch `exec`s; every branch puts `--` before user data so a package
named `-Qi` cannot become a flag; arity is checked; package names and paths
are validated in Rust *and* again in the helper. **Nothing is ever passed
through a shell** — commands are argv vectors, no interpolation surface.

Without the helper (e.g. `npm run tauri dev`), Komble falls back to
`pkexec pacman …` with fixed argv — correct, but one auth prompt per action
instead of one per session.

## 4. AppImages are per-user by nature

`~/.local/share/appimages` with menu integration, **no root at any point**;
the catalog comes from AppImageHub (~1600 apps). `fuse2` is a runtime
optional dependency — without it AppImages integrate but won't launch.

## The one-file write

The manifest write (`ewe-conf set --no-hooks apps.installed`) runs **as the
user, after the privileged step returned** — the only thing Komble writes
outside its own registry. No account, no network, no secrets. Source tag:
`repo` / `aur` / `first-party`. Komble never syncs the file — that's
ewe-sync's job (RFC-005).

## Other Arch realities Komble accepts

- `pacman -S` is all-or-nothing → the *installer* uses warn-and-skip; Komble
  surfaces failures per package instead of aborting.
- Runtime optional deps degrade gracefully: `pacman-contrib` (no update
  checking — `checkupdates` is the only safe way to ask), `expac` (no
  descriptions), `base-devel`+`git` (no AUR), `fuse2` (no AppImage launch).
- Tauri v2 has no pacman bundler → the **PKGBUILD is the packaging path**
  (installs polkit policy + helper too).

## Related

- [[Komble]] · [[Rules of the House]] · [[Decision Index]] ·
  [[Roadmap — Komble]]
