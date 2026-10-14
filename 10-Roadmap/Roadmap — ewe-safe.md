---
tags:
  - ewe-map
  - roadmap
title: Roadmap — ewe-safe
up: "[[Home]]"
---

# Roadmap — ewe-safe

Current (2026-10-14): **RFC-008 accepted**; **phase 0 done — GO, with five
conditions** (`ewe-safe/docs/SPIKE-0.md`); **phase 1 working** (`safe_core`:
item model, verified atomic write, write guard, generator, TOTP, search and
Safe's own merge — 62 tests, the 14 spike merge cases among them). On GitHub
since 2026-10-14 (`prj786/ewe-safe`); not released.
Phases, tasks and gates in full: `ewe-safe/PLAN.md` §15. Decisions:
[[RFC-008 — ewe Safe]].

| # | what | gate |
|---|---|---|
| 0 ✓ | RFC + vault; repo skeleton (Rust workspace: core, store, daemon, cli); **fidelity spike** (a corpus of KDBX files from KeePassXC, KeePassDX, Strongbox, KeeWeb round-tripped through `keepass-rs`, compared by an independent reader); merge spike; Argon2 timing | passed 2026-10-14: 30/30 real files (KDBX 3.1/4.0/4.1 from KeePassXC and KeePass 2.x) round-trip with nothing lost; content keepass-rs doesn't model is caught by a write guard (read-only); keepass-rs merge 10/14, loses data → Safe owns merge; Argon2id 64 MiB/2 lanes ≈ 22 ms per iteration. Not verified: files from KeePassDX/Strongbox/KeePassium; KeePassXC opening our output |
| 1 ◐ | the engine (conditions C1–C5 from the spike: write guard, own merge, tracked deletes, …): core, places *This computer* + *Nextcloud* (`If-Match`, 412 → merge, offline pending, rollback warning), `ewe-safed`, the CLI, the `safe` ewe-conf domain, provider `ewe` in the Passwords plugin | two sandboxed machines edit offline and both edits survive; `Super+P` fills from the safe; the file opens in KeePassXC; no secret in any log or argv |
| 2 | the app (Tauri), Emergency Kit, unlock with login/fingerprint (polkit spike first), TOTP, package + ewe-repo + Komble, site docs | a non-terminal user creates, fills, locks, unlocks; a second machine opens the safe |
| 3 | any WebDAV (guard probe), synced folder (conflict copies merged), SSH, *Move safe…*, the ewe-sync row | a Syncthing conflict ends merged with no files left |
| 4 | import (1Password, Bitwarden, browsers, KeePass, pass, Proton Pass) and export | a real 1Password export imports with matching counts |
| 5 | Dropbox and Google Drive through `ewe-auth` | the race test passes against both |
| 6 | ewe browser fill-on-click, health, the companion's P8 | never fills without a click; the canary appears nowhere |

## Gotchas

- **Never enable quick-xml's `overlapped-lists`** — saved passwords become
  garbage; CI guards it ([[Troubleshooting Knowledge]] → Safe).
- **keepass-rs `_merge` loses data** (2 of 14 cases): Safe owns its merge.
- **Delete through the tracked path** or the merge resurrects the entry.
- **keepass-rs is vendored with one fix** (`ewe-safe/vendor/keepass/`,
  `PATCHED.md`): after a file is opened it forgets which entries use an
  attachment, so a removal could delete one another item still used. Drop
  the folder and the `[patch.crates-io]` line once upstream fixes it.
- **Every save writes KDBX 4.1**; whether the phone apps read 4.1 is not yet
  checked on a real phone.
- **polkit and user services:** a process in `user@.service` belongs to no
  logind session; the unlock check must use the *calling* process as the
  subject — spike it with `Auth.qml` before building the UI on it.
- **Never test against the live account** — XDG sandboxes, the mock WebDAV
  server and `EWE_SAFE_FAKE_KEYRING`, as the `ewe-cloud` tests do.

## Related

- [[RFC-008 — ewe Safe]] · [[Roadmap and Status]] · [[Passwords Plugin]]
