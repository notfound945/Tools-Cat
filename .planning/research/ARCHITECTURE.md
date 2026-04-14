# Architecture Research

**Domain:** personal macOS menu bar Wake-on-LAN utility
**Researched:** 2026-04-11
**Confidence:** HIGH

## Standard Architecture

### System Overview

The right target here is not a rewrite to a pure SwiftUI app and not a mini clean-architecture framework. Keep the current hybrid AppKit/SwiftUI shape, but make state ownership explicit:

1. `AppDelegate` remains the composition root and owns long-lived controllers.
2. AppKit stays at the shell: menu bar item, window presentation, lifecycle hooks.
3. SwiftUI owns feature views and feature-local presentation logic.
4. Persistence and side effects move behind small protocols so views stop talking directly to `UserDefaults`, IOKit, and BSD sockets.

```text
┌──────────────────────────────────────────────────────────────────────┐
│                         App Shell (AppKit)                          │
├──────────────────────────────────────────────────────────────────────┤
│  AppDelegate / AppEnvironment / StatusBarController / WOLWindow     │
│  - bootstraps dependencies                                           │
│  - owns menu item + window lifecycle                                 │
│  - translates AppKit events into feature actions                     │
├──────────────────────────────────────────────────────────────────────┤
│                     Feature State + SwiftUI UI                       │
├──────────────────────────────────────────────────────────────────────┤
│  WOLViewModel            DevicesSettingsViewModel                    │
│  WOLView                 DevicesSettingsView                         │
│  - transient send state  - CRUD/editing state                        │
│  - validation            - notes, ordering, recent/default selection │
├──────────────────────────────────────────────────────────────────────┤
│                 Small Application Services / Stores                  │
├──────────────────────────────────────────────────────────────────────┤
│  DeviceRepository   WOLService   PowerAssertionService   StatusStore │
│  UserDefaults       BSD socket   IOKit wrapper           last result │
└──────────────────────────────────────────────────────────────────────┘
```

### Component Responsibilities

| Component | Responsibility | Typical Implementation |
|-----------|----------------|------------------------|
| `AppDelegate` / `AppEnvironment` | Own app startup, construct dependencies once, retain status bar and WOL window controllers | Small composition root in the existing app target |
| `StatusBarController` | Render the menu, show keep-awake state, open the WOL window, optionally surface last result text | AppKit controller with injected read-only state and callbacks |
| `WOLWindow` | Present and close the wake window, own the hosted SwiftUI root, stop using notifications as state transport | `NSWindowController` with constructor-injected view model / close closure |
| `WOLViewModel` | Own transient send flow state: selected device, manual MAC, sending, validation, result message | `@MainActor final class ... : ObservableObject` |
| `DevicesSettingsViewModel` | Own device CRUD, notes editing, ordering, recent-device rules, persistence commits | SwiftUI-facing object backed by repository |
| `DeviceRepository` | Persist devices and recent/default selection, publish updates to feature view models | `UserDefaults`-backed `Codable` store, no database |
| `WOLService` | Send validated wake packets and return typed results/errors | Thin protocol over the existing `WOLSender` implementation |
| `PowerAssertionService` | Toggle and query keep-awake state with real success/failure | Thin protocol over `PowerAssertionManager` |
| `StatusStore` | Hold last user-visible operation state for menu/window feedback | Tiny in-memory object, optionally persisting only last-selected device ID |

## Recommended Project Structure

Keep one app target. Add folders only where they remove confusion.

```text
Mac OS Swiss Knife/
├── App/
│   ├── Mac_OS_Swiss_KnifeApp.swift   # scenes and app entry
│   ├── AppDelegate.swift             # composition root
│   └── AppEnvironment.swift          # dependency wiring
├── MenuBar/
│   └── StatusBarController.swift     # AppKit menu shell
├── WakeOnLAN/
│   ├── WOLWindow.swift               # AppKit window host
│   ├── WOLView.swift                 # send UI
│   ├── WOLViewModel.swift            # transient feature state
│   ├── DevicesSettingsView.swift     # settings CRUD UI
│   ├── DevicesSettingsViewModel.swift
│   └── Device.swift                  # saved device model
├── Persistence/
│   ├── DeviceRepository.swift        # protocol
│   └── UserDefaultsDeviceRepository.swift
├── Services/
│   ├── WOLService.swift              # protocol + adapter
│   ├── PowerAssertionService.swift   # protocol + adapter
│   └── StatusStore.swift             # session-level status
└── Shared/
    └── Logger.swift                  # optional OSLog wrapper later
```

