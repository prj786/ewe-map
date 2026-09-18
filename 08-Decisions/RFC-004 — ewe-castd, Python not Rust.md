---
tags:
  - ewe-map
  - decisions
title: RFC-004 — ewe-castd, Python not Rust
up: "[[Home]]"
---

# RFC-004 — `ewe-castd`: headless daemon, Python on GLib

*Status: phases A+B built (2026-08-30); Miracast proven against a loopback
sink; phase C (field-proven on real Samsung + Chromecast) is the gate for
dropping gnome-network-displays. Until then gnd stays behind
`qs ipc call cast legacy` as the escape hatch.*

## The decision

Casting moves out of `gnome-network-displays` (a gtk4/libadwaita window in a
DE that deliberately has neither, driven by SIGTERM) into **ewe's own
headless daemon**, driven entirely from the Quick Settings Cast card.

## Why a daemon and not a library in the shell

1. Casting must **survive shell restarts** (`ewe.service` respawns on crash
   — a dropped call mid-presentation is unacceptable).
2. It wants **real threads** for the media pipeline.
3. Komble/future apps may want "cast this file" someday.

Same argument that made `ewe-auth` a broker — state that outlives the shell
lives outside the shell.

## The documented deviation: Python, not Rust

The original RFC said Rust. The built daemon is **Python on GLib**. The
media heavy lifting is all C (GStreamer); what's left is IO-bound protocol
logic, and Python-with-GLib is **the house pattern** (ewe-auth, ewe-conf)
with zero new dependencies on an ewe install. A Rust rewrite stays on the
table **if profiling ever demands it** — not before.

> **Build guard:** don't "fix" this to Rust on principle. The deviation is
> recorded and reasoned; the trigger for revisiting is measured
> performance, nothing else.

## What exists

- Sink A (Miracast): NM Wi-Fi P2P D-Bus + hand-rolled WFD RTSP source —
  **we LISTEN on 7236, the TV dials in** (verified against gnd's behavior).
  RTP/UDP MPEG-TS pt 33. The real-time path.
- Sink B (Chromecast): avahi discovery + cast-channel v2 (protobuf
  hand-encoded, TLS 8009), Default Media Receiver playing a local HLS
  stream. Seconds of latency — honest.
- Testing: `test/run.sh` plays the daemon against `test/wfd_sink_sim.py`, a
  loopback Samsung impersonator (full M1→M7 negotiation, counts RTP packets,
  checks clean 188-byte-aligned MPEG-TS). `EWE_CAST_FAKE=1` adds imaginary
  sinks for shell UI work.

## Related

- [[ewe-cast]] · [[Cast Flow]] · [[Decision Index]] · [[Roadmap — ewe-cast]]
