# Pitfalls Research

**Domain:** Native macOS menu bar Wake-on-LAN utility evolution
**Researched:** 2026-04-11
**Confidence:** HIGH

## Phase Legend

- **Phase 1: Device Persistence Foundation** — define device model, validation, storage contract, and migration rules.
- **Phase 2: Lifecycle and Architecture Seams** — remove notification/lifecycle fragility and isolate system side effects behind testable boundaries.
- **Phase 3: Reliability and Status Semantics** — make keep-awake and WOL feedback truthful, observable, and resilient.
- **Phase 4: Menu Bar UX Polish** — simplify the status menu and move heavier editing flows into the right surface.
- **Phase 5: Hardening and Regression Coverage** — add tests, fixtures, and verification for repeatable daily use.

## Critical Pitfalls

### Pitfall 1: Letting the View Own the Persistence Model

**What goes wrong:**
Device names, MAC addresses, notes, favorites, and recents get bolted directly onto `WOLView` state or scattered `UserDefaults` keys. The app works for one or two devices, then becomes hard to migrate, easy to corrupt, and awkward to extend.

**Why it happens:**
The current app is tiny, so adding `@State`, `@AppStorage`, or ad hoc encode/decode logic inside the existing SwiftUI form feels like the fastest path.

**How to avoid:**
Define a single persisted `SavedDevice` model before adding editing UI. Include a stable identifier plus normalized fields such as `displayName`, `macAddress`, `note`, `isFavorite`, `lastUsedAt`, `createdAt`, and `updatedAt`. Keep validation and normalization outside the view. Store one versioned collection through a repository boundary, and add migration tests before shipping schema changes.

**Warning signs:**
- Encode/decode logic appears inside `WOLView`.
- Favorites, recents, and notes are stored under separate unrelated keys.
- A close/reopen cycle loses edits or resets selection unexpectedly.
- Schema discussions show up as UI tweaks instead of store changes.

**Phase to address:**
Phase 1: Device Persistence Foundation

---

### Pitfall 2: Treating Local Data and Logs as Harmless

**What goes wrong:**
Real MAC addresses, notes, interface names, and broadcast addresses leak into source control or runtime logs. If notes become "where this machine lives" or "how to reach it," the app quietly turns personal infrastructure details into plain-text artifacts.

**Why it happens:**
This is a self-use utility, and the current code already prints raw network details and embeds a real device identifier in source. That makes it easy to keep doing the convenient thing.

**How to avoid:**
Remove personal device data from shipped source and fixtures. Use generic seed data only. Replace `print` diagnostics with `Logger` and mark MACs, IPs, notes, and other identifiers with privacy controls. Treat `UserDefaults` as acceptable only for nonsensitive configuration. If future data crosses into secrets, move it to Keychain instead of stretching notes or defaults beyond their intended use.

**Warning signs:**
- Git diffs contain real MAC addresses or personal device names.
- Console output includes full MACs, interface names, or broadcast targets in normal app runs.
- Notes start holding credentials, remote-access hints, or location details.
- Bug reports require manually scrubbing logs before sharing.

**Phase to address:**
Phase 1: Device Persistence Foundation, with logging cleanup completed no later than Phase 3

---

### Pitfall 3: Reporting Success Before the Side Effect Is Real

**What goes wrong:**
The menu can claim keep-awake is enabled when assertion creation failed, and the WOL flow can imply the device is awake when the app only knows a packet send succeeded locally. Once persistence adds recents or favorites, false success also pollutes stored usage signals.

**Why it happens:**
Menu bar apps reward immediate feedback, and low-level APIs often report only local success. The current keep-awake toggle already updates menu state optimistically.

**How to avoid:**
Make side-effect APIs return explicit results. Only update persistent recents or status badges after the local operation actually succeeds. Differentiate between `packet sent`, `send failed`, and `device wake not confirmed`. Keep labels honest: this utility can verify local send behavior more reliably than remote wake completion.

**Warning signs:**
- The icon or checkmark changes even when an underlying API call fails.
- "Success" text appears before async work finishes.
- Recent-device ordering changes after failed sends.
- User reports say "the app said it worked, but nothing woke up."

**Phase to address:**
Phase 3: Reliability and Status Semantics

---

### Pitfall 4: Turning the Status Menu Into a Tiny Settings App

**What goes wrong:**
The menu bar surface becomes cluttered with device management, notes, nested actions, and decorative icons. The app stops feeling like a native menu bar utility and starts feeling cramped, slow to scan, and inconsistent with macOS menu expectations.

