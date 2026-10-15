---
tags:
  - ewe-map
  - roadmap
title: Roadmap — ewe-safe
up: "[[Home]]"
---

# Roadmap — ewe-safe

**Current (2026-10-15): Safe 0.2.0-beta released** — "a real safe": the
owner asked for what 1Password does today. Contract: `ewe-safe/docs/TRIO.md`;
decision: [[RFC-008 — ewe Safe]] → Amendment 2026-10-15 (passkeys and the
SSH agent leave the parked list). In it: ewe-safe **#10** (`read`, `run`,
`inject`, `git-credential`, `safe://`), **#11** (passkeys, KeePassXC's
format), **#12** (the window's edit-save fix — 0.1.0-beta could not save an
edited login), **#13** (SSH keys + agent), all landed through **#14**
(`integrate/trio`), bump **#15** (`v0.2.0-beta` on `a3fcc5e` (after #16, a test-race fix, and #17, openssh for the package check; the tag moved twice, before any package was made), package
`ewe-safe-0.2.0beta-1`). Released with it: ewe **0.28.0-beta** (#58/#59,
Passwords **1.3.0**: Use Safe) and ewe browser **0.2.0-beta** (Safe built
in, ewe-browser#4). Published to `[ewe]` on 2026-10-15. The companion's side
(ewe-companion **#1**) is merged, not released. After `sudo pacman -Syu`:
`systemctl --user daemon-reload && systemctl --user restart ewe-safe.socket`.

Before it, the same day: **Safe 0.1.0-beta released** with ewe 0.27.0-beta —
`sudo pacman -S ewe-safe`, `ewe-plugin install ewe.safe`. Before that:
**RFC-008 accepted**; **phase 0 done — GO, with five
conditions** (`ewe-safe/docs/SPIKE-0.md`); **phase 1 done** (2026-10-14: core +
own merge, store + sync engine, `ewe-safed` + the `ewe-safe` CLI to
`docs/PROTOCOL.md` v1, the `[safe]` ewe-conf domain (ewe#55), provider `ewe`
in the Passwords plugin (ewe-plugin-passwords#2, 1.2.0), the unlock prompt's
window rule (ewe#56); 112 tests). On GitHub (`prj786/ewe-safe`, PRs #1–#2);
not released. **Phase 2 started:** the window's plumbing is merged
(ewe-safe#3: `safe_client`, `app/` Tauri v2 + Svelte 5 with commands,
events and a `?mock=1` backend; CI builds it in its own job); the look is a
mockup, `design-mockups/safe.html` (dark + light, every screen), **waiting
for the owner's sign-off** before the screens are built. The polkit
unlock-with-login spike needs sudo (the policy file) and the owner at the
prompt. Component:
[[ewe-safe]].
Phases, tasks and gates in full: `ewe-safe/PLAN.md` §15. Decisions:
[[RFC-008 — ewe Safe]].

| # | what | gate |
|---|---|---|
| 0 ✓ | RFC + vault; repo skeleton (Rust workspace: core, store, daemon, cli); **fidelity spike** (a corpus of KDBX files from KeePassXC, KeePassDX, Strongbox, KeeWeb round-tripped through `keepass-rs`, compared by an independent reader); merge spike; Argon2 timing | passed 2026-10-14: 30/30 real files (KDBX 3.1/4.0/4.1 from KeePassXC and KeePass 2.x) round-trip with nothing lost; content keepass-rs doesn't model is caught by a write guard (read-only); keepass-rs merge 10/14, loses data → Safe owns merge; Argon2id 64 MiB/2 lanes ≈ 22 ms per iteration. Not verified: files from KeePassDX/Strongbox/KeePassium; KeePassXC opening our output |
| 1 ✓ | the engine (conditions C1–C5 from the spike: write guard, own merge, tracked deletes, …): core, places *This computer* + *Nextcloud* (`If-Match`, 412 → merge, offline pending, rollback warning), `ewe-safed`, the CLI, the `safe` ewe-conf domain, provider `ewe` in the Passwords plugin | passed 2026-10-14 (nested Hyprland + XDG sandboxes): Super+P → Enter typed username, Tab, password into kitty; locked picker → Enter → unlock prompt → picker back; Ctrl+L locks; two machines on one mock Nextcloud edit offline, both edits survive; no secret in logs/argv; pykeepass opens the file. Not yet: a real Nextcloud, a real logind session, the units under a real user manager, KeePassXC |
| 2 ◐ | (released in 0.1.0-beta: the window, Import, the package, the desktop plugin; the ewe browser integration in ewe browser 0.2.0-beta; left: unlock with login/fingerprint (polkit, needs the owner), Komble listing, site docs) the app (Tauri), Emergency Kit, unlock with login/fingerprint (polkit spike first), TOTP, package + ewe-repo + Komble, site docs | a non-terminal user creates, fills, locks, unlocks; a second machine opens the safe |
| 2++ ◐ | Safe, the browser and the companion (owner 2026-10-15, `docs/TRIO.md`): passkeys (S1, #11), SSH keys + an ssh-agent (S2, #13, ewe#59), a CLI like `op` and `Super+P` without 1Password (S3, #10, ewe-plugin-passwords#3), Safe in ewe browser (B1, ewe-browser#4), the companion's actions (C1, ewe-companion#1) | **released 2026-10-15**: Safe 0.2.0-beta, ewe 0.28.0-beta, ewe browser 0.2.0-beta; the companion's part merged, not released. Gate: the owner's real test — a passkey on a real site (GitHub), `git push` through Safe's agent, `Super+P` with no 1Password |
| 3 | any WebDAV (guard probe), synced folder (conflict copies merged), SSH, *Move safe…*, the ewe-sync row | a Syncthing conflict ends merged with no files left |
| 4 | import (1Password, Bitwarden, browsers, KeePass, pass, Proton Pass) and export | a real 1Password export imports with matching counts |
| 5 | Dropbox and Google Drive through `ewe-auth` | the race test passes against both |
| 6 | ewe browser fill-on-click (released in 2++, ewe browser 0.2.0-beta), health, the companion's P8 (partly in P2.9: copy, lock, unlock, counts) | never fills without a click; the canary appears nowhere |

## Gotchas

- **Never enable quick-xml's `overlapped-lists`** — saved passwords become
  garbage; CI guards it ([[Troubleshooting Knowledge]] → Safe).
- **keepass-rs `_merge` loses data** (2 of 14 cases): Safe owns its merge.
- **Delete through the tracked path** or the merge resurrects the entry.
- **keepass-rs is vendored with one fix** (`ewe-safe/vendor/keepass/`,
  `PATCHED.md`): after a file is opened it forgets which entries use an
  attachment, so a removal could delete one another item still used. Drop
  the folder and the `[patch.crates-io]` line once upstream fixes it.
- **`app/src-tauri` is its own Cargo project**, outside the root workspace:
  Tauri needs webkit2gtk even to type-check, and the root CI must not.
- **Every save writes KDBX 4.1**; whether the phone apps read 4.1 is not yet
  checked on a real phone.
- **polkit and user services:** a process in `user@.service` belongs to no
  logind session; the unlock check must use the *calling* process as the
  subject — spike it with `Auth.qml` before building the UI on it.
- **Never test against the live account** — XDG sandboxes, the mock WebDAV
  server and `EWE_SAFE_FAKE_KEYRING`, as the `ewe-cloud` tests do.
- **Passkeys and SSH keys use other apps' formats** (KeePassXC's
  `KPEX_PASSKEY_*`, KeeAgent's `KeeAgent.settings`): check names and the
  protected flags against KeePassXC's source and keep a fixture it made.
  The **credential id is protected** (KeePassXC and KeePassDX write it so;
  TRIO.md's first table said no — the apps win).
- **Safe's merge is per entry, newest wins.** Two machines editing one
  login before they sync: the older edit goes to the item's history.
  Passkey fields are merged on their own since #11 (FORMAT.md rule 3a).
- **KDBX times have one-second steps.** Tests that need "newer" must wait
  a second.
- **After upgrading Safe:** `systemctl --user daemon-reload && systemctl
  --user restart ewe-safe.socket` (the socket gained the agent's
  `ListenStream`; this locks the safe).
- **The main `ewe-safe.sock` server has one thread per connection and no
  cap** (the agent's socket has 32); see [[Open Questions]].
- More in [[Troubleshooting Knowledge]] → Safe.

## Related

- [[RFC-008 — ewe Safe]] · [[ewe-safe]] · [[Roadmap and Status]] · [[Passwords Plugin]]
