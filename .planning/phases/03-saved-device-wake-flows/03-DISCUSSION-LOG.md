# Phase 3: Saved-Device Wake Flows - Discussion Log

> **Audit trail only.** Do not use as input to planning, research, or execution agents.
> Decisions are captured in CONTEXT.md — this log preserves the alternatives considered.

**Date:** 2026-04-12
**Phase:** 03-Saved-Device Wake Flows
**Areas discussed:** Menu wake surface, Menu row density, Recent and last-used memory, Shared send and status semantics

---

## Menu Wake Surface

| Option | Description | Selected |
|--------|-------------|----------|
| Short recents in root + full library path | Keep a compact recent-devices section in the root menu and route the full saved-device library through `所有设备` so every device stays reachable without bloating the root menu. | ✓ |
| Flat full-device list in root menu | Show every saved device directly in the root menu regardless of list length. | |
| Full submenu-only device access | Put all saved-device wake actions under a submenu, with no recent-device shortcuts in the root menu. | |

**User's choice:** `[auto]` Selected the recommended default: short recents in the root menu plus a full-library path.
**Notes:** Satisfies `WOL-01` while preserving the compact native menu direction from prior phases and research guidance.

---

## Menu Row Density

| Option | Description | Selected |
|--------|-------------|----------|
| Name-first quick rows | Use compact device-name labels for quick wake actions and keep MAC-heavy detail in deeper surfaces. | ✓ |
| Name + note rows | Show device names with note snippets in quick wake actions for extra context. | |
| Name + MAC rows | Show full MAC addresses directly in menu wake rows for maximum specificity. | |

**User's choice:** `[auto]` Selected the recommended default: compact name-first quick rows.
**Notes:** Keeps the menu scannable and avoids reintroducing management-style density into the status menu.

---

## Recent and Last-Used Memory

| Option | Description | Selected |
|--------|-------------|----------|
| Success-only recents + last-used preselection | Update recents and last-used saved-device memory only after a locally successful saved-device wake send, keep recents short, and reopen the WOL window with that last-used saved device selected unless an unfinished manual draft still exists. | ✓ |
| Selection-driven memory | Update recents and last-used state as soon as the user changes the picker or highlights a menu item. | |
| Window-only memory | Remember the last WOL window choice, but do not build recent-device behavior from actual sends. | |

**User's choice:** `[auto]` Selected the recommended default: success-only recents with last-used saved-device preselection.
**Notes:** Preserves truthful usage signals and carries forward Phase 1's unfinished-manual-draft behavior.

---

## Shared Send and Status Semantics

| Option | Description | Selected |
|--------|-------------|----------|
| One shared send state + persistent menu status row | Share one wake-send state across the menu and WOL window, disable all wake actions while a send is in progress, and keep one lightweight menu status row showing the active send or most recent result. | ✓ |
| Concurrent per-device sends | Allow multiple saved-device wakes at once and attach feedback only to the row that started the send. | |
| Window-only send state | Block duplicates only inside the WOL window and keep persistent status feedback out of the menu. | |

**User's choice:** `[auto]` Selected the recommended default: one shared send state with a persistent menu status row.
**Notes:** Best matches `RELY-04` and `UX-03` while preserving Phase 1's truthful send semantics.

---

## the agent's Discretion

- Exact submenu labels and grouping around the full-library path.
- Exact Chinese wording for status and section titles.
- Exact repository schema shape for recent-device and last-used metadata.
- Exact fallback choice when the remembered saved device no longer exists.

## Deferred Ideas

- Favorites or pinned devices separate from recents.
- Dedicated `Wake Last Device` keyboard shortcut.
- Advanced per-device network routing or diagnostics.