**Why it happens:**
Persistence, favorites, and recents naturally tempt developers to keep adding menu items because the app already lives in the menu bar.

**How to avoid:**
Keep the status menu focused on high-frequency actions and current state. Put editing, long-form notes, and lower-frequency management into a dedicated small window or popover. Use concise verb-based labels, clear grouping, and separators. Keep submenus shallow and short. Use symbols only when they add clarity instead of ornament.

**Warning signs:**
- The menu requires scrolling or extended hovering to parse.
- More than one submenu level appears.
- Many rows use icons even though text already communicates the action.
- Editing a device requires several menu-only interactions instead of a focused form.

**Phase to address:**
Phase 4: Menu Bar UX Polish

---

### Pitfall 5: Growing NotificationCenter Into the Real Architecture

**What goes wrong:**
Window open, close, reset, and save behavior become an implicit graph of notifications. Richer persistence and status UX then amplify duplicate observers, stale state, double resets, and side effects firing in the wrong order.

**Why it happens:**
The current app already uses `NotificationCenter` as glue between a retained `NSWindowController` and SwiftUI view state. It works for a thin flow, but it does not scale cleanly when more events matter.

**How to avoid:**
Move window state ownership into one explicit coordinator or view model. Register observers once, or use token-based lifetimes that are cancelled deterministically. Prefer explicit method calls or published state over broadcast notifications for close/reset/save flows. Add repeated open/close tests before layering device editing on top.

**Warning signs:**
- Observer registration happens in `show()` or other repeatable paths.
- Reset logic is split across view callbacks, notifications, and delegate methods.
- Reopening the window produces duplicate callbacks or stale form values.
- Developers become unsure which event is responsible for clearing or saving state.

**Phase to address:**
Phase 2: Lifecycle and Architecture Seams

---

### Pitfall 6: Treating "Architecture Cleanup" as Permission for a Rewrite

**What goes wrong:**
The milestone balloons into a framework migration or broad rewrite, such as replacing the AppKit shell wholesale before stabilizing the behavior that already works. Existing keep-awake and WOL flows regress while the app is "cleaner" on paper.

**Why it happens:**
The current code is small enough that rewriting it feels cheap, and mixed AppKit/SwiftUI code often triggers an instinct to replace everything with one pattern.

**How to avoid:**
Refactor around seams, not ideology. Keep the current runtime shell unless a specific defect requires change. Extract interfaces for the device store, power assertion service, WOL sender, and menu state one by one. Preserve observed behavior with tests and manual verification at each seam before changing the next layer.

**Warning signs:**
- One branch changes entry point, storage, menu UX, and services together.
- Large protocol hierarchies appear before any new tests.
- Existing functionality gets reimplemented instead of wrapped.
- The team cannot describe the smallest shippable increment.

**Phase to address:**
Phase 2: Lifecycle and Architecture Seams

---

### Pitfall 7: Assuming a Small Utility Doesn’t Need Real Test Seams

**What goes wrong:**
Persistence, lifecycle, and state bugs survive because they only reproduce after repeated menu interactions or OS/network failures. Manual testing catches the happy path once, but not regression behavior across reopen cycles, failure paths, or schema evolution.

**Why it happens:**
The app is small, test targets already exist, and it feels faster to validate by clicking the menu bar. The current suite is still template-level, which makes this trap easy to continue.

**How to avoid:**
Introduce thin protocols or adapter types for power assertions, WOL sending, storage, clock/time, and notification delivery. Add unit tests for state transitions, normalization, migration, and failure handling. Add at least one UI test covering repeated open/close plus a basic persisted-device flow.

**Warning signs:**
- A PR says "tested manually" with no failure-path verification.
- There is no way to simulate assertion failure or socket send failure.
- Store migrations are untested.
- Reopen-cycle regressions keep reappearing.

**Phase to address:**
Phase 5: Hardening and Regression Coverage, with seam creation started in Phase 2

---

### Pitfall 8: Baking One-Network Assumptions Into the Product Surface

**What goes wrong:**
The app stores a MAC address and behaves as if wake delivery is universal, even though success depends on LAN topology, active interface, VPN state, Wi-Fi versus Ethernet path, and whether broadcasts are routed as expected. As saved devices and recents grow, those hidden differences look like random unreliability.

