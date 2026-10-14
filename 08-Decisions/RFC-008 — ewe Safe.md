---
tags:
  - ewe-map
  - decisions
title: RFC-008 — ewe Safe
up: "[[Home]]"
---

# RFC-008 — Safe, ewe's password manager

*Status: **accepted** 2026-10-14 (the owner asked for it the same day: "like
1password, but way simpler", the file in Nextcloud or local, self-hosted
first; every default in the plan's open questions taken). Phase 0 (the
go/no-go spike) done 2026-10-14: **GO, with five conditions**; phase 1
done the same day (the engine, the daemon and the CLI; Super+P fills
from the safe) — see [[Roadmap — ewe-safe]] and [[ewe-safe]]. Full text:
`ewe/docs/RFC-008-safe.md`; build plan: `ewe-safe/PLAN.md`; repo
`prj786/ewe-safe`.*

## The idea

One safe, one master password, two kinds of item (**Login**, **Note**), a
search box. The safe is **one KDBX 4 file** (the KeePass format) kept in a
**place** the user picks: this computer, their own Nextcloud (the default),
any WebDAV server, a synced folder (Syncthing), an SSH server — then Dropbox
and Google Drive. Every save syncs; two machines **merge**, they never make a
conflicted copy. `Super+P` fills it into any app through the existing
[[Passwords Plugin]]. KeePassXC and the phone apps (KeePassDX, Strongbox,
KeePassium) open the same file — no lock-in.

## The decisions (S1–S8)

| # | decision | why |
|---|---|---|
| S1 | the file is KDBX 4, not our own format | no lock-in, phones on day one, reviewed crypto (Argon2id, AES-256), per-entry UUIDs + `DeletedObjects` make merging possible |
| S2 | one file, many places, self-hosted first | the file is encrypted before it leaves; places differ in who you depend on, not in safety |
| S3 | no new login | Nextcloud through `ewe-cloud token`; Google Drive and Dropbox through `ewe-auth` (still the only refresh-token owner); generic WebDAV password in the keyring (service `ewe-safe`) |
| S4 | a socket-activated daemon `ewe-safed` holds the unlocked safe | rule 11; the master password is typed into the Safe window or a terminal, **never the shell** (plugins share its QML engine — [[Plugins Unsandboxed]]) |
| S5 | every save is a sync; a stale save (`412`) downloads, merges, verifies, retries | the merge needs the unlocked key, which only the daemon holds |
| S6 | Rust for everything that holds a secret (`keepass-rs`); the window is Tauri v2 + Svelte 5 | Python cannot wipe a secret from memory |
| S7 | the name is **Safe** / `ewe-safe` | "the vault" already means `project-map/` in every instruction |
| S8 | the companion gets counts and events, never a title or a value | RFC-007 rule C3; its P8 is this contract |

## How it reads the house rules

- **Rule 6 (nothing else has a sync button):** Safe has no sync button. It
  syncs on save, on unlock and every 5 minutes while unlocked; ewe-sync shows
  its state on *This machine*, and ewe-sync's *Sync now* also nudges
  `ewe-safe sync`. One place for sync stays true for the user.
- **Rule 2:** `ewe.conf` `[safe]` names the place (and a WebDAV URL +
  username); passwords live in the keyring; the safe itself is encrypted.
- **Rule 1:** the `safe` domain gets its own `_domain` route that applies
  nothing (like `companion`) and must be in the map `absorb` keeps.
- **Rule 7:** Google Drive needs the user's own client; Dropbox the user's
  own app key — the owner stays out of the loop.
- **Not rclone** for transport: no conditional write, so concurrent saves
  would be lost.

## Related

- [[Roadmap — ewe-safe]] · [[Passwords Plugin]] · [[Auth Broker]] ·
  [[Account and Sync]] · [[RFC-007 — ewe Companion]] · [[Decision Index]]

> **Build guard:** never ship a writer that loses a field another KeePass app
> wrote (phase 0's fidelity corpus gates it); never type the master password
> into the shell; never test against the live account's `ewe/` folder or the
> live keyring.
