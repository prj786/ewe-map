---
tags:
  - ewe-map
  - roadmap
title: Open Questions
up: "[[Home]]"
---

# Open Questions

Deliberately unresolved. When one of these gets an answer, move it to a
decision note (or [[Parked and Rejected Ideas]]) and delete it here.

## Architecture

- **Rust rewrite of ewe-castd?** — parked until profiling demands it.
- **Native QtWebEngine OAuth webview** — browser round-trip works; webview
  stays "a later phase". Still wanted?
- **EDS (evolution-data-server) as a primary calendar source?** — currently
  an optional secondary fallback behind Google/CalDAV.

## Komble

- **AUR search across the whole AUR** — currently known-packages only.
- **Snapshots/rollback** (pacman snapshot tooling) — considered, not scoped.
- **Debian build's remaining features** — which ones translate to Arch at
  all?

## ewe-sync

- **Selective sync inside a folder pair** — "use excludes" today; is the
  UI worth it?
- **Bandwidth limits** — documented limit; does anyone actually need them?
- **Multi-account?** — one Nextcloud account is the model. More than one?

## Desktop

- **Quickshell power menu** — "on the list".
- **Text-size beyond 130?** — bar steps icon size at 130; where's the
  ceiling?
- **More accessibility modes** — which remaps does the audit data suggest
  next?

## Distro

- **Standalone release shape** — versioning, ISO cadence, upgrade story for
  beta installs.
- **CASA verification budget** — only if ewe ever outgrows 100 Google mail
  test-users (see [[RFC-002 — Auth Broker]]).

## Method

- How much of `docs/MANUAL.md` migrates to the website vs stays in-repo.

## Related

- [[Decision Index]] · [[Roadmap and Status]] · [[Parked and Rejected Ideas]]