**Why it happens:**
The current sender fans out across IPv4 broadcast-capable interfaces and is tuned for a personal environment where one machine and one network likely dominate.

**How to avoid:**
Keep the mental model modest: the app sends WOL packets; it does not guarantee wake. Persist only the data you can justify, and avoid premature "smart routing" unless real usage proves it is needed. If interface-specific behavior becomes common, add limited diagnostics or a preferred-interface setting deliberately rather than through hidden heuristics.

**Warning signs:**
- The same device works on one network path and fails on another.
- Users ask which interface or subnet the app used.
- Reliability changes after VPN, Ethernet, or Wi-Fi transitions.
- Status copy says "awake" when the app only observed local packet send.

**Phase to address:**
Phase 3: Reliability and Status Semantics

## Technical Debt Patterns

Shortcuts that seem reasonable but create long-term problems.

| Shortcut | Immediate Benefit | Long-term Cost | When Acceptable |
|----------|-------------------|----------------|-----------------|
| Store device fields directly in SwiftUI view state or `@AppStorage` bindings | Very fast to prototype | Couples schema, validation, and UI lifecycle; makes migration painful | Only for throwaway spikes, never for the milestone implementation |
| Keep using real personal devices as defaults or fixtures | No setup friction during development | Leaks identifiers into git history, tests, screenshots, and logs | Never |
| Add more `NotificationCenter` events instead of defining ownership | Easy cross-layer signaling | Hidden ordering bugs, duplicate observers, stale state | Only as a temporary bridge while replacing an existing notification path |
| Put editing, favorites, recents, and notes directly in the status menu | Fewer windows and less code at first | Cluttered, unfamiliar menu UX that is hard to extend | Only for one or two highest-frequency actions |
| Do architecture cleanup and UX redesign in the same change set | Feels efficient | Makes regressions hard to isolate and review | Never |

## Integration Gotchas

Common mistakes when connecting platform services and local persistence.

| Integration | Common Mistake | Correct Approach |
|-------------|----------------|------------------|
| `UserDefaults` | Treating it like a mini database or secure store | Use it for nonsensitive settings and small persisted app data with a versioned schema; use Keychain if secrets ever appear |
| `Logger` / unified logging | Logging full MACs, notes, or network paths as plain text | Use structured logging and privacy controls so diagnostics remain useful without exposing identifiers |
| `NotificationCenter` | Using broadcast events as the primary state machine | Keep one owner for lifecycle state and use notifications only as a narrow bridge when necessary |
| IOKit power assertions | Updating UI state without checking call results | Return explicit success/failure from the power service and derive menu state from that result |
| BSD socket WOL sending | Treating `sendto` success as proof the device woke | Model it as local send success only, with optional diagnostics about interface/target selection |

## Performance Traps

Patterns that work at small scale but fail as usage grows.

| Trap | Symptoms | Prevention | When It Breaks |
|------|----------|------------|----------------|
| Enumerating every IPv4 broadcast target on each send | Noticeable delay or noisy logging during repeated WOL sends | Cache or narrow interface selection only after real evidence shows a need | Usually becomes annoying once the app is used repeatedly across multiple active interfaces |
| Persisting on every keystroke for notes or device edits | Partial invalid data saved, menu/window churn, harder undo behavior | Save on explicit commit points or debounced validated edits | Breaks as soon as notes or richer forms are introduced |
| Recomputing dynamic menu structure from loosely normalized device data | Duplicate or oddly ordered items, inconsistent favorites/recents | Normalize and sort data in one store/view-model layer before the menu consumes it | Shows up once the device list grows past a handful of entries |

## Security Mistakes

Domain-specific security and privacy mistakes for this utility.

| Mistake | Risk | Prevention |
|---------|------|------------|
| Keeping real MAC addresses in source or fixtures | Personal infrastructure details leak through git history and screenshots | Use generic fixtures and keep user-owned devices in local storage only |
| Logging raw MACs, notes, interfaces, and broadcast addresses | Console logs become a privacy leak and are harder to share safely | Use `Logger` with privacy annotations and keep verbose network logs behind debug-only controls |
| Letting notes become a bucket for secrets | Plain-text local storage starts holding credentials or operational details | Define notes as descriptive only, document that they are local plain text, and move secrets to Keychain if needed |

## UX Pitfalls

Common user experience mistakes in this domain.

