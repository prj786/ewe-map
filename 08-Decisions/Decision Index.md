---
tags:
  - ewe-map
  - decisions
title: Decision Index
up: "[[Home]]"
---

# Decision Index

Every load-bearing decision, its status, and where its full rationale lives.
If a future session proposes something that contradicts a row here, it must
read the note first — these were settled deliberately, most with RFCs.

| # | decision | status | note |
|---|---|---|---|
| 1 | Hyprland + Quickshell as the foundation; Arch-only; dark-only; traditional GTK apps | shipped | [[Foundation Choices]] |
| 2 | The machine as one file — `ewe.conf` (RFC-001) | shipping (phases 1–5 landed; phase 6 became RFC-005/006) | [[RFC-001 — The One File]] |
| 3 | Account = your Nextcloud, Google demoted to optional BYO extra (RFC-005) | accepted, implemented across repos, merging as one wave | [[RFC-005 — Nextcloud Account]] |
| 4 | ewe-sync, a 4th Tauri app owning account + sync (RFC-006, ex-"Flock") | built, shipped preinstalled | [[RFC-006 — ewe-sync App]] |
| 5 | `ewe-auth` broker owns tokens; Google identity only for optional extras (RFC-002, superseded half) | shipped for Google extras | [[RFC-002 — Auth Broker]] |
| 6 | Casting = headless `ewe-castd`, Python not Rust (RFC-004 deviation) | phases A+B built; C pending | [[RFC-004 — ewe-castd, Python not Rust]] |
| 7 | Shell stays one process; big UIs are separate Tauri apps | shipped | [[Process Split — Shell vs Apps]] |
| 8 | Plugins run unsandboxed in the shell; honesty over pretense | shipped | [[Plugins Unsandboxed]] |
| 9 | Komble: no partial upgrades, PKGBUILD-first AUR, one polkit path | shipped (early) | [[Komble — Arch Forced Decisions]] |
| 10 | ewe-repo unsigned for now, `Optional TrustAll` | temporary | [[Unsigned Repo — for now]] |
| 11 | Everything rejected or parked | — | [[Parked and Rejected Ideas]] |
| 12 | The terminal shell is zsh with plugins, started by kitty; the LOGIN shell stays bash | built 2026-09-21 | [[Terminal Shell — zsh in kitty, bash at login]] |
| 13 | One brand mark: the line-art logo everywhere, two weights; app launcher icons stay per-app | built 2026-09-21 | [[One Mark — the line-art logo]] |
| 14 | The Overview takes the whole screen, wallpaper first; bar slides up, dock slides down; exclusive zones stay reserved | built 2026-09-21 | [[Overview Takes the Screen]] |
| 15 | App launcher icons: one Lucide line glyph per app on a dark tile | built 2026-09-21 | [[App Icons — one line glyph per app]] |
| 16 | **D1** Add-ons are opt-in — only the shell core, ewe-settings, Komble and ewe-sync are preinstalled; every extra (incl. clipboard/screenshot/passwords, dock, Cast, mail, phone, …) is an add-on | built 2026-10-04, in 0.25.0-beta (unreleased) | [[Add-ons — opt-in, not preinstalled]] |
| 17 | **D2** Add-ons ship vendored in the payload (`plugins/<id>/` + `bundle.json`), not a remote catalogue, not packages | built 2026-10-04 | [[Add-ons — vendored payload and bundle.json]] |
| 18 | **D3** Upgraders keep what they had: one-time `ewe-plugin migrate`; marker = JSON list of considered ids at `~/.local/state/ewe/addons-migrated` (local, never synced) | built 2026-10-04 | [[Add-ons — one-time migration for upgraders]] |
| 19 | **D4** Plugin API 3 — superset of 2 (host loads 2 and 3): four Quick-settings/bar/dock kinds, the `Shell` singleton, public components, `requires`, `ipcAliases` | built 2026-10-04 | [[Plugin API 3]] |
| 20 | **D5** "Keep awake" is called **Insomnia** everywhere user-facing (namespace `quickshell:caffeine` kept) | built 2026-10-04 | [[Insomnia — the name for keep awake]] |
| 21 | **D6** One repository per add-on, `prj786/ewe-plugin-<name>` | built 2026-10-04 | [[One repo per add-on]] |
| 22 | **D7** Package deps stay in ewe's `depends`; add-ons declare them (`requires`) — reported, never installed by the shell; Komble installs the missing ones | built 2026-10-04 | [[Add-on deps declared, not split]] |
| 23 | **D8** The Overview opens in one step (backdrop + cards together at `durBase`, `Theme.ease`); trigger is the `ewe:overview` global shortcut | built 2026-10-04 | [[Overview Takes the Screen]] |
| 24 | Lid-open touches only a disabled panel, with its saved spec; re-asserts are per output and minimal; no unconditional dpms-on except Reset displays | built 2026-10-04 | [[Quiet Lid — touch only a disabled panel]] |
| 25 | The Gmail split: core Google = OAuth, Calendar, Drive, sync verbs; the Gmail/IMAP visuals and `mail` IPC = the `ewe.mail` add-on | built 2026-10-04 | [[Gmail Split — core Google, Mail add-on]] |
| 26 | X11 scale at login = the smallest lit scale of the DRM-connected monitor set (not the last-saved profile's primary) | built 2026-10-04 | [[X11 Scale — smallest lit scale]] |

> **Numbering note:** RFC-003 does not exist in `ewe/docs/` (the sequence
> is 001, 002, 005, 006), and RFC-004's text lives only as references in
> `ewe-cast/README.md` — there is no RFC-004 file in the repos. Don't hunt
> for either; if they surface later, record them here.

## How decisions are made here

- Big ones get an **RFC** in `ewe/docs/RFC-0NN-*.md` with a *Status* line;
  small ones get a "Key design decisions (don't relitigate)" list in
  `ewe/CLAUDE.md`.
- RFCs record **why**, not just what — read the rationale before proposing a
  reversal.
- A superseded RFC is marked in its Status line (RFC-002 → RFC-005) so the
  history is honest.

## Related

- [[Rules of the House]] · [[Roadmap and Status]] · [[Parked and Rejected Ideas]]
