---
tags:
  - ewe-map
  - roadmap
title: Open Questions
up: "[[Home]]"
---

# Open Questions

Deliberately unresolved. When one of these gets an answer, move it to a
decision note (or [[Parked and Rejected Ideas]]) and delete it here.

## Architecture

- **Rust rewrite of ewe-castd?** — parked until profiling demands it.
- **Native QtWebEngine OAuth webview** — browser round-trip works; webview
  stays "a later phase". Still wanted?
- **EDS (evolution-data-server) as a primary calendar source?** — currently
  an optional secondary fallback behind Google/CalDAV.

## Safe, ewe browser and the companion (2026-10-15)

- **ewe browser's Sync and rule 6.** The browser still has its own sync
  switch and *Sync now*: ewe-sync can't start a browser sync yet (its Sync
  now pushes `ewe.conf` and runs folder pairs only). Proposal
  (ewe-browser's `docs/PLAN.md`): a **Browser** row in ewe-sync that reads
  `~/.config/ewe-browser/sync/status.json`, plus an `ewe-browser sync` verb
  (answers the status JSON); then the browser's *Sync now* goes and its
  Sync section says "Managed in ewe Sync". Wanted?
- **"find" now means files in the companion** (P2.9): "find my resume"
  searches `$HOME` by name; "search", "google" and "look up" mean the web.
  Is that the split the owner expects?
- **The main `ewe-safe.sock` server has one thread per connection and no
  cap** (the SSH agent's socket has 32). The window and watchers hold
  connections for hours, so a cap needs care. It needs its own change.
- **Safe's merge is per entry, newest wins.** A password changed on two
  machines before they sync: the older one goes to the item's history
  (nothing is lost, but the user may not notice). Passkeys merge on their
  own since ewe-safe#11. A field-level merge for every field?

## Komble

- **AUR search across the whole AUR** — currently known-packages only.
- **Snapshots/rollback** (pacman snapshot tooling) — considered, not scoped.
- **Debian build's remaining features** — which ones translate to Arch at
  all?

## ewe-sync

- **Selective sync inside a folder pair** — "use excludes" today; is the
  UI worth it?
- **Bandwidth limits** — documented limit; does anyone actually need them?
- **Multi-account?** — one Nextcloud account is the model. More than one?

## Plugins (0.25, from the implementation reports)

- **`quickPage.key` reserved set** = `home wifi bt audio cal notifs`; the
  extracted pages use the legacy keys `vpn ssh cast mobile mail`. Should
  the reserved set grow, or stay minimal?
- **`Shell.openSettings(page)`** forwards `--page <name>` — ewe-settings
  does not consume it yet.
- **A `Shell` network-changed signal** would remove the VPN plugin's second
  `nmcli monitor` (core runs one too). Also: a host-level `shown` convention
  for `quick-tile`s (today: hide the parent slot).
- **Core `google status` still reports `mailUnread`/`mailState`** (ewe-settings
  reads them) — drop or proxy to `ewe.mail`? Should ewe-sync poke `mail
  refresh` after a Google sign-in?
- **`autostart.sh` and the phone plugin both start `kdeconnectd`** (both
  guarded) — confirm the duplicate is gone after the carve-out.
- **Komble `plugin_create` KINDS** still list API 2 kinds.
- **`uninstall.sh` never removes `/usr/local/bin/ewe-greeter`.**
- **`ewe-diag` `diag.sh:15`** still runs `~/.config/hypr/scripts/cast-check.sh`
  → must become the plugin path.
- **Package deps split** — D7 keeps them in ewe's `depends`; when do they
  become `optdepends` driven by `requires`?
- **A static `dock-item`** cannot be hidden by the Music/Places `button =
  bar` setting from an installed dock (only `setDockItemShown` at runtime).

## Desktop

- ~~**Quickshell power menu**~~ — answered in 0.39: Quick settings has a Power page.
- **Text-size beyond 130?** — bar steps icon size at 130; where's the
  ceiling?
- **More accessibility modes** — which remaps does the audit data suggest
  next?

## Distro

- **Standalone release shape** — versioning, ISO cadence, upgrade story for
  beta installs.
- **CASA verification budget** — only if ewe ever outgrows 100 Google mail
  test-users (see [[RFC-002 — Auth Broker]]).

## Method

- How much of `docs/MANUAL.md` migrates to the website vs stays in-repo.

## Related

- [[Decision Index]] · [[Roadmap and Status]] · [[Parked and Rejected Ideas]]
