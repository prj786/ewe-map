---
tags:
  - ewe-map
  - roadmap
title: Roadmap — ewe-cast
up: "[[Home]]"
---

# Roadmap — ewe-cast

Current: phases A+B built (2026-08-30). Miracast proven against the
loopback Samsung impersonator (`test/wfd_sink_sim.py`); **phase C is the
gate.**

## Phase C — field-proven on real hardware

The only way to drop gnome-network-displays. The field checklist:

- [ ] real Samsung (or other Miracast TV): connect, negotiate M1→M7, stream
- [ ] real Chromecast / Google TV: discover, cast-channel v2, HLS playback
- [ ] long-run stability (Wi-Fi power-save fix verified live:
      `iw dev wlan0 get power_save` → `off` while casting)
- [ ] audio follows to the TV (`cast-audio.sh` makes the null sink default,
      restores speakers on stop)
- [ ] the shell's journal narrator surfaces real failure reasons
      (handshake timeout / refused / connected-then-dropped)

Until C: **gnd stays installed** behind `qs ipc call cast legacy` — the
escape hatch if a real TV meets a v0 bug mid-presentation. `EWE_CAST_FAKE=1`
keeps shell UI work honest without hardware.

## After C

1. Remove the gnd dependency and the legacy path (only after field proof).
2. **Chromecast true mirroring** — Google's real protocol; the current HLS
   path is seconds of latency, honestly stated. This is the known big-ticket
   milestone.
3. "Cast this file" from Komble / shell (the daemon design anticipated it).
4. Profiling gate for a Rust rewrite — only if measured performance demands
   (see [[RFC-004 — ewe-castd, Python not Rust]]).

## The known-hardware knowledge base

The 2026-08-21 investigation (see `ewe/docs/TROUBLESHOOTING.md` → "Cast to
TV") found four real-world failure classes:

1. `xdg-desktop-portal-hyprland` 1.4.1 screencopy retry bug → ewe ships the
   patched `1.4.1-1.1` from `packages/patched/` (retires itself when the
   repos catch up).
2. Software x264 lag → `gst-plugin-va` (`vah264enc`).
3. Wi-Fi Direct shares the Wi-Fi channel + no reg domain → `wireless-regdb`
   + GeoIP country in phase 30; prefer 5 GHz.
4. Wi-Fi power saving drops the group → NetworkManager dispatcher
   `50-ewe-cast-powersave` (power_save off while any `p2p-*` is up).

`~/.config/hypr/scripts/cast-check.sh` checks all of it.

> **Build guard:** any future cast bug report goes through these four
> classes *first* — they have bitten before and the fixes are shipped.

## Related

- [[ewe-cast]] · [[Cast Flow]] · [[RFC-004 — ewe-castd, Python not Rust]] ·
  [[Open Questions]]
