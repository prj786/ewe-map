---
tags:
  - ewe-map
  - decisions
title: RFC-005 — Nextcloud Account
up: "[[Home]]"
---

# RFC-005 — the ewe account is a Nextcloud account

*Status: accepted (owner decision, 2026-09-02) · supersedes the Google half
of RFC-002 · implemented on the `nextcloud` branch of ewe, komble-arch,
ewe-settings, ewe-os and the website; merges as one wave.*

## The decision

The user signs in to **their** Nextcloud — self-hosted or a hosted provider
(Murena, Disroot, Infomaniak, …) — through Nextcloud's own browser login
flow (Login Flow v2 → app password). Everything ewe syncs lives in a folder
of that account. **Google is demoted to an optional extra** for two things
only — mail notifications and the Drive folder — and only when the user
brings their own OAuth client file. **ewe ships no Google client at all.**

## Why

- **No gatekeeper.** WebDAV, CalDAV and IMAP need nobody's verification.
  The unverified-app warning, the restricted Gmail scope, the CASA audit,
  the dedicated Google project, the client secret in CI — all gone.
- **The audience.** People who choose an Arch-based desktop are the people
  who do not want Google in their login screen.
- **The owner is out of the loop.** Nothing about the owner's accounts or
  cloud projects lives in the package or the repos.
- **Better sync primitives.** WebDAV gives ETags and `If-Match`: a push
  that races another machine is rejected by the server itself — no clock or
  hostname guesswork (RFC-002's guard becomes the server's job).

## What the account carries

| what | where | tool |
|---|---|---|
| the one file + backup stamp | `<files>/ewe/ewe.conf` + `ewe.conf.meta.json` | `ewe-conf push/pull` |
| your files as a folder | mounted at `~/Nextcloud` | `ewe-files` (rclone remote from keyring) |
| your calendar | CalDAV | the shell's calendar widget |

Mail is separate: any IMAP account feeds the Control Centre badge (see
[[RFC-006 — ewe-sync App]]).

## Anti-regression notes

- **Do not reintroduce a Google-first sync.** If someone proposes "Google
  Drive sync again", the answer is RFC-005: the account is Nextcloud;
  Google remains BYO-client optional via [[RFC-002 — Auth Broker]].
- **Do not bake an owner-run Nextcloud** into the product (cost, abuse,
  backups, liability — the exact thing RFC-005 removes).
- The app password lives **only in the keyring** (service `ewe-cloud`);
  non-secret facts in `~/.config/ewe/cloud.json`; `ewe.conf` carries
  `[sync] provider/server/user/folder/enabled` — identity, never a secret.
- The sync record (`~/.local/state/ewe/sync.json`: the ETag last seen) is
  the whole conflict rule.

## Related

- [[Account and Sync]] · [[RFC-006 — ewe-sync App]] · [[RFC-002 — Auth Broker]] ·
  [[Decision Index]]
