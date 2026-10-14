---
tags:
  - ewe-map
  - component
title: ewe-browser
up: "[[Home]]"
---

# ewe-browser — the browser, files and music app

`~/Projects/ewe/ewe-browser` · [github.com/prj786/ewe-browser](https://github.com/prj786/ewe-browser) ·
Electron 44 (castlabs ECS build, Chromium 152) + Solid · GPL-3.0-only · 0.1.0-beta

**The desktop's browser** since it replaced Helium
([[ewe browser replaces Helium]]): a Chromium-engine browser with a left tab
rail, workspaces, a command palette, bookmarks, downloads and history, plus
`app://` pages for a home screen, a file manager, viewers (images, video,
audio, text, code, Markdown, PDF) and a music player. It reads
`~/.config/quickshell/theme-tokens.json` itself, so colours, radius, fonts and
motion follow ewe live with no theming hook.

## How it plugs into ewe

| ewe piece | what ewe browser does with it |
|---|---|
| `theme-tokens.json` | the whole look, watched live (an atomic rename by ewe-conf is picked up) |
| `ewe-cloud` | Nextcloud WebDAV sync of bookmarks, history and portable settings (`ewe/browser/`) |
| `ewe-files` / `ewe-drive` | Nextcloud and Google Drive places in the file manager, *Connect* runs `… mount` |
| `ewe-pass` | password fill (Ctrl+Shift+L); secrets go from the manager to wtype, never through the browser |
| `ewe-conf set apps.startup` | "Start with ewe" adds `ewe-browser --background` |
| GTK `recently-used.xbel` | the home screen's Recent cards (docs, videos, music, sites) |
| the companion | `browse {url}` prefers `ewe-browser` on `PATH` (`ewe-plugin-companion/Service.qml`) |

## Packaging

Exactly the Komble pattern ([[Packaging and Updates]]): a root `PKGBUILD`,
`packaging/` (desktop entry, the globe icon per [[App Icons — one line glyph per app]]),
`scripts/gen-icons.sh`, and `release.yml` (tag `vX.Y.Z-beta` → makepkg in an
Arch container → `ewe-browser-X.Y.Zbeta-1-x86_64.pkg.tar.zst` on the GitHub
release). ewe-repo's `publish` collects it; the `ewe` package depends on it;
phase 20 installs it on the tarball path; Komble lists it in `first_party.rs`.

- The package carries its **own Electron runtime** under `/usr/lib/ewe-browser`
  (`/usr/bin/ewe-browser` is a symlink): Widevine needs castlabs' build, which
  no Arch package provides. ~120 MB compressed, ~300 MB installed.
- `chrome-sandbox` is **not** setuid: Arch's kernel allows unprivileged user
  namespaces, and the renderers run in their own user namespace with seccomp
  (checked on the package, 2026-10-14).
- Desktop id `ewe-browser.desktop`, WM class / app-id `ewe-browser`, icon
  `ewe-browser`. Folders stay with Nemo; the app's *Use ewe browser for
  folders* writes its own hidden `ewe-browser-folders.desktop`, never an
  entry that would shadow the packaged one.
- The Widevine CDM downloads into the profile on first launch; nothing
  proprietary ships in the package.

## Related

- [[Repository Map]] · [[Komble]] · [[ewe-repo]] · [[Packaging and Updates]] ·
  [[ewe browser replaces Helium]] · [[Roadmap and Status]]

> **Build guard:** the runtime must stay castlabs' (`electronDist` points at
> `node_modules/electron/dist`; never let electron-builder download upstream
> Electron, which has no Widevine); the PKGBUILD lives at the repo root (the
> get.sh source fallback runs makepkg in the clone root); and the desktop id
> the app writes for folders must never be `ewe-browser.desktop`.
