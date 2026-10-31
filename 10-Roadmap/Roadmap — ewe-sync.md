---
tags:
  - ewe-map
  - roadmap
title: Roadmap — ewe-sync
up: "[[Home]]"
---

# Roadmap — ewe-sync

Current: shipped preinstalled; four-pane window + tray; account, mail,
Google (optional), this machine, machines, folders.

## Released 2026-10-31 — ewe-sync 0.15.0-beta (with ewe 0.37, ewe browser 0.6, ewe-os 0.15)

[[Sync — sign in once, everything follows]]: the Overview, Bring everything
back, the shared folder list, remote-change polling, pause per computer, the
Nextcloud app shown and taken over, `sync-folders.json` + GTK bookmarks, the
browser following the account, `--pane/--add-folder/--status`, and
`tests/e2e-nextcloud.sh` against a real Nextcloud (ALL PASS). Shipped as one
wave (ewe browser and ewe-files read the snapshot ewe-sync writes; ewe-conf's
shared `sync.folders` ships with them); the installer signs you in from
ewe-os 0.15.0-beta.

## Still open

- Selective sync inside a pair (`--unsyncedfolders`), bandwidth limits
  (`--uplimit/--downlimit`) — the engine has both now.
- Giving folders back to the Nextcloud app after a takeover (the autostart
  entry is kept in `~/.local/state/ewe/nextcloud-app/`).
- A real **second computer** on metal (the e2e test covers two sandboxed
  computers on one host).

## Earlier next-release items (from the README's own "next release" note)

- **Folders that sync** — the Folders pane is the newest surface; the
  engine (`nextcloudcmd` two-way, `rclone copy` one-way) needs real-world
  hardening:
  - inotify burst → one run after 5 quiet seconds (verify on real trees)
  - conflict flows end-to-end: *Keep mine* / *Keep theirs*
  - `--unsyncedfolders` / excludes wiring
- **Restore polish** — the full circle: fresh machine → sign in →
  `ewe-conf pull && ewe-conf apply` → Komble's For you offers the apps →
  machines list shows the new machine.
- **Tray states** — conflict/offline/signed-out coverage.

## Parked (documented limits, not bugs)

- Selective sync inside a pair — use excludes.
- Bandwidth limits.
- Account creation — impossible by design; links to provider signup pages.

## If `nextcloudcmd` disagrees

The flags were written against the documented interface —
`ewe-sync/src-tauri/src/folders.rs` → `mod nccmd`. If a client version
changes behavior, that's the file to update; the UI contract must not
change (fallback: `rclone bisync`).

## Constraints that never change

- Nothing needs root; no privileged helper.
- Commands as argv, never through a shell.
- App password only in the keyring; non-secrets in `cloud.json`;
  `ewe.conf` carries identity only.
- The one file is `ewe-conf`'s job; ewe-sync drives it.

## Related

- [[ewe-sync]] · [[Account and Sync]] · [[RFC-006 — ewe-sync App]] ·
  [[Open Questions]]
