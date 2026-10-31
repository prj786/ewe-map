---
tags:
  - ewe-map
  - decisions
title: Sync — sign in once, everything follows
up: "[[Decision Index]]"
---

# Sync — sign in once, everything follows

**Decided 2026-10-31** (owner: *"i want exactly same ecosystem like syncing
… imagine i am logging in and getting everything i had before … i see all
connected directories, like in ewe and in ewe-browser"*). Built on branches
`feat/sync-ecosystem` in ewe, ewe-sync and ewe-browser, and **released**
the same day: ewe-sync 0.15.0-beta, ewe browser 0.6.0-beta, ewe
0.37.0-beta, then ewe-os 0.15.0-beta — whose installer gained a *Your ewe
account* step (owner: "sign in or skip"; signed in, the backup's plugins
are pre-checked and any other can be turned on) — see [[ewe-os ISO]].

## What was wrong (the research, on the owner's own machine)

- **Three engines on one folder.** The official Nextcloud desktop app was
  running and syncing `~/Nextcloud`; ewe-files was configured to rclone-mount
  the account at the SAME path (it could not — rclone refuses a non-empty
  mountpoint, so "configured, not mounted" forever); ewe-sync's "Get started"
  card offered a third engine (`nextcloudcmd`, `/` ↔ `~/Nextcloud`) there too.
  ewe-sync itself had no folders.
- **The folder list never travelled.** `ewe-conf`'s merge kept the whole
  `[sync]` table on each machine (`LOCAL_ONLY = ("sync",)`), so
  `sync.folders` reached a second machine only through a full Restore.
- **"On change" was one-way.** Only the local folder was watched; nothing
  asked the account, so another machine's edits arrived only on an interval
  or at the next login.
- **The browser was off by default** with its own switch (`settings.sync`),
  so signing in to ewe never brought bookmarks, history or tabs back — and
  it had its own Sync now (against rule 6).
- **Nothing showed it all.** Settings, browser, Safe and folders each
  reported somewhere else; no file manager knew which folders were synced.

## The decision

1. **One page answers "is everything mine safe?"** — ewe-sync's **Overview**:
   the account, then Settings & apps · Browser · Passwords (Safe) · Folders,
   each with its state and, where it is this computer's choice, a switch. One
   **Sync now** for everything. Still rule 6: the browser and Safe sync
   themselves; ewe-sync shows them and nudges them (`sync-now` file,
   `ewe-safe sync`).
2. **A new computer is one click.** Signed in, never synced, a backup in the
   account → **Bring everything back**, with what comes back shown first
   (machine, date, apps, folders with download sizes, browser, Safe) —
   `ewe-conf pull --out` reads the backup without touching this machine. The
   first computer is offered its user folders (sizes against the free space).
3. **The folders follow you.** `sync.folders` is shared in the merge;
   `sync.enabled/provider/server/user/folder/browser` stay per machine. A
   running ewe-sync watches `ewe.conf` and starts folders another machine
   added. Pause and a different local path are per computer.
4. **Remote changes arrive by themselves.** Each "automatic" folder asks the
   account for the folder's ETag every 45 s (Nextcloud moves it when anything
   inside changes — what the desktop client polls) and runs when it moved;
   every folder catches up shortly after start.
5. **One engine per folder.** A pair may not be the home folder, sit inside
   another pair, sit inside the account's mount, or sit on a folder the
   Nextcloud app syncs. The app's folders are **shown as connected** and can
   be **taken over** (the app quits, its autostart entry is moved aside —
   kept — and the same folders sync through ewe-sync). ewe-files never mounts
   over a folder that holds files.
6. **Every app can see the connected folders** through one published file,
   `~/.local/state/ewe/sync-folders.json` ([[Contracts and Public API]]):
   ewe browser's file manager shows a **Synced** group, state glyphs, an
   "In your account" chip and *Keep in your account…* (`ewe-sync
   --add-folder`); each connected non-standard folder gets a **GTK
   bookmark**, so Nemo and every Open/Save dialog list it.
7. **The browser follows the account.** Under ewe it syncs exactly when the
   ewe account is signed in and `sync.browser` is not false — no toggle, no
   Sync now of its own; outside ewe the old toggle stays.

## Verified

`ewe-sync/tests/e2e-nextcloud.sh` — a throwaway real Nextcloud (podman,
127.0.0.1), two sandboxed computers running the built ewe-sync and the real
`nextcloudcmd` 35.0.0: a file written on A went up; B signed in, got the
folder list through `ewe-conf sync` and the file came down; a file added in
the account and an edit on B reached A; the snapshot, `--status` and the
bookmark agreed. ALL PASS 2026-10-31. `ewe-conf-merge-test.sh` step 8b holds
the shared/local split.

> **Build guard:** never put a second engine on a synced folder — check
> `sync-folders.json` (every engine is in it) before mounting or pairing.
> Never make `[sync]` wholly local again (the folders stop travelling), and
> never give an app other than ewe-sync a sync switch (rule 6). *Breaks if
> violated:* two engines corrupt one folder; a second machine never gets
> your folders.

## Related

- [[Decision Index]] · [[Account and Sync]] · [[ewe-sync]] ·
  [[Sync and Backup Flow]] · [[ewe-browser]] · [[RFC-006 — ewe-sync App]] ·
  [[Sync Conflicts Are About Content]]
