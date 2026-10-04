---
tags:
  - ewe-map
  - decisions
title: One repo per add-on
up: "[[Decision Index]]"
---

# One repository per add-on — `prj786/ewe-plugin-<name>` (D6)

**Decided 2026-10-04** (ewe 0.25.0-beta). Every add-on lives in its own
repository, like the three that existed before (`ewe-plugin-clipboard`,
`-screenshot`, `-passwords`), and is **vendored** into the ewe payload by
`scripts/vendor-plugins.sh` ([[Add-ons — vendored payload and bundle.json]]).

The template (what every repo has): `manifest.json` (schemaVersion 1,
`apiVersion` 3, id `ewe.<name>`, `version`, `homepage`, author `prj786`,
`icon`, `category`, one-sentence `description`, `requires`, `ipcAliases`
where a legacy target is kept), the QML entry points, any scripts,
`README.md` (what it does; install = Komble → Add-ons or `ewe-plugin
install <id>`; settings; IPC verbs), `LICENSE` (MIT 2026 prj786) and a
`test.sh` when there is testable logic.

Validate from the release branch's tool, in a sandboxed HOME:
`EWE_PAYLOAD_PLUGINS=<tmpdir> ewe/bin/ewe-plugin validate <dir> --first-party`.

The 14 plugin repos today: clipboard, screenshot, passwords, insomnia,
sysmon, ssh, vpn, media, places, phone, mail, cast, dock, plus the example
([[Repository Map]]).

> **Build guard:** fix an add-on in **its** repo, then re-vendor; never
> patch `ewe/plugins/<id>/` directly. *Breaks if violated:* the next
> `vendor-plugins.sh` run silently reverts the fix.

## Related

- [[Decision Index]] · [[Repository Map]] · [[Plugin System]] · [[Release Checklist]]
