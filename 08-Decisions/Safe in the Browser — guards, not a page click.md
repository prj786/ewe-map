---
tags:
  - ewe-map
  - decisions
title: Safe in the Browser — guards, not a page click
up: "[[Decision Index]]"
---

# Safe in the Browser — guards, not a page click

**Decided 2026-10-15** while building `ewe-safe/docs/TRIO.md` §B1 on
ewe-browser's `feat/safe` — the owner approved it, merged as ewe-browser#4
and **released in ewe browser 0.2.0-beta** (2026-10-15). It amends
nothing in [[RFC-008 — ewe Safe]]; it is how the browser keeps S10 ("the browser decides the origin").

## The decisions

| decision | why |
|---|---|
| **Built in, not a store extension.** The main process talks to `ewe-safed` over its socket and fills the page's own fields | no extension protocol to secure; the browser knows the frame's real origin |
| **The browser draws the suggestion list** (an overlay view under the field), never the page's DOM. The focus stays in the page's field: typing filters, ↑ ↓ Enter Esc work | the page can't read or restyle it (1Password uses an extension iframe for the same reason) |
| It opens on a **user's** focus (a click or Tab), never on page load or script focus. Setting `safe.suggest` (on); off = the key icon and ArrowDown only | fill is a click |
| **Passkeys** through a main-world override of `navigator.credentials` (`publicKey` requests only), installed with `contextBridge.executeInMainWorld` before the page's first script. Setting `safe.passkeys` (on). *Use a security key instead* hands the request to Chromium's own WebAuthn | sites see a normal platform authenticator; everything else is untouched |
| **The passkey sheet may open without a click on the page** (as Chrome does). Guards instead: the list and the sheet ignore a click until they have stood still for 500 ms and the mouse moved; Enter in the sheet works only after an arrow-key choice; the origin is re-checked at Save / pick; a list pick signs only for the request it was built for | Chrome does the same; the guards stop a page from tricking the user into a click (clickjacking) |
| **Frames from another site are refused** (`NotAllowedError`) in this version | the contract's first version (TRIO.md §B1); allowing them is later work |
| Site matching: exact host, then the registrable domain (public-suffix list incl. private suffixes); https never to http; ports equal | a login is offered only to its own site |

## Not verified yet

Real sites (github.com, google.com); *Use a security key instead* with a
real key (Electron's WebAuthn has no window and ignores its timeout — the
browser adds its own); zoom other than 100 %; the list's place in a
cross-site frame.

## Related

- [[Decision Index]] · [[ewe-browser]] · [[ewe-safe]] · [[RFC-008 — ewe Safe]] ·
  [[Security Posture]]
