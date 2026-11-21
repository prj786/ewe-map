---
tags:
  - ewe-map
  - decisions
title: ewe Player Plays Links — yt-dlp
up: "[[Decision Index]]"
---

# ewe Player plays web page links — through yt-dlp

**Decided 2026-11-21** (owner: "we are promising some next update — what's
that? let's implement it already … now i cant even play a video from
stremio"; decision 68). Built for ewe-apps 0.2.0-beta on
`feat/player-links` (merged with `feat/text-images`) — **not released**.
Code: `ewe-apps/apps/player/src-tauri/src/{links,support,probe}.rs`,
`packages/shared/src/{player,links,languages}.ts`; map: ewe-apps
`AGENTS.md` "Links", "Errors", "Languages".

- **The owner's "Cannot play watch" was two bugs, not a missing codec.**
  gst-libav had shipped since ewe 0.44; "watch" was a YouTube *page*
  (`watch?v=`), and (1) the error page blamed GStreamer + gst-libav for
  any remote URL with "comes with the next update" hard-coded, (2) the
  `<video>` carried `crossorigin`, which every CDN without CORS refuses.
  Now `crossorigin` is set only for the loopback server's files, and the
  sentence is gone from the repo.
- **yt-dlp is a dependency** of the `ewe-apps` package (it pulls
  `yt-dlp-ejs` + `deno` for YouTube's challenge); `mpv` is an optdepend
  (*Open in mpv*). `resolve_link`: a link whose path names media
  (`.mp4 .m3u8 .mpd` …) or answers `video/*`, `audio/*`, HLS or DASH plays
  as it is; anything else → `yt-dlp -J --no-playlist --flat-playlist` (60
  s cap) and `pick()` chooses the **HLS master** (YouTube; WebKit's
  `hlsdemux`, seeks), a **progressive** file with both tracks (≤ 1080
  lines, mp4/H.264 first), a muxed HLS variant, a **DASH** `.mpd` (BBC).
  Split video + audio only → *unplayable* (offers mpv); `has_drm` →
  *locked*. A playlist page becomes queue entries. Resolved when it
  becomes current ("Getting the video…"), cached an hour, asked again once
  when a stream fails (googlevideo URLs expire); a link that loads nothing
  in 20 s is asked again, then explained.
- **The public way in:** **`ewe-player <http(s)-url>`** (a second launch
  forwards it to the running window), Ctrl+L / *Open URL…*, a dropped or
  pasted link, an M3U of page links. ewe Browser's *Play in ewe Player*
  and Shaun call exactly that.
- **Honest errors** (`decodeFailureMessage` → `PlayFailure {kind,
  actions}`): *a web page with no video*, *needs yt-dlp*, *DRM*, yt-dlp's
  own sentence ("Private video."), *gst-libav* only when `media_support`
  says it is missing, else the codec in words. Actions: Open with another
  app, Open in ewe Browser, Open in mpv (only when on PATH), Try again,
  Next.
- **Languages:** track menus in native names ("English", "Русский ·
  Commentary", "ქართული"); preferred audio + subtitle language
  (`auto` = the system's) picked automatically; subtitles come on by
  themselves only when the sound is in another language.
- **Verified** (release build, headless): YouTube `watch?v=`, Twitch VOD +
  clip, a BBC News page, a direct CDN `.mp4` without CORS, an M3U of two
  page links, `ewe-player <url>` forwarded — all play and seek. **Not
  done:** the ffmpeg remux route for split-only sites (none of the tested
  ones needed it); Vimeo (DRM / login); link drops from a browser.

> **Build guard:** never put `crossorigin` on a remote `<video>` (CDNs
> send no CORS); never blame gst-libav without `media_support`; keep
> `ewe-player <url>` as the one entry point (rule 4 — ewe Browser and Shaun
> bind to it); links stay at ≤ 100 % volume (Web Audio plays a
> cross-origin source as silence). *Breaks if violated:* every link fails
> as "format not supported" with a false fix; Play in ewe Player breaks on
> installed machines.

## Related

- [[ewe-apps]] · [[ewe's Own Apps — Files, Player, Viewer]] ·
  [[ewe-browser]] · [[Contracts and Public API]] ·
  [[Troubleshooting Knowledge]]
