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
0.2.0-beta; the companion's part was released in ewe-companion 0.1.0-beta (2026-10-17).*

*Amended again 2026-10-18 (owner, heading out: "choose any recommended
option"): unlock with the login password, the keyring prompt at every start
fixed, cards and addresses — see "Amendment 2026-10-18" below. Released the
same day as Safe 0.3.0-beta, ewe 0.31.0-beta and ewe browser 0.5.0-beta.*

*Amended again 2026-11-01 (owner): **Safe is the SSH gate** — it replaces
1Password's agent for every `ssh` and `git`, follows the account, and
connects GitHub, Azure and the others in a few clicks — see "Amendment
2026-11-01" below. **Building** (Safe 0.4.0-beta), not released.*

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
ewe-companion #1 and ewe-plugin-companion #1 were released in ewe-companion 0.1.0-beta (2026-10-17). See
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

## Amendment 2026-10-18 — login unlock, the keyring, cards and addresses

The owner's words: "unlock Safe with my sudo password", "get rid of this
keyring thing — it asks for the keyring password every time I turn the
laptop on", "addresses and cards, without ruining users' safety — encrypt
them in Nextcloud", "full Safe control, good integration with the system",
and "when I register somewhere it should ask to save a new login". Contract:
`ewe-safe/docs/SYSTEM.md`. **Status: released 2026-10-18** — ewe-safe #18
→ **Safe 0.3.0-beta**; ewe #64 → **ewe 0.31.0-beta** (ewe.safe 1.0.1
vendored); ewe-browser → **ewe browser 0.5.0-beta**; published to `[ewe]`.

| # | decision | why |
|---|---|---|
| S14 | **Login unlock is a wrapped key, not polkit.** The master password is sealed on this computer under a random key W (`master.wrap`), and W under Argon2id(the login password) (`login.key`; XChaCha20-Poly1305; `~/.local/state/ewe/safe/`, never synced). Typing the login password opens Safe; five wrong tries → the master password once. Off by default; Settings → Security or `ewe-safe login enable` (checked with `unix_chkpwd`) | works from a user service (the polkit subject problem disappears), needs no policy file, and it is real crypto. Honest limit, said in the UI: Safe **on this computer** is then as strong as the login password; the copy in Nextcloud still needs the master password |
| S15 | **Safe opens at login by carrying W in gnome-keyring's `login` keyring**, which `pam_gnome_keyring` already unlocks at the greeter (`[safe] unlock_at_login`, default on). Fetching never prompts: a locked `login` just means "type the password later" | no new code in the login path. **Our own PAM module (`pam_ewe_safe.so`) is parked** for the owner's review: a crash there can lock a user out of their desktop, and an agent writing it was stopped twice by a safety filter (`.wt/parked-pam/`) |
| S16 | **The prompt at every start** was a second keyring (`Default_keyring`, from the 2026-09-03 bug) being the `default`, plus a gnome-keyring crash at boot. **`ewe-safe keyring repair`** copies its items into `login` and points `default` at it; it deletes nothing | fixes the owner's machine with one command; the old keyring stays as a backup |
| S17 | **Safe as the Secret Service** (`crates/secrets`: plain + dh sessions, prompts, a sealed per-machine `keyring.safe`) is built and tested but **parked**: `keyring adopt` refuses until the login module ships | without a greeter handoff, Safe-as-keyring would ask at every start — the very thing the owner wants gone |
| S18 | **Cards and addresses are items in the same KDBX** (`ewe.kind = card / address`; Number, Security code, PIN protected; plain field names every KeePass app shows). Summaries carry brand, last 4 and expiry only | the file is encrypted on this computer before it leaves — Nextcloud only ever sees a locked file. The UI says so in one line |
| S19 | **Filling a card asks for the login (or master) password again**, once per 5 minutes (`confirm`, `[safe] confirm_cards`, default on); never into `http://` pages; the PIN is never filled | like Chrome's card autofill; "don't ruin users' safety" |
| S20 | **ewe browser offers "Save to Safe?" on every sign-up**, even when Safe is locked ("Unlock and save"); a sign-up saves a new login unless the same host *and* username exist | the old prompt was dropped silently when Safe was locked |

## Amendment 2026-11-01 — the SSH gate

