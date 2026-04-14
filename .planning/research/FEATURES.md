# Feature Research

**Domain:** Personal native macOS menu bar Wake-on-LAN utility
**Researched:** 2026-04-11
**Confidence:** MEDIUM

## Feature Landscape

### Table Stakes (Daily-Use Personal Reliability)

Features the next milestone should treat as expected for a self-use WOL utility. Missing these keeps the app in "prototype" territory.

| Feature | Why Expected | Complexity | Notes |
|---------|--------------|------------|-------|
| Persistent saved device library | Existing WOL tools consistently let users keep multiple devices or bookmarks instead of re-entering addresses every time. This directly addresses the current hardcoded-device problem in the codebase. | MEDIUM | Minimum model should be `name + MAC`, stored locally. Optional advanced fields like broadcast IP or port should stay deferred unless reliability work proves they are needed. |
| Add, edit, delete, and reorder devices in a dedicated management UI | Once devices are saved locally, users expect to fix labels, replace MAC addresses, and clean up stale entries without touching preferences files or source code. | MEDIUM | Do CRUD in a small window or panel, not inline in the menu. This keeps the menu fast and uncluttered. |
| One-click wake from the menu bar for saved devices | Menu bar WOL utilities position speed as the core value. Apple’s menu guidance also favors putting important, frequent actions first. | MEDIUM | For a short device list, show devices directly in the menu. If the list grows, move less-used items into a submenu rather than indenting them. |
| Reliable validation and explicit send feedback | A utility app gets judged on whether it works. The current codebase already has false-success and weak error-surface concerns, so accuracy is table stakes, not polish. | MEDIUM | Validate before save and before send, disable duplicate sends while in flight, and show a clear result like `Sent`, `Invalid MAC`, or `No broadcast path succeeded`. |
| Clear native menu grouping and toggle state | Apple explicitly recommends space-efficient grouped menus, sparing submenu use, and toggled items that communicate current state clearly. | LOW | The menu should have stable sections: keep-awake toggle, wake actions, manage devices, quit. Use checkmarks or changeable labels for current state. |
| Last-attempt status that survives closing the window | At least one menu bar WOL app exposes "status of last wake up," and daily-use reliability benefits from letting the user see what just happened without reopening a form. | LOW | Keep this lightweight: one recent result line or disabled menu item, not continuous monitoring. |

### Differentiators (Polish and Convenience)

These improve repeated personal use, but the app still delivers its core value without them.

| Feature | Value Proposition | Complexity | Notes |
|---------|-------------------|------------|-------|
| Optional per-device notes | Notes help disambiguate boxes that otherwise look identical, like two NAS units or a desktop and a VM host. Surveyed WOL utilities emphasize names, icons, or colors more often than notes, so notes are useful polish rather than a baseline expectation. | LOW | Keep notes short and secondary. Show them in the management UI and optionally in a submenu or inspector, not as noisy primary menu text. |
| Recent devices and pinned favorites | For a personal tool used on the same few machines, recents/favorites reduce scan time and keep the menu feeling fast. | LOW to MEDIUM | Best implementation is hybrid: pin a few favorites, then maintain a short recents list. Avoid a long flat history list in the root menu. |
| Remember last selected device when reopening the wake UI | This removes repetitive clicks for the common case where the same machine is woken repeatedly. | LOW | Good convenience win once the device store exists. It should never overwrite explicit favorites or recents ordering. |
| Subtle menu-bar polish for transient states | Small native touches improve trust: disabled items during send, consistent separators, and menu labels that reflect state instead of forcing the user to infer it. | LOW | This is where the milestone can feel "native" without adding more product surface. |
| Keyboard shortcut for `Wake Last Device` or `Manage Devices…` | Useful for personal self-use, especially when the app is menu-bar-first. | MEDIUM | Defer until menu structure and state management are stable. Shortcut support is nice, but not the main blocker today. |

### Anti-Features (Overcomplicate a Small Self-Use App)

These are tempting because other WOL tools or power-user utilities expose them, but they pull the app away from its stated scope.

| Feature | Why Requested | Why Problematic | Alternative |
|---------|---------------|-----------------|-------------|
| Automatic LAN scanning / network discovery | It sounds convenient because it promises less manual setup. | Discovery adds network complexity, false positives, permissions questions, and more surface area than a personal utility needs. It also does not guarantee WOL compatibility. | Manual add with strong validation, paste-friendly input, and maybe import from the last successful custom entry later. |
| Cloud sync, shared libraries, or account-backed device management | It seems useful for using the same device list across Macs. | This project is explicitly self-use and local-first. Sync introduces identity, conflict resolution, privacy, and failure modes that are unrelated to waking a few personal machines. | Local persistence only. Revisit only if multi-Mac use becomes an actual pain point. |
| Rich automation rules like wake on login, wake on Mac wake, scripts, or batch wake orchestration | Power-user WOL tools sometimes add these to look more "complete." | These features expand the app from a quick utility into an automation system. They increase surprise, background side effects, and debugging cost. | Start with explicit user-triggered wake actions and a simple `Wake Last Device` convenience path. |
| Deeply nested or editable menus | Menu bar utilities often keep adding items until the menu becomes the entire app. | Apple’s guidance warns against long or deep menus; inline editing in menus is especially awkward and fragile. | Keep the menu for quick actions; push editing and metadata management into a small dedicated panel/window. |

## Feature Dependencies