### Structure Rationale

- **`App/`:** keeps lifecycle and dependency construction together so long-lived ownership remains obvious.
- **`MenuBar/`:** isolates AppKit menu code from feature and persistence logic.
- **`WakeOnLAN/`:** groups the feature that is actually changing; this is the main unit of iteration for the milestone.
- **`Persistence/`:** makes device storage explicit without pretending the app needs a full data layer.
- **`Services/`:** creates the minimum seams needed for testing and reliable status reporting.

## Architectural Patterns

### Pattern 1: Composition Root + Thin Adapters

**What:** Construct real services once in `AppDelegate`, then inject protocols into controllers and view models.
**When to use:** Immediately. This is the smallest change that unlocks testing and keeps future changes localized.
**Trade-offs:** A few more initializer parameters, but much lower coupling than global singletons.

**Example:**
```swift
@MainActor
final class AppEnvironment {
    let devices: DeviceRepository
    let wol: WOLService
    let power: PowerAssertionService
    let status: StatusStore

    init() {
        devices = UserDefaultsDeviceRepository()
        wol = SystemWOLService()
        power = SystemPowerAssertionService()
        status = StatusStore()
    }
}
```

### Pattern 2: Feature View Model Owns Transient State

**What:** `WOLView` becomes a rendering surface. Validation, async send, result mapping, and recent-device updates move into `WOLViewModel`.
**When to use:** Before adding persistent devices or richer feedback. Otherwise new logic keeps piling into the view.
**Trade-offs:** Slightly more files, but state transitions become testable and window lifecycle gets simpler.

**Example:**
```swift
@MainActor
final class WOLViewModel: ObservableObject {
    @Published var selectedDeviceID: UUID?
    @Published var manualMAC = ""
    @Published var isSending = false
    @Published var statusMessage: String?

    private let devices: DeviceRepository
    private let wol: WOLService
    private let status: StatusStore

    func send() async {
        let target = resolveTarget()
        isSending = true
        defer { isSending = false }

        do {
            try await wol.send(to: target.macAddress)
            try devices.markUsed(target.id, at: Date())
            status.record(.wakeSucceeded(target.displayName))
            statusMessage = "发送成功"
        } catch {
            status.record(.wakeFailed(target.displayName, message: error.localizedDescription))
            statusMessage = "发送失败：\(error.localizedDescription)"
        }
    }
}
```

### Pattern 3: `UserDefaults` Repository, Not Core Data / SwiftData

**What:** Persist a small array of `Codable` devices and a few preference keys locally.
**When to use:** This milestone. The app is a personal utility with a small device list and no sync.
**Trade-offs:** No complex queries, but that is fine here. Simpler migration story than introducing a database.

Use:
- `UserDefaults` + JSON-encoded `[Device]` for the device list and notes
- `UserDefaults` scalar keys for `lastSelectedDeviceID`, `preferredDeviceID`, and small preferences
- `@AppStorage` only for simple settings bound directly to a Settings view

Do not use:
- Core Data / SwiftData
- a separate helper process
- a DI framework
- event buses for feature state

## Data Flow

### Request Flow

```text
[Menu click or WOL window action]
    ↓
[StatusBarController / WOLView]
    ↓
[WOLViewModel or Power action handler]
    ↓
[WOLService / PowerAssertionService]
    ↓
[DeviceRepository + StatusStore update]
    ↓
[Published state change]
    ↓
[Menu + window redraw from derived state]
```

### State Management

Use three clearly separated state buckets:

