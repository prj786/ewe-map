---
tags:
  - ewe-map
  - decisions
title: RFC-011 — One File Picker
up: "[[Home]]"
---

# RFC-011 — One file picker: ewe draws every Open / Save / Open with

*Status: **accepted and released 2026-11-22**. The owner asked on 2026-11-22:
"cant we have one ewe like looking app? the popup dialog where we can select
files we want. floating one always. now picker sometimes is under the app".
After the plan they said "go", then "commit and release". Both open questions
were settled as proposed: a dimmed screen behind the card, and Open with in
the same wave. Released in **ewe 0.48.0-beta** (ewe#91), with Komble
0.25.1-beta (komble-arch#24), ewe Settings 0.26.1-beta (ewe-settings#29),
ewe Sync 0.17.2-beta (ewe-sync#17), ewe Safe 0.5.2-beta (ewe-safe#25) and
ewe apps 0.2.1-beta (ewe-apps#3). The full text, with what Phase 0 found, is
`ewe/docs/RFC-011-file-picker.md`.*

## What was wrong

- **Many dialogs.** The routing was Arch's stock `hyprland-portals.conf`
  (`default=hyprland;gtk`) and xdph has no file chooser, so every app that asks
  the portal (ewe Browser and every Chromium/Electron app, GTK 4) got
  **xdg-desktop-portal-gtk's GTK 3 dialog**. Our own Tauri apps never asked:
  `tauri-plugin-dialog` defaults to the `gtk3` feature, so rfd drew a GTK dialog
  inside the app. Firefox and GTK 3 apps drew their own (GtkFileChooserNative
  without `GTK_USE_PORTAL`), and Qt apps showed Qt's (qt6ct
  `standard_dialogs=default`).
- **Underneath the app.** The portal's dialog is a separate process's window.
  A floating parent you click, a fullscreen or maximised parent, an XWayland
  parent (it can't be attached), or focus on another monitor could all leave
  it under the app.

## The decision

1. **The shell draws the picker** (`FilePicker.qml`, `AppChooser.qml`) on an
   **Overlay layer**. That is above every window, fullscreen included, so it
   can't end up underneath by construction. It exists only while a request
   is open (LazyLoader); the keyboard is Exclusive then and released when it
   closes. Layer surfaces stay in the shell (Rule 3).
2. **A daemon owns the portal backend:** `bin/ewe-portal` (Python, dbus-python).
   It survives shell restarts, per [[Process Split — Shell vs Apps]]. It writes
   the request to a file, asks the shell (`qs ipc call filepicker|appchooser
   open <file>`) and takes the answer on its own bus name
   (`org.ewe.Portal1.Answer`). When the shell can't answer — no `ok`, or two
   missed pings — **the same request goes to xdg-desktop-portal-gtk**, so a
   dialog never breaks.
3. **Only FileChooser and AppChooser** are routed to ewe; everything else stays
   `hyprland;gtk`.
4. **Every app that can ask, asks:** `GTK_USE_PORTAL=1`, qt6ct
   `standard_dialogs=xdgdesktopportal`, and the Tauri apps' dialog plugin on
   `xdg-portal`.

**Rejected:**
- **A picker mode in ewe Files.** A cold start every time, an ordinary window with
  the same stacking problem, and Tauri can't make layer surfaces.
- **Restyling GTK's dialog.** Still GTK, Qt and Tauri unchanged, stacking unchanged.
- **Third-party backends** (termfilechooser, shana): not ewe.

## Contracts

- **D-Bus:** `org.freedesktop.impl.portal.desktop.ewe` at
  `/org/freedesktop/portal/desktop` (FileChooser: OpenFile, SaveFile,
  SaveFiles; AppChooser: ChooseApplication, UpdateChoices; Request.Close);
  private `org.ewe.Portal1` at `/org/ewe/Portal` (`Answer(id, json)` → `b`,
  `Status()`).
- **IPC (public API, Rule 4):** `filepicker open|close|ping|select|cancel`,
  `appchooser open|update|close|ping|select|cancel`. `picker` stays the
  screen-share picker's.
- **Files:**
  - `~/.config/xdg-desktop-portal/` (linked from `dotfiles/xdg-desktop-portal`);
  - `~/.local/share/xdg-desktop-portal/portals/ewe.portal`;
  - `~/.local/share/dbus-1/services/org.freedesktop.impl.portal.desktop.ewe.service`;
  - `~/.config/systemd/user/ewe-portal.service`;
  - `~/.local/bin/ewe-portal`;
  - `$XDG_RUNTIME_DIR/ewe-portal/<id>.json` (0600, deleted when done);
  - state in `~/.local/state/ewe/filepicker.json` (last folder per app, list or grid, hidden files, sort — not ewe.conf; nothing syncs).
- **CLI:** `ewe-portal status` (routing as x-d-p sees it, backend, shell) and
  `ewe-portal test <kind> [--direct]`, which print JSON and exit 0.

## Build-guard

- x-d-p 1.22 reads the **user's** routing and portal files first, so the backend
  deploys per user with no root (`deploy_portal` in lib/deploy.sh, both
  install paths). `XDG_DESKTOP_PORTAL_DIR`, the frontend's test switch, also
  makes it read portals.conf from that folder only.
- `qs ipc call <missing target>` prints "Target not found." and **exits 0**.
  Every verb returns a word, and the daemon checks the word.
- `EWE_QS_IPC` (the nested shell's `--pid N`) goes **between `ipc` and
  `call`**.
- Editing a QML file reloads the nested shell and drops an open picker. That
  is the GTK fallback working, not a bug.
- Some apps can't be changed from outside: GIMP, JetBrains IDEs, Steam, Wine
  and Java apps draw their own dialogs.

## Related

- [[Process Split — Shell vs Apps]] · [[Rules of the House]] ·
  [[Troubleshooting Knowledge]] · [[Decision Index]]