| Pitfall | User Impact | Better Approach |
|---------|-------------|-----------------|
| Using the menu as both launcher and full editor | The menu becomes slow to scan and unpleasant for daily use | Keep the menu focused on quick actions and use a small dedicated editor window |
| Using optimistic status copy like "success" or "awake" | Users lose trust because the app overpromises what it actually knows | Prefer precise copy such as "packet sent" or a clear local failure message |
| Resetting fields on window close without a draft policy | Users lose partially entered work and feel the app is fragile | Decide explicitly whether edits autosave, commit, or discard, then implement one consistent rule |

## "Looks Done But Isn't" Checklist

- [ ] **Device persistence:** Often missing schema versioning and migration handling — verify old saved data still loads after field additions.
- [ ] **Keep-awake toggle:** Often missing failure-state handling — verify the menu item and icon stay accurate when assertion creation fails.
- [ ] **WOL reliability:** Often missing honest status semantics — verify the UI distinguishes local packet send from confirmed device wake.
- [ ] **Window lifecycle:** Often missing reopen-cycle verification — verify repeated open/close does not duplicate observers or stale state.
- [ ] **Logging cleanup:** Often missing privacy review — verify shipped logs do not expose raw identifiers by default.

## Recovery Strategies

When pitfalls occur despite prevention, how to recover.

| Pitfall | Recovery Cost | Recovery Steps |
|---------|---------------|----------------|
| View-owned persistence model shipped | MEDIUM | Freeze schema changes, introduce a canonical device model, write one migration path from legacy keys, and backfill tests before adding features |
| Notification-driven lifecycle bugs shipped | MEDIUM | Centralize ownership in one coordinator, remove duplicate observer registration, and add repeated open/close tests before more UX changes |
| False-success status shipped | LOW to MEDIUM | Change copy and result types first, stop writing recents on failed sends, then patch service APIs to surface real failure states |
| Menu clutter shipped | LOW | Move editing into a dedicated surface, reduce menu items to top actions and status, and re-test frequent daily flows |
| Sensitive identifiers leaked into logs or source | HIGH | Rotate fixtures to generic data, scrub logs and docs, remove personal defaults from history where practical, and switch to privacy-aware logging immediately |

## Pitfall-to-Phase Mapping

How roadmap phases should address these pitfalls.

| Pitfall | Prevention Phase | Verification |
|---------|------------------|--------------|
| Letting the view own the persistence model | Phase 1 | Device add/edit/remove, favorites, and recents all go through one store with migration coverage |
| Treating local data and logs as harmless | Phase 1 and Phase 3 | No real identifiers remain in source, and runtime logs redact sensitive values by default |
| Reporting success before the side effect is real | Phase 3 | Keep-awake failures do not flip UI state, and WOL copy clearly separates send from wake |
| Turning the status menu into a tiny settings app | Phase 4 | The status menu remains short, scannable, and limited to frequent actions and state |
| Growing NotificationCenter into the real architecture | Phase 2 | Repeated open/close cycles show no duplicate callbacks or stale reset behavior |
| Treating architecture cleanup as permission for a rewrite | Phase 2 | Refactors land incrementally with behavior parity checks for existing keep-awake and WOL flows |
| Assuming a small utility doesn’t need real test seams | Phase 5 | Unit and UI tests cover failure paths, reopen cycles, and persistence behavior |
| Baking one-network assumptions into the product surface | Phase 3 | Status copy, diagnostics, and any stored routing data match what the app can actually observe |

## Sources

- `.planning/PROJECT.md`
- `.planning/codebase/CONCERNS.md`
- `.planning/codebase/TESTING.md`
- `.planning/codebase/ARCHITECTURE.md`
- `Mac OS Swiss Knife/WOLView.swift`
- `Mac OS Swiss Knife/WOLWindow.swift`
- `Mac OS Swiss Knife/StatusBarController.swift`
- `Mac OS Swiss Knife/PowerAssertionManager.swift`
- `Mac OS Swiss Knife/WOLSender.swift`
- Apple Developer Documentation: `UserDefaults` — https://developer.apple.com/documentation/foundation/userdefaults
- Apple Developer Documentation: `OSLogPrivacy` — https://developer.apple.com/documentation/os/oslogprivacy/
- Apple Developer Documentation: `NSStatusBar` — https://developer.apple.com/documentation/AppKit/NSStatusBar
- Apple Human Interface Guidelines: `Menus` — https://developer.apple.com/design/human-interface-guidelines/menus

---
*Pitfalls research for: native macOS menu bar Wake-on-LAN utility evolution*
*Researched: 2026-04-11*
