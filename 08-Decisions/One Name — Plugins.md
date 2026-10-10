---
tags:
  - ewe-map
  - decisions
title: One Name — Plugins
up: "[[Decision Index]]"
---

# One name: plugins (D9)

**Decided 2026-10-10** (released in ewe 0.25.1-beta). The
user's words: *"lets keep it simple we call it ewe-plugin as cli … make it
one naming."*

The CLI was `ewe-plugin`, the repos `ewe-plugin-<name>`, the manifest and
the API "plugin" — but Komble's page, Settings and the Welcome screen said
**Add-ons** for the first-party ones (D1–D7). Two words for one thing. Now
every user-facing string says **plugin(s)**: Komble's sidebar and page
("Plugins", first group "From ewe"), Settings, the in-shell Welcome and
Settings, `ewe-plugin` help, the manifests, the docs, the installer and the
website. When the difference matters: *first-party plugins* (ship inside
ewe, installed when you ask) vs *plugins from a git URL*.

## What did NOT change (contracts)

`komble --addons` (still valid; `--plugins` is its twin), the `list --json`
keys (`available`, `removed`), the marker
`~/.local/state/ewe/addons-migrated`, `plugins/bundle.json`, repo names,
IPC targets, code identifiers (`addons.js`, `addons_state`, `open_addons`),
website URLs (`/docs/add-ons/`), and the installer's machine-read lines
`ok add-on <id>` / `!! add-on <id>:` (ewe-os's helper parses them). The vault
keeps the D1–D7 note file names (links) and their history.

> **Build guard:** new user-facing text says "plugin". *Breaks if violated:*
> the two-words-for-one-thing confusion this decision removed comes back.

## Related

- [[Decision Index]] · [[Add-ons — opt-in, not preinstalled]] · [[Plugin System]] ·
  [[Conventions]] · [[Glossary]]