```text
Persisted state
    Device list
    Device notes
    Preferred / last-selected device
    Last-used timestamps
        ↓ loaded by repository

Session state
    isSending
    current validation error
    last wake result
    current keep-awake status
        ↓ exposed through view model / status store

Derived UI state
    picker items
    recent devices section
    menu icon/checkmark
    disabled/enabled controls
```

### Key Data Flows

1. **Device management flow:** `Settings` scene edits devices through `DevicesSettingsViewModel` → repository saves to `UserDefaults` → repository publishes updated list → WOL send UI and menu read the new list.
2. **Wake flow:** WOL UI chooses a device or manual MAC → `WOLViewModel` validates → `WOLService` sends → repository records recency → `StatusStore` records user-visible result → menu/window update from the new state.
3. **Keep-awake flow:** Menu toggle invokes `PowerAssertionService.setEnabled(...)` → service returns real success/failure → status controller updates icon/checkmark only from returned state, never optimistically.

## Suggested Ownership Boundaries

### Long-Lived Objects

Owned by `AppDelegate`:

- `AppEnvironment`
- `StatusBarController`
- `WOLWindow`

These should live for the process lifetime or close to it.

### Feature-Scoped Objects

Owned by the window or settings scene:

- `WOLViewModel`
- `DevicesSettingsViewModel`

These may be recreated when the view/window is recreated.

### Persisted Records

Owned by `DeviceRepository`:

- `Device`
- `RecentDeviceMetadata`
- preference keys related to selection/order

Views should never mutate persisted models directly without going through the repository or a feature view model.

## Suggested Build Order

This matters more than the final diagram. The safe path is to introduce seams before moving UX around.

1. **Add service protocols around current side effects.**
   - Wrap `PowerAssertionManager` and `WOLSender`.
   - Make keep-awake return success/failure or current state.
   - This fixes the current false-success path before more UI depends on it.

2. **Introduce `Device` model + `UserDefaultsDeviceRepository`.**
   - Replace the hardcoded device array in `WOLView`.
   - Seed from the current preset once if needed, then treat persistence as the source of truth.

3. **Extract `WOLViewModel` and remove business logic from `WOLView`.**
   - Move validation, async send, recent-device writes, and status mapping out of the view.
   - Keep the existing window and menu UI mostly unchanged.

4. **Replace notification-driven window state with explicit ownership.**
   - `WOLWindow` should host the view with constructor-injected dependencies and call `viewModel.resetForPresentation()` on show if needed.
   - Close actions should use callbacks/closures, not `NotificationCenter` as a feature-state bus.

5. **Fill the existing `Settings` scene with device management UI.**
   - Use a native macOS settings window for CRUD and notes editing.
   - Use `@AppStorage` only for simple preferences; let the repository own the actual device list.

6. **Add recent-device and status feedback surfaces.**
   - Show recent or preferred devices in the send UI first.
   - Optionally show the last wake result as a disabled menu row or tooltip-like summary.
   - Keep this derived from repository/status state instead of duplicating flags in AppKit and SwiftUI.

7. **Only then consider `MenuBarExtra(.window)` migration, if still needed.**
   - Apple supports richer menu bar content with `MenuBarExtra` in `.window` style.
   - For this milestone, it is optional. Do not migrate the shell until the feature seams are already clean.

## Scaling Considerations

| Scale | Architecture Adjustments |
|-------|--------------------------|
| 1-5 devices, single user | Current recommendation is enough: one target, `UserDefaults`, one window, one settings scene |
| 5-25 devices, more sorting/notes | Add repository query helpers, search/filter UI, and clearer recent/favorite ordering |
| Beyond personal utility scope | Re-evaluate product scope before architecture. If it becomes a real device manager, the storage and UI model should change deliberately, not incrementally |

### Scaling Priorities

1. **First bottleneck:** duplicated state between AppKit shell and SwiftUI views. Fix with shared services/view models before adding more UI.
2. **Second bottleneck:** persistence shape. If `UserDefaults` becomes awkward because device records grow, move to a file-backed store later, not a database now.

## Anti-Patterns

### Anti-Pattern 1: Rewriting the Shell First

