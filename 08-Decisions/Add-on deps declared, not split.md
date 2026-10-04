---
tags:
  - ewe-map
  - decisions
title: Add-on deps declared, not split
up: "[[Decision Index]]"
---

# Package deps stay in ewe's `depends`; add-ons **declare** them (D7)

**Decided 2026-10-04** (ewe 0.25.0-beta). The packages an add-on needs
(`kdeconnect`, `ewe-cast`, `networkmanager-l2tp`, …) stay in the `ewe`
package's dependencies for now. Each add-on **declares** them in its
manifest — `requires: { "packages": [...], "commands": [...] }` — so that:

- `ewe-plugin list --json` and `install` **report** what is `missing`
  (packages and commands); the shell **never installs anything**.
- Komble's Add-ons catalogue offers to install the missing packages
  (`install-repo` via the polkit helper, batched
  `install_packages_named`, no `[apps.installed]` entry — they are deps,
  not apps) and then runs `ewe-plugin install <id>`.
- A later split into `optdepends` is mechanical: the declarations already
  exist.

Two nuances: `missing` is **per package**, so an add-on that works with
*any one* of several packages (the VPN types) declares only the command
(`nmcli`) and names the packages in its README; Komble **never decides**
what is missing — the catalogue does.

> **Build guard:** no `pacman` call anywhere in `ewe-plugin` or the shell.
> *Breaks if violated:* a plugin install asks for root (Rule 10's
> one-privilege-path promise) and Komble's conflict/restart dialogs are
> bypassed.

## Related

- [[Decision Index]] · [[Komble]] · [[Plugin Manifest Reference]] · [[Rules of the House]]
