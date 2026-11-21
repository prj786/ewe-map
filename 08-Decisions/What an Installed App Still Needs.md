---
tags:
  - ewe-map
  - decisions
title: What an Installed App Still Needs
up: "[[Decision Index]]"
---

# Komble fixes what an installed app still needs

**Decided 2026-11-21** (owner: "now i cant even play a video from
stremio"; decision 69). Built for Komble 0.24.0-beta on `feat/stremio` —
**not released**. Code: `komble-arch/src-tauri/src/needs.rs`,
`src/lib/components/AppNeeds.svelte`, `src/lib/curated.js`.

- **Cause (verified on the owner's box):** Stremio Enhanced (an Electron
  AppImage, or AUR `stremio-enhanced(-bin|-git)`) installs fine but plays
  almost nothing: on Linux it looks for Stremio's **streaming server** only
  as a **Flatpak** (`flatpak info com.stremio.Service` — ewe has no
  Flatpak) or as `server.js` in
  `$XDG_CONFIG_HOME/stremio-enhanced/streamingserver/`, which it runs with
  the system ffmpeg/ffprobe. The owner's folder held only `version.txt`;
  nothing listened on :11470 — no torrents, no transcoding.
- **The pattern:** `app_needs(id)` → `{"needs": [{id, title, detail,
  action, ok}]}` (empty for nearly every app) and `fix_app_need(need)` →
  `{"ok": true, …}` or an error string — Tauri commands inside Komble, shown
  as a warning card on the app's page and under its row in Installed, one
  button. A new need is one more arm in `needs.rs`.
- **The first need, `stremio-server`:** Stremio's own `server.js` from
  `dl.strem.io/server/<v>/desktop/server.js` at the version the app pinned
  in `version.txt`, else the one stremio-service's `Cargo.toml` names
  (`[package.metadata.server]`); the version must match `v<digits>.<digits>…`,
  the download 1–64 MB and not HTML; written beside and renamed. "Restart
  Stremio Enhanced afterwards."
- **The safe answer is curated:** Komble's Popular → Media lists
  **Stremio** = AUR `stremio-linux-shell` — Stremio's official Linux app,
  mpv and the server inside ("Its streaming server comes with it.").
  Stremio Enhanced stays searchable. Same pass: IntelliJ IDEA is
  `intellij-idea-oss` (the community-edition package left the repos).
- **Not done here:** a real stream played after the fix is not recorded as
  verified (dev-mock shots only); the plan's `stremio-service` package route
  was not taken (the file is all Stremio Enhanced reads).

> **Build guard:** Komble never decides an app's needs from guesses — each
> need names the app ids it applies to, checks its own `ok`, and fetches
> only from the app's own vendor with the version and size checked. No
> Flatpak in ewe. *Breaks if violated:* Komble downloads code for apps that
> don't want it, or a moved strem.io answer drops an HTML page where
> `server.js` should be.

## Related

- [[Komble]] · [[Komble — Arch Forced Decisions]] ·
  [[ewe Player Plays Links — yt-dlp]] · [[Troubleshooting Knowledge]]
