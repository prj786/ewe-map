---
tags:
  - ewe-map
  - decisions
title: Password Sign-in — a reversal
up: "[[Decision Index]]"
---

# Password sign-in — ewe does see your password, once

**Decided 2026-11-19** (owner: *"login with no nextcloud gui"*; decision 58).
Released in ewe 0.44.0-beta (`ewe-cloud login --password-stdin`), ewe Sync
0.17.0-beta (the fields), and the ewe-os 0.16.0-beta installer.

**This reverses a stance the vault and the repos stated plainly.** RFC-005
(accepted 2026-09-02) signed in "through Nextcloud's own browser login
flow"; RFC-006 called Login Flow v2 "the only sanctioned way for a desktop
app to obtain credentials"; `docs/NEXTCLOUD.md` said **"ewe never sees your
real password."** It does now — once, and never keeps it.

## What changed

- **`ewe-cloud login <server-url> --user <login> --password-stdin`** (also
  `--user=X`): the password is read from **stdin, never argv**, sent **once
  over https** with Basic auth to Nextcloud's own password → app-password
  exchange, `GET <server>/ocs/v2.php/core/getapppassword?format=json`
  (`OCS-APIRequest: true`, `User-Agent: ewe (<hostname>)`). **Redirects are
  never followed** (`_NoRedirect`) — the password goes only to the address
  typed. 200 → `ocs.data.apppassword`; 403 → the typed value is verified as
  an app password and used as is. Both paths end in the same
  `finish_login()`: the app password into the keyring (`ewe-cloud`), the
  account into `~/.config/ewe/cloud.json`, the reply
  `{"ok": true, "server", "user", "login_name", "display_name", "email",
  "quota", "keyring"}`. Error codes: `no-user`, `no-password`,
  `unauthorized` (+ `browser: true`), `forbidden` (+ browser),
  `too-many-tries` (429), `redirected` (+ browser), `not-nextcloud` (404),
  `bad-reply`, `http-<n>`, `network`.
- **Login Flow v2 stays** as `ewe-cloud login <server>` (no `--user`) and as
  *Sign in with the browser instead* — the path for **two-step verification
  and single sign-on**, where the exchange answers `unauthorized` with
  `browser: true` and the UI highlights that link.
- **ewe Sync** (Account pane): *Server address · Username or email ·
  Password*, *Sign in*, *Sign in with the browser instead*; the card says
  "Your password goes to your server once, which gives this computer its own
  app password; the password itself is never kept." `cloud_login` runs the
  tool with the password + `\n` on stdin and **zeroes the buffer**; a line
  break is `bad-password`; names ≤ 256 characters, no control characters;
  the last user in `localStorage` `ewe-sync.lastUser`.
- **The installer** (ewe-os, `Cloud.svelte` / `account.rs`): the same three
  fields and the same tool, in the *Your ewe account* step; the footer tells
  the user the app password can be revoked in Nextcloud → Settings →
  Security.
- Tests: `tests/ewe-cloud-test.sh` §10, `tests/mock-nextcloud.py`
  (`getapppassword`, a `wanderer` user redirected to `/steal` — the redirect
  must not be followed, `LOGIN_PW = "login-Pass word:1"`).

## Why reverse

The browser flow asked the user to leave the app, sign in on a web page,
grant, and come back — on a fresh install that meant a browser inside the
installer. The owner wanted the sign-in where the fields are. Nextcloud
provides exactly this exchange for desktop clients (its own client uses
it); what ewe gives up is the claim, not the protection: the server still
hands out a **per-computer app password** the user can revoke, the real
password crosses the wire once over TLS to the typed host only, and nothing
stores it.

What stays true (rules 2 and 6): the app password lives in the keyring,
never in `ewe.conf`; ewe Sync is still the only place with a sign-in and a
sync button; Komble, the shell and ewe Browser never see either secret.

## Not taken

Keeping the browser flow as the only path (the owner's ask). Storing the
password for a re-login (the app password is the credential). Passing the
password as an argument (visible in `ps`). Following redirects (a redirect
to another host would leak the password).

> **Build guard:** the password travels **stdin → one https request to the
> typed server, no redirects → gone**. No argv, no log line, no file, no
> `ewe.conf`. *Breaks if violated:* a real account password in a process
> list, a journal or the synced file. Update `docs/NEXTCLOUD.md`,
> `docs/MANUAL.md`, RFC-005/006 and `Settings.qml`'s "ewe never sees your
> password" string together (the QML string still says it in 0.44 — a
> follow-up).

## Related

- [[Decision Index]] · [[RFC-005 — Nextcloud Account]] ·
  [[RFC-006 — ewe-sync App]] · [[ewe-sync]] · [[ewe-os ISO]] ·
  [[Contracts and Public API]] · [[Security Posture]]
