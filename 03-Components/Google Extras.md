---
tags:
  - ewe-map
  - component
title: Google Extras
up: "[[Home]]"
---

# Google Extras — the optional, BYO-client Google stack

Google is **not the account** (that's Nextcloud, RFC-005) and ewe ships **no
Google client**. It's an extra: Gmail in the Control Centre and Drive as a
folder — powered by the user's own OAuth client file
(`~/.config/ewe/oauth-client.json`, type *Desktop app*, Gmail + Drive APIs;
see `ewe/docs/GOOGLE-CLIENT.md`). ewe-sync → Google says whether the file
parses and connects. Settings sync **never** uses Google; an IMAP mail
account, when set up, takes precedence over Gmail.

## Who does what

```mermaid
flowchart LR
    U["you"] -->|"own oauth-client.json<br/>(personal client: no Google verification)"| AUTH["ewe-auth broker"]
    AUTH -->|"refresh token"| KEY["keyring"]
    AUTH -->|"short-lived access tokens"| SH["shell Google.qml — consumer"]
    SH -->|"calendar.readonly"| CAL["Calendar API"]
    AUTH -->|"ewe-auth token --json"| MAIL["ewe Mail app (0.1; the ewe.mail plugin 1.x until 2.0)"]
    MAIL -->|"gmail.modify (readonly through plugin 1.x)"| GMAIL["Gmail API"]
    SH -->|"drive.appdata"| DRIVE["Drive (ewe-drive mount)"]
    SH -.->|"fallback when signed out"| EDS["EDS (evolution-data-server)<br/>contacts + Accounts.events"]
```

> **The Gmail split (0.25):** `Google.qml` keeps OAuth, Calendar, Drive and
> the settings-sync verbs (`google syncSoon`, `google status`); the **Gmail
> unread polling, Gmail notifications, the Inbox page, the bar envelope and
> the `mail` IPC** live in the [[Mail Plugin]] (`ewe.mail`), which obtains
> tokens from the core broker via `ewe-auth token --json`. Rationale:
> [[Gmail Split — core Google, Mail add-on]]. The Gmail bullet below
> describes what the plugin does now.

## The operations (how it actually runs)

- **Calendar** — 14-day window over every selected calendar
  (`calendarList` → `events.list`, `singleEvents`, per-calendar colours),
  polled every 15 min + on sign-in + when Quick Settings opens stale;
  cached to `google-events.json` (offline shows the last sync). Reminders
  honour per-event/calendar popup overrides (else 10-min lead), fire
  through the shell's own notification server via `notify-send`, de-duped
  across restarts in `google-notified.json`.
- **Gmail** (read-only) — `labels.get(INBOX)` feeds the unread badge (bar
  envelope + Mail tile); `users.history.list` with a persisted `historyId`
  cursor detects genuinely new arrivals (**404 → silent re-baseline**;
  first sync marks existing unread as seen so sign-in never floods
  notifications); rows are metadata-only (From/Subject/Date + snippet,
  never bodies), deep-linking to Gmail in the browser. Poll: 2 min + on QS
  open when stale. State: `google-mail.json`. Tokens minted before the
  `gmail.readonly` scope get `mailState=scope` → a "Reconnect Google" pill.
- **Drive** — `ewe-drive setup|mount|unmount|status` mounts Drive as a
  folder (personal client only; the shipped project client's Drive scope is
  appData for the legacy RFC-002 bundle).
- **Auth** — `scripts/google-auth.py` (stdlib Python): PKCE + random-port
  `127.0.0.1` loopback redirect, browser via `xdg-open`. Access tokens live
  in shell memory, single-flight refreshed with queued waiters; `api()`
  injects Bearer and retries exactly once on 401. Sign-out revokes at
  Google and clears everything.

## The degrade-cleanly rules (the house pattern)

- not configured → actionable message (no spinners)
- signed out / offline → cached or empty states
- keyring missing → explicit install hint
- boot-race safe: the signed-in probe retries with backoff (gnome-keyring
  may come up after the shell); a failed fetch retries every minute (Wi-Fi
  may connect after the shell); Quick Settings renders cached events
  without waiting — sign-out clears caches so nothing stale leaks.

## Caches (all non-secret, gitignored)

`google-profile.json` (name/email/avatar only) · `google-events.json` ·
`google-mail.json` · `google-notified.json` · `google-oauth.json` (client
id/secret) — under `~/.config/quickshell/`. The refresh token is keyring-only.

## Scope tiers (the ceiling Google imposes)

| scope | tier | unverified client |
|---|---|---|
| openid/email/profile | basic | fine |
| drive.appdata | non-sensitive | fine |
| calendar.readonly | sensitive | works, "unverified" warning |
| gmail.readonly | **restricted** | **blocked** except ≤100 test users; full = CASA audit |

> **Build guard:** don't promise Gmail for everyone — 100 test-users is the
> honest maximum without a CASA verification budget. Personal clients are
> unverified-but-unrestricted; that's why BYO-client is the default story.
> Policy rationale: [[RFC-002 — Auth Broker]].

## Gmail in ewe Mail (ewe 0.51.0-beta, released 2026-11-27)

[[ewe Mail]] is Gmail's one consumer from plugin 2.0.0 (the plugin runs
`ewe-mail-app --inbox` and polls nothing; ewe Mail is public and
preinstalled since ewe 0.51.0-beta). It reads and writes Gmail through the same broker (`ewe-auth token
--json`, an access token in the app's memory only). That needs more than the
read-only row above: personal clients now ask for **`gmail.modify`** (read,
label, archive, trash, send; no permanent delete) — see [[Auth Broker]]. The
shipped project client keeps `gmail.readonly` behind `--with-mail`, so the
restricted-scope policy and the 100-test-user ceiling are unchanged. **An
existing connection must be reconnected once in ewe Sync** (Disconnect →
Connect); until then `ewe-auth status` says `mail: read`, the app reads Gmail
but says "Reconnect Google in ewe Sync to send and organise mail". The Google
page in ewe Sync shows the Gmail permission with a Reconnect button. IMAP
accounts no longer take precedence: Gmail and every IMAP account share one
inbox, in the app and (plugin 2.0.0) in the bar ([[Mail Plugin]]). The
Gmail bullet above describes plugin 1.x; from 2.0.0 the app does the polling.

## Related

- [[Auth Broker]] · [[Account and Sync]] · [[RFC-005 — Nextcloud Account]] ·
  [[CLI Tools]] · [[Mail Plugin]] · [[ewe Mail]]
