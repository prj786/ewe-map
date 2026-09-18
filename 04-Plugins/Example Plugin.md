---
tags:
  - ewe-map
  - plugin
title: Example Plugin
up: "[[Home]]"
---

# ewe-plugin-example — the reference plugin

`~/Projects/ewe/ewe-plugin-example` ·
[github.com/prj786/ewe-plugin-example](https://github.com/prj786/ewe-plugin-example)

The reference plugin for ewe — **copy it to start your own.** Three entry
points, one file each:

| kind | file | shows |
|---|---|---|
| `service` | `Service.qml` | a headless object: logs the shell version and accent via `Globals` and `Theme` |
| `panel` | `Panel.qml` | a `PanelWindow` with its own `IpcHandler` — `qs ipc call example.hello toggle` |
| `bar-widget` | `Widget.qml` | an `Item` the bar packs like a built-in indicator, click opens Settings |

## Try it

```sh
ewe-plugin add https://github.com/prj786/ewe-plugin-example.git --enable
qs ipc call example.hello toggle
ewe-plugin remove example.hello
```

## Make it yours

1. Change `id` in `manifest.json` to `<your-namespace>.<name>` (lowercase,
   `ewe.` is reserved).
2. Edit.
3. `ewe-plugin validate .`

The manifest fields, the kinds, what the shell exposes as public API and
the safe-mode rules are in ewe's
[`docs/PLUGINS.md`](https://github.com/prj786/ewe/blob/main/docs/PLUGINS.md).

> Plugins run unsandboxed inside the shell process. Keep yours small and
> honest, and so will everyone who reads it before enabling it.

MIT.

## Related

- [[Plugin System]] · [[Clipboard Plugin]] · [[Screenshot Plugin]] ·
  [[Passwords Plugin]]
