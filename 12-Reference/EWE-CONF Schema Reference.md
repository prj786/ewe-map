---
tags:
  - ewe-map
  - reference
title: EWE-CONF Schema Reference
up: "[[Home]]"
---

# `ewe.conf` schema reference (v1)

The one file. Human guide: `ewe/docs/EWE-CONF.md`; architecture:
[[RFC-001 — The One File]]. TOML, `schema = 1`, comment headers regenerated
on write. **Keys are quoted when they contain dots** (plugin ids).

## Top-level domains

```toml
schema = 1

[desktop.theme]        # ← user-theme.json today
  color_scheme = "dark"          # dark (light parked)
  accent = "#0a84ff"
  theme_name = "flock"           # flock | blacksheep
  tint_borders = true
  window_transparency = 1.0
  avatar_shape = "circle"
  bar_opacity = 100              # 0..100 → Theme.barAlpha; 10–99 adds blur + layer rule
  app_blur = false               # every WINDOW at 85 % + blur (fixed, not a slider)
  [desktop.theme.schemes]        # user schemes (Base24 + accent), builtins ewe-dark / ewe-light

[desktop.dock]
  enabled = true
  autohide = false               # "intelligent hide"
  icon_size = "medium"

[desktop.layout]                 # ← user.lua (ewe-conf set desktop.layout)
[desktop.input]                  # ← input.lua + input-devices.json (ewe-conf set desktop.input)
[desktop.wallpaper]              # ← wallpapers.conf
[desktop.screensaver]            # hypridle.conf stays SHELL-generated (not here — by design)

[apps.installed]                 # Komble's manifest: source = repo | aur | first-party

[plugins]
  enabled = ["ewe.clipboard", "ewe.screenshot", "ewe.passwords"]
  removed = ["some.thirdparty"]              # removed-and-stay-removed (seed skips)
  [plugins.sources]              # id = git url (or "local") — THE installed set
  [plugins.widgets]              # desktop-widget placement: "ns.name" = { x, y, layer, visible, output }
  [plugins.settings]             # "ns.name" = { key = value } — always written as whole tables

[sync]
  provider = "nextcloud"         # nextcloud | google (RFC-005; google only with personal client)
  server = "cloud.example.org"
  user = "me"
  folder = "ewe"
  enabled = true
  [sync.folders]                 # ewe-sync folder pairs: local, remote, mode (two-way|upload|download), trigger, interval
```

## Tool verbs

```
get <dotted.key>        value (JSON on stdout for structures)
set <dotted.key> <v>    value parsed as JSON, else string; then apply
dump                    whole file as JSON (one read for QML/Rust)
import                  build ewe.conf FROM the live runtime files (migration/repair)
apply [--only <domain>] regenerate artifacts + re-theme + poke shell + hyprctl reload
path                    print the canonical file path
push [--force]          upload to the account named in [sync] (If-Match guard)
pull [--out <path>]     download; keeps ewe.conf.<timestamp>.bak; then run apply
sync-status             remote copy + this machine's sync record
```

## Gotchas

- `apply` re-themes toolkits + pokes the shell + runs `hyprctl reload`
  **unless `--no-hooks`** (the shell passes it — it applies live itself).
- Writes are atomic (tmp + rename) with `flock`; key order stable → honest
  diffs.
- **Settings prefs MUST be in `THEME_MAP`** or `absorb` drops them (the
  0.12.7 bug).
- Secrets never here — a feature needing one gets redesigned (rule 2,
  [[Rules of the House]]).
- `ewe-conf effective_accent()` gives the scheme's accent to the border and
  the colorscheme hook; `Globals.schemeActive` stops the in-shell accent
  pick from overriding a scheme.

## Related

- [[The One File]] · [[Contracts and Public API]] · [[Storage Map]]
