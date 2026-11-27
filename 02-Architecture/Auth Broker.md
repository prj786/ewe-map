---
tags:
  - ewe-map
  - architecture
title: Auth Broker
up: "[[Home]]"
---

# Auth Broker — `ewe-auth`

`ewe-auth` is a small broker (Python, stdlib + keyring via libsecret CLI or
D-Bus) that owns exactly three things:

1. **the refresh token** — in gnome-keyring, nowhere else, ever;
2. **access tokens** — `ewe-auth token [scope-set]` prints a short-lived
   access token, refreshing under a lock when expired. Shell, Komble and
   future apps call this instead of doing OAuth;
3. **sign-in/out** — `ewe-auth login` runs the loopback-redirect flow once
   for all apps; `ewe-auth logout` revokes + wipes.

**The promise of RFC-002:** *log in, get your machine back* — one Google
identity for every ewe app, and `ewe.conf` syncing behind it. That Google
half is now **superseded** (RFC-005): the account and the sync of the one
file moved to Nextcloud. `ewe-auth` and the Drive backend remain **only for
the optional, bring-your-own-client Google extras** (Gmail unread +
notifications, your Drive mounted as a folder).

## Token flow

```mermaid
flowchart LR
    subgraph consumers["consumers — call the broker"]
        SH["shell<br/>mail / calendar cards"]
        SY["ewe-sync<br/>Google pane"]
        FUT["future ewe apps"]
    end

    consumers -->|"ewe-auth token [scope-set]"| AUTH["ewe-auth broker"]

    AUTH -->|"refresh token (only here)"| KEY["gnome-keyring"]
    AUTH -->|"short-lived access token"| consumers

    AUTH -->|"loopback OAuth login once for all apps"| GOOGLE["Google"]
    AUTH -->|"logout: revoke + wipe"| GOOGLE

    DRIVE["ewe-drive"] -->|"your Drive as a folder"| AUTH
```

## The rules

- **One client id, one consent screen, one sign-out.** The shell's
  `Google.qml` shrank to a *consumer* — profile/mail/calendar reads through
  the broker instead of owning OAuth itself.
- **No Google client ships with ewe.** Google is optional and needs the
  user's own OAuth client file (`oauth-client.json`, a drop-in file swap —
  see `ewe/docs/GOOGLE-CLIENT.md`).
- **Secrets never reach `ewe.conf`** — the file names accounts (an email),
  never credentials. This is rule 4 of [[The One File]].
- **Keyring playbook** — when a prompt keeps rejecting the login password,
  `ewe-auth keyring-reset` (used by ewe-sync).

## Why a broker

Before it, Google OAuth lived inside the shell (`Google.qml`): it owned the
client config, the refresh token, the refresh loop and the sync of its own
caches, while Komble ran a *separate* restore pipeline off files the shell
wrote. The broker deletes that duplication: one token owner, one sign-in,
consumers stay thin.

## The Gmail scope (ewe 0.51.0-beta, released 2026-11-27)

[[ewe Mail]] sends, archives and labels, so the mail scope changed:

- `MAIL_SCOPE` for personal clients (`ewe`, `legacy`, `env`) is now
  **`https://www.googleapis.com/auth/gmail.modify`** (it was `gmail.readonly`).
  The shipped project client keeps `gmail.readonly` behind `--with-mail`
  (restricted-tier rules unchanged).
- The scopes Google granted are recorded (non-secret) in `auth.json` as
  `scopes` at login and refreshed from each token response's `scope`.
- **`ewe-auth status`** adds `scopes: [...]` and `mail: "none" | "read" |
  "full"` — `full` = `gmail.modify` or `mail.google.com`; `read` =
  `gmail.readonly` only; `none` = signed out or no mail scope. An old
  `auth.json` with no `scopes` and a signed-in user reads as `"read"`.
- **The consumer is ewe Mail, not the shell:** from Mail plugin 2.0.0 the
  `ewe.mail` plugin asks the app (`ewe-mail-app --inbox`) and no longer calls
  `ewe-auth token` — no Gmail token is in the shell any more.
- **Existing users reconnect once** (ewe Sync → Google: Disconnect → Connect,
  or its Reconnect button) to get `full`. Nothing about the token flow, the
  keyring or the refresh token changed.

## Related

- [[The One File]] · [[Account and Sync]] · [[CLI Tools]] ·
  [[Sync and Backup Flow]]

> **Build guard:** the refresh token lives only in the keyring; `ewe-auth`
> is the single thing that touches it; the shipped Google story is
> BYO-client only. Rationale: [[RFC-002 — Auth Broker]].
