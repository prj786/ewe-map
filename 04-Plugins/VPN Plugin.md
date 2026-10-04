---
tags:
  - ewe-map
  - plugin
title: VPN Plugin
up: "[[Plugin System]]"
---

# VPN — `ewe.vpn`

`~/Projects/ewe/ewe-plugin-vpn` ·
[github.com/prj786/ewe-plugin-vpn](https://github.com/prj786/ewe-plugin-vpn)
· v1.0.0 · API 3 · **add-on since 0.25** (was the VPN tile + page in Quick
settings).

Your NetworkManager VPN connections (OpenVPN, L2TP/IPsec, WireGuard …): a
split tile (body connects/disconnects — the only profile, or opens the list
— chevron opens the page), rows to connect/disconnect, a **one-time
sign-in form** under a row whose secrets are not stored (username,
password, PSK; stored with `password-flags=0`, root-only under
`/etc/NetworkManager`). Failures carry the real reason: when NM only says
"The VPN service failed to start", the add-on reads the plugin's line from
the NM journal — for IPsec with the IKEv1/libreswan hint.

| kind | file |
|---|---|
| `quick-tile` (order 20) | `Tile.qml` |
| `quick-page` key **`vpn`** (order 20) | `Page.qml` |
| `bar-status` (order 21) — a shield while up, a **spinner while connecting** (in the plugin's glyph) | `Status.qml` |

## Facts

- **Install:** Komble → Add-ons, or `ewe-plugin install ewe.vpn`.
- **Stays core:** profiles are created in Settings → Network → VPN
  (`ewe-conf` `[network.vpn]`), by import, or `nmcli`; the secret prompt
  for a NM agent request stays the core `Auth.qml`; the NM plugins and
  libreswan ship with ewe ([[Phone and VPN]]).
- **Fresh:** its own `setpriv --pdeathsig TERM nmcli monitor` (400 ms
  debounce, backoff) + a read at start, after `Shell.resumed()` and when
  the tile/page appears.
- `requires` names only the command `nmcli`: `missing` is per package, so
  listing `networkmanager-openvpn` would flag the add-on broken for users
  of one VPN type (the README names them) — [[Add-on deps declared, not split]].
- No settings, no IPC target: `quicksettings tab vpn`.

Open: a `Shell` network-changed signal would remove the second `nmcli
monitor` (core has one too).

## Related

- [[Plugin System]] · [[SSH Plugin]] · [[Phone and VPN]] · [[Troubleshooting Knowledge]]
