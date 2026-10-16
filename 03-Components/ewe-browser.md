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
**0.2.2-beta** released 2026-10-16 (0.2.1-beta the same day, 0.2.0-beta on 2026-10-15, 0.1.0-beta on 2026-10-14)

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

## Fixed in 0.2.1-beta and 0.2.2-beta (released 2026-10-16)

Two bugs the owner reported, both in the browser's identity with the web,
no new features. Tags `v0.2.1-beta` on `a43fcb3` (fix ewe-browser#7, bump
#8) and `v0.2.2-beta` on `0711ece` (fix #9, bump #10); packages
`ewe-browser-0.2.1beta-1` and `ewe-browser-0.2.2beta-1`, published to
`[ewe]` on 2026-10-16.

- **0.2.1** — Gmail said *This browser version is no longer supported*:
  pages saw Chromium 152 while Chrome stable was 155 (see *Identity* below).
- **0.2.2** — some clicks on websites did nothing: a page's
  `app-region: drag` area swallowed input (see the build guard and
  [[Troubleshooting Knowledge]]).

Not verified on the owner's machine yet: Gmail without the banner, and the
Azure portal panel from the report clicking again.

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

## Identity — the Chrome version pages see

Since Chrome 153 (2026-09-08) Google ships a new major **every two weeks**;
Electron's newest stable (44.x) still carries Chromium 152 and cannot keep
up at that cadence. Gmail supports only the two newest Chrome majors, so a
page told "152" showed *This browser version is no longer supported*
(2026-10-15, Chrome stable was 155). ewe browser therefore reports the
major Chrome stable is on today, counted from the official schedule
(`identity.ts`: 155 on 2026-10-06, +1 every 14 days, never below the
engine), in three places that must agree: the reduced user agent
(`Chrome/<major>.0.0.0`), the `Sec-CH-UA*` headers (rewritten on every
https request; Electron sends them on subresource requests, not on
navigations) and `navigator.userAgentData` (`preload/chrome-version.ts`,
main world at document start, every http(s) frame). A user agent that says
one version while the client hints say another looks like a spoofed
browser to Google's sign-in checks.

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
> The reported Chrome major must follow Chrome's schedule: if Google changes
> the cadence, move `STABLE_MAJOR` / `STABLE_SINCE` / `STABLE_CADENCE_MS` in
> `identity.ts`, and keep the user agent, `Sec-CH-UA*` and `userAgentData` on
> one number. Web pages must never contribute drag regions
> (`ignoreDragRegions` in the page preload): a site's `app-region: drag`
> makes a dead patch in a frameless window.
> The main process decides a page's origin for Safe; nothing fills on page
> load. Keep e2e runs off the live session (nested Hyprland) and give
> parallel runs their own `EWE_TEST_RULE` and a short `TMPDIR`.
