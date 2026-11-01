---
tags:
  - ewe-map
  - reference
title: Version Ledger
up: "[[Home]]"
---

# Version Ledger

Versions as of **2026-10-18** (from the repos' `VERSION` files). Update
this note on every release (see [[Release Checklist]]).

| component | version | notes |
|---|---|---|
| ewe (DE) | **0.38.0-beta** | canonical in repo-root `VERSION`; mirrored in `Globals.version` (Settings sidebar) — bump both, tag `vX.Y.Z`. 0.38.0-beta released 2026-11-01 (`v0.38.0-beta` on `6b1c8d0`, ewe#77: the network says what's true — `20-ewe-wired.conf`, zram everywhere, NetState, `ewe-tailscale` — and Remote, RFC-009 — `ewe-remote`, the per-user sshd, code pairing, the Sharing tile/page and bar glyph); 0.37.0-beta released 2026-10-31 (`v0.37.0-beta` on `d12c269`, ewe#76: `sync.folders` shared in `ewe-conf sync`, `sync.browser`, ewe-files never mounts over files, no second restore offer — [[Sync — sign in once, everything follows]]); 0.36.0-beta released 2026-10-27 (`v0.36.0-beta` on `2a2f7f2`, ewe#75: the Alt+Tab window switcher `ewe.switcher` — written straight into `plugins/`, its repo still to be created — Monocle, one Overview card per group); 0.35.2-beta released 2026-10-26 (`v0.35.2-beta` on `d1c6493`, ewe#74: the shell's own keys are global shortcuts, no process per press); 0.35.1-beta (ewe#73: one "Workspace 3" per display again) — the three recorded here 2026-10-31 from git, the vault had lagged. 0.35.0-beta released 2026-10-23 (`v0.35.0-beta` on `d1cca36`, ewe#72: every display has its own workspaces 1, 2, 3 … like macOS, or one shared set — `[desktop.workspaces] mode`; vendors `ewe.dock` 1.3.0; [[Workspaces Per Display]]); 0.34.1-beta released 2026-10-23 (`v0.34.1-beta` on `1d5901a`, ewe#71: minimized windows sit in the dock themselves, like macOS — vendors `ewe.dock` 1.2.1); 0.34.0-beta released 2026-10-23 (`v0.34.0-beta` on `cc5b4eb`, ewe#70: the Overview spreads your windows like Mission Control, Super+Z minimizes — the Pen is gone, vendors `ewe.dock` 1.2.0 (Minimized + Downloads); [[Overview Spreads the Windows]]); 0.33.1-beta released 2026-10-21 (`v0.33.1-beta` on `623a468`, ewe#69: "Sign in" buttons open your browser again); 0.33.0-beta released 2026-10-20 (`v0.33.0-beta` on `761eb7b`, ewe#68: ewe-conf sync merges key by key); 0.32.1-beta released 2026-10-20 (`v0.32.1-beta` on `5a57142`, ewe#67: ewe browser back in the launcher); 0.32.0-beta (ewe#66: vendors `ewe.slack` 0.3.0 — unread Slack DMs; recorded here 2026-10-23 from git, the vault had lagged); 0.31.0-beta released 2026-10-18 (`v0.31.0-beta` on `f6fbe73`; ewe#64: `[safe] unlock_at_login` + `confirm_cards`, vendors `ewe.safe` 1.0.1, TROUBLESHOOTING's keyring repair; [[RFC-008 — ewe Safe]] → Amendment 2026-10-18); 0.30.0-beta released 2026-10-18 (`v0.30.0-beta` on `1f6721e`, ewe#62: a 4-finger swipe left/right switches ewe browser's own workspaces while it is focused — [[Four Fingers — ewe browser's workspaces]]; SHORTCUTS.md rows for it and the browser's 2-finger back/forward; vendors `ewe.companion` 0.5.0); 0.29.0-beta released 2026-10-17 (`v0.29.0-beta` on `d0f84de`: vendors `ewe.companion` 0.4.0 — Shaun — opt-in; ewe#61); 0.28.0-beta released 2026-10-15 (`v0.28.0-beta` on `52bf89a`; vendors `ewe.passwords` 1.3.0 — Super+P offers **Use Safe**; ewe-conf quoted keys keep their dots, ewe#58; `[safe] ssh_agent`/`ssh_confirm`, ewe#59; bump ewe#60); 0.27.0-beta released 2026-10-15 (Safe on the desktop: the `ewe.safe` plugin vendored, `ewe.passwords` 1.2.0 fills from Safe; ewe#55–57); 0.26.1-beta released 2026-10-14 (light mode is official, companion groundwork: the `[companion]` ewe-conf domain, kitty remote control; ewe#52 + the bump ewe#53); 0.26.0-beta released 2026-10-14 (ewe browser replaces Helium; get.sh takes the newest release; ewe#51); 0.25.2-beta released 2026-10-11 (first-party plugins survive a Restore — the payload, not ewe.conf, makes an installed `ewe.` plugin first-party; ewe#50); 0.25.1-beta released 2026-10-10 (sync that heals, Glass, plugin settings with the plugin, movable widgets, one name — D9–D13; ewe#49); 0.25.0-beta released 2026-10-04 (add-ons, quiet lid, snappy Overview, X11 scale); `vault-check` also accepts `versions.<key>_next` for a branch whose `VERSION` is already the next one |
| ewe-os (distro) | **0.15.0-beta** | its own version line, separate from the DE; 0.15.0-beta released 2026-11-01 (`v0.15.0-beta` on `c6f6800`, ewe-os#19) = the ISO for ewe 0.37 / ewe-sync 0.15 / ewe browser 0.6: the installer's *Your ewe account* step (sign in or skip; the app password into the new login keyring, the restore at install, the backup's plugins pre-checked) — built by CI, no QEMU pass yet; 0.14.0-beta released 2026-10-23 = the ISO for ewe 0.35 (Plugins step shows all 16 plugins with Shaun/Slack glyphs, the username fix #13, *beta* rail label; ewe-os#18, the owner asked for it). Before it, 0.13.0-beta released 2026-10-04 = the ISO for ewe 0.25 (installer Plugins step, `addons` helper verb, `ewe-install --addons`, live user gets the dock; ewe-os#15). Since then on `main`, untagged: the Plugins name in the installer (#16), the light-mode ROADMAP line (#17). No ISO unless the owner asks |
| ewe-repo | rolling `x86_64` | no version — the release *is* the repository |
| komble-arch | **0.20.2-beta** | 0.20.2 (2026-10-14): ewe browser is a first-party app; Helium's card is an AUR app. 0.20.1 (2026-10-11): Add a plugin is the first group on Plugins; dialogs open in place and the scrim fades its colour (WebKitGTK blink). 0.20.0 (2026-10-10): plugin Options in a dialog, Show in bar, widget pin/lock, `--options=<id>`, the page is called Plugins. 0.19.0: the catalogue (`--addons`, `plugin_install`) |
| ewe-settings | **0.20.0-beta** | 0.20.0 (2026-10-23, `v0.20.0-beta` on `14b72a8`, ewe-settings#21): Displays → Workspaces, Separate or Shared (shown with two or more displays). 0.19.0 (2026-10-19, `v0.19.0-beta` on `9326e16`, ewe-settings#20 — recorded here 2026-10-23 from git, the vault had lagged): network details — IP, DNS, MAC and MTU per network. 0.18.0 (2026-10-10): plugin settings left (Dock, Mail, bar rows), Glass and transparency, a shell probe that recovers. 0.17.0: plugin-aware panes, Insomnia, guarded hypridle wake; footer shows **ewe's** version, by design |
| ewe-sync | **0.15.1-beta** | 0.15.1-beta released 2026-11-01 (`v0.15.1-beta` on `64fbd32`, ewe-sync#10: `machines/<id>.json`, two computers with one hostname no longer overwrite each other); 0.15.0-beta released 2026-10-31 (`v0.15.0-beta` on `c2eacc3`, package `ewe-sync-0.15.0beta-1`; ewe-sync#8 + the fix #9): the Overview, Bring everything back, Folders (suggestions, pickers, pause, the Nextcloud app taken over), remote-change polling, `sync-folders.json`, `--pane/--add-folder/--status` ([[Sync — sign in once, everything follows]]); the first tag's build failed on a Tauri npm/crate mismatch, the unreleased tag moved to #9. 0.14.4 (2026-10-10): the conflict banner/tray read `conflict`. 0.14.3: icon line-glyph release; RFC-006; preinstalled from ISO 0.9-alpha on |
| ewe-browser | **0.7.0-beta** | 0.7.0-beta released 2026-11-01 (`v0.7.0-beta` on `90fd24f`, ewe-browser#18: the remote workspace — Browse from <computer>, RFC-009); 0.6.0-beta released 2026-10-31 (`v0.6.0-beta` on `9db8818`, package `ewe-browser-0.6.0beta-1`, ewe-browser#17): sync follows the ewe account (`sync.browser`, no own toggle), the file manager's Synced folders, chip and *Keep in your account…*. 0.5.2-beta released 2026-10-23 (`v0.5.2-beta` on `b842952`, package `ewe-browser-0.5.2beta-1`, ewe-browser#16): downloads.json is THROTTLED (once a second while a download runs, first write at once) — the 1 s trailing debounce held every write back until a download finished, so the dock's progress ring never moved; e2e slow download red/green. 0.5.1-beta (2026-10-21, ewe-browser#15): links from other Electron apps open again (recorded here 2026-10-23, the vault had lagged). 0.5.0-beta released 2026-10-18 (`v0.5.0-beta` on `e326ea1`, package `ewe-browser-0.5.0beta-1`; ewe-browser#14, the bump inside it): every sign-up asks to save (also when Safe is locked: Unlock and save), step usernames, app-style sign-ups; Safe's cards and addresses fill in pages (cards on https only, after `ewe-safe confirm`). 0.4.0-beta released 2026-10-18 (`v0.4.0-beta` on `1d36473`, package `ewe-browser-0.4.0beta-1`; ewe-browser#13, the bump `7788522` inside it): wave 2 — two-finger swipe, side buttons, find in page, ~20 new shortcuts (page first), right-click menus on pages, Safe-only filling ([[Browser Passwords — Safe only]]), Settings → Privacy and security (Secure DNS, HTTPS-Only, third-party cookies blocked, GPC), site permissions that ask ([[Site Permissions — ask per site]]), site search (`@zara …`), CLI 31 → 43 tools. 0.3.0-beta released 2026-10-17 (`v0.3.0-beta` on `a18366c`, package `ewe-browser-0.3.0beta-1`): workspaces and tools leave the rail for a thin full-width bottom bar, `+` opens "Workspace N" on Home (ewe-browser#11, bump #12; [[Browser Bottom Bar — workspaces and tools]]). 0.2.2-beta released 2026-10-16 (`v0.2.2-beta` on `0711ece`, package `ewe-browser-0.2.2beta-1`): a page's `app-region: drag` no longer makes a dead patch (ewe-browser#9, bump #10). 0.2.1-beta released 2026-10-16 (`v0.2.1-beta` on `a43fcb3`): pages see Chrome stable's major, so Gmail stops calling the browser outdated (#7, bump #8). 0.2.0-beta released 2026-10-15 (`v0.2.0-beta` on `1e94143`, package `ewe-browser-0.2.0beta-1`): the command line (ewe-browser#3), Safe built in — suggestions and passkeys (#4), history + real sync (#5); bump #6. First release 2026-10-14 (ewe-browser#1): the package (~120 MB, castlabs runtime), served from `[ewe]`, a dependency of `ewe` ([[ewe browser replaces Helium]]). Tag `vX.Y.Z-beta` → pkgver `X.Y.Zbeta`, like the Tauri apps; version in both `package.json` files |
| ewe-safe | **0.3.0-beta** | 0.3.0-beta released 2026-10-18 (`v0.3.0-beta` on `215321b`, package `ewe-safe-0.3.0beta-1`; ewe-safe#18 = `integrate/system`: system base, login unlock, cards, keyring): unlock with the login password (and Safe opens at login through gnome-keyring's `login`), `confirm`, `keyring repair` for the prompt at every start, cards and addresses; the PAM module and Safe-as-Secret-Service are parked. 0.2.0-beta released 2026-10-15 (`v0.2.0-beta` on `a3fcc5e` (after #16, a test-race fix, and #17, openssh for the package check; the tag moved twice, before any package was made), package `ewe-safe-0.2.0beta-1`): passkeys (KeePassXC's format), SSH keys + an ssh-agent, `read`/`run`/`inject`/`git-credential`, the window's edit fix — #10–#13 landed through #14 (`integrate/trio`), bump #15. After the upgrade: `systemctl --user daemon-reload && systemctl --user restart ewe-safe.socket` (the socket gained the agent's socket; this locks the safe). First release 2026-10-15 ([[ewe-safe]], RFC-008): `ewe-safed`, `ewe-safe`, `ewe-safe-app`, user units; served from `[ewe]`, **opt-in** (nothing depends on it — `pacman -S ewe-safe`). Tag `vX.Y.Z-beta` → pkgver `X.Y.Zbeta` (`release.yml` rewrites `_tag`/`pkgver`); version in `VERSION`, the root and app `Cargo.toml`, `app/package.json`, `tauri.conf.json`, the PKGBUILD |
| ewe-cast | phases A+B · **0.12.3** | built 2026-08-30; C = field-proven gate; 0.12.3 = the portal 1.4.1-2.1 threshold |
| ewe-companion · ewe.companion | **0.2.1-beta** · **0.5.0** | 0.2.1-beta released 2026-10-18 (`v0.2.1-beta` on `9ab6aa4`, ewe-companion#4: the pack said two fingers "left or right" go back and forward; with natural scrolling, ewe's default, fingers to the right go back). 0.2.0-beta released 2026-10-18 (`v0.2.0-beta` on `30eb37f`, package `ewe-companion-0.2.0beta-1`, ewe-companion#3 — P2.10, wave 2: a site's own search, more of the browser, Wi-Fi/Bluetooth/airplane/keep awake, a calculator, timers and reminders (`companion.db` migration 002), proposals for dark/light, power and the trash, the knowledge pack 91 → 122 topics with `cli.md`); the plugin 0.5.0 (ewe-plugin-companion#3: row icons) vendored in ewe 0.30.0-beta. **First release 2026-10-17** (the owner's "commit and make new release"): `v0.1.0-beta` on `0bf5267` (ewe-companion#2: Shaun, the release workflow), package `ewe-companion-0.1.0beta-1` in [ewe] (ewe-repo#4 carries it, opt-in); the plugin 0.4.0 (ewe-plugin-companion#2: Shaun, xray blur, the clip) is vendored in ewe 0.29.0-beta. Before: P2.9 on `main` 2026-10-15 (ewe-companion#1, plugin 0.3.0, ewe-plugin-companion#1) |
| plugin API | **3** (0.25) · 3.2 in 0.25.1 | host loads 2 and 3; 1 refused. 3.1 = `Shell.dockPrefs`/`pinnedApps`; 3.2 (0.25.1-beta) = `Shell.setSetting`, `defaultShown`/`toggle`, widget `pinLevel`/`locked`/`overlay`, setting `description`/`legacy` — additive, feature-detected |
| first-party plugins (were "add-ons") | in 0.25.1: **dock 1.1.0** (own settings) · **mail 1.1.0** (`notify` setting) · **sysmon 1.1.0** (Show in bar) · **media 1.0.2**, **places 1.0.2** (`toggle: false`) · cast, insomnia, phone, ssh, vpn **1.0.1** (one name) · clipboard **1.1.2** · screenshot **1.1.1** · passwords **1.3.0** (0.27: 1.2.0, provider `ewe`; 0.28: 1.3.0, **Use Safe**, ewe-plugin-passwords#3) · **safe 1.0.1** (new in 0.27, `migrate: false`; 1.0.1 in 0.31: Quick Access lists logins and notes only, ewe-plugin-safe#1) | as recorded in `plugins/bundle.json` (`default: false`, `migrate: true` for all); repos `prj786/ewe-plugin-<name>` |

## Versioning rules

- **Semver** `MAJOR.MINOR.PATCH` with `-alpha`/`-beta` until the first
  stable cut. Beta = usable, daily-drivable, but expect rough edges and
  breaking changes between versions.
- Named targets: **1.0-beta "Dolly"**; earlier milestones referenced
  `0.4-alpha` (RFC-001 phase 6), `0.5-alpha "connected"` (RFC-002), ISO
  `0.9-alpha` (RFC-006 preinstall).
- `VERSIONS` (plural) is unrelated to the release version — it documents
  **minimum tool floors**: Hyprland ≥ 0.55 (Lua config), Quickshell ≥ 0.2.
  It is documentation, not a lockfile (Arch rolls).

## Rename history (the migrations)

- **2026-08-19 — the deep rename**: `hypr-shell` → **ewe**. User unit
  `ewe.service`, state `~/.local/state/ewe`, every system file `*ewe*`.
  Old-name references remaining in phases 20/30/32/35 + deploy/startup
  scripts are **migrations** — leave them until a release or two has
  passed.
- `ewe-settings` was formerly `hypr-shell-settings`: the package
  `provides`/`replaces` the old name and ships a `hypr-settings`
  compatibility symlink.
- Old URLs redirect; a dev checkout may still sit in a dir called
  `hypr-shell` — that's outside the repo.

## Release history notes

- ewe 0.9.0: RFC-001 phases 1–5 landed.
- ewe 0.9.3 (Komble): For You restores from the manifest.
- ewe 0.9.7: `ewe-conf` generates `input.lua` + `user.lua` too.
- 0.12.7: the "Top bar settings do nothing" bug — prefs not in `THEME_MAP`
  were dropped by `absorb` (now a rule, see [[Rules of the House]]).
- 0.21.0-beta (2026-09-16): clipboard/screenshot/passwords extracted into
  bundled plugins.
- 0.24.1-beta (2026-09-25): shell death = Hyprland toplevel-export race;
  DNS → systemd-resolved.
- 0.25.0-beta (2026-10-04): **add-ons** — plugin API 3, the
  `Shell` singleton, `ewe-plugin install/migrate`, ten features carved out
  of the shell into `ewe.*` add-ons, nothing pre-installed on a fresh
  machine (D1–D8, [[Decision Index]]); quiet lid; one-step Overview; X11
  scale from the DRM-connected set; `post_upgrade` refreshes the greeter.
- 2026-10-15, one wave: **Safe 0.2.0-beta**, **ewe browser 0.2.0-beta**,
  **ewe 0.28.0-beta** (Passwords 1.3.0 vendored) — "a real safe":
  passkeys, an SSH agent, an `op`-like CLI, Safe inside the browser,
  browser history and sync. Published to `[ewe]` the same day; no ISO.
- 2026-10-18, wave 2 (PRs + release in one wave, no ISO): **ewe browser
  0.4.0-beta**, **ewe-companion 0.2.0-beta** (+ `ewe.companion` 0.5.0),
  **ewe 0.30.0-beta** — gestures, menus, find, privacy and security, site
  search, Safe-only filling in the browser; Shaun's desktop switches,
  timers, sums and site search; decisions 40–42. Same day,
  **ewe-companion 0.2.1-beta**: the pack's two-finger swipe direction.
- 2026-10-18, the same evening: **Safe 0.3.0-beta**, **ewe 0.31.0-beta**
  (ewe.safe 1.0.1), **ewe browser 0.5.0-beta** — unlock Safe with the login
  password, `keyring repair` for the prompt at every start, cards and
  addresses, every sign-up asks to save; decision 43. Published to `[ewe]`;
  no ISO.
- 2026-10-31, "sign in once, everything follows": **ewe-sync 0.15.0-beta**,
  **ewe browser 0.6.0-beta**, **ewe 0.37.0-beta**, then the `[ewe]`
  publish and **ewe-os 0.15.0-beta** (the installer's *Your ewe account*
  step); decision 46.

## Related

- [[Roadmap and Status]] · [[Release Checklist]] · [[Roadmap — Desktop and One File]]
