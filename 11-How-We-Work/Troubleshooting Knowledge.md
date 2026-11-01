---
tags:
  - ewe-map
  - how-we-work
title: Troubleshooting Knowledge
up: "[[Home]]"
---

# Troubleshooting Knowledge — known failure classes

Distilled from `ewe/docs/TROUBLESHOOTING.md` and the project's history.
**Before debugging anything new, scan this list** — most hard bugs here are
repeats.

## Cast to TV (the 2026-08-21 investigation — in the order it bit)

1. **Frozen picture / TV drops ~10 s after connect.** `xdg-desktop-portal-hyprland`
   1.4.1 screencopy retry bug (`Out of buffers` → `Retrying screencopy` →
   `tried scheduling on already scheduled cb` → never asks again). ewe ships
   a patched build from `packages/patched/`: first **1.4.1-1.1**, then —
   after Arch's stock **`1.4.1-2` replaced it and the freeze came back
   (2026-09)** — **`1.4.1-2.1`**, which is the threshold now (`vercmp` in
   phase 90; ewe-cast 0.12.3). Check: `pacman -Q xdg-desktop-portal-hyprland`
   (must be ≥ 1.4.1-2.1) +
   `journalctl --user -u xdg-desktop-portal-hyprland | grep -c "Out of buffers"`.
   Measured: stock delivered 7 frames then froze; patched ran indefinitely.
2. **Lag/stutter.** Software x264 → install `gst-plugin-va` (`vah264enc`);
   or Wi-Fi Direct sharing a crowded 2.4 GHz channel; or no regulatory
   domain (`iw reg get` → `country 00` makes 5 GHz receive-only) — phase 30
   installs `wireless-regdb` + GeoIP country.
3. **TV drops after ~3.5 min (working stream).** Wi-Fi power saving on the
   group owner — dispatcher `50-ewe-cast-powersave` turns power_save off
   while any `p2p-*` is up. Live check: `iw dev wlan0 get power_save`.
4. **No sound on TV.** The null sink was made but audio wasn't moved —
   `hypr/scripts/cast-audio.sh` makes it default while casting. Check
   `pactl get-default-sink`.
5. **"Connection failed" with nothing else.** Read the journal: the shell
   narrates NM + wpa_supplicant into toasts; raw:
   `journalctl -f -u NetworkManager -u wpa_supplicant`; app trace:
   `~/.local/state/ewe/cast.log`. `supplicant-timeout` with no GO-negotiation
   = the TV wasn't listening (open Source → Screen Mirroring first).

**The preflight checks all of the above and prints the fix for each.** Since
0.25 it lives with the [[Cast Plugin]]: `sh
~/.config/ewe/plugins/ewe.cast/cast-check.sh` (the old
`~/.config/hypr/scripts/cast-check.sh` is gone — `ewe-diag`'s `diag.sh`
must point at the new path). The `cast` IPC target is an alias of
`ewe.cast`; `qs ipc call ewe.cast legacy` is the gnd door.

## Sign-in / keyring

- **No keyring prompt, "keyring not showing up"** — the account credential
  (Nextcloud app password / Google refresh token) lives in the Secret
  Service keyring; a missing gnome-keyring or an unlocked-at-boot problem is
  the usual cause. Boot-race safe probes retry with backoff (the keyring
  may come up after the shell). Keyring playbook: `ewe-auth keyring-reset`.

## Settings sync

- **"Another machine ("<this machine's name>") saved newer settings", and
  no push ever succeeds** (the home laptop, 2026-09-13 → 10-10) — an upload
  the server stored but whose reply was lost (lid closed mid-push; the
  display `lastKey` changes on every dock/undock, so auto-push runs often),
  or whose meta stamp PUT failed, left `~/.local/state/ewe/sync.json` on the
  old ETag: every later push = `remote-newer`, forever. Check: `ewe-conf
  sync-status` (`in_sync: false` while `remote_modified ==
  recorded_remote_modified`) and compare the record's `id` with
  `remote.etag`. Fixed in ewe-conf (D12 —
  [[Sync Conflicts Are About Content]]): bytes this machine sent/saw are adopted, a stored upload is
  recorded. A machine stuck from BEFORE the fix has no hashes on record:
  ewe-sync → This machine → **Push anyway** (or Restore) once.
- **ewe-sync shows no Push anyway / Restore** — pre-fix ewe-sync keyed the
  banner on `sync-status`'s `error`, which never carries a conflict. Now
  `conflict`. Same for the tray's conflict state.
- **Two machines with one hostname** — the stamp said `emoh` for both and
  `machines/<name>.json` is shared. Since D12 the stamp carries a hashed
  `machine_id` (`remote_is_this_machine`); still give each machine its own
  hostname.
- **The Nextcloud desktop client syncs `~/Nextcloud/ewe` too** — a
  same-bytes re-upload moves the ETag; adopted since D12 (different bytes
  stay a conflict). Don't edit `~/Nextcloud/ewe/ewe.conf` by hand.

## Settings

- **"Top bar settings do nothing" (0.12.7)** — prefs the Settings app
  writes MUST be in ewe-conf's `THEME_MAP`, or `absorb` drops them on the
  next write. When adding a setting: add it to `THEME_MAP` in the same
  change.
- **A change vanished** — you edited a `generated/` file; it's a build
  artifact. Change the source (`ewe.conf`), then `apply`.

- **"The shell isn't running" in Settings while it is** — `shell_running`
  was asked once, at open; a shell restart then (login, update, plugin
  install) left the note up for the window's life. Since 2026-10-10:
  re-asked on focus + every 10 s, two misses before it shows, 3 s timeout,
  a failed `--pid` call retried by config path. The User pane flipped to
  "isn't running" on ANY unreadable reply too (stderr was appended to
  `qs_ipc` replies) — now stdout only, last good status kept.
- **Glass looked "weird"** (2026-10-10,
  [[Glass — the slider moves the bar only]]): Overview chips / widget cards followed the bar slider (80 % with
  Glass off, invisible at 25), the dock's shadow showed through its pill,
  `xray` blurred the wallpaper instead of the window behind, Glass blurred
  every translucent window, Window transparency's live eval turned windows
  solid under App blur, and Reduce transparency silently overrode the
  controls. All fixed; see the decision.

## Plugins (0.25)

- **"My dock / clipboard / Cast tile is gone" on a fresh install** — not a
  bug: nothing in the payload is installed on a fresh machine
  ([[Add-ons — opt-in, not preinstalled]]). Komble → Plugins, the Welcome
  Plugins step, or `ewe-plugin install <id>`. On an **upgrade** the features
  the user had are installed once by `ewe-plugin migrate`
  (`~/.local/state/ewe/addons-migrated`); the dock is skipped only when
  `[desktop.dock] enabled = false`, and anything in `[plugins].removed` stays
  out.
- **Re-adding a removed first-party plugin with `ewe-plugin add
  https://github.com/prj786/ewe-plugin-<x>.git` failed** (reserved `ewe.`
  id) — since 0.25 that URL/id installs the payload copy; the honest
  command is `ewe-plugin install <id>`.