```text
[Persistent Device Library]
    ├──requires──> [Local Device Model]
    ├──enables──> [Menu Device List]
    ├──enables──> [Manage Devices UI]
    ├──enables──> [Per-Device Notes]
    └──enables──> [Recent Devices / Favorites]

[Reliable Send Pipeline]
    ├──enables──> [Last-Attempt Status]
    └──enables──> [Recent Devices Ordering]

[Manage Devices UI]
    └──edits──> [Persistent Device Library]

[Recent Devices / Favorites]
    └──enhances──> [One-Click Wake From Menu]

[Editable Menu UI]
    ──conflicts──> [Small Native Menu Structure]
```

### Dependency Notes

- **Persistent Device Library requires a local device model:** The app cannot support notes, recents, or device management until device records exist outside view-local state.
- **Manage Devices UI edits the persistent library:** CRUD and reordering belong in a dedicated editor, not in transient menu actions.
- **Reliable Send Pipeline enables last-attempt status:** If send outcomes are not trustworthy, surfacing recent result text just amplifies bad state.
- **Reliable Send Pipeline enables recent-device ordering:** Recents should be based on confirmed user actions, not optimistic UI taps alone.
- **Recent Devices / Favorites enhances one-click wake:** These are ranking layers on top of saved devices, not replacements for a stable device library.
- **Editable Menu UI conflicts with small native menu structure:** Trying to make the menu both a launcher and a full editor will hurt scan speed and native feel.

## MVP Definition

### Launch With (Next Milestone)

- [ ] Persistent local device library with `name + MAC` and local storage — this is the real unlock for daily use.
- [ ] Dedicated `Manage Devices…` flow for add/edit/delete/reorder — keeps management out of source code and out of the menu root.
- [ ] One-click wake from grouped menu sections — the app should feel useful without opening a full form every time.
- [ ] Reliable validation plus explicit last-attempt feedback — trust matters more than adding more options.
- [ ] Optional short notes field — small usability win with low implementation cost once the device model exists.

### Add After Validation (v1.x)

- [ ] Recent devices and pinned favorites — add once saved devices and status tracking are stable.
- [ ] Remember last selected device in the wake window — worth adding if repeated wake flows still feel too click-heavy.
- [ ] Keyboard shortcut for `Wake Last Device` or `Manage Devices…` — add after menu behavior is settled.

### Future Consideration (v2+)

- [ ] Advanced per-device networking fields like custom ports or broadcast targets — only if real hardware requires it.
- [ ] On-demand reachability check before/after wake — useful, but separate from the core "send magic packet reliably" job.
- [ ] Lightweight import/export of device list — only if local-device maintenance becomes a repeated friction point.

## Feature Prioritization Matrix

| Feature | User Value | Implementation Cost | Priority |
|---------|------------|---------------------|----------|
| Persistent local device library | HIGH | MEDIUM | P1 |
| Manage Devices UI | HIGH | MEDIUM | P1 |
| One-click wake from grouped menu | HIGH | MEDIUM | P1 |
| Reliable validation and last-attempt feedback | HIGH | MEDIUM | P1 |
| Optional per-device notes | MEDIUM | LOW | P1 |
| Recent devices / pinned favorites | MEDIUM | LOW to MEDIUM | P2 |
| Remember last selected device | MEDIUM | LOW | P2 |
| Keyboard shortcut | LOW to MEDIUM | MEDIUM | P3 |
| Advanced network fields | LOW | MEDIUM to HIGH | P3 |

**Priority key:**
- P1: Must have for this milestone
- P2: Good follow-on once P1 is stable
- P3: Defer unless a concrete daily-use need appears

## Competitor Feature Analysis

| Feature | Wake on Lan - Menu Bar | miniWOL | Our Approach |
|---------|------------------------|---------|--------------|
| Persistent saved devices | Explicitly markets "manage as many devices as you like" from the menu bar. | Markets a known-device list with assisted setup. | Treat as mandatory. This is the main gap between current code and daily usefulness. |
| Quick wake UX | Markets "quick and fast" wake directly from the menu bar. | Focuses on simple wake flows, though with more advanced options. | Keep quick wake in the menu root for the few most-used devices. |
| Last result / device status | Markets "watch status of last wake up." | Markets detection helpers and attempts to verify wake success. | Implement lightweight last-attempt status, not full background monitoring. |
| Metadata and personalization | Other surveyed WOL tools often add custom names, icons, or colors more than rich notes. | More setup helpers than metadata polish. | Use short notes as a pragmatic differentiator, but keep them secondary to device name. |
| Automation and advanced controls | Offers wake-after-login. | Offers custom ports, scripts, wake-on-start, and more. | Explicitly defer these. They are useful in bigger tools, but misaligned with this milestone’s "small, native, self-use" goal. |

## Sources

- Apple Human Interface Guidelines, Menus: https://developer.apple.com/design/human-interface-guidelines/menus
- Apple AppKit documentation, `NSStatusBar`: https://developer.apple.com/documentation/AppKit/NSStatusBar
- Apple SwiftUI article, Building and customizing the menu bar with SwiftUI: https://developer.apple.com/documentation/SwiftUI/Building-and-customizing-the-menu-bar-with-SwiftUI
- Wake on Lan - Menu Bar (Mac App Store): https://apps.apple.com/us/app/wake-on-lan-menu-bar/id1624703732
- miniWOL (Mac App Store): https://apps.apple.com/us/app/miniwol/id6504813686
- Wake On Lan (Mac App Store, Depicus): https://apps.apple.com/us/app/wake-on-lan/id412170664
- Wake Me Up - Wake-on-LAN (App Store): https://apps.apple.com/us/app/wake-me-up-wake-on-lan/id1465416032
- Magic Packet - Wake On Lan (App Store): https://apps.apple.com/us/app/magic-packet-wake-on-lan-wol/id1488937601

---
*Feature research for: Personal native macOS menu bar Wake-on-LAN utility*
*Researched: 2026-04-11*