The owner's words: "It should be main gate for ssh connections — now
1Password manages it. One ecosystem: the password manager connected to the
browser and ewe's SSH. Nothing outside it; everything the single source of
truth for its job. Attach it to the account. SSH agents should connect to
any system, Azure, GitHub and others, in an easy, intuitive way." Found on
the owner's machine: Safe's agent was on with 6 keys, yet `work` and
`work-proxy` (ewe.conf's managed block, so every computer) still said
`IdentityAgent ~/.1password/agent.sock` and `emoh` used a key file.
Contract: `ewe-safe/docs/GATE.md`. **Status: building 2026-11-01** —
ewe-safe `feat/ssh-gate` (+ `feat/ssh-gate-app`), ewe `docs/safe-ssh-gate`,
ewe-plugin-ssh `feat/safe-gate` (1.1.0); release Safe 0.4.0-beta with the
owner's OK.

| # | decision | why |
|---|---|---|
| S21 | **The gate: two lines Safe owns at the top of `~/.ssh/config`** (`Include ~/.ssh/ewe-safe/config`, whose `Host *` sets `IdentityAgent` = Safe's socket and adds Safe's `known_hosts`), written by `ssh enable`, removed by `ssh disable`, a one-time backup `config.before-safe`. Every computer converges on the shared `[safe] ssh_agent` at daemon start. Reverses TRIO.md's "Safe never edits `~/.ssh/config`" | `ssh` takes the **first** value of each option, so the top `Include` beats every later `IdentityAgent` (1Password's included; checked with `ssh -G`, OpenSSH 10.6), and a missing include file is no error. Turn it on once, every computer of the account follows |
| S22 | **Public key files `~/.ssh/ewe-safe/key-<tag>.pub`** (tag = the first 16 characters of the SHA256 fingerprint, `+`→`-`, `/`→`_`), written from the public-key cache; a host picks its key with `IdentityFile` + `IdentitiesOnly yes` | the name never changes on a rename and is the same on every computer, so host definitions in ewe.conf work everywhere; no "too many authentication failures" |
| S23 | **`ssh takeover`** moves SSH to Safe: imports private key files from `~/.ssh` (never deletes or changes them), removes other agents' `IdentityAgent` from ewe.conf hosts **through `ewe-conf`**, lists keys only another agent (1Password) has | one action ends 1Password's role; Safe can't take a private key out of another agent, so it says which to import |
| S24 | **One service catalogue** (`ssh-services`) and **connect / test / hosts** verbs: GitHub, GitLab, **Azure DevOps (RSA 4096 — Azure Repos takes RSA only)**, Bitbucket, Codeberg, Gitea/Forgejo, Azure VM (Ed25519, GA 2024-10), AWS, Google Cloud, DigitalOcean, Hetzner, any server (`ssh-copy-id` in a terminal). Connect = a key, the public file, a host in ewe.conf, the key on the clipboard and the service's page **in ewe browser** (Safe fills that login there); **Check** runs `ssh -T` and reads the service's answer. New error `conflict` | "easy and intuitive": three steps on one sheet; the browser and Safe already work together for the sign-in |
| S25 | **Sign Git commits with an SSH key** (`ssh sign-commits`): `git config --global` `gpg.format ssh` + `gpg.ssh.program ewe-safe-ssh-sign` (ssh-keygen with Safe's socket) + an `allowed_signers` file; `[safe] git_sign` (shared) makes every computer sign the same way ; Safe changes Git only where it applied it (a marker with the old values in `~/.local/state/ewe/safe/git-signing.json`; off restores them), and another computer's sync never overwrites your own signing setup | as 1Password does; signing reaches Safe even from a terminal opened before the gate |
| S26 | **The services' host keys ship with Safe** (`~/.ssh/ewe-safe/known_hosts`: GitHub, GitLab.com, Bitbucket, Azure DevOps, Codeberg), each fingerprint checked in a test against the one the service publishes | the first connection never asks "Are you sure…?", and a fake server is caught |
| S27 | **The agent says where a key goes** when ssh tells it (`session-bind@openssh.com`): "Allow *git* to use *GitHub key* for *github.com*?" It follows OpenSSH's own ssh-agent rules (no bind after a non-forwarding bind; forwarded is sticky; a userauth request must be for the bound session; first-use approval remembered per program, key **and destination**; a forwarded connection is asked every time). Safe's own **Check** forwards nothing (`-a`, `ClearAllForwardings`) and is the only unasked signer, and only when it is `/usr/bin/ssh` | the question means more when it names the server; the security review (2026-11-01) showed a remembered approval must not cover a different destination |
| S28 | **The window's SSH page**: the gate card (off / "1Password still answers…" → Move SSH to Safe / all good), Connect grid + sheet, keys with "used by" and "last used", hosts (terminal, check), **your ewe computers** (from `ewe-remote`), a line that it follows the account; `ewe-safe-app --ssh`; the SSH plugin links to it (1.1.0) | one place for SSH; the Quick settings page leads there |
| — | **ewe-remote keeps its own key per computer** (RFC-009); Safe only shows the computers and opens a terminal to them | a lost laptop is locked out alone; one source of truth per job (ewe-remote owns pairing) |

Owners per job (GATE.md, "One owner for each job"): keys and signing →
Safe; which agent `ssh` asks → Safe (the gate); host definitions →
ewe-conf (`network.ssh.hosts`); your ewe computers → ewe-remote; the
service's web page → ewe browser.

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
> boundary (S12). Safe touches only its two top lines of `~/.ssh/config`
> and its own `~/.ssh/ewe-safe/` (S21) — never a key file, never the user's
> own host lines, and ewe.conf hosts only through `ewe-conf`. Never ship a
> service host key whose fingerprint wasn't checked against the service's
> published one (S26). Never ship a PAM module the owner hasn't reviewed (S15);
> `unix_chkpwd` reads a NUL-ended password — without the NUL a right
> password is refused.
