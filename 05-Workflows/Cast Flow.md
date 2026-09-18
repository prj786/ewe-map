---
tags:
  - ewe-map
  - workflow
title: Cast Flow
up: "[[Home]]"
---

# Cast Flow — mirror the desktop to a TV

The whole flow lives in the Control Centre's **Cast card**. No foreign
window, no gnome-network-displays, no DE it doesn't belong to.

```mermaid
sequenceDiagram
    participant U as you
    participant CC as Cast card (Quick Settings)
    participant SP as SharePicker (shell)
    participant CD as ewe-castd
    participant XDG as portal ScreenCast
    participant PW as PipeWire
    participant GST as GStreamer (VA-API H.264)
    participant TV as TV

    U->>CC: expand the Cast card
    CC->>CD: scan
    CD-->>CC: live sink list<br/>Miracast peers via NetworkManager P2P<br/>Chromecasts via avahi
    U->>CC: pick a sink
    CC->>SP: open the share picker (same as screen share)
    U->>SP: output / window / region
    CC->>CD: start <sink>
    CD->>XDG: ScreenCast session
    XDG-->>CD: PipeWire stream
    CD->>GST: encode — vah264enc (x264 fallback)
    GST-->>TV: Miracast: RTP/UDP MPEG-TS pt 33<br/>(we LISTEN on RTSP 7236 — the TV dials in)
    GST-->>TV: Chromecast: cast-channel v2 (TLS 8009)<br/>Default Media Receiver ← local HLS
    Note over CC: card shows sink name + stop button
    U->>CC: stop
    CC->>CD: stop
```

## The two sink paths

| sink | discovery | transport | latency |
|---|---|---|---|
| Miracast (Samsung…) | NetworkManager Wi-Fi P2P D-Bus | hand-rolled WFD RTSP source, port 7236; RTP/UDP MPEG-TS pt 33 | **real-time** |
| Chromecast / Google TV | avahi | cast-channel v2 (protobuf, TLS 8009), Default Media Receiver playing local HLS | seconds — honest; true mirroring is a future milestone |

## Status (2026-08-30)

Phases A+B built; Miracast proven against a **loopback sink**. First
real-TV field test pending.

## Related

- [[ewe-cast]] · [[Desktop Shell]] · [[Roadmap and Status]]
