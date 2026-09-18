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