**What people do:** Replace `NSStatusItem` + `NSWindowController` with `MenuBarExtra(.window)` immediately because it looks more modern.
**Why it's wrong:** It changes lifecycle, presentation, and feature code at the same time, which makes brownfield regressions hard to isolate.
**Do this instead:** Keep the AppKit shell for now. Clean state and service boundaries first, then decide whether the shell rewrite still buys anything.

### Anti-Pattern 2: Letting Views Own Persistence and Side Effects

**What people do:** Store device arrays in `@State` or `@AppStorage`, call `WOLSender` directly from the view, and coordinate close/reset through notifications.
**Why it's wrong:** The same feature state gets split across views, controllers, and global notifications, which is exactly the current fragility.
**Do this instead:** Put persistence in a repository, side effects in services, and transient flow state in a feature view model.

### Anti-Pattern 3: Inventing Too Many Layers for a Utility App

**What people do:** Add use-case folders, coordinators everywhere, repository factories, or multiple modules because the app now has persistence.
**Why it's wrong:** The project becomes harder to navigate than the problem is complex.
**Do this instead:** Keep one app target, one composition root, a few protocols, and feature-scoped view models. Add new abstractions only when a second feature genuinely needs them.

## Integration Points

### External Services

| Service | Integration Pattern | Notes |
|---------|---------------------|-------|
| IOKit power assertions | `PowerAssertionService` adapter | Must return real state to prevent menu/icon drift |
| BSD sockets / network interfaces | `WOLService` adapter over `WOLSender` | Keep interface enumeration hidden from UI |
| `UserDefaults` | `UserDefaultsDeviceRepository` | Good fit for a small personal device list and preferences |
| SwiftUI Settings scene | Native preferences window | Best place for device CRUD and notes editing |

### Internal Boundaries

| Boundary | Communication | Notes |
|----------|---------------|-------|
| `AppDelegate` ↔ `StatusBarController` | direct ownership + callbacks | Keep AppKit lifecycle centralized |
| `WOLWindow` ↔ `WOLViewModel` | direct injection | Prefer this over notifications |
| `WOLViewModel` ↔ `DeviceRepository` | protocol API | Single source of truth for saved devices and recents |
| `StatusBarController` ↔ `StatusStore` | read-only subscription / polling on menu open | Menu state should be derived, not duplicated |
| `Settings` scene ↔ repository | view model + repository | Ensures edits appear everywhere consistently |

## Apple Platform Implications

- `Settings` is the right native place for device management in a SwiftUI app. The current app already exposes a `Settings` scene stub, so filling it is lower risk than inventing a separate editor window.
- `AppStorage` is appropriate for small scalar preferences backed by `UserDefaults`, but it is not the primary architecture for the device list itself.
- `MenuBarExtra` with `.window` style is a valid future direction for richer menu bar content, but it should be treated as a shell swap after the milestone's state seams are cleaned up.

## Recommendation

For this milestone, keep the app as a hybrid AppKit/SwiftUI utility and add exactly four architectural moves:

1. A small composition root.
2. A `UserDefaults`-backed device repository.
3. A WOL feature view model.
4. Thin service adapters for power and networking.

That is enough to support persistent devices, recent-device state, reliable native feedback, and cleaner seams without turning a personal menu bar tool into a framework exercise.

## Sources

- Local project context: `.planning/PROJECT.md`
- Local codebase analysis: `.planning/codebase/ARCHITECTURE.md`
- Local codebase concerns: `.planning/codebase/CONCERNS.md`
- Local conventions: `.planning/codebase/CONVENTIONS.md`
- Apple Developer Documentation: `MenuBarExtra` — https://developer.apple.com/documentation/SwiftUI/MenuBarExtra
- Apple Developer Documentation: `Settings` — https://developer.apple.com/documentation/swiftui/settings
- Apple Developer Documentation: `AppStorage` — https://developer.apple.com/documentation/SwiftUI/AppStorage
- Apple Developer Documentation: `defaultAppStorage(_:)` — https://developer.apple.com/documentation/swiftui/view/defaultappstorage%28_%3A%29

---
*Architecture research for: personal macOS menu bar Wake-on-LAN utility*
*Researched: 2026-04-11*
