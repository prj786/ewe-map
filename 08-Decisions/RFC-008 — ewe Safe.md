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
done the same day; **0.1.0-beta released 2026-10-15** with ewe
0.27.0-beta (the window, import from 1Password, [[Safe Plugin]]) — see
[[Roadmap — ewe-safe]] and [[ewe-safe]]. Full text:
`ewe/docs/RFC-008-safe.md`; build plan: `ewe-safe/PLAN.md`; repo
`prj786/ewe-safe`.*

*Amended 2026-10-15 (owner): passkeys and the SSH agent leave the parked
list, and S8 lets the companion act — see "Amendment 2026-10-15" below.
Released the same day as Safe 0.2.0-beta, ewe 0.28.0-beta and ewe browser
0.2.0-beta; the companion's part is merged, not released.*

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
| S8 | the companion gets counts and events, never a title or a value (**amended 2026-10-15**: S8′ below) | RFC-007 rule C3; its P8 is this contract |

## Amendment 2026-10-15 — passkeys, the SSH agent, the companion's actions

The owner asked for "a real safe", like 1Password today: suggestions in
the browser's login fields, passkeys, SSH keys for `ssh` and `git`, a CLI
that needs no 1Password, and a companion that can use Safe and the
browser. The contract between the repos is `ewe-safe/docs/TRIO.md`.
**Status: released 2026-10-15** — ewe-safe #10 (CLI), #11 (passkeys), #12
(edit fix), #13 (SSH) through #14 → **Safe 0.2.0-beta**; ewe #58, #59 and
ewe-plugin-passwords #3 → **ewe 0.28.0-beta**; ewe-browser #3, #4, #5 →
**ewe browser 0.2.0-beta**; published to `[ewe]` the same day.
ewe-companion #1 and ewe-plugin-companion #1 are merged, not released. See
[[Roadmap — ewe-safe]].

| # | decision | why |
|---|---|---|
| S9 | **Passkeys** leave the parked list. Stored the way KeePassXC 2.7.7+ stores them: custom fields `KPEX_PASSKEY_*` (credential id, private key PEM and user handle **protected**) and the tag `Passkey`; one passkey per entry; ES256 and EdDSA; sign count 0; BE and BS set; attestation `none`; Safe's own AAGUID `452b824e-42d3-4324-bc6c-581888ca2851` | KeePassXC, KeePassDX and Strongbox use the same passkeys, on the phone too. No Linux passkey API is needed: ewe browser asks Safe itself |
| S10 | **The browser decides the origin.** Safe checks only the shape (`rp_id` is a host name, `client_data_hash` is 32 bytes). ewe browser's main process takes the origin from the frame, checks the RP ID and builds `clientDataJSON` | a page can lie about its origin; the frame can't |
| S11 | **The SSH agent** leaves the parked list. Keys are stored as **KeeAgent** entries (the OpenSSH key as an attachment, `KeeAgent.settings`, the passphrase in the password, `public_key` and `fingerprint` as plain fields). `ewe-safed` speaks the ssh-agent protocol on `$XDG_RUNTIME_DIR/ewe-safe-ssh.sock`. Off until `ewe-safe ssh enable`; `ssh-add` into it is refused | the owner pushes with 1Password's agent today; KeePassXC's agent reads the same entries |
| S12 | **`ssh_confirm` is noise reduction, not a boundary.** `first-use` (default: once per program per unlock), `every-time`, `never`. The master password is the boundary | any program running as you can reach the agent while Safe is unlocked |
| S13 | **A CLI like `op`:** `read`, `run`, `inject`, `git-credential` and `safe://` references. Two items with one name are `ambiguous`, never a guess. These four follow the tools they copy (rule-5 exceptions) | scripts that used `op` keep working; `Super+P` must not need 1Password |
| S8′ | **S8 amended:** the companion may now *act* on Safe — copy, lock, unlock, count, open a login's site. **Values never cross** (Safe runs `wl-copy` itself; the companion never calls `show` or `reveal`). **Names stay local** (titles and usernames on the island only, never to a model, a log or `companion.db`). `ewe-companion/tests/canary.sh` proves it in CI | the owner asked for it; RFC-007's C3 still holds |

Unchanged: **fill is a click** (nothing fills on page load; a passkey is
used only after a click in the browser's own UI), and public API is
additive (rule 4).

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
> live keyring — nor the live safe, `~/.ssh` or browser profile. Never trust
> an origin a page sent (S10), and never call `ssh_confirm` a security
> boundary (S12).
