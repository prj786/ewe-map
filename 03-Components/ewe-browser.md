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
**0.4.0-beta** released 2026-10-18 (0.3.0-beta on 2026-10-17, 0.2.2-beta and 0.2.1-beta on 2026-10-16, 0.2.0-beta on 2026-10-15, 0.1.0-beta on 2026-10-14)

**The desktop's browser** since it replaced Helium
([[ewe browser replaces Helium]]): a Chromium-engine browser with a left tab
rail, a thin bottom bar for workspaces and tools, a command palette, bookmarks, downloads and history, plus
`app://` pages for a home screen, a file manager, viewers (images, video,
audio, text, code, Markdown, PDF) and a music player. It reads
`~/.config/quickshell/theme-tokens.json` itself, so colours, radius, fonts and
motion follow ewe live with no theming hook.

## How it plugs into ewe

| ewe piece | what ewe browser does with it |
|---|---|
| `theme-tokens.json` | the whole look, watched live (an atomic rename by ewe-conf is picked up) |
| `ewe-cloud` | Nextcloud WebDAV sync of bookmarks, history and portable settings (`ewe/browser/`) — under ewe it **follows the account** (signed in and `sync.browser` not false; `sync/ewe-link.ts`), no toggle or Sync now of its own (rule 6); runs a cycle when `~/.local/state/ewe/sync-now` changes (2026-10-31) |
| ewe-sync | `sync-folders.json` → the file manager's **Synced** group, state glyphs, the "In your account" chip; *Keep in your account…* runs `ewe-sync --add-folder <path>`, the chip and Settings run `ewe-sync --pane …` (2026-10-31) |
| `ewe-files` / `ewe-drive` | Nextcloud and Google Drive places in the file manager, *Connect* runs `… mount` |
| Safe — **the only password filler** since 0.4.0-beta ([[Browser Passwords — Safe only]]) | `ewe-safe.sock`: `match` for the suggestion list, `passkey-*` for WebAuthn; `ewe-safe unlock --ask`, `ewe-safe-app`; Ctrl+Shift+L, the address field's key and the page menu open Safe's list. Up to 0.3.0-beta Ctrl+Shift+L went through `ewe-pass` (the [[Passwords Plugin]]'s tool, any manager) — removed; password-manager extensions are refused |
| `ewe-conf set apps.startup` | "Start with ewe" adds `ewe-browser --background` |
| GTK `recently-used.xbel` | the home screen's Recent cards (docs, videos, music, sites) |
| the companion (Shaun) | `browse {url}` prefers `ewe-browser` on `PATH` (`ewe-plugin-companion/Service.qml`); since ewe-companion 0.1.0-beta it calls the command line — search, open, play, history, tabs, `page --text` (untrusted) — and since 0.2.0-beta a site's own search (`search --site`), bookmarks, back/forward, workspaces, downloads |
| Hyprland (ewe 0.30.0-beta) | a 4-finger swipe left/right while the browser is focused runs `ewe-browser workspace next\|prev` ([[Four Fingers — ewe browser's workspaces]]) |

## New in 0.4.0-beta — wave 2 (released 2026-10-18)

The owner's ask (2026-10-18): finger gestures, more shortcuts, right-click
menus on websites, only Safe filling inputs; DNS and security settings; and
Shaun reaching further into the browser ("search men's shoes on zara" →
Zara's own results). Two streams, `feat/input-menus` and
`feat/privacy-site-search`, landed together as ewe-browser#13 (the bump
`7788522` inside it); tag `v0.4.0-beta` on `1d36473`, package
`ewe-browser-0.4.0beta-1`, published to `[ewe]` on 2026-10-18. Decisions: [[Browser Passwords — Safe only]]
(#40), [[Four Fingers — ewe browser's workspaces]] (#41),
[[Site Permissions — ask per site]] (#42). Lands with ewe-companion
0.2.0-beta (Shaun) and ewe 0.30.0-beta (the 4-finger gesture).

| what | how |
|---|---|
| **Two-finger swipe** back / forward | the page preload watches `wheel` in the main frame; an arrow at the page edge fills toward 160 css px and navigates past it; only with history that way, never when something under the pointer can still scroll sideways or the page handled the wheel. With ewe's natural scrolling, fingers to the right = back. Settings → Browsing → *Swipe to go back* (on) |
| **Mouse side buttons** | pages already had them (Chromium, and a page may cancel them); now the rail, the bottom bar, the overlay and the sidebar too |
| **Find in page** | Ctrl+F: a bar at the page card's top right with "2/7"; Enter / F3 / Ctrl+G next, Shift+Enter / Shift+F3 / Ctrl+Shift+G previous, Esc closes and keeps the match selected; prefilled with the selection. Files, Music, History and the sidebar keep their own Ctrl+F |
| **~20 new shortcuts**, all rebindable | listed in [[Keymap Reference]]; the keys a web app may use itself go to the page first |
| **Right-click on web pages** | links (new tab, new workspace, new window, save, copy), images, video and audio, selected text (copy, search, Go to), fields (spelling, *Fill from Safe*, *Use a strong password*, editing), the page (back, forward, reload, bookmark, save page, print, view source) and Inspect; the menu key and Shift+F10 too. Extension menu items not yet |
| **Safe only** (#40) | Ctrl+Shift+L, the key and the menu open Safe's own list; the `ewe-pass` route is gone; 36 password-manager extension ids refused before they load |
| **Settings → Privacy and security** | **Secure DNS** Off (default) / Automatic / Cloudflare / Quad9 / Mullvad / AdGuard / NextDNS (your id) / Custom (a DoH template), applied live through `app.configureHostResolver` (a provider = secure mode, no fallback); **HTTPS-Only** (off by default): http main frames and subframes of non-local hosts upgraded, a failed upgrade shows an interstitial (`app://sad/?kind=https-only`) with *Continue to the http site* for this run; **third-party cookies blocked** (on) through Chromium's `ForceThirdPartyCookieBlockingEnabled` at startup — a change applies after a restart; **Global Privacy Control** (on): `Sec-GPC: 1` and `navigator.globalPrivacyControl`. Not synced: DNS is per machine |
| **Site permissions** (#42) | ask per top-level site through a prompt card; `permissions.json`; a site-info panel from the lock; a list in Settings |
| **Site search** | `@zara men's shoes` in the palette or the address field, `search --site`, `site`. Order: the newest **history** url on that site with a search term (https, a site with 2+ visits — keeps your locale) → an **OpenSearch** descriptor found on a visited page (`site-search.json`, 500 hosts, 30 days) → the built-in **table** of 66 sites (`{cc}` from the time zone via `zone1970.tab`, `{lang}` from `LANG`; Zara is `zara.com/{cc}/{lang}/search?searchTerm=…`, `/ge/en/` here) → a `site:` **filter** with the Settings engine |
| **Command line** | 31 → **43 tools**: `site`, `workspaces`, `workspace activate\|next\|prev\|create\|rename\|remove`, `back`, `forward`, `download open\|show`, `search --site`, `open --workspace` (see [[Contracts and Public API]]); `workspace next` answers in ~45 ms (the 4-finger swipe runs it) |

Inside the browser (not ewe API): IPC `ewe:page-input`, `ewe:page-action`,
`ewe:permissions`, `ewe:permissions-changed`, `ewe:privacy-frame`;
`ewe:passwords` removed. New in the profile: `permissions.json`,
`site-search.json` ([[Storage Map]]).

Tests: unit shared 146, browser 326 (2 skipped); e2e on the merged build 58
passed, 7 skipped (they need the real Safe daemon); both streams had an
independent security review, every finding fixed (none critical or high).
Not verified: the swipe on a real touchpad, printing by hand; location has
no provider in Electron on Linux.

Open (`docs/PLAN.md`, Wave 2): screen sharing (`getDisplayMedia` needs the
portal picker), external protocol links, USB/HID/serial choosers, Storage
Access prompts, per-site HTTPS-Only exceptions beyond the session, GPC in
workers, a fast fallback when port 443 hangs, the lock while the rail is
hidden, extension context-menu items, deleting a refused password-manager
extension from the UI, a find bar that survives another overlay part.

> **Build guard:** Electron answers **"denied"** for every undecided
> permission, so the page preload must keep patching
> `Permissions.prototype.query` / `Notification.permission` to
> `prompt` / `default` for the origin's undecided kinds — or sites never
> ask. `before-input-event` runs **before** the page: the shortcuts a web
> app may use (`PAGE_FIRST_SHORTCUTS`, `PAGE_FIRST_CHORDS`) act on http(s)
> tabs only after the page did not `preventDefault` them (the preload
> reports within `PAGE_KEY_MS`, 1 s) — or Ctrl+U in Gmail opens the page
> source instead of underlining. An OpenSearch descriptor is fetched only
> over https, on the default port, without credentials, from the page's own
> registrable domain (private suffixes on), never a local name or private
> address, with `redirect: 'error'` (64 KiB, 8 s) — or a page can make the
> browser fetch inside your network (SSRF). Third-party cookie blocking has
> no Electron API: the Chromium feature is read at startup only (from
> `settings.json` in `bootstrap()`), so Settings must say "after a
> restart". The CLI bundle loads the site-search modules only for `site` /
> `search --site`, keeping `workspace next` fast for the gesture.

## New in 0.3.0-beta (released 2026-10-17)

The owner's ask: workspaces and the tool buttons did not fit in the rail's
small foot. Tag `v0.3.0-beta` on `a18366c` (feature ewe-browser#11, bump
#12), package `ewe-browser-0.3.0beta-1`, published to `[ewe]` on
2026-10-17. Decision: [[Browser Bottom Bar — workspaces and tools]].

- A 32px bar across the whole window under the page card, kept when the
  rail is hidden, gone in fullscreen: workspace chips with names on the
  left (click, double-click to rename, right-click for colour and the
  rest, drop a dragged rail tab on one), `+` opens "Workspace N" on Home;
  Bookmarks / Downloads / History, Music, Files, Settings on the right.
- The rail keeps tabs: pinned tiles under the address field, extension
  buttons at the foot. The sidebar and the rail peek end above the bar.
- Verified with e2e (45 passed) and screenshots; not yet on the owner's
  machine.

> **Build guard:** keep the sidebar and the peek `BOTTOM_BAR_HEIGHT`
> above the bottom outside fullscreen, and render the chips with
> `<Index>` (with `<For>` a state broadcast rebuilt them mid-rename).
> *Breaks if violated:* the sidebar covers the bar's buttons; a rename
> commits half a name.

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
  [[ewe browser replaces Helium]] · [[Roadmap and Status]] ·
  [[Browser Passwords — Safe only]] · [[Site Permissions — ask per site]] ·
  [[Four Fingers — ewe browser's workspaces]]

> **Build guard:** the runtime must stay castlabs' (`electronDist` points at
> `node_modules/electron/dist`; never let electron-builder download upstream
> Electron, which has no Widevine); the PKGBUILD lives at the repo root (the
> get.sh source fallback runs makepkg in the clone root); and the desktop id
> the app writes for folders must never be `ewe-browser.desktop`. The repo
> must stay **public**: ewe-repo's `publish` reads releases with its own
> `GITHUB_TOKEN`, and Komble and get.sh fetch them anonymously — while it was
> private the first publish logged `ewe-browser -> (no release)` and the
> fresh-install gate refused it (2026-10-14).
> `docs/CLI.md` is public API (since 0.2.0-beta): verbs and fields are only added;
> since 0.4.0-beta ewe's `hyprland.lua` calls `workspace next|prev` and
> Shaun calls the wave-2 verbs.
> The reported Chrome major must follow Chrome's schedule: if Google changes
> the cadence, move `STABLE_MAJOR` / `STABLE_SINCE` / `STABLE_CADENCE_MS` in
> `identity.ts`, and keep the user agent, `Sec-CH-UA*` and `userAgentData` on
> one number. Web pages must never contribute drag regions
> (`ignoreDragRegions` in the page preload): a site's `app-region: drag`
> makes a dead patch in a frameless window.
> The main process decides a page's origin for Safe; nothing fills on page
> load. Keep e2e runs off the live session (nested Hyprland) and give
> parallel runs their own `EWE_TEST_RULE` and a short `TMPDIR`.
