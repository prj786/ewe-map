---
tags:
  - ewe-map
  - rules
title: Security Posture
up: "[[Home]]"
---

# Security Posture

From `ewe/SECURITY.md` + the scattered security-relevant rules. ewe is
**alpha/beta software shipping security-relevant components** — a polkit
authentication agent (`Auth.qml`), a Wayland session lock (`Lock.qml`), and
gnome-keyring PAM integration. Treat it accordingly until it stabilises.

## What's in scope (what a report should get attention for)

1. **Lock screen bypass** — anything that escapes `Lock.qml`.
2. **Polkit agent spoofing / password capture** — anything that fakes or
   eavesdrops on `Auth.qml`.
3. **Keyring unlocked unexpectedly** — the credential store must stay
   locked behind login (PAM creates + unlocks it with the login password).
4. **Privilege escalation through the install scripts** — the installer
   uses `sudo` only at explicit `sudo_run` points and never passes
   passwords on the command line (the App Store uses a **0700
   `SUDO_ASKPASS` helper** under `$XDG_RUNTIME_DIR`).

## Reporting

**Never a public issue for security problems.** GitHub private reporting:
Security tab → Report a vulnerability (Private Vulnerability Reporting), or
a draft security advisory. Include: affected component, repro, impact,
environment (GPU/driver, distro, ewe version).

## The credential geography (the core invariant)

| secret | lives | never |
|---|---|---|
| Nextcloud app password | keyring, service `ewe-cloud` | never in `ewe.conf`, never on a command line |
| Google refresh token | keyring, `ewe-auth` only | never in caches (only non-secret facts cached) |
| VPN credentials | root-only NetworkManager profiles | one file records the *definition*, never secrets |
| pairing keys (KDE Connect) | kdeconnectd | shell persists only seen-ids + device choice |
| password-manager credentials | the providers' own stores (op/rbw/pass) | ewe-pass only *reads* |
| Safe's passwords ([[ewe-safe]]) | one KDBX file, encrypted before it leaves the machine (Argon2id + AES-256), in its place; unlocked only inside `ewe-safed`'s memory, zeroized on lock | the master password is never stored and never typed into the shell; secrets never on argv, never in a log |
| Safe's passkeys (Safe 0.2.0-beta) | inside the KDBX file, KeePassXC's `KPEX_PASSKEY_*` fields (credential id, private key, user handle protected) | never in a reply: the summary carries only `rp_id` and the site's user name; nothing a passkey verb gets or answers is logged |
| SSH keys in Safe (Safe 0.2.0-beta) | inside the KDBX file as KeeAgent attachments; only public keys + titles in `ssh-public.json` (`0600`, local) | the agent signs inside `ewe-safed`; the key leaves only on an explicit `reveal`/`read` of `private_key`; `~/.ssh/config` is never edited |

Rules 2 & 7 of [[Rules of the House]] are the same invariant from two
angles: secrets in the keyring, identity in the file.

## The privilege surface (deliberately minimal)

- **Shell / ewe-settings / ewe-sync** — zero privileges. Every file they
  touch is user-owned.
- **Komble** — one polkit helper authorising one path, four verbs,
  argv-only, validated twice. See [[Komble — Arch Forced Decisions]].
- **Installer** — `run()`/`sudo_run()` choke point; `--dry-run` honest;
  never passwords on argv.
- **Plugins** — unsandboxed by necessity; the tool says so; no install
  hooks, no privileges at install. See [[Plugins Unsandboxed]].
- **Safe (RFC-008)** — zero privileges. `ewe-safed`'s socket is `0600` in
  `$XDG_RUNTIME_DIR`, both ends check `SO_PEERCRED`; the daemon is not
  dumpable (no core dumps, no same-uid ptrace) and locks on screen lock,
  sleep and idle. Honest limit: malware running as you while the safe is
  unlocked can ask the socket, like every desktop password manager.
