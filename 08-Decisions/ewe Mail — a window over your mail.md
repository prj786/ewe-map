---
tags:
  - ewe-map
  - decisions
title: ewe Mail — a window over your mail
up: "[[Decision Index]]"
---

# ewe Mail — a window over your mail; accounts stay in ewe Sync, notifications stay the plugin's

**Decided 2026-11-27**, built and **released** the same day (owner: "now i want you to generate new ewe app. its called ewe
mail … same stack same ui [as ewe Sync] … we already have gmail and google
cloud connection using google json auth file. also if i set up any email it
should be the so i will receive new emails, response and send messages").
The owner was offered options and took the recommended one every time:

- **Any number of accounts.** `[accounts.mail]` becomes a list
  (an array of tables, `accounts.mail`); Gmail plus as many IMAP/SMTP mailboxes as you like,
  **one inbox for all of them**. A single table (what 0.50 writes) still
  reads as a list of one.
- **Accounts are added in ewe Sync** (rule 6: ewe Sync owns accounts). The
  app never adds, changes or removes one; its "Add account" runs
  `ewe-sync --pane mail` (or `google`). Everything it knows about an account
  it reads from `ewe-auth status` and `ewe-mail accounts`.
- **Plain-text compose first.** Quoted replies, attachments and a signature;
  rich text is a later version, server-side drafts too (unsent drafts live in
  the webview's localStorage meanwhile).

What follows from it:

- **A Tauri app in its own repo, the ewe Sync stack** (Tauri 2.12, Svelte 5,
  Tailwind 4, the design system) — `ewe-mail`, the same shape as
  [[ewe Mobile]]. The **binary is `ewe-mail-app`**, because the core already
  ships `/usr/bin/ewe-mail` (the CLI); the same precedent as `ewe-files-app`
  ([[ewe's Own Apps — Files, Player, Viewer]], decision 56). Id
  `io.github.prj786.ewe-mail`, window class `ewe-mail-app`, dev port 5178.
  It is the `mailto:` handler.
- **Not resident** ([[Apps Are Not Resident]], decision 59). Closing the
  window ends the process. **Notifications, the bar envelope and the Inbox
  page stay the `ewe.mail` plugin's** (rule 3; [[Mail Plugin]]): the app never
  notifies on its own, so nothing is told twice. The plugin opens the app for
  every row and notification.
- **It keeps a cache and three settings, no secret.** The cache is
  `$XDG_CACHE_HOME/ewe-mail/mail.sqlite` (rows, cursors, the last 500 opened
  messages, people, trusted senders; deleting it loses only time). Settings
  are `[mail]` `remote_images`, `mark_read`, `signatures` in ewe.conf,
  written through `ewe-conf` (rule 1) as a **store-only** domain: a mail
  setting must never rebuild the theme or reload Hyprland. Passwords and
  tokens stay in the keyring and in Rust memory — never in the window, a log,
  a command line or the file (rule 2).
- **HTML mail is cleaned, then caged.** ammonia cleans it in Rust; the window
  shows it in `iframe sandbox="allow-same-origin"` — **never `allow-scripts`**
  — with its own CSP. Pictures from the web are blocked until allowed, once
  or "always for this sender". Attachments go out by token only (a file the
  picker or a drop gave); "Open" is refused for anything that runs by name,
  type or content, and those are Save-only.
- **Gmail needs `gmail.modify`.** The core `ewe-auth` used to ask for
  `gmail.readonly`; personal clients now ask for `gmail.modify` (read, label,
  archive, trash, send — no permanent delete). The shipped project client
  keeps `gmail.readonly` behind `--with-mail`. **The owner must reconnect
  Google once in ewe Sync.** `ewe-auth status` has `scopes` and
  `mail: none|read|full`; until `full`, the account reads but cannot send and
  says so. See [[Auth Broker]].
- **One list, two kinds.** Gmail is `google:<email>` (REST, History API for
  new mail, polled by the app alone); IMAP is `imap:<email>` (IMAP IDLE, SMTP to send, then an
  APPEND to Sent except on hosts that file sent mail themselves).

**The owner's second pick, same day** ("create github repo and update
everything. it should be working as other ewe apps. preinstalled and
preconfigured. email pligin should be using ewe mail as source"):

- **The repo is public:** `github.com/prj786/ewe-mail`, `main` pushed, tag
  `v0.1.0-beta` pushed; its release workflow builds the Arch package and
  attaches it to a GitHub pre-release.
- **Preinstalled and preconfigured from ewe 0.51.0-beta** — a separate wave
  after the release session's 0.50.2. `ewe` `feat/ewe-mail-accounts`
  (ae6faeb): `packaging/PKGBUILD` depends on `ewe-mail`, phase 20 installs it
  on the get.sh path, ewe-setup and phase 60 seed ewe Mail as the `mailto:`
  default **only where no mail app was chosen**
  (`_mime io.github.prj786.ewe-mail.desktop x-scheme-handler/mailto`), and the
  MANUAL has an "ewe Mail (0.51)" section. ewe-mail's own PKGBUILD has `ewe`
  as an **optional** dependency (like ewe-sync): a hard one back would be a
  cycle.
- **The plugin takes ewe Mail as its one source** (Mail plugin 2.0.0,
  `ewe-plugin-mail` `feat/ewe-mail-app`, abcbb6d): it runs `ewe-mail-app
  --inbox --limit 10` and **no longer polls Gmail or IMAP itself** — one
  engine, one cache, one Gmail poller, no token in the shell. It stays an
  opt-in add-on and requires the `ewe-mail` package. [[Mail Plugin]]
- **`ewe-mail-app --inbox [--limit N]` is public API** now (the plugin depends
  on it): [[Contracts and Public API]].
- Every ewe Tauri app now carries komble-arch#26's `crash.rs` (journal:
  `journalctl -t ewe-mail-app -p crit`) and `pointer.rs`, and declares no
  minimum window size; ewe Mail has them.

The core and the shell parts shipped in one wave, **the 0.51 wave, released
2026-11-27** after the release session's 0.50.2 wave and ISO, with the
owner's OK for the `[ewe]` publish ("we can publish email so i can install
it"; run 45996222052): ewe#103 → **ewe 0.51.0-beta** (ewe-auth, the
store-only `accounts` and `mail` domains, `ewe-mail` with many accounts, an
SMTP-tested login, `logout`, `set`, `accounts`, `autoconfig`, `unseen --all`;
`ewe` depends on `ewe-mail`; the `mailto:` default; ewe.mail 2.0.0 vendored),
ewe-sync#19 → **ewe Sync 0.18.0-beta** (the Mail page lists accounts with an
email-first add sheet; the Google page shows the Gmail permission),
ewe-plugin-mail#3 (**2.0.0**), ewe-repo#10 (publish.yml carries ewe-mail),
komble-arch#27 → **Komble 0.26.2-beta** (the name and the first-party
DISCOVER entry) and prj786.github.io#20 (the website).

**Status: released 2026-11-27** — ewe Mail 0.1.0-beta, preinstalled since
ewe 0.51.0-beta. The plan and contracts:
`~/Projects/ewe/ewe-mail/docs/PLAN.md` (it wins over this note).

**Later, not decided here:** rich-text compose, server drafts.

## Related

- [[ewe Mail]] · [[Mail Plugin]] · [[Google Extras]] · [[Auth Broker]] ·
  [[ewe-sync]] · [[ewe Mobile — a window over KDE Connect]] ·
  [[Process Split — Shell vs Apps]] · [[Apps Are Not Resident]]
