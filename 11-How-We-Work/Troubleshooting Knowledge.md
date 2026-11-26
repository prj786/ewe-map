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

- **Shaun takes 5–8 s to answer with Claude Code** (before 0.3). Each
  question started `claude -p`, which loaded the user's own plugins, skills
  and MCP servers (~94k tokens) and took ~4 s to start. 0.3 runs it lean
  (`--disable-slash-commands --strict-mcp-config --setting-sources ""`)
  and warm (started on the first keystroke and after an answer): ~1 s.
  `--bare` is no fix: it refuses OAuth.
- **A `claude` process sits idle at ~190 MB** (0.3): the warm one waiting
  for a question. It goes after 3 idle minutes, or when the provider or
  model changes.
- **An offline answer picks the wrong topic** ("how do I use rsync to
  exclude a folder" → ewe Sync; "what is ewe-bt" → ewe). The pack's search
  treats a key phrase said whole as a confident match, and a one-word key
  is a phrase: ewe Sync's "folders" stems to "folder". Since 0.3, with no
  model, "how do I use <program>" goes to its manual first, a typo fix needs
  six letters ("rsync" is not "sync"), and a phrase never ends inside a
  hyphenated name. Probe a change with `QS="q1|q2" cargo test -p
  companion-core calibrate -- --ignored --nocapture`. Keep one spelling per
  key: "ewe-browser" and "ewe browser" count twice.
- **`cargo test` fails `every_shipped_feature_has_a_topic`** (0.3): an item
  in `knowledge/coverage.json` (a Settings page, `ewe-*` tool, app or
  built-in plugin) has no topic whose title or keys name it. Write the
  topic; never drop the item. Re-run `scripts/coverage.py` when ewe gains
  one (`--check` says the file is out of date; for the newest facts pass
  `--facts` a copy of `origin/main:ewe-facts.json`).
- **"What's new" talks about an older ewe**: `knowledge/news.md` has no
  "What's new in ewe X.Y" topic for the installed version
  (`/usr/share/ewe/VERSION`). `scripts/news.sh` lists the owed ones; write
  them by hand, in the user's words.
- **A word vanished from an answer** (an `<url>` in a topic showed as
  nothing): Qt guessed rich text. The island draws answers as plain text
  since `ewe.companion` 0.7.0; keep angle brackets out of a row's title
  anyway (the shell's `ListRow` is not the plugin's).
- **"wiki …" hangs or a dialog flashes**: `wiki-search` opens `dialog` when
  it is installed and waits on a terminal; Shaun sets `wiki_width` on every
  call. It also writes `/tmp/.wiki-search.$USER.tmp` (the tool's own file,
  shared with the user's searches). "Find arch-wiki-lite in Komble" means
  the dependency is missing (installed without its dependencies).
- **"man rsync" shows `--help`**: no `man-db` (an optdepend; the dev box has
  none). Programs on `lookup::NO_HELP` get neither.
- **"play this link" says a Vimeo or Netflix link is locked**: by design
  (DRM or a sign-in); ewe Player would show "This video is locked".
  `why_no_play` reads yt-dlp's `has_drm`.
- **"add japanese typing" opens ewe Settings instead of offering a
  command**: `typing_add` proposes `ewe-ime add <id>` only when `ewe-ime
  catalog` says nothing is missing (`installed`, `core`, `packages`);
  otherwise Keyboard and mouse → Add a language… installs it. Before ewe
  0.46 (no `ewe-ime`) it offers Updates.
- **A music search in the island harness shows the owner's library**: the
  harness daemon reads the real home. Set `EWE_MUSIC_DIR`, `XDG_CACHE_HOME`
  and `EWE_COMPANION_NOTES` in a scratch dir before `tests/island.sh up`.
- **"Remember my pin is …" was refused but stayed in the conversation**
  (before 0.3's release): the store refused it, but the user's words went
  into the history. A command line that `memory::looks_secret` is kept as a
  placeholder now (`tests/brain.sh` checks the next request).
- **A reminder's text came back changed** ("take a break" → "make a
  break", 0.3 before release): the typo pass touched free text. Everything
  after remind, remember, open, search, close, kill … is never corrected,
  and "lock" is out of the vocabulary so "look" never becomes it.
- **A CPU row offered Quit for Hyprland** (0.3 before release): the busiest
  programs included the compositor and the shell. `commands::SESSION`
  refuses them, so their rows carry no Quit. `pkill -x` matches the
  15-character process name; names with spaces are skipped.
- **`tokio::spawn` refuses a future "not `Send`"**: a `libc::tm` (it holds a
  raw pointer) lived across an `.await`. Read its fields into numbers
  first.
- **A fake process exits at once in CI** ("coreutils: unknown program"):
  the runner's coreutils is multi-call (uutils), so a renamed `sleep` dies.
  A fake process with a name is `python3` through a link of that name.
- **The window commands may be wrong on a live desktop**: never run on a
  live compositor by rule. Close (`{ window = "address:…" }`) and
  fullscreen's `action` arguments come from Hyprland 0.57.1's error
  strings; `windows::dispatch` counts only error-looking output as a
  failure. Check them on a real desktop before trusting a bug report.

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

### SSH hosts from the account — data, never code (ewe-conf, 2026-11-01)

- **A host with `ProxyCommand` (or `LocalCommand`, `Match`, `Include` …)
  doesn't come back on a second computer** — by design since the SSH-gate
  security review: `[network.ssh] hosts` travel through the account, so
  ewe-conf (`ssh_host_clean`, `SSH_NEVER_SYNC`) never adopts, stores or
  writes an option that runs something, and refuses a host or value with a
  newline. Your own lines keep them on the computer where you wrote them.
  Test: `ewe/tests/ewe-conf-network-test.sh` step 7. Branch
  `docs/safe-ssh-gate` (ewe), not released.

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
- **A closed Tauri window still leaves `WebKitWebProcess` (~90 MB) behind**
  (ewe-sync / Komble, 2026-11-19): destroying the window finalises the
  `WebKitWebView` (checked with a weak ref), but WebKitGTK 2.54 parks the
  page-less web process in its process cache for up to 30 min and a new
  window gets a fresh one anyway — so idle RAM did not fall after close.
  There is no env knob any more (`WEBKIT_USE_SINGLE_WEB_PROCESS` is gone).
  Fix: `webview.with_webview(|w| w.inner().terminate_web_process())` from
  inside `WindowEvent::CloseRequested` (it runs synchronously on the main
  thread before the teardown), then `malloc_trim(0)` a few seconds after
  `Destroyed` (~20 MB back). `WebKitNetworkProcess` (~13 MB) stays: Tauri
  keeps the web context for the app's lifetime on Linux (tauri#14626).
  Measure with the sum of `Pss` over `/proc/<pid>/smaps_rollup` of the
  app's process tree; close a window in headless cage with a tiny
  wlr-foreign-toplevel client (cage speaks it; nested Hyprland does not
  start under cage — xdg_wm_base v6 vs v5).

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

## The UI revamp's build lessons (2026-11-01)

- **`node --test <dir>/` fails on Node 22** ("Cannot find module …/tests") but
  passes on Node 26 — ewe Safe's new `npm test` went red in CI. Name the files
  (`node --test tests/ui.test.js`) or a glob.
- **mise's node shim refuses to run under a test's temp `HOME`** — put
  `~/.local/share/mise/installs/node/lts/bin` first on `PATH` (ewe-sync's
  `tests/*.sh` "frontend builds" step). Rust under a temp HOME needs
  `RUSTUP_HOME`/`CARGO_HOME` pointed at the real ones.
- **A Tauri `productName` with a space renames nothing that matters**: the
  binary, app id and window class come from the crate name — "ewe Settings" is
  still class `ewe-settings`. Never match a window by title (see
  [[Contracts and Public API]] → App names).
- **QML: never bind a size to a Row's implicit width that depends on that size**
  — Quick settings' account plate spun the shell at 100 % CPU.
- **Test notifications into the nest only:** `HS_PRIVATE_BUS=1` +
  `driver.sh notify …`; the host bus would put them on the real desktop.
- **Vendored-only fixes get lost:** ewe 0.35.2 patched `plugins/ewe.dock` but not
  `ewe-plugin-dock`; a `vendor-plugins.sh --clone` would have dropped it (Dock
  1.3.1 upstreamed it). Before vendoring, diff each `plugins/<id>` against its
  recorded commit.
- **Headless Brave on this box** works with `env -u WAYLAND_DISPLAY -u DISPLAY
  brave --headless=new --ozone-platform=headless`, one warm profile, runs in
  sequence (parallel or fresh profiles hang); `--screenshot` hangs — drive it
  over the DevTools protocol.

## "Safe asks Allow all the time" (2026-11-04)

**Seen:** the log says `ssh (its file can't be seen) (not a system program)` for
every program, including `git` and `systemd`, and every signature asks. **Cause:**
a mount-namespace directive in a **user** unit (`PrivateTmp=`, `ProtectSystem=`,
…) puts the service in its own user namespace, and the kernel then hides
`/proc/<pid>/exe` of everything outside it (`ptrace_may_access`). `comm` and
`stat` still work, so nothing looks broken. **Check:** `readlink
/proc/$(systemctl --user show -p MainPID --value ewe-safe.service)/ns/user`
against `/proc/self/ns/user`: they must match. **Lesson for any ewe user unit:**
these directives aren't free, and a test outside systemd can't catch this. Run
the unit's directives through `systemd-run --user` when a daemon looks at other
processes.

## "<computer> can't be reached" while plain ssh works (2026-11-05)

**Symptom:** after a reboot, a computer that only joins others says its paired
computer can't be reached: the browser's remote workspace shows that page, and
the terminal says "Not connected. Trying again..." forever. Plain `ssh` to the
same computer works, and the shared computer is fine. **Cause:** `ewe-remote`'s
runtime directory (`$XDG_RUNTIME_DIR/ewe-remote`) is on tmpfs, and only sharing
and pairing made it. `tunnel` then failed opening its log (`error: internal`,
`FileNotFoundError`, which the browser shows under the same headline as a real
network failure), and `ssh -F` logged in, then exited 255 at `unix_listener:
cannot bind to path` because the generated `ControlPath` lived in that directory.
**Check:** `ls -d /run/user/$UID/ewe-remote`, then `ewe-remote tunnel <name>`.
**Fixed:** `main()` makes the directory for every verb, and the `ControlPath` sits
beside it, so `ssh -F` needs no earlier `ewe-remote` call. **Lesson:** a file that
survives a reboot can't point at a directory that doesn't, and a test that pairs
and connects in one sitting can't see this. `tests/ewe-remote-test.sh` now empties
the runtime directory between the steps.

## The browser's Recent keeps reappearing; ewe Sync runs `ewe-conf` all day (2026-11-05)

**Symptom:** Home's Recent cards blink every 2 to 3 seconds. **Cause, two bugs:**
`ewe-sync`'s `watch_conf` watched `~/.config/ewe` and ran `ewe-conf get`, and the
`notify` crate reports `OPEN` too (`WatchMask::OPEN` in its inotify backend), so
reading `ewe.conf` woke the watcher: forever, every 2.3 s (the 2 s debounce plus the
tool's run time), with two Python processes and a `pgrep` each round and a rewrite of
`sync-folders.json` where only `updated_at` moved. And Home's `<For>` got new objects
on every refresh, so it rebuilt every card and replayed the entrance. **Check:** watch
that file's mtime, and sample the children of `ewe-sync` for `ewe-conf get sync.folders`.
**Fixed:** ewe-sync 0.16.1 `is_real_change` (both watchers ignore every access event
except a close after writing); ewe browser 0.8.2 announces `folders` only when the
snapshot says something new, and reconciles Recent by key. **Lessons:** a `notify`
watcher that reads what it watches wakes itself, so filter by event kind. And
`Close(Write)` is an access event too, so don't drop all of them. A test of events
must wait for them to stop: a write reports its own open first.

## "ewe uses too much RAM" / Chrome opens slowly (2026-11-08)

**Symptom:** the memory meter read ~12 GB used on an idle 30 GB laptop; Chrome took
over a second to open. **Causes, measured:** (1) `GPUReclaim` in `/proc/meminfo` — the
xe/TTM pool of freed GPU buffers, 4.47 GB, outside `MemAvailable` (it fell to 62 MB on
its own once memory was needed); (2) Chrome was a Komble AppImage — FUSE mount and
decompression per launch, 1.1–1.3 s vs 0.5 s unpacked; (3) idle churn: 11 `hyprctl`
per focus change (kb-per-window), a 1.5 s sysmon tick with 4 forks, two `nmcli
monitor`, a 30 s global-shortcut sync, ewe Sync's hidden page polling every 30 s.
**Check:** `grep -E 'MemAvailable|GPU' /proc/meminfo`; PSS per program (the loop in
`ewe/docs/TROUBLESHOOTING.md`); a child sweep of `/proc/<pid>/task/*/children` at
30 ms catches the spawns (a 100 ms `pgrep` loop misses a 5 ms `sh`). **Fixed:** ewe 0.41,
Komble 0.22, ewe Sync 0.16.2, System monitor 2.0.1, VPN 1.0.3 ([[Roadmap and Status]]).
**Lessons:** Qt's pixmap cache keys on `fillMode` too (the provider options), so a warm
`Image` must match the drawing one in url, `sourceSize` AND `fillMode`. A Chrome you
start with `gio launch` and close with `hyprctl closewindow` can keep running — time
launches with a throwaway profile and kill the browser process by its profile path
after. `dbus-run-session` starts a second `xdg-desktop-portal-hyprland` on the live
compositor (it exits with the bus); `ewe-cloud status` waits ~10 s for a keyring that
the sandbox bus does not have. Testing in `/tmp` costs RAM (tmpfs) — and a deleted
file stays resident while a process holds it.

## Chinese, Japanese or Korean text shows as boxes (2026-11-08)

**Symptom:** CJK characters drew as hex boxes everywhere (shell, apps, browser).
**Cause:** no CJK font was installed at all — `packages/common.list` had
`noto-fonts` (no CJK) and nothing else; `fc-list :lang=zh` was empty. **Fixed (ewe
0.42):** `adobe-source-han-sans-otc-fonts` (the Noto Sans CJK design, 112 MB vs
299 MB, no serif) becomes an `ewe` dependency, and `dotfiles/fontconfig/fonts.conf`
+ `system/fontconfig/60-ewe-geist.conf` put **Source Han Sans SC** after Geist and
Noto Sans Georgian, with rules that put `Source Han Sans` (JP), `… K`, `… TC`,
`… HC` first for `lang` ja / ko / zh-tw / zh-hk. **Check without installing:**
download the package into a scratch dir and point `FONTCONFIG_FILE` at a config
that includes `/etc/fonts/conf.d/*` with the repo's `fonts.conf` in place of
`50-user.conf`; `fc-match 'Geist:lang=ja:charset=3042'` and a `pango-view
--no-display -o x.png` render show it. **Trap:** in a **monospace** context
fontconfig 2.18 prefers the one cut it classes as monospace (`genericfamily` 3),
the half-width **HW SC**, whatever the language — kana and hangul are right, a
shared Han character keeps its Simplified shape. The family names in the OTC are
`Source Han Sans` (Japanese), `… K`, `… SC`, `… TC`, `… HC` (+ `HW` cuts) —
not `… JP`/`… KR`, which are the subset OTFs' names.

## "Game mode does nothing" (2026-11-08)

**Symptom:** the owner's game mode (Shaun's, then) changed nothing a game could
feel. **Cause:** GameMode's polkit rule allows its helpers only to the
`gamemode` group, which no ewe installer adds anyone to — `journalctl --user -u
gamemoded` shows `pkexec … Not authorized` for `cpugovctl set performance` and
`procsysctl split_lock_mitigate`. What did run: DND and animations off. **Fixed
(ewe 0.42):** `system/tuning/70-ewe-gamemode.rules` (wheel), and game mode moved
into the desktop as `ewe-game` with an Ultra level ([[Game Mode — one, owned by
the desktop]]). **Trap:** RAPL energy (`/sys/class/powercap/intel-rapl*/energy_uj`)
is root-only, so GameMode's own iGPU governor logic is blind — once allowed, its
default would pin an integrated-GPU laptop's CPU at full speed; `ewe-game setup`
writes `desiredgov` = the current governor there. **Test without touching the
machine:** `tests/ewe-game-test.sh` (fakes for hyprctl, busctl, systemctl,
gamemoded, a fake /proc and /sys); in the nest, `EWE_GAME_TOOL=<wrapper>` with
the same fakes on PATH and `EWE_GAME_NO_SCOPE=1` — a real toggle there would set
the REAL power profile, stop the REAL ewe Sync and kill the REAL browser.

## The polish pass (2026-11-19, ewe 0.43)

- **A rule-placed window still pulled the view with `follow = false`.** Hyprland focuses
  a new window when it maps and switches to its workspace to do it. Quiet placement is a
  static `no_initial_focus` rule; ewe focuses the window itself on `window.open` when the
  user launched it ([[Who May Move You — launches, toasts and activation]]).
- **Static rules and tags:** a rule matches a tag that an EARLIER rule set in the same
  pass (`ewe-ws-quiet-N` after the generated `windowrules.lua`), by the exact tag only (a
  pattern never matched); a tag added from `window.open_early` comes too late, and
  `hl.dsp.window.set_prop` cannot set a static prop such as `no_initial_focus`.
- **`hl.dispatch` takes a Lua function**, so the shell runs compositor Lua with no process:
  `Hyprland.dispatch('function() … end')`. Globals persist between dispatches; `hyprctl
  eval` prints nothing back. `Hyprland --verify-config --config <file>` parses the whole
  Lua config and DOES report unknown config keys and rule fields — use it before a release.
- **The nest is not ewe's compositor config** (`hypr-min.lua`): to test `workspaces.lua`
  there, `driver.sh hc eval 'package.path = "<repo>/dotfiles/hypr/?.lua;" .. package.path;
  require("workspaces").setup()'`, then `hc output create headless X` / `output remove X`
  so its settle pass assigns the displays.
- **The nest changed the owner's real cursor.** It shares the host's session bus, and
  Hyprland's `cursor.sync_gsettings_theme` (default on) wrote the nest's startup cursor into
  the live `org.gnome.desktop.interface cursor-theme` (black → white). The driver turns the
  sync off since 0.43 — but an agent worktree branched from an OLDER commit runs the old
  driver: check `gsettings get … cursor-theme` after parallel nests.
- **Quickshell 0.3.2:** `HyprlandToplevel.urgent` is declared but never raised (track the
  raw `urgent` / `activewindowv2` / `closewindow` events); `Notification.expireTimeout`
  arrives in MILLISECONDS despite the docs. `notify-send` with `-A` blocks until an action
  is chosen — background it in a test.
- **Files' "Open in Terminal" does nothing:** cinnamon-desktop 6.8's schema default is
  `velocitty`; ewe's dconf system db (kitty) reached only install.sh machines until 0.43.
- **Merging parallel agent worktrees:** `git apply --3way` refuses files whose index
  differs from the working tree; export with `git add -N . && git diff`, apply plainly or
  with `--reject`, resolve the rejects (manifest versions: keep the higher bump).

## ewe's own apps and the package diet (2026-11-19, ewe 0.44 / ewe-apps 0.1)

- **"Why is `nvidia-utils` on my Intel laptop?"** `zed` depends on the virtual
  `vulkan-driver`; `pacman -S ewe` ran before the installer's GPU phase, and with no
  provider installed pacman takes the first alphabetical one — `nvidia-utils` (1 GB,
  **blacklists nouveau** — the live ISO then had no GPU driver on NVIDIA, which is why
  `nvidia-open` rode along). **Check:** `pacman -Qi nvidia-utils` → *Required By: zed*, or
  `pacman -Sp --print-format %n ewe | grep nvidia` against a fresh database. **Fixed:**
  `vulkan-swrast` first in the `ewe` depends, in `common.list` and the ISO list; the
  publish gate blacklists `nvidia-utils` ([[The Package Diet]]). **Lesson:** every virtual
  dependency (`vulkan-driver`, `jack`, `ttf-font` …) needs an explicit provider *before*
  the package that asks, or the gate must name the wrong provider.
- **A closed Tauri window's `WebKitWebProcess` (~90 MB) stays for 30 min** — WebKitGTK
  2.54 caches page-less web processes; `terminate_web_process()` from
  `CloseRequested`, then `malloc_trim(0)`; the network process (~13 MB) stays for the
  app's life (details above, [[Apps Are Not Resident]]).
- **`notify` reports `OPEN` events** — a watcher that reads what it watches wakes itself
  (ewe-sync 0.16.1, and again in ewe-apps): drop `EventKind::Access` except
  `Close(Write)` (the 2026-11-05 entry above).
- **"Load failed" from pdf.js in a Tauri window:** WebKitGTK refuses a **module worker
  from `tauri://`**. Bundle pdf.js's worker into the main bundle; pdf.js uses
  `globalThis.pdfjsWorker` when it is already there (ewe Viewer).
- **DOM `drop` never fires in a Tauri window:** Tauri's drag-drop handler returns true
  for any uri-list drop and swallows it. Handle drops from `onDragDropEvent` by
  hit-testing `[data-drop]` under the pointer; keep DOM `dragover` for the highlight and
  DOM `drop` as a deduped fallback (ewe Files).
- **`fetch()` to the loopback media server fails with a bare "Load failed"** while
  `<img>`/`<video>` work: the webview origin is `tauri://localhost`, the server
  `http://127.0.0.1` — CORS. The server must **echo the app's own origins** (never `*`
  with a token in play), answer the `Range` preflight (OPTIONS 204) and expose
  `Content-Range`/`Accept-Ranges`/`ETag` (ewe Viewer's text, PDF, book and sheet loads).
- **`tauri build` refuses "version mismatched Tauri packages"** — pin the npm
  `@tauri-apps/api` and `@tauri-apps/cli` to the crate's major.minor (2.12.x);
  pinning the crate alone does not work (the 2026-10-31 entry, again in ewe-apps).
- **`du` says the icon theme is 416 MiB (1.9 GB on btrfs):** Reversal's 24 colour variants
  are full copies differing in ~285 of ~10,660 files. `hardlink -q -c usr/share/icons` in
  the PKGBUILD → ~14 MiB; icon loaders see regular files. **Check:** `pacman -Qi
  reversal-icon-theme` → *Installed Size*.
- **WebKitGTK publishes its own MPRIS player** (`org.mpris.MediaPlayer2.org.webkit.app-<hash>.Sandboxed.instance-N`)
  beside ewe Player's `org.mpris.MediaPlayer2.ewe-player`: the shell's now-playing
  shows two players until it skips `org.webkit.*` (open in ewe 0.44).
- **Videos with audio (5–20 MB) never start in a WebKitGTK `<video>`:** WebKit's media
  download buffer; ewe Player sets `WPE_SHELL_MEDIA_DISK_CACHE_SIZE_BYTES=536870912`,
  `…_NSEC=600000000000`, `WEBKIT_GST_ENABLE_HLS_SUPPORT=1`,
  `WEBKIT_GST_ENABLE_DASH_SUPPORT=1` (only if unset). MPEG-4 Part 2, WMV/WMA, ALAC, AC-3,
  DTS need `gst-libav`: `gst-inspect-1.0 avdec_h264` is phase 90's codec check.
- **"Show in folder" from another app opens Nemo, not ewe Files:** Nemo still owns D-Bus
  `org.freedesktop.FileManager1` while installed — ewe Files does not fight for the name
  (stderr `FileManager1 not claimed`). Remove the old apps once after the upgrade:
  `sudo pacman -Rns nemo engrampa imv zathura zathura-pdf-mupdf mpv-mpris mpv-uosc-git`
  (keep `mpv`: `mpvpaper`).
- **A PDF still opens in Zathura after the upgrade:** the one-time take-over
  (`_mime_take`) moves only an explicit default that *is* the old app and only once —
  marker `~/.local/state/ewe/default-apps-0.44.done`; delete it and run `ewe-setup`
  again, or pick the app in ewe Settings → Default apps (the rows Document viewer /
  Music player / Archives are new in 0.24).
- **Nemo's "Open in Terminal" ran `velocitty` even after 0.43:** 0.43's dconf file wrote
  `/org/cinnamon/desktop/default-applications/terminal/` — **the path is not the schema
  id**; Nemo reads `/org/cinnamon/desktop/applications/terminal` `exec` + `exec-arg`.
  0.44 writes `exec='ewe-terminal-here'`, `exec-arg='-e'`; check with `gsettings get
  org.cinnamon.desktop.default-applications.terminal exec`.
- **`ewe-cloud login` answers `unauthorized` with `browser: true`** for a correct
  password: the account has two-step verification or single sign-on — the OCS exchange
  cannot do those; use *Sign in with the browser instead* (Login Flow v2). `redirected`
  means the typed server answered with a redirect — the password is **not** sent on;
  type the final address.
- **Measuring the apps' memory:** sum `Pss` over `/proc/<pid>/smaps_rollup` of the
  process tree (ewe Files ~213 MB PSS / 540 MB RSS, ewe Player ~189 MB PSS) — RSS
  double-counts WebKit's shared pages.

## The milestone polish (2026-11-20, ewe 0.45)

- **"The external monitor goes black for a second when something goes fullscreen"**
  (+ Hyprland's notice *"Monitor DP-1: wide color gamut is enabled but the display is not
  in 10-bit mode"*): Hyprland's `render:cm_auto_hdr` (default 1) switched the output's
  colour management for a fullscreen client asking for HDR / wide gamut, so the output
  was committed again. Check `hyprctl getoption render:cm_auto_hdr` (0 from 0.45 →
  [[No Automatic HDR]]); the aquamarine log shows `Modesetting DP-1 …` twice with no
  hotplug when it happens.
- **"Now playing lists the same song twice" / the wrong player:** WebKitGTK publishes
  `org.mpris.MediaPlayer2.org.webkit.*` beside the app's own entry (ewe Player is both).
  Music 1.1.0's `MprisPick` takes a WebKit entry only when nothing else qualifies (by
  `dbusName`). Shaun's `NowPlaying` (ewe-plugin-companion) still lacks the filter.
- **The clipboard says "cliphist isn't installed" on a fresh install:** `cliphist list`
  exits 1 with "please store something first" until the first copy. Clipboard 1.3.0
  runs `command -v cliphist || exit 127; cliphist list` and says "isn't installed" only
  on 127.
- **A row's grey icon tile vanished on hover** (Komble, ewe Sync, Safe, ewe Settings):
  `.ewe-row__lead--tile` wears `surface-hover`, the hovered row's own fill. Fixed once in
  `design/components.css` (+ `bundle.css`): the tile steps to `surface-pressed` with the
  row; the app copies are refreshed (`design/check-tokens.sh`).
- **Vendor plugins by id:** `scripts/vendor-plugins.sh ewe.dock ewe.clipboard …` — a
  blanket run takes every `../ewe-plugin-*` checkout as it is, and the local
  `ewe-plugin-companion` (0.2.0, dirty) is older than the bundle's 0.5.2: Shaun would
  be downgraded.
- **Dock: which display a minimized window came from** — `special:minimized` is ONE
  workspace, so `hyprctl clients` reports the monitor that workspace last sat on, not
  where the window was minimized. Dock 1.5.0 records it before the move
  ([[Dock On Every Display]]).
- **Harness:** a plugin under test runs from a scratch payload — `cp -a
  ewe/plugins /tmp/<x>`, swap in the working tree, `HS_PLUGINS=1 HS_PAYLOAD=/tmp/<x>
  HS_HEADLESS=1 driver.sh up` (headless keeps 1920×1200 when several nests run). Two
  nests at once: separate `HS_WORK`. A shell edit hot-reloads every nest running that
  checkout.

## Media + languages (2026-11-21, the ewe 0.46 wave )

- **ewe Player: "Cannot play watch … comes with the next update; install
  gst-libav"** — the promise had been kept (gst-libav ships since 0.44); the
  sentence was hard-coded and shown for *any* remote URL with no probe.
  "watch" was the last path segment of a YouTube `watch?v=` page. Two bugs:
  (1) the wrong blame — fixed by `media_support` (gst-libav named only when
  it is missing) and the sentence removed from the repo; (2) the page link
  itself — ewe-apps 0.2 plays it through yt-dlp
  ([[ewe Player Plays Links — yt-dlp]]).
- **Every remote video "format not supported"** even when it was an `.mp4`:
  the `<video>` carried `crossorigin` (needed for the loopback server's
  files), and CDNs (googlevideo, Twitch, BBC) send no
  `Access-Control-Allow-Origin` — WebKit refuses the load. `crossorigin`
  only for loopback files; links stay ≤ 100 % volume (Web Audio plays a
  cross-origin source as silence).
- **"A video link won't play"** — what the Player says next decides it:
  *web page with no video* (not a video page), *needs yt-dlp* (`pacman -Qi
  yt-dlp`), *locked (DRM)* (Vimeo's anonymous player), yt-dlp's own
  sentence ("Private video."), *connection broke* (nothing loaded in 20 s
  twice — one YouTube start in nine stalled with no error). Sites that serve
  only split video + audio offer *Open in mpv* (no remux route yet).
  Reproduce: `EWE_PLAYER_YTDLP=<path>`, `EWE_PLAYER_LIBAV=0|1`,
  `GST_DEBUG=webkitmediaplayer:6`. A server that sends headers and then never
  a byte froze the whole WebProcess in a test (one that never answers is
  caught by the stall watchdog).
- **Auto-picked subtitles never drew:** WebKit's automatic caption
  selection flips a track set to `showing` back off when more tracks arrive
  (in-band after the sidecars) — re-apply on the textTracks `change` event.
  **Bottom subtitles under the control bar:** move the cue container with a
  `transform` (`--vp-cue-lift`), not `cue.line` (it jumps and re-lays every
  cue).
- **Russian / Arabic / Chinese subtitles as mojibake:** `subs.rs` read
  "UTF-8, else Latin-1". Since ewe-apps 0.2 one decoder (BOM → UTF-8 →
  chardetng + encoding_rs, hinted by `Movie.ru.srt` or the locale); the
  *Subtitle encoding* menu overrides a wrong guess.
- **"Stremio doesn't play"** (Stremio Enhanced from Komble): it needs
  Stremio's streaming server and on Linux looks for it only as a Flatpak
  (`com.stremio.Service`) or as `server.js` in
  `~/.config/stremio-enhanced/streamingserver/` — the owner's folder had
  only `version.txt`, nothing on :11470, so no torrents and no
  transcoding. Komble 0.24: the app's page → *Get the streaming server*,
  then restart Stremio Enhanced; or install **Stremio**
  (`stremio-linux-shell`, server + mpv inside)
  ([[What an Installed App Still Needs]]).
- **Arabic drawn unjoined, typewriter-spaced (Hebrew in FreeSans):**
  `system-ui` is not a fontconfig family on Arch; WebKitGTK falls to
  whatever fontconfig matches first, and with GNU FreeFont installed that is
  FreeMono. Name Noto faces before `system-ui` (apps' `withScriptFonts`,
  ewe's Geist stacks, the CSS tokens).
- **LinOffice's Word/Excel/Outlook/OneNote/PowerPoint missing from the
  launcher** + hundreds of `invalid line "[Desktop Entry]\r"` in the log:
  Quickshell drops a CRLF `.desktop` file **entirely**.
  `scripts/desktop-entries.py` writes LF copies to
  `$XDG_CACHE_HOME/ewe/desktop-entries/applications` (on the shell's
  `XDG_DATA_DIRS`); the warning for the originals stays. Test:
  `tests/ewe-desktop-entries-test.sh`.
- **Quickshell 0.3.2 crashed when fcitx5 started (in the nest):** fcitx5's
  hidden tray item asked for an icon name the theme lacks (`fcitx-rime`) →
  a QSocketNotifier from another thread. The tray delegate for fcitx5's
  item loads no icon (a Loader) and the bar reads the engine through
  `ewe-ime current`.
- **Typing in other languages: nothing happens in an X11 or Qt 5 app** —
  they read `XMODIFIERS` / `QT_IM_MODULE` at start, and the shell hands its
  own environment to what it launches: sign out and back in after the first
  language (`ewe-ime status` → `needs_signout`). Chromium/Electron apps need
  a restart (the flags block). A placeholder showing through composed
  letters = the field ignores `preeditText`.
- **Pinyin asked "Enable Cloudpinyin?"** — never again: `ewe-ime apply`
  seeds `CloudPinyinEnabled=False` + `FirstRun=False` in `conf/pinyin.conf`
  where absent (privacy: typed text would go to an online service). The
  user can still turn it on in fcitx5's Language options.
- **fcitx5's profile reverts after `ewe-ime apply`:** fcitx5 rewrites
  `~/.config/fcitx5/profile` when it exits — stop it first, then write,
  then start (what `apply` does).
- **ewe Browser doesn't underline Georgian:** Chromium has no Georgian
  `.bdic`; the system's `hunspell-ka` (AUR) serves other apps only. Settings
  says "isn't checked in ewe Browser yet" ([[Spell Checking — hunspell and Chromium]]).
- **The Player's preferred language reads as en-US under `LANG=de_DE.UTF-8`:**
  WebKit takes `navigator.language` from the *installed* locale
  (`setlocale`); for a test build one with `localedef -i de_DE -f UTF-8
  <dir>/de_DE.UTF-8` and pass `LOCPATH=<dir>`.
- **Testing fcitx5 safely:** in the nest, run fcitx5 from a `pacman -Sp`
  root overlaid on /usr with the shell's PRIVATE bus (`HS_PRIVATE_BUS=1`),
  `DISPLAY` unset, `EWE_IME_NO_SCOPE=1 EWE_IME_NO_SESSION=1` — never against
  the live bus or X server. `tests/ewe-ime-test.sh` uses fakes.

## The installer in your language (2026-11-21, ewe-os 0.17)

- **"command not found: sudo" on an installed ewe** — systems installed
  with the graphical installer up to ISO 0.16 have no `sudo`: `base` does
  not carry it and the installer only wrote `/etc/sudoers.d/wheel`. Fix:
  `pkexec pacman -S sudo` (your password). 0.17's `pacstrap` adds it, and
  `sudo` is an ewe dependency after 0.47.0 (ewe#90), so the next ewe
  update brings it too. Found by the 0.17 QEMU pass.
- **The Disk screen preselects nothing on a one-disk machine** (ISO ≤
  0.16): the probe listed the live system's `zram0` swap as a second disk;
  0.17 drops `zram*` names.
- **The login screen is always US English** (ISO ≤ 0.16): cage reads
  libxkbcommon's `XKB_DEFAULT_*`, which nothing set. 0.17's greeter wrapper
  reads `/etc/X11/xorg.conf.d/00-keyboard.conf` (localectl's X11 keymap) at
  every start; change it with `sudo localectl set-x11-keymap us,ge` and
  `sudo systemctl restart greetd`.
- **Apps marked "Komble" were not installed** — by design: the installer
  never builds from the AUR or fetches AppImages. Komble → For you → *Apps
  you picked while installing ewe* (`~/.local/state/ewe/install-picks.json`).
- **Testing the installer in QEMU on a slow link:** a stalled GitHub
  download kills `pacstrap`; serve packages from a host cache through
  pacman's `CacheServer` (ewe-os `docs/TESTING.md`). `scripts/vm.sh` keeps
  its work folder off tmpfs and gives each ISO boot fresh UEFI variables.

## One file picker (2026-11-22, ewe 0.48)

- **A file dialog looks like GTK again, or opens behind the app.** Since
  0.48 every app's Open, Save and "Open with" is ewe's own picker, drawn by
  the shell on an overlay layer, so it cannot be under the app. A GTK dialog
  means one of three things:
  - the shell couldn't answer (restarting, a QML error), so `ewe-portal` handed
    THAT request to the GTK dialog on purpose (`journalctl --user -u ewe-portal`:
    "GTK dialog for … — <why>");
  - the app never asks the portal: GIMP, JetBrains, Steam, Wine and Java draw
    their own; Firefox and GTK 3 need `GTK_USE_PORTAL=1` (a new session after
    upgrading); Qt needs qt6ct `standard_dialogs=xdgdesktopportal`;
  - the routing isn't deployed: `ewe-portal status` → `routing.ewe` false →
    run `ewe-setup`, then `systemctl --user restart xdg-desktop-portal`.
- **`qs ipc call` to a target the shell doesn't have exits 0** (it prints
  "Target not found."). Never trust the exit code: ewe-portal checks the word
  each verb returns (`ok`, `open`, `idle`). ewe-share-picker still trusts it
  and waits 300 s when the `picker` target is missing.
- **Testing the portal without touching the session:** `dbus-run-session` with
  `XDG_DESKTOP_PORTAL_DIR=<dir>` holding `ewe.portal` AND the
  `hyprland-portals.conf` (in that mode the frontend reads its config from
  that folder only), a fake `qs` on PATH, `ewe-portal serve`, then
  `ewe-portal test open …` (tests/ewe-portal-test.sh). For the nested shell:
  `HS_PRIVATE_BUS=1 HS_HEADLESS=1 driver.sh up`, run the daemon with the
  nested qs's environment and `EWE_QS_IPC="--pid <pid>"` — it goes between
  `ipc` and `call`. Editing a QML file reloads the nested shell and drops an
  open pick; the GTK dialog then appearing is the fallback working.
- **Proving a toolkit reaches the portal:** Qt's portal theme asks for the
  portal's FileChooser version asynchronously at start, so a test that opens
  `QFileDialog` immediately gets Qt's own dialog. Wait about a second first;
  `QT_QPA_PLATFORM=offscreen` loads no platform theme at all.


## eep and Applications (2026-11-22, eep 0.1 / ewe 0.48.1)

- **Applications "becomes laggy, not functional, breaks the UI"** (owner,
  2026-11-23, ewe-apps 0.3.1). Not eep and not the icons (SVG vs PNG
  measured the same): ewe Files' windowed grid took its row height from the
  FIRST RENDERED row. App names are one or two lines, so rows differed,
  each window measured another height, each height asked for another
  window — an endless microtask loop, the page frozen at 100 % CPU. The
  `WebKitWebProcess` SIGABRT core dumps are only the 10 s watchdog of a
  closed window whose page was stuck. Repro (headless): `--shot=applications
  --shot-height=656`, eight Down keys. Fixed in ewe-apps 0.4 (one tile
  height; measurement independent of what is rendered).
- **"I moved the card in, it looks installed, the first start takes
  forever"** (same day). Nothing showed that the app was still downloading,
  and `eep open` waited for the watcher's lock — a click on ANY card hung
  until the download ended, and three clicks started the app three times.
  eep 0.3 + ewe-apps 0.4: the activity file and the ring; a ready app
  starts with no lock.
- **The Install window covers the whole screen.** A window that cannot be
  resized floats on Hyprland by itself, but at the size of the screen (GTK
  takes the first size it is offered). It is an ordinary window; ewe's
  `eep-install` rule (title `Install an app`) gives it 400×380, centred.
  The rule and ewe-apps' `INSTALL_TITLE` / `INSTALL_SIZE` change together.
- **The first key of a `wtype` session is lost** in the cage harness: send
  a harmless key (`wtype -k Shift_L`) before the one that matters.

- **An app's card opened as text, or something other than the app ("GIMP
  opens as file manager")** (owner, 2026-11-22). eep was not installed on
  the machine, so `GIMP.eep` was a plain TOML file to everything: the
  launcher's file result went to `xdg-open` (text/plain → the editor), ewe
  Files to the GIO default. Fixed in ewe 0.49 / ewe-apps 0.3.1 / eep 0.2:
  ewe depends on eep (its package registers `application/x-eep` →
  `eep open`), the launcher leaves `~/Applications/*.eep` out of file
  results, Files says "update ewe" when eep is missing. Check: `xdg-mime
  query filetype ~/Applications/GIMP.eep` says `application/x-eep`.
- **An app vanished from the launcher but is still installed** (eep 0.2):
  its card went to the Trash, so eep hides it — `~/.local/share/applications/<entry>`
  carries `NoDisplay=true` + `X-Eep-Hides=sys-…`. Restore the card from the
  Trash (or `eep install sys-…`); a permanently deleted card stays hidden
  until then. Never delete an `X-Eep-Hides` file by hand while
  `~/.local/share/eep/hidden/<entry>` holds the user's own original — `eep
  install sys-…` puts it back.

- **Searching "firefox" in the launcher listed hundreds of files from
  `~/.local/share/containers`, `~/.config/zen`, Komble's AppImage prefixes**
  (owner, 2026-11-22). The launcher's plocate index (`~/.cache/ewe/files.db`)
  covered all of `$HOME`; only a short noise list was filtered, so apps'
  insides (podman storage alone: 326k files) came back as results. Fixed in
  ewe 0.48.1-beta: every hidden folder at the top of `$HOME` is pruned
  (`updatedb --add-prunepaths`), and results inside any hidden folder show
  only for a query that starts with a dot (`.zshrc`, `.env`). Check: search
  a name that only exists under `~/.local` — nothing comes back.
- **An eep app doesn't start or has no GL** — `eep doctor` first. Its usual
  causes, all handled by the package, are worth knowing when it says
  not-ready: the driver farm `/run/opengl-driver` comes from
  `eep-driver.timer` (system); ewe's session exports Arch's
  `__EGL_VENDOR_LIBRARY_FILENAMES`/Vulkan pins, which `eep run` clears; a
  command-line app must go through its shim in `~/.local/share/eep/bin`
  (it calls `eep run`), never the store path.
- **Firefox from eep took 8.7 s to open** — Nix's glibc can't use Arch's
  NSS modules, so the machine's own hostname didn't resolve until a timeout.
  The driver step adds the hostname to `/etc/hosts`; `.local` mDNS names
  still don't resolve for Nix apps.
- **After a power cut an eep app crashes with an empty library** — Nix had
  marked store paths valid whose files never reached the disk. eep keeps a
  crash journal and `syncfs` after every fetch; to repair an older store:
  `nix-store --verify --check-contents --repair`.
- **An app installed by eep has no bar title or icon, or the app writes a
  `userapp-*.desktop`** — the launcher entry must keep the app's own
  desktop-file name (eep marks its entries with `X-Eep-Id`, never renames
  them).
- **eep updated but the old watcher kept running** — `eep watch` re-execs
  itself when its binary is replaced; if a watcher predates that,
  `systemctl --user restart eep-watch`.
- **A card in the Trash keeps its app's disk** — on purpose: `eep gc` keeps
  apps whose card is in the Trash so a restore needs no download; emptying
  the Trash frees them on the next gc.

## The apps were slow to open, and small bugs (2026-11-23, ewe-apps 0.4.1)

Measured with `scripts/perf.sh` (ewe-apps) and strace unpacked into a temp
folder (`pacman -Sp strace`, nothing installed).

- **All three apps re-applied the theme five times a second** — the theme
  watcher (notify) took its own read of `theme-tokens.json` for a change:
  inotify reports OPEN and CLOSE_NOWRITE. Every notify watcher must drop
  `EventKind::Access(_)` (Files' folder watcher and ewe Sync's already did).
- **~40 ms of every start went to a title bar nobody sees** — tao shows a
  window before it turns the decorations off; on Wayland GTK builds its own
  title bar for that moment and loads three symbolic icons, and since
  gdk-pixbuf 2.44 an image is decoded by a sandboxed glycin loader that has
  to be spawned (bwrap). Build the window hidden, then show it. Never load
  a pixbuf on a start-up path.
- **150–250 ms went to fonts** — the faces are web fonts; text laid out
  before they arrive is measured with fallbacks, and WebKit finds a fallback
  by trying every family of the stack in turn, opening each file: eighteen
  Noto script faces, none with a Latin letter. Render after
  `document.fonts.load()`, preload the files, and keep a Latin-capable face
  ("Noto Sans") second in the stack — a single character Geist lacks (the
  narrow no-break space in "5:45 PM") walked the same list.
- **The first answers over Tauri's IPC come ~45 ms after the first call** —
  what a window needs to draw its first screen (theme, launch, media
  server) goes into an initialization script instead.
- **"Ctrl+C does nothing"** on the Georgian layout or with Caps Lock —
  `e.key` is the character typed, not the key. Match shortcuts on the Latin
  letter, falling back to the physical key (`comboKey`).
- **A file vanished after copy + paste in the same folder** — "Replace"
  removed the destination, which was the source. The same queue could lock
  up when a job finished while the page asked for the list (two locks taken
  in opposite orders).
- **A two-finger swipe zoomed a picture to 800 %** — a touchpad sends tens
  of small wheel events per swipe; one step per event is wrong for it.
- **`on(() => props.x.y, fn)` in Solid** runs `fn` whenever the source is
  re-evaluated, not when the value changes: every folder was listed twice.
  Give it a memo.

## KDE Connect over D-Bus (ewe Mobile, 2026-11-23)

What the daemon really does, found by asking a running `kdeconnectd` 26.08
with a paired phone (`busctl --user introspect org.kde.kdeconnect <path>`;
the daemon object itself needs `gdbus introspect` — busctl says "duplicate"):

- **SMS is on the device object.** `org.kde.kdeconnect.device.conversations`
  is an interface of `/modules/kdeconnect/devices/<id>`; a `/conversations`
  child does not exist (`No such object path`). The `/sms` child is the
  plugin's own, lower-level interface.
- **A message is a struct, not a dict:** `(i s a(s) x i i x i x a(xsss))` in
  a variant — event, body, addresses (each a struct `(s)`), date in ms, type
  (1 received, 2 sent, 5 failed), read, thread id, uid, SIM id, attachments
  (part id, mime, base64 thumbnail, unique id). A recipient for
  `sendWithoutConversation(av s av)` is that same struct `(s)` in a variant.
- **`replyToConversation` can do nothing, silently:** it looks the thread up
  in the daemon's cache and returns when it is not there. Check
  `activeConversations()` first, fall back to the addresses.
- **`requestAllConversationThreads` twice:** the first time each thread's
  newest message arrives as `conversationCreated`; asked again the daemon
  only emits `conversationLoaded(thread, count)` per thread. Read
  `activeConversations()` for what it already holds.
- **Contacts are files, not D-Bus:** vCard 2.1 in
  `~/.local/share/kpeoplevcard/kdeconnect-<id>/<uid>.vcf` — names as
  `CHARSET=UTF-8;ENCODING=QUOTED-PRINTABLE` (soft line breaks end in `=`),
  photos as folded `BASE64`.
- **The daemon never says a call ended** (`telephony.callReceived` has
  `ringing`, `talking`, `missedCall` and nothing after), and never reports
  back on a sent message: the UI must not claim more than it knows.
- **`busctl --user list` names services that COULD be started** (activatable)
  beside the running ones; a test that asks "did this start kdeconnectd?"
  wants `--acquired`.
- **A match rule's `sender` does not keep strangers out.** The bus delivers a
  signal sent straight at a client (a destination set) whatever that
  client's rules say, and a client-side filter cannot resolve a well-known
  name. Compare each signal's sender with `GetNameOwner` of the service
  (ewe Mobile's `pump`; `tests/origin.sh` proves it with an impostor).
- **A call to a unique name (`:1.42`) never starts a service** — the way to
  talk to a daemon only if it is already there, with no race.
- **Any method call on `org.kde.kdeconnect` starts the daemon** (D-Bus
  activation). `EWE_MOBILE_NO_DAEMON=1` / `EWE_PHONE_NO_DAEMON=1` and a
  private bus for every test, or the test is a new device on the network.
- **The Remote page does nothing on the phone** (2026-11-26) — before it is
  a bug it is the phone: Android takes a pointer and keys from KDE Connect
  only as an **accessibility service**, and drops them silently until it is
  one. Check `busctl --user get-property org.kde.kdeconnect
  …/devices/<id>/remotekeyboard org.kde.kdeconnect.device.remotekeyboard
  remoteState` with the phone in reach: `false` = switched off on the phone
  (KDE Connect for Android 1.36+; older ones say `true` only while their own
  keyboard is up). The page says so while it is false.
- **`sendKeyPress` has seven arguments since 26.08** — `super` came in
  before `sendAck`. Qt exports one D-Bus method per number of arguments, so
  six still "works" and the last one lands in `super`. Introspect before
  trusting a signature from an older note; `tests/remote.sh` holds it.
- **A phone's `scroll` is not a distance.** KDE Connect for Android adds
  `dy` up and turns ONE page when the sum passes 500, forward when positive
  — the opposite sign from a wheel, and a wheel notch (111 px in WebKitGTK)
  sent as it comes never gets there. Send whole pages.
- **A phone's storage, as the daemon tells it** (ewe Files 0.5.0, 2026-11-26,
  a Pixel): `…/devices/<id>/sftp` only exists while the phone is in reach;
  `mountAndWait()` → `b`, and the mount is sshfs at `mountPoint()` =
  `/run/user/1000/<id>`; `getDirectories()` → `a{sv}`, folder → its name
  (`/run/user/1000/<id>/storage/emulated/0` → "Internal shared storage").
  GIO's volume monitor never sees it (it hides `$XDG_RUNTIME_DIR`). The
  folders are the phone's words glued onto the mount point: take one only
  when it is inside the mount with no `..` (`phones.rs`, `dir_ok`). A paired
  device's `supportedPlugins` is remembered while it is away — that is how to
  know a phone offers storage before it is back.
- **Ask for a tool only when the thing it serves has failed.** ewe Files
  checked for `sshfs` before asking the daemon anything: on a machine without
  it (CI) a phone that was away read as "needs sshfs" and a stand-in daemon
  could not be connected at all. Name the missing tool after the mount fails.
- **What the phone makes of a click:** `singleclick` taps, `singlehold` /
  `singlerelease` put the finger down and lift it, `middleclick` Home,
  `backclick` Back, `forwardclick` and `doubleclick` Recents, `rightclick`
  the menu key on Android 16+ (Back before). The phone answers none of them;
  only a key is acknowledged (`sendAck` → `keyPressReceived`).

Building the app:

- **Svelte 5:** `const list = obj[k] ?? (obj[k] = [])` hands back the plain
  array, not the reactive one — pushes to it are never seen (the compiler
  warns `assignment_value_stale` in dev). Assign, then read it back. The same
  for an object pushed into a `$state` array: mutate the one read back from
  the array, not the literal.
- **`node --test tests/` works on Node 26 and fails on Node 22**
  (`MODULE_NOT_FOUND`: the older one takes the folder for a module to run).
  CI sets up 22: name the files, `node --test tests/*.test.js`.
- **A private repo's release is invisible to ewe-repo's publish workflow** —
  its `github.token` reads its own repo and public ones. A first-party app
  in a private repo is installed from its own release until it goes public
  (or the workflow is given a token of its own).
- **`gh repo create --public` is public at once**: ask which before creating
  (ewe Mobile was public for two minutes before the owner said "private").
- **A module imported from outside the page's graph is a second copy** — a
  screenshot script that `import()`s `state.svelte.js` drives nothing. The
  dev mock exposes the page's own (`window.__EWE_MOBILE_MOCK__.state`).
- **Screenshots without a window on the desktop:** a GTK window with a
  WebKit2 4.1 `WebView` inside `WLR_BACKENDS=headless cage`, then
  `get_snapshot` — the engine Tauri uses, at any size. The real binary runs
  in the same cage with `grim`. **The nested Hyprland harness does not start
  inside a headless cage** (`CBackend::create() failed`, with pixman and with
  the GPU renderer) — it needs the host session, and each failed try leaves
  a crash report in `~/.cache/hyprland/`.
- **Real input without a window on the desktop** (2026-11-26): in that
  headless cage, `wtype` types (also `-k dead_acute -k e`, a real
  composition) and a forty-line client of `wlr-virtual-pointer-unstable-v1`
  moves, presses, holds and scrolls — real pointer events in WebKitGTK, with
  pointer capture. The page under test is `MiniBrowser
  --enable-write-console-messages-to-stdout=true` on the dev mock
  (`trace=1`), or the built binary on `dbus-run-session` with a stand-in
  daemon. Three things the harness does that the app does not: the first key
  after a click is lost when no keyboard was on the seat at the click (keep
  one alive: `wtype -s 3000 -k Shift_L &`); `wl-copy` needs that keyboard
  too; and Ctrl+V / Shift+Insert from `wtype` never reach GTK's key
  bindings — paste with the middle button (`wl-copy --primary`).
- **WebKitGTK and paste:** a `paste` event's `clipboardData` is EMPTY for a
  pasted selection, on a text field and on anything else — the text arrives
  afterwards as the field's `input`. Take pasted text from a real, unseen
  `<textarea>`'s `input` event, never from the paste event; the same field
  gets dead keys and input methods as composition events.
- **`pkill -f <pattern>` kills the shell that runs it** when the pattern is
  in that shell's own command line. Stop test processes by pid, or by exact
  name (`pkill -x`).

## The phone as one ecosystem (2026-11-26, ewe 0.50 / ewe Mobile 0.2)

- **82 phone-app launcher entries became 82 `~/Applications` cards within a
  minute.** Cause: ewe Mobile 0.2.0 writes one
  `ewe-mobile-app-<package>.desktop` per phone app on any run (even
  `--apps`), and eep older than 0.4.1 finds every launcher entry and gives it
  a card (decision 75). **Fix: deploy eep first** — eep 0.4.1-beta skips
  entries marked `X-Eep-Skip=true`, and ewe-mobile's PKGBUILD says
  `conflicts=('eep<0.4.1beta')` so pacman refuses the wrong order. **Clean-up
  if it happened:** delete the marked entries (`~/.local/share/applications/
  ewe-mobile-app-*.desktop`, or unpair the phone) and eep retires the cards by
  itself; deleting the *cards* instead makes eep's watcher **hide the apps**
  (a card leaving = app hidden). Done the same evening: 71 cards left, no hide
  copies.
- **A phone notification has the app's name as title and "title: text" as
  body** — `kdeconnectd` sets `x-kde-display-appname` (and the sender as the
  summary) only when the notification server **advertises** that capability
  in `GetCapabilities`. The shell advertises it since 0.50; a server that does
  not gets the old layout.
- **KDE Connect's logo on a phone card.** Quickshell's `Notification.image`
  falls back to `image://icon/<appIcon>` when the notification carries no
  picture, so a card with no `image-data` drew the sender's `appIcon` — KDE
  Connect's logo. `Globals.hasPicture` tells a real picture from the fallback;
  with none the card shows ewe Mobile's entry icon, else the phone glyph, never
  `appIcon`.
- **"Initials" instead of the app's icon on a phone card** — the picture the
  PC shows is the notification's **large icon** on Android, and an app picks
  it (Google Messages sets a letter avatar of the contact). The fork now sends
  the app's launcher icon first (`AppIcons.launcherIconBitmap`, 96 px, rounded
  like the apps list) and falls back to the large or small icon only when that
  returns nothing.
- **`adb install -r` of an update keeps Android 17's accessibility service
  on; force-stopping the app switches it off.** Update over `install -r` and
  the pairing and the service survive (checked on the Pixel); `am force-stop`
  (or "Force stop" in settings) turns the service off and the Remote page and
  "open on the phone" from the background stop working until it is switched on
  again. Never force-stop to make the app reload.
- **Never `cat` the Android app's `shared_prefs`** — they hold the pairing's
  private key.
- **Two paired devices with one name** while the stock app and ewe Mobile for
  Android are both on the phone: pick by id; a device is ewe Mobile when its
  `remotecommands` list carries the `"ewe"` key. The stock app is uninstalled
  from the owner's phone and its entry unpaired.
- **Developer options on the phone is the price of "open here" and the
  screen**: TBC Bank and Liberty refuse to open while it is on (BOG opens).

## Related

- [[Testing and QA]] · [[Development Loops]] · [[Rules of the House]] ·
  [[Roadmap — ewe-cast]] · [[Plugin System]] · [[Quiet Lid — touch only a disabled panel]] ·
  [[Overview Takes the Screen]] · [[Roadmap — ewe-safe]]