- **Safe's SSH agent (Safe 0.2.0-beta)** — its own socket
  `ewe-safe-ssh.sock` (`0600`, `SO_PEERCRED`), off until `ewe-safe ssh
  enable`; refuses adding/removing keys, SHA-1 `ssh-rsa`, DSA and `sk-` keys;
  32 connections at most. **`ssh_confirm` is noise reduction, not a
  boundary:** it names the program by its full path and marks one outside
  `/usr` and `/opt`, but any program running as you can use the agent while
  Safe is unlocked. The master password is the boundary.
- **Passkeys and the browser (Safe 0.2.0-beta, ewe browser 0.2.0-beta)**
  — **the browser decides the origin**: its main process takes it from the
  frame and checks the RP ID; Safe checks only shapes and never trusts a
  page. Nothing fills on page load; a passkey is used only after a click in
  the browser's own sheet or list, which ignore clicks until they have stood
  still 500 ms and the mouse moved. Frames from another site are refused
  ([[Safe in the Browser — guards, not a page click]]).
- **The companion (RFC-007)** — zero privileges. `ewe-companiond`'s socket
  is `0600` in `$XDG_RUNTIME_DIR` and both ends check `SO_PEERCRED` (same
  uid or nothing). The Claude Code hook relay **never prints an allow the
  daemon did not send, and the daemon sends one only for a click**; every
  failure is "no opinion" (Claude asks in its terminal). No IPC verb answers
  a card. "Always" only echoes Claude's own `permission_suggestions`.
- **The companion and Safe (P2.9, ewe-companion#1, merged, not released)** —
  values never cross: the companion asks Safe to *copy* (Safe runs `wl-copy`
  and clears it) and never calls `show` or `reveal`. Names stay local:
  titles and usernames show on the island only, never in a model's context
  or `companion.db` (`tests/canary.sh` in CI). A proposed command that would
  print a password manager's values is refused. Page text from ewe browser
  goes to a model marked untrusted; an action in that reply is a button.
- **The companion's shell commands (2026-10-14)** run only on a click. A
  model's `run_shell`, a knowledge topic's `run:` line or the user's own
  `$ command` becomes a *proposal* shown exactly as it will run, with Run and
  In terminal; `commands::run` refuses `run_shell` outright, and the Run
  click is the island's `confirm.run` (or `debug.confirm` on a debug daemon).
  `companion_core::shell::assess` refuses machine killers (`rm -rf` on home or
  the system, `mkfs`, `dd` onto a disk, fork bombs) and house-rule breaks (a
  partial `pacman -Sy`, writing ewe.conf or `generated/` by hand), warns on
  risky ones, and sends sudo and interactive programs to a terminal so the
  user types their own password. A guard rail, not a sandbox: same uid, the
  user's own shell.
- **kitty remote control** (`dotfiles/kitty`, for the companion's jump to
  a tab) is `socket-only` on a **file** socket in `$XDG_RUNTIME_DIR`, never
  an abstract `@` socket (which any local user could reach). Same uid, same
  trust.

## Installer safety model (from MANUAL.md)

- **Never clobbers configs** — existing `~/.config/hypr` (etc.) is moved to
  `….bak.<timestamp>` before symlinking; `uninstall.sh` restores.
- **Symlink farm, not copy** — re-running re-links (no-op); uninstall
  unlinks + restores newest backup; packages stay installed (`--purge` also
  disables the display manager).
- **The most important step: `hyprland-session.target`** user unit
  (`BindsTo=graphical-session.target`) — it activates `xdg-desktop-portal`
  on a non-uwsm session. **Without it, screen sharing, file pickers and
  app/URL handoff silently fail.**
- **User-state seeding** — committed `*.default` files seed gitignored
  runtime files only when missing: a fresh install has working defaults,
  your edits are never committed or clobbered.

## Related

- [[Rules of the House]] · [[Contracts and Public API]] · [[Auth Broker]] ·
  [[Komble — Arch Forced Decisions]]
