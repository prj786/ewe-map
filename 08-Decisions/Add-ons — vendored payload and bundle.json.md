---
tags:
  - ewe-map
  - decisions
title: Add-ons — vendored payload and bundle.json
up: "[[Decision Index]]"
---

# Add-ons ship vendored in the payload, listed in `bundle.json` (D2)

**Decided 2026-10-04** (ewe 0.25.0-beta). Add-ons are distributed **inside
the ewe payload** — `ewe/plugins/<id>/` plus `plugins/bundle.json` — not
from a remote catalogue and not as pacman packages.

- `scripts/vendor-plugins.sh` copies each add-on repo into `plugins/<id>/`
  (a vendored copy — `git archive` ships it; a submodule would arrive
  empty) and records **repo, commit, version, `default`, `migrate`** in
  `plugins/bundle.json`. The script reads its plugin list *from*
  `bundle.json`, not from a hard-coded array.
- `default: true` ids are seeded on every machine (**none in 0.25**);
  `migrate: true` ids are what `ewe-plugin migrate` installs for upgraders
  (all 13 add-ons today); every id in the payload is offered by
  `ewe-plugin list --json` under `available`.
- The payload scanner must accept extra roots later (`addons.d/`) — do not
  hard-wire the single directory.
- `PAYLOAD_PLUGINS` resolves via realpath with fallbacks
  (`/usr/share/ewe/plugins`, `~/.local/share/ewe/plugins`); before 0.25
  `seed --restore <id>` silently seeded nothing because of this.

```json
{ "plugins": {
    "ewe.clipboard": { "repo": "https://github.com/prj786/ewe-plugin-clipboard",
                       "commit": "861d2b3…", "version": "1.1.1",
                       "default": false, "migrate": true } } }
```

## Why

Offline installs work (the ISO carries everything), and the add-ons move
in **lockstep with the shell's `apiVersion`** — a remote catalogue or a
separate package line would let an add-on and its host drift apart.

> **Build guard:** an add-on's version in `bundle.json` is what a newer ewe
> compares to refresh an installed bundled copy; bump the plugin repo's
> `manifest.json` version AND re-run `vendor-plugins.sh` in the same wave.
> *Breaks if violated:* upgraders keep stale copies, or the Welcome/Komble
> catalogue shows an add-on the payload does not contain.

## Related

- [[Add-ons — opt-in, not preinstalled]] · [[Add-ons — one-time migration for upgraders]] ·
  [[Plugin System]] · [[Storage Map]] · [[Release Checklist]]
