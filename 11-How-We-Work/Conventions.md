---
tags:
  - ewe-map
  - how-we-work
title: Conventions
up: "[[Home]]"
---

# Conventions — naming, layout, style

The patterns that keep the project legible across repos. They're not law,
but a deviation should be a decision, not an accident.

## Naming

- **Tools are `ewe-<noun>`**: `ewe-conf`, `ewe-plugin`, `ewe-auth`,
  `ewe-drive`, `ewe-cloud`, `ewe-caldav`, `ewe-mail`, `ewe-files`,
  `ewe-theme`, `ewe-bt`, `ewe-pass`, `ewe-setup`, `ewe-share-picker`,
  `ewe-globalshortcuts`. New tool = same family (RFC-006 named ewe-sync
  explicitly for this).
- **Plugin ids are `<namespace>.<name>`**, lowercase `[a-z0-9_-]`; `ewe.`
  is reserved (validates only in the payload or with `--first-party`).
- **RFCs are `RFC-0NN-short-slug.md`** in `ewe/docs/`, each with a *Status*
  line at the top — statuses stay honest when superseded.
- **Commits**: scoped, descriptive (`fix(kitty): …`, `feat(theme): …`).
- The user-facing name is **ewe**; old `hypr-shell` names remain only as
  migrations (see [[Foundation Choices]]).

## Repo layout

- Every product repo: `README.md` with role + status + honest limits;
  `packaging/` for package plumbing; `VERSION` (or equivalent) at root.
- Tauri apps: `src/` (Svelte) + `src-tauri/src/` (Rust modules named after
  their domain: `pacman.rs`, `catalog.rs`, `folders.rs`, …).
- ewe repo: `bin/ lib/ phases/ dotfiles/ system/ systemd/ packages/
  packaging/ design/ docs/ tests/ templates/ scripts/`.
- `packages/patched/<name>/` = an official package rebuilt with upstream
  fixes, `pkgrel` N.1, a header saying **why** — retires itself when the
  repos catch up. Add new patched packages this way, never fork casually.

## Licences

- The DE (`ewe`): **GPL-2.0-only**.
- Komble: **MIT**. The Tauri apps follow suit.
- Plugins: **MIT** (the example plugin ships MIT).

## Docs style

- READMEs carry the pitch + install + the honest limits. Deep dives go to
  `docs/` (MANUAL, RFCs, per-topic guides) or the website.
- **Honesty is a house style**: unsupported things are labelled (Komble
  "early, not yet run against live pacman"; cast "seconds of latency —
  honest"; sync "cannot create accounts"). New features must say what they
  cannot do.
- Badges: distro/Arch-only, session/Wayland, license, CI, release.

## Configuration style

- All user-facing strings/copies consistent with the brand voice; design
  copy rules in `design/system/guidelines/` (writing guide).
- `ewe.conf` keys are snake_case dotted paths; structures print as JSON;
  values parse as JSON else string.

## Related

- [[Repo Layout]] · [[Rules of the House]] · [[Design System]] ·
  [[Release Checklist]]
