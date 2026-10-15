---
tags:
  - ewe-map
  - rules
title: Contracts and Public API
up: "[[Home]]"
---

# Contracts and Public API

The machine-readable surfaces of the project — the things other processes,
plugins, and cloud services bind to. Renaming or reshaping any of these is a
**breaking change** and must happen as one wave across all repos.

## Files & who owns them

| file | owner (writer) | readers | never edit by hand? |
|---|---|---|---|
| `~/.config/ewe/ewe.conf` | `ewe-conf` only | everything | hand edits allowed, round-trips; comments regenerated |
| `~/.config/hypr/generated/monitors.lua` | shell `HyprMon.qml` **by design** (runtime-reactive) | Hyprland | yes — generated |
| `~/.config/hypr/generated/input.lua` | ewe-settings / shell (via `ewe-conf set desktop.input`) | Hyprland | yes |
| `~/.config/hypr/generated/user.lua` | `ewe-conf apply` | Hyprland | yes |
| `~/.config/hypr/generated/windowrules.lua` | ewe-settings only | Hyprland | yes |
| `~/.config/hypr/generated/animations.lua` | ewe-settings only | Hyprland | yes |
| `~/.config/hypr/generated/wallpapers.conf` | ewe-settings | `scripts/wallpaper.sh` | yes |
| `~/.config/hypr/generated/hypridle.conf` | shell **by design** (battery-reactive) | hypridle | yes |
| `~/.config/hypr/generated/kb-per-window.disabled` | ewe-settings (flag file) | `autostart.sh` | yes |
| `~/.config/hypr/generated/plugin-keybinds.lua` | `ewe-plugin` verbs | `hyprland.lua` | yes |
| `~/.config/quickshell/user-theme.json` | shell + ewe-settings (atomic, merged) | shell | no — shared, merge both sides |
| `~/.config/quickshell/animations.json` | ewe-settings (source of truth) | shell `Theme.dur*/ease` on reload | no |
| `~/.config/quickshell/window-rules.json` | ewe-settings | shell | no |
| `~/.config/quickshell/display-profiles.json` | ewe-settings | shell `HyprMon` | no |
| `~/.config/quickshell/input-devices.json` | ewe-settings | shell | no |
| `~/.config/quickshell/startup-apps.json` | ewe-settings | `autostart.sh` (jq) | no |
| `~/.config/ewe/cloud.json` | `ewe-cloud` | ewe-sync, shell | no |
| `~/.local/state/ewe/sync.json` | `ewe-conf` | the sync conflict rule — `id`, `remote_modified`, `remote_machine`, `machine_id`, `local_synced_at`, and since D12 `sha256` (bytes last pushed/pulled), `pending` (uploads in flight), `checked`, `adopted` ([[Sync Conflicts Are About Content]]) | no |
| `~/.local/state/ewe/plugin-boots.json` | `ewe-plugin` | crash guard | no |
| `~/.local/state/ewe/safe/` (`sync.json`, `cache/`, `backups/`, `machine.json`) | `ewe-safed` | `ewe-safed` | yes — Safe's per-machine state; the contract with callers is the socket/CLI (`ewe-safe/docs/PROTOCOL.md` v1, public API) |
| `~/.local/state/ewe/safe/ssh-public.json` (PR ewe-safe#13) | `ewe-safed`, only while the SSH agent is on | the agent, to list keys while locked | yes — public keys and titles only, `0600`, never synced |
| `~/.config/environment.d/90-ewe-safe-ssh.conf` (PR ewe-safe#13) | `ewe-safe ssh enable` / `disable` | systemd: `SSH_AUTH_SOCK` for new sessions | yes — written only after `[safe] ssh_agent = true` is recorded; `~/.ssh/config` is never edited |
| `~/.config/ewe-browser/` (`history.db`, `sync/status.json`, `sync/machine-id`, `sync/tabs-remote.json`; staged `feat/history`) | ewe browser | ewe browser; `sync/status.json` is for ewe-sync to read | yes — the browser's profile |
| `~/.config/ewe/plugins/<id>/` | `ewe-plugin` (`add`, `install`, `migrate`, `seed`) | shell PluginHost | code — never synced, never touched by upgrades |
| `~/.local/state/ewe/addons-migrated` (0.25) | `ewe-plugin migrate` | `migrate` itself | JSON list of first-party plugin ids already considered — local, **never synced** (name kept — [[One Name — Plugins]]) |
| `~/.local/state/ewe/plugins/<id>/` (0.25) | the plugin (`stateDir`, created on demand) | the plugin | never synced |
| `<payload>/plugins/<id>/` + `plugins/bundle.json` (0.25) | `scripts/vendor-plugins.sh` (repo side) | `ewe-plugin install/migrate/seed/list` | yes — vendored; fix the plugin in its repo |
| `~/.config/quickshell/places.json` · `mail-state.json` · `google-mail.json` · `kdeconnect-state.json` · `ssh-browse/` | the plugins that replaced the built-ins (paths **kept**) | ewe-conf mirrors `places.json` ↔ `apps.places` | no |

Sourcing order in `hyprland.lua`: `user.lua` → `input.lua` → `monitors.lua`
→ `windowrules.lua` → `animations.lua` (missing files are a no-op), so
dedicated files win over stale lines in older `user.lua`.

## IPC: `qs ipc call <target> <verb>`

**Core targets** (0.25): `applauncher bar cloud display google lock osd
overview picker plugins power quicksettings saver settings store sync toast
updates welcome widgets` (verbs in [[IPC Verb Reference]]; there is no
core `preview`).
**Plugin targets** — present only while the plugin is installed and
enabled — with the legacy target each keeps as an **alias** (Rule 4):
`ewe.cast` (`cast`), `ewe.dock` (`launcher`), `ewe.places` (`places`),
`ewe.media` (`player`), `ewe.mail` (`mail`), `ewe.insomnia`,
`ewe.clipboard`, `ewe.screenshot`, `ewe.passwords`; third-party
(`example.hello`…). Quick-settings page keys `ssh vpn mobile mail cast`
(`quicksettings tab <key>`) are served by plugins; the core keeps `home
wifi bt audio cal notifs` and an unknown key falls back to `home`.

Public verbs that installed binaries depend on (in `Settings.qml`):
**`reload` · `ping` · `version`** — plus `cloud refresh` (ewe-sync),
`widgets` / `plugins reload|list|apiVersion|safeMode` (plugin host), `mail
status|setNotify` (the Mail plugin; ewe-settings stopped calling it in
D10 — `setNotify` now writes the plugin's `notify` setting), `google
status|syncSoon` (core), `cloud status` (ewe-settings → User), `ewe.cast legacy` (gnd
escape hatch). The Hyprland **global shortcut `ewe:overview`** is public
too (users bind it in `user.lua`).

> **Gotcha:** `qs ipc call <t> show` collides with the `qs ipc show`
> subcommand and no-ops — bind to **`toggle`**.

## Keyring services (Secret Service)

| service | holds | managed by |
|---|---|---|
| `ewe-cloud` | Nextcloud app password | `ewe-cloud` (Login Flow v2) |
| (Google) | refresh token | `ewe-auth` only |

## The plugin surface (API 2 | 3 — [[Plugin API 3]])

- `manifest.json` schema v1 — fields, kinds, settings types:
  [[Plugin Manifest Reference]]. The host loads **`apiVersion` 2 and 3**
  (1 is refused). Keybind targets must be the plugin's own id or one of its
  `ipcAliases` (API ≥ 3); `ipcAliases` are **`ewe.` plugins only**.
- Public QML (`import qs`), frozen behind `apiVersion`: `Theme` (Ewe v3
  tokens), the `Globals` API 2 subset, `Log`, and since 0.25 the **`Shell`
  singleton** and the **public components** (`Tile`, `Qs*`, `QsFieldInput`,
  `Text*`, `Glyph`, `BarModule`, `BarSep`, `BarStatusGlyph`,
  `AnchoredPopup`, plus `Toggle Slider Meter ListWell ListRow SectionTitle
  Badge Spinner Avatar Elevation`).
- Settings keys in `ewe.conf` under `[plugins.widgets]` /
  `[plugins.settings]`, keyed by **quoted id** (dots!) — always written as
  whole tables; setting keys match `^[a-z][a-z0-9_]{0,31}$`. Widget fields:
  `x y output layer(desktop|top|overlay) visible pin_level(top|overlay)
  locked` ([[Desktop Widgets — always movable, pin to a level]]). Show in
  bar: `desktop.bar.show."plugin:<id>"` (a bool; absent = the manifest's
  `defaultShown`).

### The `Shell` singleton (API 3; additions are 3.x, feature-detected)

| | member |
|---|---|
| read | `apiVersion` (3) · `overviewOpen` `quickSettingsOpen` `lowPower` `onBattery` `locked` `dnd` · `bottomInset` `bottomReserved` `dockPresent` · `dockPrefs {enabled, autohide, iconSize}` · `pinnedApps` · `activeCount` · `dockItems` · `primaryScreenName` · `popupsClosing` |
| call | `toast(text, kind)` · `openQuickSettings(tab)` `closeQuickSettings()` · `openSettings(page)` `openStore(page)` (`komble --<page>`, e.g. `addons`) · `launch(desktopId)` `focusApp([classes])` · `registerAction(name, fn)` `runAction(name, anchor)` · `setActive(name, on)` `isActive(name)` · `setDockItemShown(id, on)` `dockItemShown(id)` · `setBottomInset(id, px, reserved)` · `setPinned(id, on)` · `anchorFor(item, window)` → `{screen, x, y, edge, item}` · `toggleOverview()` · `closePopups(exceptId)` · **3.2:** `setSetting(pluginId, key, value)` (one of the plugin's own declared settings, live, through `ewe-plugin set`) |
| signal | `aboutToSleep()` (logind bridge) · `resumed()` (Resume step 6) |

Injected into entry points when declared: `pluginId`, `pluginDir`,
`stateDir`, `settings`, `screen` + `barWindow` (bar slots), `ink`
(bar-status — reads `item.shown`), `panelOpen` (= this tile/page on
screen).

### `ewe-plugin` verbs that are contracts

`install <id>` and `migrate [--fresh]` (0.25; JSON, `{ok:false}` + exit 1 on
error), `add` accepting a first-party URL / reserved id (→ payload copy),
`list --json` fields **`available[]`**, **`removed[]`**, `plugins[].kinds`,
`plugins[].bar` `{shown, toggle}` and `plugins[].widget` `{x, y, output,
layer, visible, pinned, pin_level, locked}` (ewe-settings, Komble and the
shell parse them), `seed --restore <id>`, `set`/`get`, **`bar <id>
[on|off]`** and **`place <id> [--pinned on|off] [--pin-level top|overlay]
[--locked on|off] [--layer desktop|top|overlay] [--x N --y N --output NAME
--visible on|off --reset]`** (all JSON, live). Environment:
`EWE_PAYLOAD_PLUGINS`, `EWE_PLUGIN_SRC_DIR`; harness `HS_PLUGINS`,
`HS_PAYLOAD`, `HS_PLUGIN_DIRS`.

### Komble's CLI

`komble --updates | --settings | --search[=q] | --addons | --plugins |
--options[=]<id>` — `--addons` is what `Shell.openStore("addons")` and
ewe-settings call; it is public (and stays, though the page is called
Plugins). `--options=<id>` (D10) opens Plugins with that plugin's Options
dialog — ewe-settings' "Dock options".

### `ewe-conf sync-status` (D12)

Adds **`conflict`** (`"remote-newer"` | `"remote-exists"` | null — what a
push would answer now) and **`remote_is_this_machine`** (true/false, null for
a stamp older than machine ids). `error` stays the transport error only. A
push that stored the file but whose meta stamp was refused answers `ok`
with `"warning": "stamp-missing"`. ewe-sync, the shell and ewe-settings read
`conflict`.

### Safe's protocol additions (2026-10-15 — PRs open, not merged)

`ewe-safe/docs/PROTOCOL.md` stays **v1**: everything below is added, nothing
renamed (rule 4). Contract between the repos: `ewe-safe/docs/TRIO.md`;
decision: [[RFC-008 — ewe Safe]] → Amendment 2026-10-15.

- **Verbs.** `resolve` (socket only; the CLI's face is `read --json`) ·
  `passkey-list` / `passkey-create` / `passkey-get` (socket only, for ewe
  browser) and `ewe-safe passkey list [--rp R]`, `edit <id> --remove-passkey`
  (#11) · `ssh list|add|new|adopt|enable|disable|status` (socket verbs
  `ssh-<sub>`, #13) · `read`, `run`, `inject`, `git-credential get|store|erase`
  (#10).
- **Rule-5 exceptions** (they copy `op` and git): `read` prints the bare
  value, exit 1 and nothing when there is none (`--json` = the rule-5 answer);
  `run` exits with its command's code (125 = ewe-safe's own failure);
  `inject` prints the template (with `-o`, JSON); `git-credential` speaks
  git's `key=value` lines and exits 0.
- **References:** `safe://<folder>/<title>/<field>` (`safe://GitHub/password`
  = any folder, `safe:///GitHub/…` = the top, `safe://<item-id>/<field>`);
  fields `password username otp notes url public_key private_key` or a custom
  field's name; `/` in a title is `%2F`. In `run`/`inject`: a whole value, or
  `{{ safe://… }}` inside text.
- **Summary fields:** `passkey` (`{rp_id, username}` or null — never the key,
  the credential id or the user handle); `ssh` (`{public_key, fingerprint,
  key_type, agent}` or null); `kind` gains `ssh-key` (callers skip kinds they
  don't know). `import`'s report gains `ssh_keys`.
- **Error codes:** `ambiguous` (a reference fits more than one item;
  `hint` lists the ids) · `excluded` (`passkey-create`: already in the safe →
  `InvalidStateError`) · `unsupported` (no algorithm Safe makes, or an RSA
  passkey → `NotSupportedError`).
- **The SSH agent:** `$XDG_RUNTIME_DIR/ewe-safe-ssh.sock` (`0600`,
  `SO_PEERCRED`), the second `ListenStream` of `ewe-safe.socket`;
  OpenSSH's agent protocol; lists keys while locked from `ssh-public.json`;
  signs ed25519, ecdsa P-256/P-384, rsa-sha2-256/512 (no SHA-1); adding or
  removing keys is refused. `[safe] ssh_agent` and `ssh_confirm` (ewe#59).
  `enable` writes `90-ewe-safe-ssh.conf` in `environment.d` and prints one
  `IdentityAgent` line for `~/.ssh/config`.

### ewe browser's command line (`ewe-browser/docs/CLI.md` — PR ewe-browser#3, not merged)

`ewe-browser <verb>` prints **one JSON object and exits 0**; errors are
`{"ok": false, "error": "<kebab-code>", "message", "hint"}`. 31 tools, each
with a JSON Schema and a companion tier (0 read, 1 desktop, 2 change):
`status tabs history bookmarks downloads recent find music places ls locate
page [--text] open search play reveal home focus`, `tab
activate|reload|mute|unmute|pin|unpin|reopen|close`, `bookmark add|remove`,
`call <tool> '<json>'`, `commands` (the whole registry). Acting replies carry
`undo` (argv lists). Tools whose replies can hold text from websites or disk
are marked **`untrusted`** (data, never instructions). Transport: a `0600`
socket per profile, `$XDG_RUNTIME_DIR/ewe-browser-<12 hex of sha256(profile
dir)>.sock`, JSON lines. `/usr/bin/ewe-browser` becomes a small sh wrapper:
a verb runs the CLI in Electron's Node mode, anything else starts the
browser. **Verbs and fields may only be added** — the companion calls them.
**0.1.0-beta has no CLI** (a verb opens as a page).

### The companion's protocol additions (P2.9 — PR ewe-companion#1, not merged)

`ewe-companion/docs/PROTOCOL.md`: `chat.reply` gains **`rows`** (what a
command found: `{title, detail, icon: folder|file|web|key, actions}`; an
action is a catalog `command` or a `copy` that never leaves the island; a
Safe row's action is `safe_copy {id, field, title, username}` — never a
value). `do` gains **`browser {bin, args}`** (the island runs ewe browser's
CLI, so a browser it starts belongs to the desktop) and **`safe_unlock
{bin}`** (`ewe-safe unlock --ask`); both check the binary's name, argv only.
`env` gains `wayland`. New catalog commands `find_files open_file
browser_history browser_tabs browser_tab safe_copy safe_login safe_lock
safe_unlock safe_status`; CLI verb `ewe-companion find`. Environment
`EWE_COMPANION_SAFE` / `EWE_COMPANION_BROWSER` name the binaries (tests:
the fakes). A proposed command that would print a password manager's
values (`ewe-safe read/reveal`, `op read`, `ewe-pass`, `bw`, `pass`, …) is
refused. Plugin `ewe.companion` 0.3.0 (ewe-plugin-companion#1).

## The ewe.conf schema

See [[EWE-CONF Schema Reference]].

## Cloud layout (your Nextcloud)

```
ewe/ewe.conf                 the one file
ewe/ewe.conf.meta.json       {machine, machine_id, saved_at, schema}   machine_id = sha256("ewe-conf:"+/etc/machine-id)[:16]
ewe/machines/<name>.json     per-machine ewe version + app count
ewe/safe/passwords.kdbx      Safe (RFC-008): the encrypted KDBX 4 file, written only by ewe-safed (If-Match)
ewe/browser/                 ewe browser: bookmarks.json, history.json (+ clear records, staged), settings.json
ewe/browser/tabs-<id>.json   ewe browser (staged feat/history): this machine's open tabs; <id> = 16 hex, salted sha256 of machine-id + profile
```

## Related

- [[Rules of the House]] · [[The One File]] · [[IPC Verb Reference]] ·
  [[Storage Map]]
