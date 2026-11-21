---
tags:
  - ewe-map
  - decisions
title: Every Script Reads Right — encodings, phone pictures, right-to-left
up: "[[Decision Index]]"
---

# Every script reads right — encodings, phone pictures, right-to-left

**Decided 2026-11-21** (decision 70). Built for ewe-apps 0.2.0-beta
(`feat/text-images`, merged into `feat/player-links`) and ewe 0.46.0-beta
(`feat/languages`, merged into `feat/media-languages`) — **not
released**. Translating ewe's own interface is **not** part of it (parked —
[[Parked and Rejected Ideas]]).

- **Text in any encoding, one helper** (ewe-app-core `text.rs`, route
  `/text/<name>?path=&t=[&enc=][&max=]`, `readText()` in `@ewe/shared`):
  a BOM (UTF-8/16) wins, then valid UTF-8, then BOM-less UTF-16, else
  Firefox's **chardetng** guesses — hinted by the language tag in the file
  name (`Movie.ru.srt`) or the system locale — and **encoding_rs**
  decodes. Answers UTF-8 with `X-Ewe-Encoding` (WHATWG name),
  `X-Ewe-Encoding-Confident`, `X-Ewe-Truncated`; `enc=` forces a label;
  `max=` reads a prefix (2 MB default, 32 MB at most). Used by the
  Player's subtitles (`subtitle_vtt {path, encoding?}`, a *Subtitle
  encoding* menu) and `.m3u` titles, the Viewer's text / Markdown / CSV
  (an encoding button; `--encoding=<label>`, `--encoding-menu`), Files'
  quick look and preview. Fixtures: one subtitle in cp1251/1253/1254/
  1255/1256, GBK, GB18030, Big5, Shift_JIS, EUC-KR, Latin-1, UTF-16 ±BOM.
- **Phone pictures:** WebKitGTK 2.54 shows AVIF and JPEG XL itself but has
  no HEIF decoder → `.heic/.heif/.hif` go through **`heif-dec`** (libheif,
  now an `ewe-apps` dependency) into an upright cached JPEG
  (`$XDG_CACHE_HOME/ewe-apps/pictures/`, LRU 512 MB, 30 s per decode);
  EXIF is read from the original. HEIC/AVIF/JXL thumbnails decode too.
  `webp-pixbuf-loader` (ewe's `common.list`) gives GTK3 apps WebP.
- **Right-to-left without mirroring:** every element that shows a user's
  name, title or tag carries `dir="auto"` (web) — an Arabic or Hebrew name
  reads right to left with its ellipsis at its own end, lined up with the
  left-to-right chrome; the shell's paragraphs follow their own direction
  and short labels sit by their icon. **ewe's own chrome is never
  mirrored** (`LayoutMirroring` stays off).
- **Fonts by name, never `system-ui`:** `system-ui` is not a fontconfig
  family on Arch — WebKit fell to FreeMono for Arabic (unjoined) and
  FreeSans for Hebrew. The apps' stacks name Noto faces (Arabic, Hebrew,
  Georgian, Armenian, Indic, Thai, Lao, Khmer, Myanmar, Ethiopic) before
  `system-ui`; ewe's Geist stacks name Noto Sans Arabic UI, Hebrew,
  Armenian and Noto Sans after Georgian, and the CSS token stacks drop
  `system-ui`. CJK stays with fontconfig (Source Han Sans by language).
- **Launcher:** CRLF `.desktop` files (LinOffice's Word, Excel …) were
  dropped by Quickshell entirely; `scripts/desktop-entries.py` writes LF
  copies into `$XDG_CACHE_HOME/ewe/desktop-entries/applications` (on the
  shell's `XDG_DATA_DIRS`, the user's files untouched) and the launcher
  matches a translated entry's English `Name` too.

> **Build guard:** decode user text through the one helper (never
> `TextDecoder('utf-8')` on a file); put `dir="auto"` on the element that
> clips (ellipsis follows it); never write `system-ui` as the only family;
> never mirror ewe's chrome. *Breaks if violated:* mojibake subtitles,
> unjoined Arabic, ellipses on the wrong end, apps missing from the
> launcher.

## Related

- [[ewe-apps]] · [[ewe Desktop]] · [[Troubleshooting Knowledge]] ·
  [[ewe Player Plays Links — yt-dlp]]
