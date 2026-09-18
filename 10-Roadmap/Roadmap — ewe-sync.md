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

## Next-release items (from the README's own "next release" note)

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