- **Every first-party plugin INVALID — "the "ewe." namespace is reserved for
  ewe's own (bundled) plugins" — and no switch turns one on** (0.25.0–0.25.1,
  2026-10-11). `[plugins.sources]` had lost its `"ewe.<x>" = "bundled"`
  records: a Restore from the account (`ewe-conf pull` — look for
  `~/.config/ewe/ewe.conf.<stamp>.bak`, only a pull writes one) or a file
  synced from another machine. The check trusted only that synced table.
  Fixed in **0.25.2-beta**: an installed copy of an id the payload ships is
  first-party (`payload_ships`); `enable` / `seed` write the records back.
  On an older ewe, `ewe-plugin install <id>` re-records one. A Restore also
  brings back that copy's `[plugins].enabled`, so plugins come back **off**.
- **`seed --restore <id>` silently seeded nothing** (pre-0.25) —
  `PAYLOAD_PLUGINS` didn't resolve; now realpath with fallbacks
  (`/usr/share/ewe/plugins`, `~/.local/share/ewe/plugins`).
- **A plugin's legacy IPC target / QS key / layer namespace stopped
  working** — the plugin is not installed or not enabled (`ewe-plugin
  list`); when installed, `cast launcher places player mail` and
  `quicksettings tab ssh|vpn|mobile|mail|cast` behave exactly as before.
  ewe-settings treats a missing `mail` target as "plugin absent", not an
  error.
- **Komble shows no Plugins group** — the shell's `ewe-plugin list --json`
  has no `available` key = an ewe older than 0.25.
- **A tile won't hide** — hide the host slot (`parent.visible`), never
  `Tile.visible`; the home grid collapses empty slots.
- **A `dock-item` shows nothing** — no dock installed: the item simply has
  no host (by design, not an error). With the dock: check
  `Shell.dockItemShown(id)` (the Music plugin hides its own button).
- **`kdeconnectd` appeared as a new device on the network during a test
  run** — D-Bus **auto-activation starts it on ANY proxy call**. A harness
  needs `EWE_PHONE_NO_DAEMON=1` **and** a private bus (`HS_PRIVATE_BUS=1`).

- **Komble → Options seemed to do nothing** — the first-party plugins'
  form opened under the WHOLE card grid, off-screen. It is a Dialog now
  (D10).
- **A setting a plugin moved out of ewe-settings came back reset** — it
  must declare `legacy: "<old.ewe.conf.key>"` (first-party only); the
  old value then stands until the user sets the new one.
- **`ewe-plugin bar <id> off` refused** — the plugin's manifest says
  `toggle: false` (Music, Places: their `button` setting places them).
- **`Super+P` says "make sure 1Password CLI is installed"** (the owner's
  machine, 2026-10-15) — the Passwords plugin's `provider` is still
  `1password`. `ewe-plugin set ewe.passwords provider ewe` (or `auto`).
  Since ewe 0.28.0-beta, Passwords 1.3.0 offers **Use Safe** in that error
  row.
