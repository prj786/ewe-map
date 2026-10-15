---
tags:
  - ewe-map
  - component
title: ewe-browser
up: "[[Home]]"
---

# ewe-browser — the browser, files and music app

`~/Projects/ewe/ewe-browser` · [github.com/prj786/ewe-browser](https://github.com/prj786/ewe-browser) ·
Electron 44 (castlabs ECS build, Chromium 152) + Solid · GPL-3.0-only ·
**0.2.0-beta** released 2026-10-15 (0.1.0-beta on 2026-10-14)

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
| the companion | `browse {url}` prefers `ewe-browser` on `PATH` (`ewe-plugin-companion/Service.qml`); with P2.9 (merged, the companion is not released yet) it calls the command line: search, open, play, history, tabs, `page --text` (untrusted) |
| Safe | `ewe-safe.sock`: `match` for the suggestion list, `passkey-*` for WebAuthn; `ewe-safe unlock --ask`, `ewe-safe-app` |

## New in 0.2.0-beta (released 2026-10-15)

Tag `v0.2.0-beta` on `1e94143` (bump ewe-browser#6), package
`ewe-browser-0.2.0beta-1`, published to `[ewe]` on 2026-10-15. The owner
approved committing and shipping the Safe and history work that day.

| what | PR | tests |
|---|---|---|
| **The command line** `ewe-browser <verb>` (`docs/CLI.md`): 31 tools, JSON, exit 0, `undo`, `untrusted`; a `0600` socket per profile; `/usr/bin/ewe-browser` becomes a sh wrapper. Also the rail: *collapsed* now hides it; the left window edge brings it back | ewe-browser#3 (the owner's WIP, taken over) | 206 unit + 27/27 e2e |
| **Safe built in** ([[Safe in the Browser — guards, not a page click]]): a suggestion list under login/email/password/code fields drawn by the browser (setting `safe.suggest`, on), passkeys through a main-world `navigator.credentials` override and a browser-drawn sheet (setting `safe.passkeys`, on), conditional mediation, save/update prompts | ewe-browser#4 | e2e 40 passed with a local relying party that checks every signature; the 7 tests against a real Safe daemon passed in a sandbox before the merge, skipped in the PR run |
| **History and real sync** ([[Browser History — SQLite, synced clear records]]): `app://history` (by day, search, site filter, delete, *Clear browsing data*, *Keep history for*), Ctrl+Shift+H, `history.db` through `node:sqlite`, synced deletes, tabs from other computers, `sync/status.json` for ewe-sync | ewe-browser#5 | 104 shared + 258 browser unit, e2e 44 passed |

Inside the browser (not ewe API): Safe adds IPC channels `ewe:safe-page`,
`ewe:safe-passkey` (invoke, page layer, http(s) frames) and `ewe:safe-fill`,
`ewe:safe-suggest` (main → one frame), and overlay parts `prompt`,
`suggest`, `sheet`.

Not verified: real sites (github.com, google.com); *Use a security key
instead* with a real key; zoom other than 100 %; history sync between two
real machines on the owner's Nextcloud.

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
> the app writes for folders must never be `ewe-browser.desktop`. The repo
> must stay **public**: ewe-repo's `publish` reads releases with its own
> `GITHUB_TOKEN`, and Komble and get.sh fetch them anonymously — while it was
> private the first publish logged `ewe-browser -> (no release)` and the
> fresh-install gate refused it (2026-10-14).
> `docs/CLI.md` is public API (since 0.2.0-beta): verbs and fields are only added.
> The main process decides a page's origin for Safe; nothing fills on page
> load. Keep e2e runs off the live session (nested Hyprland) and give
> parallel runs their own `EWE_TEST_RULE` and a short `TMPDIR`.
