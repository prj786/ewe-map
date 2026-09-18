---
tags:
  - ewe-map
  - decisions
title: RFC-006 — ewe-sync App
up: "[[Home]]"
---

# RFC-006 — ewe-sync, the account app

*Status: proposed (owner idea, 2026-09-02) → built as a fourth first-party
Tauri app in its own repo `prj786/ewe-sync`, shipped preinstalled by the
`ewe` package from ISO 0.9-alpha on.*

## The decision

One app owns everything "cloud": the Nextcloud account, the sync of
`ewe.conf`, the list of your machines, and which folders sync where. It has
a tray icon like Komble's, our UI, our theme.

**Division of labour (the sentence that prevents scope creep):**
Komble installs apps and writes the manifest; ewe-settings edits `ewe.conf`;
**ewe-sync moves the one file and your folders between machines**. Nothing
else has a sync button.

## Why it's its own app

The account surface is large and rarely open — exactly the profile that
earned ewe-settings its own process (see [[Process Split — Shell vs Apps]]).
Name: **ewe-sync**, sitting next to `ewe-auth`, `ewe-drive`, `ewe-cloud`,
`ewe-conf` (drafted as "Flock" for an afternoon). Binary `ewe-sync`,
desktop id `io.github.prj786.ewe-sync`.

## What the research decided (don't re-research)

- **Login:** Nextcloud's Login Flow v2 is the only sanctioned way; yields an
  app password appearing as a device under the user's Security page.
  `ewe-cloud` implements it; ewe-sync drives that, never reimplements.
- **Registration:** impossible without admin credentials; ewe-sync links to
  provider signup pages instead. Running an owner-hosted Nextcloud to make
  registration work in-app was **rejected** (owner back in the loop as an
  operator).
- **Folder sync engine:** writing a two-way sync is a multi-year project —
  the Nextcloud desktop client *is* that project. ewe-sync = **our UI +
  scheduler** (inotify + interval + on-login) around `nextcloudcmd` runs,
  one per folder pair. The client's own GUI/tray are never started; we ship
  `nextcloud-client` for the binary only. Fallback if too slow for big
  trees: `rclone bisync` — the UI does not change.
- **Settings/apps sync:** unchanged from RFC-005 — `ewe-conf push/pull`.

## Anti-regression notes

- Nothing needs root; there is no privileged helper.
- Commands run as argv, **never through a shell**.
- One-way folder copies use rclone `copy` (adds/updates, never deletes).
- Conflicts: server's version kept, yours becomes
  `name (conflicted copy <date>).ext`; *Keep mine*/*Keep theirs* resolves.
- No selective sync inside a pair (use excludes), no bandwidth limits —
  documented limits, not bugs.

## Related

- [[ewe-sync]] · [[Account and Sync]] · [[RFC-005 — Nextcloud Account]] ·
  [[Decision Index]]
