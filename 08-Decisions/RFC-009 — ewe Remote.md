---
tags:
  - ewe-map
  - decisions
title: RFC-009 — ewe Remote
up: "[[Home]]"
---

# RFC-009 — Remote: your other ewe computers, over SSH

*Status: **accepted** 2026-11-01 (the owner asked the same day: "connect other
ewe PC with same account via ssh … on the PC I choose to share my PC for remote
control … not like rdp but fully ssh control … in ewe browser a new workspace
like remote-hostName from where I could open any website restricted from work
PC"). Answers taken on 2026-11-01: **Tailscale** is how two networks meet
(built into ewe, set up from ewe); **pairing is a code typed once**, with no
action needed on the shared PC at that moment; sharing gets **an indicator in
the bar and a Control Centre tile**. Shipped together with the network
honesty round in the same wave (see "The network round" below). **Released
2026-11-01**: ewe 0.38.0-beta (ewe#77), ewe browser 0.7.0-beta (ewe-browser#18),
ewe-sync 0.15.1-beta (ewe-sync#10).*

## The idea

On the work PC: **Control Centre → Share this computer → On**. It shows an
8-digit code. At home, the owner picks the work PC under **Your computers**
and types the code. That's it: from then on the home computer has a terminal
on the work PC, its files (SFTP) and a **browser workspace "via work-pc"**
whose traffic leaves from the work PC. Nobody has to click anything on the
work PC at the moment of pairing — it may be locked, unattended, across town.

Not screen sharing. It's an SSH login as the owner's user, with every SSH
power (shell, port forwards, SOCKS, SFTP), plus the browser workspace.

## Pieces

| Piece | Where | What |
|---|---|---|
| `ewe-remote` | `ewe/bin` (Python, JSON, exit 0) | keys, the sharing server, pairing, the account record, tunnels |
| `ewe-remote-sshd.service` | `ewe/systemd/` (systemd **--user**) | a per-user `sshd` on port **3933**, key-only, ewe's own `authorized_keys` |
| `ewe-tailscale` | `ewe/bin` | Tailscale status/health, one-prompt setup, sign-in, exit node off |
| Control Centre tile + page, bar glyph | shell (core, not a plugin: a security indicator must not be removable) | sharing on/off, the code, who is connected, Your computers |
| Settings → Network → Remote, Tailscale | `ewe-settings` | the same switches, for people who look there |
| Remote workspace | `ewe-browser` | a workspace bound to a computer: own partition, `socks5://` through `ewe-remote tunnel` |
| `[remote]` | `ewe.conf`, **LOCAL_ONLY** | `sharing` (bool), `port` (int) — per machine, never travels |

### Why a user-level sshd, not the system one

- No root: turning sharing on/off is starting/stopping a user unit — no
  polkit prompt, no `/etc/ssh` edits, no clash with a system `sshd` the owner
  already runs (the dev box has one).
- Its own `authorized_keys` (`~/.local/share/ewe/remote/authorized_keys`): ewe
  never touches `~/.ssh/authorized_keys`, and "Remove" is exact.
- Sharing lives with the session: logged out = not shared. Locked = still
  shared (that's the work-PC case). "Keep sharing when signed out" (linger)
  is a later option, off.
- Verified 2026-11-01 on OpenSSH 10.6: non-root `sshd -D -f <file>` logs in,
  `-D` SOCKS works (HTTP 200 through it), `internal-sftp` works. Without PAM
  the session has no `XDG_RUNTIME_DIR`/D-Bus → the config `SetEnv`s both, so
  `systemctl --user`, `qs ipc`, `notify-send` work from the remote shell.

sshd config (generated, `~/.local/share/ewe/remote/sshd_config`): `Port 3933`,
`HostKey …/host_ed25519`, `AuthorizedKeysFile …/authorized_keys`,
`PasswordAuthentication no`, `KbdInteractiveAuthentication no`, `UsePAM no`,
`PermitRootLogin no`, `AllowUsers <user>`, `AllowTcpForwarding yes`,
`X11Forwarding no`, `PermitTunnel no`, `GatewayPorts no`, `MaxAuthTries 3`,
`ClientAliveInterval 30`, `LogLevel VERBOSE` (logins name the key
fingerprint — that's how the bar knows *which* computer is connected),
`Subsystem sftp internal-sftp`, `SetEnv XDG_RUNTIME_DIR=… DBUS_SESSION_BUS_ADDRESS=…`.

### How two networks meet: Tailscale, built in

The owner's two machines already sit on one tailnet (`emoh`, `emoh-1`). The
work network blocks UDP (`netcheck: UDP is blocked`), so a direct connection
can't work there anyway — Tailscale's relays over 443 do.

- `tailscale` joins `packages/common.list` (installed everywhere), but
  **`tailscaled` is not enabled until the owner presses "Set up Tailscale"** —
  no daemon talks to a third party until asked.
- Setup = one admin prompt: `systemctl enable --now tailscaled` +
  `tailscale set --operator=$USER` (after that every action is the user's).
  Sign-in opens the login URL in ewe browser. Defaults set explicitly:
  `--accept-routes=false` (home and work are both `192.168.1.0/24` here — an
  accepted subnet route would eat the LAN), `--accept-dns=true` (resolved
  mode, phase 30), no exit node. A self-hosted control server (Headscale) is a
  "Login server" field.
- Without Tailscale, Remote works between computers on the same network (LAN
  addresses from the record), and says plainly why another one can't be
  reached.

### The account record — discovery only, never trust

Each sharing computer writes **`<sync.folder>/remote/<id>.json`** in the
owner's Nextcloud (WebDAV with `ewe-cloud token --json`, like the browser's
sync). One writer per file: only that computer's `ewe-remote`.

```json
{ "v": 1, "id": "3f9c0a1b2c3d4e5f", "name": "work-pc", "user": "you",
  "sharing": true, "port": 3933,
  "host_key": "ssh-ed25519 AAAA…",
  "addresses": { "tailscale": ["100.90.99.117"], "dns": "work-pc.tailXXXX.ts.net",
                 "lan": ["192.168.1.246"] },
  "ewe_version": "0.38.0-beta", "last_seen": 1793500000 }
```

- `id` = first 16 hex of `sha256("ewe:" + /etc/machine-id)` — stable, not the
  raw machine id, and **not the hostname**: the owner's two machines are both
  called `emoh` (Tailscale renamed one `emoh-1`), and ewe-sync's
  `machines/<hostname>.json` lets them overwrite each other (fixed in the same
  wave: ewe-sync moves to `machines/<id>.json`).
- The record is a **hint**. Someone holding the Nextcloud password can edit it
  — so nothing in it is trusted until the pairing below proves it.

### Pairing: a code, typed once, SPAKE2

The shared computer keeps an 8-digit code (`~/.local/share/ewe/remote/code`,
0600 — a file like the host key beside it, never `ewe.conf`). Shown on its
Control Centre page; **single-use** (a successful pairing makes a new one —
the paired computer can read it over SSH if a third one needs it).

1. Joiner connects to `user@address:3933` with a **public, well-known pairing
   key** shipped in ewe. Its `authorized_keys` line is
   `restrict,command="ewe-remote pair-serve" ssh-ed25519 … ewe-pairing` — no
   shell, no pty, no forwarding: the only thing it can do is speak pairing.
   The joiner records the host key it saw (temp known_hosts).
2. Both run **SPAKE2** (`python-spake2`, Arch `[extra]`) with the code: one
   guess per attempt, nothing an eavesdropper or the account can brute-force
   offline.
3. Host sends `HMAC(K, "host" ‖ host-key-fp)`; the joiner checks it against
   the key it actually connected to → the code also proves there's no man in
   the middle, and the host key gets pinned (`known_hosts` with
   `HostKeyAlias ewe-<id>`).
4. Joiner sends its own public key + `HMAC(K, "joiner" ‖ key ‖ id ‖ name)`;
   the host appends it to its `authorized_keys`
   (`… ewe-remote:<id>:<name>:<date>`), rotates the code, and the desktop
   says "home-laptop can now control this computer".
5. Guessing: one attempt per 5 s, 10 wrong codes → the code changes and the
   desktop says so.

Keys: each computer has one client key `~/.local/share/ewe/remote/id_ed25519`
(never leaves the machine). Revoke = remove the line + kill that key's sessions.

### Using a paired computer

- **Terminal**: kitty with `ssh -F ~/.local/share/ewe/remote/ssh_config ewe-<name>`
  (generated: best address first — Tailscale, then same-LAN — `HostKeyAlias`,
  `IdentitiesOnly`, `ControlMaster auto`, `ServerAliveInterval 30`).
- **Browse from it**: `ewe-remote tunnel <id>` keeps one `ssh -N -D
  127.0.0.1:<port>` per computer (reused, port from a free-port pick) and
  prints the SOCKS address; ewe browser's remote workspace uses its own
  partition (`persist:remote-<id>`, own cookies), `socks5://` (names resolve on
  the far side), WebRTC limited to proxied UDP (no local-IP leak), and a "via
  work-pc" chip in the bottom bar.
- **Files**: SFTP (`internal-sftp`), shown in the file manager later.

### ewe browser's remote workspace (built 2026-11-01, `feat/remote-workspace`)

- **+ → Browse from work-pc** (or `ewe-browser workspace create --remote
  <computer>`); the chip shows a monitor glyph; named after the computer.
- Own session `persist:remote-<id>`, `socks5://` via `ewe-remote tunnel`, a
  request gate that cancels everything until the tunnel is set, no direct
  fallback, WebRTC `disable_non_proxied_udp`, **loopback through the tunnel**
  (`<-loopback>`: `localhost` there is the remote computer's — its dev servers
  work, and remote pages can't reach this computer's local services).
- Leaks the e2e caught and closed: favicons (the browser UI fetched a remote
  tab's icon directly — now fetched through the tab's session as `data:`),
  `dns-prefetch` hints (resolved locally even behind a proxy — prefetch off for
  all pages).
- **No history** is recorded in a remote workspace (history views load
  `origin/favicon.ico` directly); remote workspaces' tabs are not synced; the
  binding lives only in the local `session.json` — sync can never create one
  on another computer. "This computer" is hidden/refused.
- A tunnel error re-runs `ewe-remote tunnel` once (new port) and reloads,
  then shows "work-pc can't be reached" (Try again · Go back). Downloads
  remember `via` and retry through it.
- A paired computer whose sharing is unknown (account unreachable) stays
  usable — the tunnel answers `not-sharing` if it is off.

### Indicators

- **Bar**: a share glyph while sharing is on; accent-coloured with a count
  while someone is connected (the mic-in-use pattern). Event-driven: the shell
  follows the unit's journal (`Accepted publickey … SHA256:…` / `Disconnected`)
  — no polling.
- **Control Centre**: tile "Share this computer" (Off / On · code / "home-laptop
  connected"); its page: switch, code (show / new), connected now (Disconnect),
  allowed computers (Remove), Your computers (Pair · Terminal · Browse from it).

## CLI contract (`ewe-remote`, JSON, exit 0)

```
status                         {"ok","this":{id,name,user,sharing,port,code?,addresses,sessions[]},
                                "computers":[{id,name,user,sharing,online,paired,allowed,addresses,last_seen}],
                                "tailscale":{installed,running,state,self}}
share on|off                   start/stop the unit, publish the record
code [--new]                   {"ok","code":"48219035"}   (this computer only)
pair <id|name> <code>          {"ok"} | {"ok":false,"error":"wrong-code|unreachable|not-sharing|busy|locked"}
forget <id>                    drop our pin + ssh_config entry for that computer
revoke <id>                    remove its key from our authorized_keys, end its sessions
disconnect <id>                end its sessions, keep the pairing
terminal <id>                  launch kitty with the ssh command
tunnel <id> [--port N]         {"ok","socks":"127.0.0.1:N","pid"}  (reuses a live one)
untunnel <id> · tunnels        stop one · list
publish                        write remote/<id>.json now
pair-serve                     the forced command (stdin/stdout JSON lines) — not for people
```

## The network round (same wave)

Owner, 2026-11-01: "cable based internet while it was connected and indicator
was showing … I still had problem". Evidence (work PC `emoh`, ewe 0.35.2,
`igc` 2.5G NIC, read over SSH with the owner's permission):

1. **28 Oct 18:15 — out of memory.** No swap at all: phase 60 only writes the
   zram config on **laptops**; a 31 GiB desktop had none. The kernel killed
   ewe browser; Tailscale's relay timed out, resolved flushed. → **zram on
   every chassis.**
2. **After two reboots the cable had a link (100 Mb/s) but DHCP never
   answered** — `ip-config-unavailable` every 45 s; after 4 tries
   NetworkManager **blocks the connection for 5 minutes**, and the lease came
   at 18:38 right after a block ended. The bar only knows "ethernet connected
   or not", so it said nothing useful and a reboot looked like the fix. →
   `20-ewe-wired.conf` (`ipv4.dhcp-timeout=infinity` for `type:ethernet`: a
   cable keeps asking, never "fails"), and **honest states**: *Cable plugged
   in — waiting for an address (3 min)*, *Connected — no internet*, *Sign in to
   this network*, *Cable at 100 Mb/s — the cable or port may be faulty*, with
   **Reconnect**.
3. Laptop dock (RTL8153) never saw a carrier on any boot since 18 Oct — that
   port now reads "Cable unplugged" instead of nothing.
4. Tailscale on the laptop: 44 `no-derp-connection`, 34 `captive-portal-detected`
   in a month, clustered at resume and work-VPN start. → Tailscale's health in
   Quick Settings + "Reconnect"; exit node shown (and one click off) — an
   offline exit node is the classic "Tailscale broke my internet".
5. Work PC disk: one Btrfs checksum error (28 Oct 18:18, ino 1227510) — told
   to the owner; `btrfs scrub` recommended.

## Rejected / parked

- **Trust every computer on the account automatically** — offered, not taken:
  whoever holds the Nextcloud app password would get a shell.
- **ewe's own relay** (no Tailscale) — parked: it's Tailscale's DERP rebuilt.
- **System sshd + `/etc/ssh/sshd_config.d`** — root for every toggle, clashes
  with an sshd the owner already runs.
- **Screen sharing (RDP/VNC)** — not asked for ("not like rdp").

## Related

[[RFC-005 — Nextcloud Account]] · [[RFC-006 — ewe-sync App]] ·
[[Security Posture]] · [[Phone and VPN]] · [[Troubleshooting Knowledge]]
