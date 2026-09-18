---
tags:
  - ewe-map
  - decisions
title: Plugins Unsandboxed
up: "[[Home]]"
---

# Plugins run unsandboxed — the honesty decision

## The decision

Plugins run **unsandboxed, inside the shell process**, with everything the
desktop itself can do. There is **no way to sandbox QML inside one engine**,
and the tool says so instead of pretending:

> Installing never runs plugin code — there are no install hooks and nothing
> asks for privileges. `add` clones the repository, validates its manifest,
> and records where it came from. The code runs the moment the plugin is
> enabled, unsandboxed, inside your shell process. Read it first.

## The trust model that follows from it

- `ewe-plugin add` **clones, validates, records the source URL** — it never
  executes anything at install time.
- `update` shows the **diff first**; a manifest that stops validating is
  rolled back.
- `remove` deletes the clone (a hand-made directory is moved to
  `<id>.bak.<stamp>` — never destroyed).
- The public API surface (`import qs` → `Theme`, public `Globals` subset,
  `Log`) is versioned by **`apiVersion`** — it will not change without the
  number moving, and a mismatch is refused **at install, not at login**.

## Why plugins at all

The desktop is one long-lived Quickshell process; a plugin is a directory
of QML it loads at startup exactly as it loads its own bar and dock.
Plugins add bar widgets, panels, overlays, menus and headless services —
using the same `Theme` roles and the same `Globals` as first-party code.

**Plugins are not apps.** *Komble installs programs; `ewe-plugin` extends
the desktop.*

## Anti-regression notes

- Don't promise sandboxing, install hooks, or privilege prompts — they'd be
  theater given one QML engine.
- Don't make plugin code "more powerful" silently: the `ewe.` namespace is
  reserved and validates only in the payload or with `--first-party`.
- Entry-point symlinks that resolve outside the plugin dir are **rejected**.
- A QML error in a plugin kills the desktop — same risk as the shell, stated
  openly. (This is also why the big UIs were moved out; see
  [[Process Split — Shell vs Apps]].)
- The crash guard counts boots in `~/.local/state/ewe/plugin-boots.json`.

## Related

- [[Plugin System]] · [[Plugin Manifest Reference]] · [[Decision Index]]
