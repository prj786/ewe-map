---
tags:
  - ewe-map
  - onboarding
title: 00 Onboarding
up: "[[Home]]"
---

# 00 — Onboarding (read this first)

> You are an AI agent (or a human) resuming work on **ewe**. This note is
> written to you. Read it before touching any code — it exists so you do not
> relitigate settled decisions or re-break a contract.

## What ewe is

**ewe** *(the sheep)* — an Arch-only, opinionated, dark Wayland desktop: an
installable **operating system** (`ewe-os` ISO) whose desktop is
**Hyprland** (Lua-configured compositor) + **Quickshell** (QML shell). The
project lives in `/home/scubba/Projects/ewe/` as 8 product repos + 4 plugin
repos. Everything about the machine's configuration lives in **one file**,
`ewe.conf`, synced through the user's own **Nextcloud**. See [[What is ewe]].

## The 10 rules of the house (the short form)

1. `ewe-conf` is the **only writer** of `ewe.conf`. Everything persists *through* it.
2. **Secrets never enter `ewe.conf`** — it syncs to the cloud. Keyring only.
3. **Layer-shell surfaces stay in the shell.** Tauri apps are ordinary windows.
4. **IPC verbs are public API** — renaming one breaks installed binaries.
5. Every CLI tool prints **JSON and exits 0**; callers never hang.
6. **Nothing else has a sync button** — ewe-sync owns account + sync.
7. **No Google client ships.** Google is optional, BYO OAuth client file.
8. **No raw colour/size/duration in QML** — only design-system tokens.
9. **Never edit `generated/` files or deployed `~/.config`** — repo is truth.
10. **Arch only, pacman only** — no multi-distro branches, no partial upgrades.

Full list with reasoning: [[Rules of the House]].

## Reading order

1. [[Home]] — the map
2. This note
3. [[Quick Answers]] — if you have a specific question, it's probably here
4. [[Rules of the House]] and [[Contracts and Public API]] — the contracts
5. [[Decision Index]] — everything already decided (and [[Parked and Rejected Ideas]])
6. [[Roadmap and Status]] + `10-Roadmap/` — what's next
7. [[Development Loops]] — how to build/test/run safely
8. The area-specific notes for whatever you're about to touch

## Source-of-truth hierarchy

1. **The repos** — READMEs, `CLAUDE.md`, RFCs in `ewe/docs/`, code. They win.
2. **This vault** — memory distilled from the repos. Fast to read, may lag.
3. **Your context/memory** — last resort; verify against the repos.

## Update discipline (so the vault stays true)

When you change reality — a decision reversed, a contract renamed, a version
bumped, a phase landed — **update the vault in the same commit**:

- Decision changed → update `08-Decisions/` + [[Decision Index]]
- Contract changed → update `09-Rules/` + the `12-Reference/` sheet
- Version/status changed → update `01-Overview/Roadmap and Status.md` + [[Version Ledger]]
- New gotcha → add it to the relevant "Build guard" line and [[Troubleshooting Knowledge]]

If you don't, the next session will make exactly the mistake this vault was
built to prevent.

## The one-line summary for every future session

> ewe is the dark, one-file, Nextcloud-backed Arch desktop. Don't add a
> second config writer, don't put secrets in the file, don't rename IPC
> verbs, don't ship Google, don't light the mode, don't edit generated
> files. Change the source, apply, sync.