- **`ewe-conf set 'plugins.settings."ewe.passwords".provider' ewe` wrote a
  stray `[plugins.settings."\"ewe"]` table** and left the setting alone —
  ewe-conf split a quoted key on every dot (fixed in ewe 0.28.0-beta,
  ewe#58; it now refuses a broken key with `bad-key`). Change a plugin setting with
  `ewe-plugin set <id> <key> <value>`; it also checks the schema.
- **The Passwords plugin's `test.sh` answered from the real 1Password** —
  never: it runs on a PATH of fakes only (`op`, `wtype`, `hyprctl`,
  `ewe-conf`, `ewe-safe`). A new provider test must keep a fake on that PATH
  and check the real binary is *not* found.

## Shell / QML

- **Lid-open blinks 3–4× before the password field** (fixed 2026-10-04,
  0.25 — [[Quiet Lid — touch only a disabled panel]]). Four stacked causes:
  an unconditional `after_sleep_cmd` dpms-on (hypridle.conf, the
  Settings.qml generator **and** ewe-settings `hypr.js`), `Lid._open`
  sending `preferred/auto` + dpms to every output, `HyprMon._reassertT`
  re-applying the whole set, and the Lock surface's `sourceSize` bound to
  the surface. Rule: never `hl.monitor` for an output that already matches
  (`verifyOne` per output in `applyMatching`; `force` = Reset only); never an
  unconditional dpms-on except Reset displays.
- **Machine re-sleeps 0.1–0.7 s after a hibernate resume** — a stale
  `HyprMon.lidClosed` plus Qt timers elapsing through the hibernate
  transition. Every sleep decision re-reads
  `/proc/acpi/button/lid/*/state` (`HyprMon.probeLid()`); `Lid` logs `lid:
  going to sleep: <reason>` at WARN — look for that line first.
- **Every lid-close suspend waits the full delay** — the logind bridge
  called `readline()` once per wakeup; buffered `os.read` now
  (`tests/logind-bridge-test.py`, 17 checks).
- **Overview: keys die / the wrong output takes the keyboard** — per-screen
  layer windows must not all request keyboard focus (last-mapped wins):
  `Exclusive` only on the field's window while open, `None` otherwise; keys
  die without an `activeFocusItem` → root `FocusScope` `focus: true` +
  `Keys.onPressed` fallback.
- **A Hyprland `global` shortcut fires twice / never** — Hyprland 0.56
  signal matrix: a *release* bind → `released` only; a *press* bind →
  `pressed` + `released`; a `dispatch` → `pressed` only. Toggle on
  `released`. `ewe:overview` is a release bind on Super.
- **A touchpad gesture does nothing, and Hyprland says nothing** (ewe
  0.30.0-beta, the 4-finger swipe) — Hyprland's Lua `hl.gesture` accepts
  **any** `direction` string when the config loads: no validation, no
  `configerrors`, so a typo (`"lft"`) is a gesture that never fires. Use
  only the documented words (`left`, `right`, `up`, `down`, `horizontal`,
  `vertical` …), and check on a real touchpad: the nested harness has
  none. A gesture whose action depends on the focused window
  (`hl.get_active_window().class == "ewe-browser"`) also does nothing
  elsewhere, by design ([[Four Fingers — ewe browser's workspaces]]).
- **A `Loader` whose `visible` binds to `item.visible`** — effective-
  visibility cycle (the item is invisible because the Loader is, because
  the item is …). Drive visibility from state, not from the child.
- **Reading an attached property (`QsWindow.window`) from another object**
  returns nothing — attached properties live on the attachee; pass the
  window explicitly (`Shell.anchorFor(item, window)`).
- **`AnchoredPopup` opened over the bar** — a top-edge card must clear the
  bar (fixed by B1); a bottom-edge one clears `Shell.bottomInset`.
- **`pgrep -f <pattern>` matches itself** when run inside `sh -c` (the
  wrapper's command line contains the pattern) — use `pgrep -x` or anchor
  the pattern; same family as the clipboard guard bug below. **`pkill -f
  <pattern>` from an agent's Bash tool kills the calling shell** when the
  pattern is in its own command line.
- **`hyprctl` with no `HYPRLAND_INSTANCE_SIGNATURE` errors out** — so
  `env -u HYPRLAND_INSTANCE_SIGNATURE` is a real guard against touching the
  live compositor, not a cosmetic one.
- **The whole shell vanishes at random, Hyprland keeps running** (0.23–0.24,
  fixed 0.24.1-beta). Journal: `wl_display#1: error 0: invalid object N` →
  `The Wayland connection experienced a fatal error: Invalid argument` →
  `ewe.service: … status=255`. Hyprland 0.56 bug: `captureToplevel()` returns
  without creating the frame when the window closed that instant, and qs's
  later `frame.destroy()` names an id the server never had. Trigger = a live
  toplevel `ScreencopyView` (the Overview cards). Fix: cards capture only
  while the Overview is mapped, ✕ drops the capture before closing, and
  `qs-launch.sh` turns "255 after ≥ 15 s with Hyprland still answering" into
  exit 1 so the unit restarts it. Still racy by design while the Overview is
  open → the restart is the safety net. Repro: nested harness, open kitty
  windows, Overview open, `pkill` them → dead in round 1 (`WAYLAND_DEBUG=client`
  shows the id). Never capture toplevels in a hidden surface.
- **`qs` dies on `up`** — read `driver.sh log`; QML errors name file:line.
  Ignore benign "already registered" D-Bus / PolkitAgent /
  "hyprland-guiutils not installed" warnings (nesting artifacts).
- **Surface didn't open** — a ~15 KB driver shot = bar only; a real window
  is ~40–57 KB.
- **`onAccent:` parses as a signal handler** beside a property called
  `accent` — declare the token bare and fill it with a `Binding`.
- **Plugin widget renders nothing** — inside a `Scope` use `Variants`,
  never `Repeater` (needs an Item parent, silently creates nothing).
- **`qs ipc call <t> show` no-ops** — collides with the `qs ipc show`
  subcommand; bind `toggle`.
- **Shell aborts at start with "pure virtual method called"** (2026-09-20)
  — Quickshell 0.3.1's icon loader on its image thread, when a themed icon
  misses (`QIcon::pixmap → QPlatformPixmap::fromFile`). Intermittent (≈1 in
  3) in the driver's sandbox until it linked the live `qt6ct` (icon theme);
  a machine with a broken icon theme would see it too. Not the polkit
  warning that happens to precede it.
- **Never destroy a refused `PolkitAgent`** — a Loader flip on a failed
  registration also crashes 0.3.1; `Auth.qml` parks refused agents and caps
  the retries.
- **"Plugins disabled for this session" after a few manual restarts** —
  the crash guard used to count every start; since 2026-09-20 `ewe-plugin
  list --boot` counts only starts that follow a Quickshell crash report or
  a systemd automatic restart (`NRestarts` resets on `systemctl restart`).
- **Clipboard history records nothing** — the `wl-paste --watch` guard was
  `pgrep -f "wl-paste …"`, which matched its own `sh -c` wrapper; the
  pattern must be anchored (`^wl-paste`). Plugin ewe.clipboard ≥ 1.1.1.
- **Low-battery warnings / hibernate never fire** — Quickshell's
  `UPowerDevice.percentage` is a 0–1 fraction; `Battery.qml` refused every
  reading as "ambiguous" until 2026-09-20.
- **Settings app: Glass / bar opacity / corners / accessibility persist but
  the desktop does not repaint** — `set_conf` wrote with `--no-hooks` and
  never poked the shell; it now sends `settings reload` + `hyprctl reload`.
- **`nmcli` state strings** — device states carry a parenthetical
  (`connecting (getting IP configuration)`, `connected (externally)`): match
  the word, never the whole string. `nmcli -t` escapes `:` and `\` in
  values (SSIDs): unescape after splitting.
- **`Behavior on y` animates the map** — an item whose `y` depends on
  `parent.height` inside a lazily-mapped `PanelWindow` slides across hundreds
  of pixels the first time the window maps. Put the motion on a
  `transform: Translate`, or drop it. Bit `LauncherPanel.qml`, `Places.qml`,
  `AppStore.qml` and `Launcher.qml`.
- **A surface's backdrop image arrives late** — `sourceSize` bound to a
  `PanelWindow`'s `width`/`height` re-keys Qt's pixmap cache on every map and
  re-decodes. Bind it to `screen.width`/`height` and warm it in
  `Wallpaper.qml`.
- **Never put a state-dependent duration (`cond ? a : b`) inside a Behavior's
  animation** — the Behavior fires before the binding re-evaluates and plays
  the other direction's value. Sequence with an explicit flag + Timer.
- **X11 apps (Steam, Java/ProjectLibre) huge on a 1x external** — X11 has
  one scale for all screens. `start-hyprland.sh` decides it at login: it used
  the PRIMARY display of the `lastKey` profile, and `lastKey` only moves when
  Settings → Displays saves, so a docked login sized X11 for the 1.8x laptop.
  Since 2026-10-04 it reads the connected set from `/sys/class/drm`, picks
  that set's profile and takes the SMALLEST lit scale (soft on the laptop,
  right size everywhere). Check with `env | grep -E 'GDK_SCALE|STEAM_FORCE|EWE_X11'`
  and `hyprctl getoption xwayland:force_zero_scaling`. Docking after login still
  needs a re-login. Test: `tests/x11-scale-test.sh`.
- **Java/Swing apps with jagged text** — outside GNOME the JDK gets no font
  hints, so Swing draws un-antialiased. Fix per app with
  `-Dawt.useSystemAAFontSettings=on` (ProjectLibre: `JAVA_OPTS` in
  `~/.projectlibre/run.conf`). Not exported globally on purpose:
  `JDK_JAVA_OPTIONS`/`_JAVA_OPTIONS` print a "Picked up" line on every `java` run.

- **A layer window's `mask: Region { regions: [] }` is CLICK-THROUGH** —
  Quickshell sets `WindowTransparentForInput` for an empty region. Arrange
  mode used it while it wanted every click: the drag, the chips and Esc
  never arrived (until 2026-10-10). Use the union of the items that take
  input.
- **A drag assigns `x`/`y` and breaks their binding** — re-bind
  (`Qt.binding`) after persisting, or later placement changes never show.
- **`property var settings` already has a `settingsChanged` signal** —
  declaring `signal settingsChanged()` beside it is a duplicate-signal
  error.

## The nested harness (`run-ewe/driver.sh`) and agent tooling

- **A PR merged on a red CI run** (Safe 0.1.0-beta, 2026-10-15): `gh pr
  checks --watch … | tail && gh pr merge …` — the pipe's exit status is
  `tail`'s, so the merge ran after a failed check. Poll until nothing is
  `pending`, then merge only if every check says `pass`.
- **A release build fails: "install file … does not exist"**: `makepkg`
  reads `install=` from beside the PKGBUILD, not from `packaging/`. Test a
  release by running its workflow's steps locally (`git archive` the source,
  `makepkg -d --skipchecksums`) from a clean folder — a build in a folder
  where someone copied the file proves nothing.
- **"Disk quota exceeded" mid-build**: the session scratchpad lives in the
  16 GB `/tmp` tmpfs; release builds of a Rust + Tauri tree take ~2.5 GB each.
  Delete old build folders first. A Unix socket path over 108 bytes (deep
  scratchpad sandboxes) fails with SUN_LEN: give `XDG_RUNTIME_DIR` a short
  symlink.

- **A window rule "does nothing" in the harness**: the nested compositor
  runs `hypr-min.lua`, not `hyprland.lua` — no window rules at all. Apply
  the rule live with `driver.sh hc eval 'hl.window_rule({…})'`, spawn the
  window through a small launcher script (`spawn` splits quoted
  arguments), and read `hc -j clients` after ~3 s: kitty maps at its own
  size first. The nested output is only ~792×474, so a big floater clamps
  to it (2026-10-14, Safe's unlock prompt).

- **`ewe-plugin … --no-restart` still touched the LIVE Hyprland** — the
  keybind writer runs `hyprctl reload` against
  `$HYPRLAND_INSTANCE_SIGNATURE`, and `set`/`place` poke `qs ipc plugins
  reload` on `$WAYLAND_DISPLAY`; the driver's install step inherited the
  host's values (2026-10-04: `HS_PLUGINS=1` reloaded the real session — no
  persistent change, but a live touch). The driver now runs every tool call
  as `env -u HYPRLAND_INSTANCE_SIGNATURE -u WAYLAND_DISPLAY ewe-plugin …`.
  **Rule for any wrapper: unset both before calling `ewe-plugin`.**
- **`ewe-plugin set/place` reloads nothing in the harness** — `qs` matches
  `plugins reload` by config path, so the poke never reaches `qs -p
  <checkout>`; use `driver.sh ipc plugins reload`. With the host display
  set it hits the live shell instead.
- **`HS_PLUGIN_DIRS` refuses `ewe.*` ids** (reserved) and the driver forces
  `EWE_PAYLOAD_PLUGINS=$REPO/plugins` — to test a first-party plugin from
  its repo, copy it into a private payload dir and use
  `HS_PAYLOAD=<dir> HS_PLUGINS=1` (or an `EWE_PLUGIN_TOOL` wrapper).
- **Two headless outputs must not share a position** — `HS_HEADLESS` puts
  SHOT at `1920x0`; a second headless output goes to `3840x0` or the shots
  overlap.
- **`wtype` cannot trigger binds in the nested compositor** unless
  `input:resolve_binds_by_sym = true`; a Super *tap* is `wtype -M logo -k
  Super_L -m logo`.
- **Headless screenshots of the Tauri UIs on this box** — Brave
  `--headless=new` hangs; the chrome-devtools MCP wants
  `/opt/google/chrome`. What works: **Helium** `--headless=new
  --ozone-platform=headless --virtual-time-budget=6000`, or a WebKit shot
  under a headless cage: `env -u WAYLAND_DISPLAY -u DISPLAY
  WLR_BACKENDS=headless WLR_LIBINPUT_NO_DEVICES=1 cage -- python3
  webkit-shot.py URL out.png` (WebKit2 GI; broadway is unusable for WebKit).
  ewe-settings' mocks are inline in `dev-mock.html`
  (`?addons=fresh|dock|legacy`, `?komble=0`).

- **`$(curl …)` drops the trailing newline** — a test that re-uploads "the
  same bytes" that way uploads different bytes. Use `curl -o file` +
  `--data-binary @file`.
- **`tests/ewe-conf-roundtrip.sh` fails on `user.lua` after a generator
  change** — its golden is THIS machine's live `generated/user.lua`, written
  by the installed (older) ewe-conf. Expected until the new build is
  deployed; run with `EWE_TEST_GEN=/nonexistent EWE_TEST_QS=/nonexistent`
  to check everything else.
- **No pointer injection in the harness** (`/dev/uinput` is root-only, no
  ydotool) — drive pin/lock/place through `ewe-plugin place` + `driver.sh
  ipc plugins reload`; move the pointer with `driver.sh hc dispatch
  'hl.dsp.cursor.move({ x = X, y = Y })'` (SHOT starts at x = 1920).
- **`pkill -f vite…` killed the calling shell** — the pattern was in its own
  command line; anchor it (`pkill -f "[v]ite --port N"`). The same for
  `pgrep -f`: it matches your own shell. Better: find the PID and check
  `readlink /proc/PID/exe` (the companion's `tests/island.sh down` does).
- **Headless Electron (castlabs) crashes with `--ozone-platform=headless`.**
  For a Playwright check of a page (the Safe window's dev mock, 2026-10-15),
  open a hidden window instead (`show: false`).

## Installer

- **`sudo /usr/share/ewe/install.sh` exits 2** — on purpose
  (`install.sh:38-50`): under sudo `$HOME` is `/root`, the desktop would
  install into root's home and the session entry would point there, so
  login dies silently. Run `bash /usr/share/ewe/install.sh --no-packages` as
  your user; it escalates itself where root is needed.
- **A single missing package must never abort the run** — installers
  warn-and-skip and return 0 (this was the root cause of a past "no
  greeter" failure). Don't regress `lib/pkg.sh`.
- **A plugin must never abort the ISO install** (ewe-os 0.13.0-beta) —
  the helper's `addons` verb and `ewe-install`'s `install_addons` report
  `!! add-on <id>: why` / `{"addon":id,"ok":false}` and exit 0; only a
  malformed id list or an unmounted target is an error.
- **Plugins in the target chroot** — run `ewe-plugin install <id>
  --no-restart` **as the new user** (`arch-chroot … runuser -u $u -- env -u
  HYPRLAND_INSTANCE_SIGNATURE -u WAYLAND_DISPLAY -u DBUS_SESSION_BUS_ADDRESS`):
  `--no-restart` keeps the tool away from `systemctl --user`, and the
  keybind writer only runs `hyprctl reload` when the signature is set.
  Prefer the copy `ewe-setup` just deployed (`~/.local/share/ewe/bin/
  ewe-plugin`) over `/usr/bin`'s. `ewe-setup` on a fresh home already ran
  `migrate --fresh` (marker = all ids considered, nothing installed), so
  installing picks afterwards migrates nothing — proven in a sandbox
  (`EWE_INSTALL_LIB=1 . ewe-install` sources only the functions; override
  `chroot_user`/`chroot_root`, set **`EWE_INSTALL_MNT`** — the script
  derives `MNT` from it, a plain `MNT=` export is overwritten).
- **The live ISO has no dock since ewe 0.25 unless `ewe-live-deploy`
  installs it** — a fresh account has no plugins; the live user gets
  `ewe.dock` (only that) so the pinned *Install ewe* has a surface. The
  installer also autostarts (`apps.startup`) and is first in the launcher
  (`apps.pinned` is still read by the core Launcher).
- **Everything through `run()`/`sudo_run()`** — direct `cp`/`ln`/`pacman`/
  `systemctl` in a phase breaks `--dry-run` honesty.
- **Hyprland config silently ignored** — Hyprland < 0.55 ignores Lua
  config (`VERSIONS` documents the floor).
- **Screen sharing / file pickers / app handoff silently fail** — the
  `hyprland-session.target` user unit (`BindsTo=graphical-session.target`)
  is missing or not enabled; it's what activates `xdg-desktop-portal` on a
  non-uwsm session. It is "the single most important step" of the install
  (MANUAL.md).

- **Blue text flashes on tty1 while the greeter loads and again right
  after login** (2026-09-20) — greetd hands the greeter its VT as stdio and
  cage runs wlroots at INFO, whose lines are bold blue on a tty. The
  `ewe-greeter` wrapper (phase 30) now clears the VT and logs to
  `$XDG_CACHE_HOME/greeter.log` (`/tmp/ewe-greeter/`). Before 0.25 a
  packaged install got the new wrapper only when `install.sh` (the system
  side) was re-run; **since 0.25 `pacman -Syu` refreshes the greeter wrapper
  (shipped as `system/greeter/ewe-greeter`), `shell.qml` and
  `theme-tokens.json` via the package's `post_upgrade`** where phase 30 had
  run before. Fonts, greetd `config.toml` and PAM still need `install.sh`
  (as the user, `--no-packages`). `uninstall.sh` never removes
  `/usr/local/bin/ewe-greeter` (open).
- **Anything with the old `#0a84ff` blue is stale** — the v3 default accent
  is `#eeb407`; `colorscheme.sh`'s fallback, `ewe-setup`, phase 60,
  kitty.conf and ewe-os's `os-release ANSI_COLOR` were updated 2026-09-20.

## VPN

- **"Only the VPN works" — no internet on home Wi-Fi without it.** DNS, not
  routing: `/etc/resolv.conf` was a plain file and Tailscale (MagicDNS)
  rewrote it to `nameserver 100.100.100.100`; resolved was disabled. Check
  `ls -l /etc/resolv.conf` (must → `/run/systemd/resolve/stub-resolv.conf`)
  and `resolvectl status`. Phase 30 (0.24.1-beta) enables resolved, drops
  `/etc/NetworkManager/conf.d/10-ewe-dns.conf` (`dns=systemd-resolved`) and
  relinks resolv.conf; phase 90 checks it.
- **Every L2TP profile fails with "The VPN service failed to start"** —
  strongSwan 6.1 (as Arch ships it) no longer speaks IKEv1, and L2TP/IPsec
  *is* IKEv1. The installer ships libreswan with `ikev1-policy=accept`;
  re-run `install.sh` (or `--check-only` to look) to swap the backend.
  See [[Phone and VPN]].

## The companion (RFC-007, 2026-10-14)

- **The notch looks darker or greyer than the bar** (Glass on). Its blur
  rule lacks `xray`: the notch shows the window under it through the
  translucent ground, the bar shows the wallpaper. `ewe.companion` ≥ the
  2026-10-17 fix adds `xray = true` (`Service.applyBlur`). Measure, do not
  eyeball: a light window under the notch, then compare the bar's pixel with
  the notch's in a shot. The nested harness has no `user.lua`, so give the
  bar its blur by hand first (`driver.sh hc eval 'hl.layer_rule({ name =
  "ewe-bar-blur", match = { namespace = "^quickshell:(bar|dock)$" }, blur =
  true, ignore_alpha = 0.05 })'`). Re-registering a named layer rule without
  a field keeps the old value: restart the nested Hyprland to compare.
- **A 1-px line across the top of the notch** (darker in light mode,
  lighter in dark): a half-covered row of the notch's fill over the bar gets
  the whole xray blur under it. The fill is clipped at the bar's edge (a
  scissor, whole pixels); keep that clip.
- **`tests/island.sh restart` keeps the old daemon** after a rebuild
  (before 2026-10-17): the old process's exe link ends in " (deleted)", so
  the binary check missed it. Fixed in `daemon_pid`; on an old checkout,
  find the PID (`pgrep -x ewe-companiond`, check `readlink /proc/PID/exe`
  and its `EWE_COMPANION_SOCK`) and stop it.

- **No permission card ever appears.** Check the session's permission mode:
  in `bypassPermissions` (the owner's `defaultMode` on the dev machine)
  Claude fires no `PermissionRequest` at all. Questions, finished peeks and
  sessions still work. `claude --permission-mode default` or Shift+Tab.
- **A card shows, but Claude asks in the terminal anyway.** The island did
  not ack within 800 ms (`journalctl --user -u ewe-companion`: `no ack from
  the island`). Usually the overlay failed to compile: `driver.sh log` or
  the shell journal shows `ewe.companion/overlay: … Type … unavailable`.
- **The island is missing from the bar.** Its `screen` setting names an
  output that is not there: it falls back to the first screen since
  2026-10-14. In the nested harness with `HS_HEADLESS=1` the output is
  `SHOT`.
- **`bind …: path must be shorter than SUN_LEN`.** A Unix socket path is at
  most 108 bytes; put test sockets in `$XDG_RUNTIME_DIR`
  (`EWE_COMPANION_SOCK=$XDG_RUNTIME_DIR/ewe-companion-smoke.sock`).
- **Jump to terminal focuses nothing.** Hyprland 0.56 only takes
  `hl.dsp.focus({ window = "address:…" })` (the old `focuswindow pid:` is
  rejected). The daemon uses the signature the island sends in `env`. For
  the exact kitty tab, `$KITTY_LISTEN_ON` must be set in the agent's shell
  (ewe's `kitty.conf` from 2026-10-14).
- **The notch looks like clear glass.** With Glass on (`bar_opacity` < 100)
  ewe blurs only `^quickshell:(bar|dock)$`; the plugin adds
  `ewe-companion-blur` for `quickshell:companion` through `hyprctl eval` at
  load and after each `configreloaded`. With `EWE_NO_BLUR=1` it adds none.
- **The chat answers "pick a provider".** The question was not about ewe
  (ewe questions are answered from the built-in knowledge pack with no
  provider). Komble → Plugins → Companion → Options → *Who answers
  questions*. Key providers then ask for the key in the notch (it goes to
  the keyring as `service ewe-companion provider <id>`); `claude-code` needs
  `claude` logged in once in a terminal.
- **The notch is gone.** Since P2.6 it shows only while something runs (an
  agent working or waiting, a card, a line, a question, game mode) or when
  opened: Super+A.
- **The notch blinks or stretches when it opens.** The window grew while it
  showed something (Hyprland stretches the old buffer). `Drop.qml` sizes
  the window first and comes out after; check nothing resizes it while
  `out` is true.
- **Something grows or jumps on hover.** A slot that holds text only on
  hover (the quick-action hint) must have an explicit width: a Qt Column
  skips zero-width children, so the empty slot collapses and the hover
  pushes everything down.
- **The home panel opens and shuts at once.** The focus grab started with
  the Exclusive keyboard and Hyprland cleared it; it must start a beat later
  (`grabTimer`).
- **"There is no app called … here."** The island looks the name up in the
  shell's desktop-entry index: a `.desktop` name, id, program, or whole
  words of the name. An app with no `.desktop` file (a bare binary) is not
  found; "the browser" and "file manager" follow `xdg-mime` (Settings →
  Default apps).
- **"Open a folder" opens a terminal.** Before 2026-10-14 it used
  `xdg-open`, which follows `inode/directory` and fell to kitty where
  nothing was set. It now launches the default file manager (`xdg-mime
  query default inode/directory`), else Nemo.
- **"I won't run …" in the chat.** `shell::assess` refused it: a machine
  killer, a partial upgrade, or a hand write to ewe.conf / `generated/`.
  The reason is in the line; the safe way (`sudo pacman -Syu`, `ewe-conf
  set`) is named there.
- **"That command is no longer waiting."** A proposal's token works once
  and for 15 minutes; ask again.
- **A command runs in the chat but finds no display or the wrong
  compositor.** The runner uses the daemon's environment (systemd's user
  environment) plus the island's `HYPRLAND_INSTANCE_SIGNATURE`; check
  `systemctl --user show-environment`.
- **An answer names the wrong page or label.** The knowledge pack lags ewe:
  fix `ewe-companion/knowledge/*.md` (`EWE_COMPANION_KNOWLEDGE=<dir>` loads
  an edited pack without a rebuild).
- **The chat history is model context** (P2.9). A reply's text goes into
  the next question, so anything that shows Safe's titles or usernames must
  set `Outcome::private` ("done", a count). `tests/canary.sh` fails
  otherwise — run it after any change near Safe, the conversation, logs or
  the store.
- **The browser the companion started closed when the daemon stopped.** An
  app a command line starts joins the caller's cgroup, so from
  `ewe-companiond`'s unit it dies with the unit. Acts (`search`, `open`,
  `play`, tab switches) go through the island (`do browser`); reads stay in
  the daemon.
- **"commands" opened as a web search in ewe browser.** ewe browser
  0.1.0-beta has no command line: `ewe-browser <verb>` opens the verb as a
  page. The companion asks `ewe-browser commands` only when the binary is a
  `#!` script (ewe-browser#3's wrapper); otherwise it opens a URL as before.
- **"I won't run …" for `ewe-safe read`, `op read`, `pass show` …** —
  refused on purpose: a run's output goes back into the conversation, so a
  command that prints a password manager's values never runs from the chat.
- **Tests must not reach the real Safe or browser:** point
  `EWE_COMPANION_SAFE` / `EWE_COMPANION_BROWSER` at `tests/fakes/`
  (`tests/island.sh` does). Since 0.2.0-beta the same holds for `nmcli`,
  `ewe-bt`, `qs`, `notify-send`, `ewe-theme` and `gio`: the test scripts
  put `tests/fakes` first on the daemon's `PATH` and refuse to run
  otherwise.
- **The daemon hung the first time a timer fired** (0.2.0-beta, before the
  release) — a rusqlite store guard lives to the end of its statement:
  `hub.store().list().into_iter().filter(|t| hub.store().remove(..))`
  locked the store's mutex twice on one thread. Bind the list with `let`
  first, then remove. Any `hub.store()` twice in one expression is the
  same bug.
- **"search men's shoes on zara" opened a plain web search** — the browser
  is older than 0.4.0-beta (no `site` in `commands`' schema) or answered
  `unknown-site`; the reply says so. "search gifts for mum" is meant to be
  a plain search ("search Y for X" needs a known site or a domain).
- **Test hooks in a scratch project, never in `~/.claude`:** hooks in the
  project's `.claude/settings.local.json` pointing at
  `target/debug/ewe-companion`; `EWE_COMPANION_HOOK_LOG=<file>` records the
  real payloads.

## Safe (RFC-008, phase 0 spike 2026-10-14)

Details and the rerun recipe: `ewe-safe/docs/SPIKE-0.md`.

- **Every password decrypts to garbage after a save**: quick-xml's
  `overlapped-lists` feature was on. It "fixes" files whose entry fields are
  not one contiguous block, but it breaks the order of protected values in
  the inner stream. ewe-safe's CI fails if anything in the dependency tree
  enables it. Such a file is opened read-only instead.
- **A deleted entry comes back after a sync**: it was removed with
  keepass-rs's plain `EntryMut::remove`, which records no `DeletedObjects`.
  Delete through the tracked path (`EntryTrack::remove`) or the recycle bin.
- **An edit from the other machine vanished in a merge**: keepass-rs's
  `_merge` (0.15.x) drops the older side instead of moving it to history,
  and skips attachments added to an existing entry. Safe owns its merge
  (`safe_core::merge`); don't switch back to `_merge`.
- **An attachment vanished from another item (or from history)**: stock
  keepass-rs 0.15.2 keeps no attachment back-references after a file is
  opened, so removing an attachment or an entry deleted a file another
  item still used. ewe-safe builds against the patched copy in
  `vendor/keepass/` (`PATCHED.md`) — never drop the patch before upstream
  fixes it.
- **A safe opens read-only with a reason**: the write guard found an element
  or attribute keepass-rs would drop on save (another app's extension). The
  guard is right; teach keepass-rs the element or keep it read-only.
- **The one-time code is wrong or the secret is refused**: keepass-rs's TOTP
  gives 8 digits and rejects unpadded base32; Safe computes codes itself
  (`safe_core::otp`).

### Safe — 2026-10-15 (passkeys, SSH agent, CLI; Safe 0.2.0-beta)

- **Saving an edited login in the Safe window does nothing** (0.1.0-beta,
  released): `ItemEdit.svelte` shadowed `was` inside its own initializer, so
  every save threw `ReferenceError`. Fixed in Safe 0.2.0-beta (ewe-safe#12).
- **`ssh` ignores Safe's agent although `SSH_AUTH_SOCK` points at it** — an
  `IdentityAgent` line in `~/.ssh/config` (1Password's
  `~/.1password/agent.sock` on the owner's machine) wins over
  `SSH_AUTH_SOCK`. `ewe-safe ssh status` lists them (`ssh_config_agents`);
  replace that line with the one `ewe-safe ssh enable` prints. **Since Safe
  0.4.0-beta (building, `docs/GATE.md`)** `ssh enable` puts Safe's gate on
  top of `~/.ssh/config` (first value wins) and `ssh takeover` cleans the
  ewe.conf hosts — the owner's `work`/`work-proxy` had exactly this.
- **"Too many authentication failures" with Safe's agent** — the agent
  offers every key and the server stops after `MaxAuthTries` (6). Point the
  host at one key: `IdentityFile ~/.ssh/ewe-safe/key-<tag>.pub` +
  `IdentitiesOnly yes` (`ewe-safe ssh host set <alias> --key <id>`; Connect
  does it). Safe 0.4.0-beta.
- **After upgrading Safe the agent's socket is missing** — the socket unit
  gained a second `ListenStream`: `systemctl --user daemon-reload &&
  systemctl --user restart ewe-safe.socket` (this locks the safe). The
  package's `post_upgrade` prints it.
- **A passkey from Safe doesn't show in KeePassXC/KeePassDX, or theirs
  doesn't sign in Safe** — check the five `KPEX_PASSKEY_*` fields and their
  protected flags: the **credential id is protected** (KeePassXC and
  KeePassDX write it so; TRIO.md's first table said no). KeePassDX needs all
  five fields.
- **A merge test passes alone and fails in a run** — KDBX times have
  one-second steps; two edits in one second tie. Tests that need "newer"
  wait a second.
- **A password edited on two machines before they synced "went back"** —
  not lost: Safe's merge is per entry, newest wins, and the older version is
  in the item's history. Passkey fields merge on their own (#11, FORMAT.md
  rule 3a). See [[Open Questions]].
- **The release build's `check()` fails "nothing to save" but CI was
  green**: a test read the safe file's time right after an edit answered.
  An edit is in the cache when it answers; a local place's file gets it
  moments later, so on a slow builder the test caught that late write. Wait
  for `status.sync.pending` to clear (and the time to settle) before
  measuring a file (ewe-safe #16). The `v0.2.0-beta` tag moved for it
  (and for the next one), before any package was made.
- **The release build's `check()` fails "ssh-keygen: No such file or
  directory"**: the SSH agent's tests drive OpenSSH's own `ssh-add` and
  `ssh-keygen`, and the release container (archlinux:base-devel) has no
  openssh. The PKGBUILD lists `checkdepends=('openssh' 'git')` and
  release.yml installs openssh (ewe-safe #17). The host and CI have it, so
  only the release build failed: run a release's steps in an
  `archlinux:base-devel` container (podman) before tagging, not on the host.

### Safe — 2026-10-18 (login unlock, keyring repair, cards; Safe 0.3.0-beta)

- **"Enter the keyring password" at every start** — `~/.local/share/keyrings/default`
  names a second keyring (`Default_keyring`, made by the 2026-09-03 bug).
  PAM unlocks only `login`, apps use the `default` → locked → a prompt. On
  the owner's machine the same boot showed gnome-keyring dying on
  `gkd-secret-unlock.c:244 perform_next_unlock: assertion failed` (two apps
  asked at once) and the D-Bus-started replacement had no password. Fix:
  `ewe-safe keyring repair` (Safe 0.3.0+; copies everything into `login`,
  points `default` at it, deletes nothing). Check:
  `ewe-safe keyring status` → `needs_repair: false`.
- **A right login password is refused** by a `unix_chkpwd` check —
  pam_unix's helper reads a **NUL-ended** password; without the NUL it sees
  none. Use `safe_client::chkpwd`. A fake helper in tests won't catch this:
  make it read up to the NUL too.
- **Safe doesn't open at login although login unlock is on** — the carrier
  item is missing from `login` (it was locked when login unlock was turned
  on), or `login` didn't open at the greeter. Unlocking once with the login
  password stores it again; `secret-tool search application ewe-safe`.
- **A user D-Bus service file is ignored** — dbus-broker never re-reads
  service files on its own: call `org.freedesktop.DBus.ReloadConfig`.
  dbus-run-session sandboxes use dbus-daemon, so they don't show this.
- **An agent stopped while writing a PAM module** — a safety filter cut it
  off twice: code that takes the login password at the greeter and passes it
  on looks like a credential stealer out of context. The module is parked
  for the owner's review (`.wt/parked-pam/`); don't hand it to an agent
  again without the owner.
- **Screenshots of the Safe window's dev mock** — Brave headless dumps core
  here; puppeteer's `chrome-headless-shell` works
  (`~/.cache/puppeteer/chrome-headless-shell/…`, `--screenshot`,
  `--virtual-time-budget=4000`, `http://localhost:<vite>/?mock=1&…`).

## ewe browser (2026-10-15, e2e and Safe)

- **Chromium aborts: "Socket path too long"** in an e2e run — its
  singleton socket lives under `TMPDIR`; a long temp path breaks it. Use a
  short one (`TMPDIR=/tmp/x`).
- **Two e2e runs in sibling worktrees switch each other's window rule off**
  — give each run its own Hyprland rule: `EWE_TEST_RULE=<lua name>`.
- **The nested compositor's output shrank mid-run** when the host
  rearranged its windows — give the e2e nest a fixed-size output.
- **A stateful Playwright suite went strange after one failure** —
  Playwright re-runs `beforeAll` after a failure; such suites need serial
  mode.
- **The smoke bookmarks test fails offline** — it needs the network.
- **Gmail: "This browser version is no longer supported"** (2026-10-15) —
  pages saw the engine's Chromium major (152) while Chrome stable was 155,
  and Gmail supports the two newest. Chrome ships every two weeks since 153,
  so Electron always trails; the browser reports the schedule's current
  major instead (`identity.ts`, `preload/chrome-version.ts`). Check in a
  page: `navigator.userAgent` and `navigator.userAgentData.brands` must name
  the same major as chromiumdash's current stable; if not, the schedule
  constants in `identity.ts` drifted.
- **"Some clicks on a website do nothing"** (2026-10-16) — one patch of a
  page is dead: no hover, no click, for good, while the rest works. The
  page marked it `app-region: drag`; Electron reports a tab's drag regions
  to the frameless window, which swallows the input there (Chrome ignores
  the property on ordinary sites). ewe browser 0.2.2-beta forces `no-drag`
  as a user-origin `!important` sheet from the page preload. To check one:
  `getComputedStyle(el).getPropertyValue('-webkit-app-region')` in the page
  must say `no-drag`. Proving a click fix needs a real pointer (nested
  Hyprland + `ewe-companion/tests/vptr.py`): `sendInputEvent` skips the
  window's hit test. (The companion island's tall transparent window was
  ruled out the same day: its input mask is the notch alone, checked with
  clicks through it in every state.)
- **"Use a security key instead" hangs** — Electron's own WebAuthn has no
  window and ignores its timeout; 0.2.0-beta (ewe-browser#4) adds its own
  timeout. Not yet tried with a real key.

## ewe browser 0.4.0-beta (2026-10-18, wave 2)

- **A site never asks for the camera / notifications** — Electron reports
  **"denied"** for every permission it was not told to grant, so
  `navigator.permissions.query` and `Notification.permission` said denied
  and sites skipped their own "allow" step. The page preload patches
  `Permissions.prototype.query` and `Notification.permission` in the main
  world to `prompt` / `default` for the undecided kinds of that origin (the
  `ask` list of `ewe:privacy-frame`); a document keeps the values it
  started with until it reloads. Check in a page:
  `(await navigator.permissions.query({name: 'camera'})).state` must be
  `prompt` on a site with no decision ([[Site Permissions — ask per site]]).
- **A browser shortcut ate a web app's key** (review, 2026-10-18: Ctrl+U
  in Gmail opened the page source instead of underlining) —
  `before-input-event` runs **before** the page. The keys a web app may use
  (`PAGE_FIRST_SHORTCUTS`, `PAGE_FIRST_CHORDS`) are left to http(s) pages;
  the preload's capture `keydown` reports them after dispatch and main acts
  only when the page did not `preventDefault` (within 1 s). `app://` pages
  and the shell layers stay browser first. Tests send keys with
  `webContents.sendInputEvent` (Playwright's CDP keyboard bypasses
  `before-input-event`).
- **OpenSearch discovery is an SSRF vector** — a page names its own
  descriptor url, and the browser fetches it. Fetch only https on the
  default port, without credentials, on the page's registrable domain
  (private suffixes on, so one github.io tenant never speaks for another),
  never a local name or private address, `redirect: 'error'`, 64 KiB, 8 s;
  keep a template only if it is https on the page's own host or its
  `www.` (`acceptDescriptor`, `acceptTemplate`).
- **"Block third-party cookies" changed nothing** — Electron 44 has no
  cookie-settings API; the Chromium feature
  `ForceThirdPartyCookieBlockingEnabled` is appended to
  `--enable-features` at startup only (`bootstrap()`, from `settings.json`
  read synchronously). The change applies after a restart, and Settings
  says so. To check: a cross-site iframe's `Set-Cookie` (`SameSite=None;
  Secure`) must not be stored.
- **Location allowed, but no position** — Electron on Linux has no location
  provider (it needs a Google API key); expected, and the prompt says so.
- **Four fingers do nothing in ewe browser** — the browser is older than
  0.4.0-beta (`ewe-browser workspace next` answers `unknown-verb`), or ewe
  is older than 0.30.0-beta; see also the gesture entry under *Shell / QML*.
- **A password-manager extension "is off"** (toast "… is off: Safe fills
  passwords") — refused on purpose ([[Browser Passwords — Safe only]]);
  its files stay in `<userData>/Extensions`, not listed in Settings.

## Overview and dock (2026-10-23)

- **Every window shows twice while the Overview flies** — the wallpaper
  patches under each window's real rectangle are missing or misplaced
  (`lastIpcObject.at` minus the monitor's `x/y`); see
  [[Overview Spreads the Windows]].
- **The Overview's windows re-arrange when the workspace strip opens** —
  something re-ran the spread with the smaller field; the strip must only
  scale the card layer (one `Scale` transform), never change the layout.
- **The dock's Downloads button never appears** although the browser
  downloaded — a FileView cannot watch a file that does not exist yet;
  `Downloads.qml` re-tries every 5 s while `downloads.json` is missing.
  Check `$XDG_CONFIG_HOME/ewe-browser/downloads.json` exists. **No progress
  while it runs, only when it ends** — ewe browser older than 0.5.2-beta wrote
  the file through a trailing debounce (fixed: throttled). A download
  stuck "running" after a browser crash clears on the browser's next start
  (it rewrites `progressing` as `interrupted`).
- **Minimized tiles are app icons, not pictures** — the toplevel has no
  Wayland handle yet (`modelData.wayland`), or no frame came within
  `durDim` (the tile gives up and keeps the icon). Hyprland 0.56 does
  render a window on a hidden special workspace for a toplevel capture
  (verified in the nested harness).
- **A minimized tile changed shape** — Hyprland tiles `special:minimized`
  like any workspace, so a minimized window is resized as others join it;
  the tile keeps the aspect captured with its picture (`thumbs[addr].aspect`),
  never the window's current size.
- **Restarting only the nested shell** — never find its pid with
  `pgrep -n -x qs`: that can be the LIVE shell, and `driver.sh down` kills
  the state file's `QS_PID`. Pick the qs whose environ has the nest's
  `WAYLAND_DISPLAY` (and `HOME=/tmp/hs-driver/home`). The first click
  after `vptr` starts is dropped; click again.
- **Testing pointer moves in the run-ewe nest** — the promo's `vptr`
  (`promo/capture2/vptr`) maps commands onto a 1920×1080 frame whatever the
  output is: scale X by 1920/width and Y by 1080/height, and pass the
  button (`down left`) explicitly.

## Workspaces on several displays (2026-10-23)

- **A display shows "11" instead of "1"** — something shows a raw Hyprland
  id; use `Globals.wsNumber(id)` / `Shell.workspaceNumber(id)`
  ([[Workspaces Per Display]]).
- **Shared mode: the other display does not follow** — `_G.ewe_workspaces_mode`
  is not "shared" in the compositor (`generated/user.lua`, then `hyprctl
  reload`), or the switch never fired `workspace.active`.
- **Hyprland segfaults on `--verify-config` / at a reload** — an `hl.timer`
  started from `config.reloaded` (it fires during the first parse, before the
  event loop). Settle at once there.
- **Testing two displays without hardware** — in the run-ewe nest
  `hyprctl output create headless HEADLESS-2` adds one (`output remove` unplugs
  it); `HS_EXTRA_LUA` appends Lua (e.g. `require` the repo's workspaces.lua
  with `package.path` set) to the minimal config; Lua can write probe output
  with `io.open` through `hyprctl eval`.

## Theming

- **A colour ignores the accent** — a raw literal in QML; only tokens
  allowed (rule 8).
- **A `control*` got double-grown** — never wrap a `control*` in
  `Theme.grow()`; it has grown already.
- **GTK stays light while the shell is dark** — `colorscheme.sh` is
  `set -u` (not `-e`) on purpose; a stray non-zero line must not abort
  before all files are written. Check the log it prints.
- **A Tauri app's dialog blinks as it opens** (Komble Options, 2026-10-11):
  WebKitGTK puts an `opacity` animation on a GPU layer and, tearing it
  down when the animation ends, sometimes presents one frame without the
  dialog and the scrim. Komble 0.20.1: dialogs open in place, the scrim
  animates `background-color` — never animate `opacity`/`transform` on a
  full-window overlay there. To SEE it: the app's `dev-mock.html` in a
  WebKit2 4.1 window inside `WLR_BACKENDS=headless cage`, `grim` in a loop,
  per-frame brightness (Chromium never shows it). ewe-settings and
  ewe-sync carry the same `.ewe-dialog[data-state="open"]` fade.

## ~/Nextcloud "configured, not mounted"; files sync twice (2026-10-31)

**Seen:** `ewe-files status` → `configured: true, mounted: false` forever,
while `~/Nextcloud` was full of files — the official Nextcloud desktop app
(`nextcloud --background`, its own autostart) was syncing it, and rclone
refuses a non-empty mountpoint. ewe-sync's old "Get started" card would have
put a THIRD engine there. **Now:** `ewe-files` reports `occupied`/`synced`
and never mounts over files; ewe-sync lists the app's folders as connected,
refuses a pair on them, and *Folders → Let ewe-sync take over* quits the app,
moves its autostart entry to `~/.local/state/ewe/nextcloud-app/` and syncs
the same folders. Check `~/.local/state/ewe/sync-folders.json` — every
engine is in it. [[Sync — sign in once, everything follows]]

## A Tauri app's release build fails "Found version mismatched Tauri packages" (2026-10-31)

**Seen:** ewe-sync's `v0.15.0-beta` package build (makepkg → `npm run tauri
build`) failed while the PR's CI was green. `npm install
@tauri-apps/plugin-dialog` had let the `^` ranges float: `@tauri-apps/api`
2.12.4 against the `tauri` crate 2.11.5, `plugin-dialog` 2.8.4 against
`tauri-plugin-dialog` 2.7.3 — `tauri build` refuses any major.minor
difference, and PR CI only runs `npm run build` + clippy. **Fix:** pin
`@tauri-apps/*` with `~` to the crates' major.minor (ewe-sync#9); ewe-sync's
CI now checks package-lock vs Cargo.lock. Before tagging a Tauri app after
adding a plugin, run the release build itself (`npm run tauri build --
--no-bundle`) — the dev build skips the check. The unreleased tag was moved
to the fix (no release had been made).

## "The cable is connected but there's no internet" (2026-11-01)

**Seen (owner's work PC, ewe 0.35.2, Intel `igc`):** 28 Oct 18:15 the kernel
OOM-killed ewe browser — **no swap at all** (phase 60 wrote the zram config
only on laptops) — Tailscale's relay timed out, resolved flushed. After two
reboots the cable had a link (at **100 Mb/s** on a 2.5G port) but **DHCP never
answered**: `ip-config-unavailable` every 45 s, then NetworkManager **blocks the
connection for 5 minutes after 4 failures**; the lease came at 18:38, right
after a block. The bar knew only "ethernet connected or not". **Check:**
`journalctl -b -1 -u NetworkManager | grep -E 'enp|dhcp4'`, `cat
/sys/class/net/<dev>/speed`, `swapon --show`, `nmcli -t -f CONNECTIVITY
general`. **Now:** `20-ewe-wired.conf` (a cable keeps asking, never fails
into the block), honest Quick Settings states (waiting for an address · N
min / no internet / sign in / 100 Mb/s hint) + Reconnect, zram everywhere.
Also seen there: a Btrfs checksum error (ino 1227510) — `btrfs scrub`.
The owner's laptop dock (RTL8153, `r8152`) never reported a carrier on any
boot since 18 Oct — if a cable is in it, it's the dock or the cable.
[[RFC-009 — ewe Remote]]

## Tailscale "breaks the internet" / drops after resume or a VPN (2026-11-01)

**Seen (owner's laptop):** in a month, 44 `no-derp-connection` and 34
`captive-portal-detected` health errors, clustered at resume and at the work
L2TP VPN's start (it takes the default route + DNS); the work network blocks
UDP (`netcheck: UDP is blocked`), so Tailscale rides its relays over 443.
**Check:** `journalctl -u tailscaled | grep 'health(warnable'`, `tailscale
status --json | jq .Health`, `tailscale debug prefs` (ExitNodeID — an
offline exit node takes ALL traffic down; RouteAll — an accepted subnet
route can swallow a `192.168.1.0/24` LAN, and home and work both use it).
**Now:** `ewe-tailscale status` + Quick Settings show health, relay-only and
the exit node (one click off); ewe's setup sets `--accept-routes=false`.

## Related

- [[Testing and QA]] · [[Development Loops]] · [[Rules of the House]] ·
  [[Roadmap — ewe-cast]] · [[Plugin System]] · [[Quiet Lid — touch only a disabled panel]] ·
  [[Overview Takes the Screen]] · [[Roadmap — ewe-safe]]
