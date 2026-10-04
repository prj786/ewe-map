---
tags:
  - ewe-map
  - decisions
title: Quiet Lid — touch only a disabled panel
up: "[[Decision Index]]"
---

# Lid-open touches only a disabled panel; re-asserts are per output (A2)

**Decided 2026-10-04** (ewe `fix/lid-resume-blinks`, in 0.25.0-beta).
Opening the lid used to blink the screen 3–4 times before the password
field. Four unconditional actions were stacked on one event:

1. `after_sleep_cmd` ran `hyprctl dispatch dpms on` unconditionally
   (hypridle.conf, the shell's Settings.qml generator **and** ewe-settings'
   `hypr.js`);
2. `Lid._open` re-sent `preferred/auto` + dpms for every output;
3. `HyprMon._reassertT` re-applied the whole monitor set;
4. the Lock surface's `sourceSize` was bound to the surface, re-decoding
   the backdrop on every map.

**The decision:** lid-open touches **only a panel that is disabled**, with
its **saved spec** (never `preferred/auto`), and every re-assert is
**per-output and minimal** — `applyMatching` runs `verifyOne` per output
and issues `hl.monitor` only for an output that does **not** already
match. `force` (full re-apply) exists only for *Reset displays*. An
unconditional `dpms on` exists nowhere except that Reset.

Two siblings fixed in the same branch (details in
[[Troubleshooting Knowledge]]): a **hibernate resume re-sleeping 0.1–0.7 s
later** (stale `HyprMon.lidClosed` + Qt timers elapsing through the
transition — every sleep decision now re-reads
`/proc/acpi/button/lid/*/state` via `HyprMon.probeLid()`, and `Lid` logs
`lid: going to sleep: <reason>` at WARN), and **every lid-close suspend
waiting the full delay** (the logind bridge read one line per wakeup —
buffered `os.read` now, `tests/logind-bridge-test.py`, 17 checks).

> **Build guard:** never issue `hl.monitor` for an output that already
> matches; never an unconditional dpms-on except *Reset displays*; the
> ewe-settings `hypr.js` generator and the shell's generator must emit the
> same **guarded** `after_sleep_cmd`. *Breaks if violated:* the blink comes
> back on every lid-open and the lock screen re-decodes its wallpaper.

Real-hardware check still pending on the user's laptop (nested harness has
no lid).

## Related

- [[Decision Index]] · [[Shell Singletons]] · [[ewe-settings]] · [[Troubleshooting Knowledge]]
