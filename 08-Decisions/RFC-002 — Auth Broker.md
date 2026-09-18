---
tags:
  - ewe-map
  - decisions
title: RFC-002 — Auth Broker
up: "[[Home]]"
---

# RFC-002 — `ewe-auth` and the sync of the one file

*Status (2026-09-02): SUPERSEDED for the account and the sync of the one
file by RFC-005 — the ewe account is a Nextcloud account. `ewe-auth` and
the Drive backend remain only for the optional, bring-your-own-client
Google extras (mail, Drive folder).*

## What shipped and stays

`ewe-auth` is a small broker (Python, stdlib + keyring via libsecret CLI or
D-Bus) owning exactly three things:

1. **the refresh token** — in gnome-keyring, nowhere else, ever;
2. **access tokens** — `ewe-auth token [scope-set]` prints a short-lived
   access token, refreshing under a lock when expired;
3. **sign-in/out** — `ewe-auth login` runs the loopback-redirect flow once
   for all apps; `ewe-auth logout` revokes + wipes.

## Why a broker

Historically Google OAuth lived inside the shell (`Google.qml`): it owned
the client config, the refresh token, the refresh loop, and the sync of its
own caches — while Komble ran a *separate* restore pipeline off files the
shell wrote. The broker deletes the duplication: one token owner, one
sign-in, thin consumers.

## The scope strategy (why Mail is opt-in)

Google tiers scopes; `gmail.readonly` is **restricted** — blocked for
unverified clients except listed test users (full verification = CASA audit).
So: base scopes (identity, calendar, one-file sync) ship; Mail is an extra
explicit consent (`ewe-auth login --with-mail`), available to test-list
users and personal clients. **The honest maximum Google allows** — if ewe
ever outgrows 100 mail users, CASA verification is the gate to budget for.

Personal clients (`~/.config/ewe/oauth-client.json`) override the shipped
client and get the full scope set by default.

## Anti-regression notes

- **Do not ship a Google client by default** — the shipped client
  (`system/oauth-client.json`, minted once by the owner) is a desktop-app
  client whose secret is non-confidential by Google's definition; the
  refresh token never leaves the keyring.
- The shell's Google surface must stay a *consumer*: profile/mail/calendar
  read through the broker. One client id, one consent screen, one sign-out.
- Tokens minted before the mail scope get `mailState=scope` → a "Reconnect
  Google" pill re-runs consent. Degrade cleanly, never spin.
- `ewe-auth keyring-reset` is the playbook when a prompt keeps rejecting
  the login password.

## Related

- [[Auth Broker]] · [[RFC-005 — Nextcloud Account]] · [[Decision Index]]
