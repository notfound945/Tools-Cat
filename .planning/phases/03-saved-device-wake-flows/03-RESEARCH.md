# Phase 3: Saved-Device Wake Flows - Research

**Researched:** 2026-04-12
**Domain:** Native macOS saved-device wake acceleration for a small local Wake-on-LAN utility
**Confidence:** MEDIUM

<user_constraints>
## User Constraints (from CONTEXT.md)

### Locked Decisions

### Menu Wake Access
- **D-01:** Keep the root menu compact with a short recent-devices section plus an `所有设备` path for the full library.
- **D-02:** Every saved device must remain wakeable from the menu bar; recents are only an acceleration layer.
- **D-03:** Quick wake rows stay compact and name-first; full MAC addresses do not belong in high-frequency root-menu actions.

### Recent and Last-Used Memory
- **D-04:** Update recent-device ordering and last-used saved-device memory only after a locally successful saved-device wake send.
- **D-05:** Keep recents short at three devices, ordered most-recent-first.
- **D-06:** Reopening the WOL window should default to preset mode with the most recently used saved device selected.
- **D-07:** Do not overwrite an unfinished manual MAC draft just to force preset preselection.
- **D-08:** If there is no saved-device history yet, fall back to canonical library order rather than inventing ranking logic.

### Shared Send and Status Semantics
- **D-09:** Menu-triggered and window-triggered wakes must share one send state.
- **D-10:** While a send is in progress, all saved-device wake actions should be disabled rather than queued.
- **D-11:** The menu should expose one lightweight status row that shows in-flight state and then preserves the last local success or failure until replaced.
- **D-12:** Success copy must stay Phase 1 truthful: local packet send only, not confirmed remote wake.

### the agent's Discretion
- Exact submenu and row labels around the `所有设备` path.
- Exact Chinese status wording and section titles.
- Exact persistence shape for recents and last-used metadata.
- Exact fallback choice when the remembered saved device no longer exists.

### Deferred Ideas (OUT OF SCOPE)
- Favorites or pinned devices separate from recents
- Dedicated `Wake Last Device` keyboard shortcut
- Advanced per-device networking diagnostics or routing
</user_constraints>

<phase_requirements>
## Phase Requirements

| ID | Description | Research Support |
|----|-------------|------------------|
| WOL-01 | User can wake any saved device directly from the menu bar | Requires compact root-menu actions, a full-library path, and menu/controller wiring into the shared WOL session |
| WOL-03 | User sees the most recently used saved device preselected when reopening the WOL window | Requires persisted last-used saved-device identity plus reopen logic that respects manual draft preservation |
| WOL-04 | User can access a short recent-devices list for faster repeat wake actions | Requires persisted recent-device metadata derived from successful sends only and rendered in menu order |
| RELY-04 | User cannot accidentally trigger duplicate wake sends while another send is in progress | Requires one shared send state across menu and window, with all wake actions disabled during in-flight sends |
| UX-03 | User sees the result of the most recent wake attempt without needing to reopen or reinterpret the UI | Requires a persistent menu status row backed by explicit success/failure state rather than transient view-local copy |
</phase_requirements>

## Summary

Phase 3 is not a new networking feature; it is a workflow acceleration layer on top of the saved-device work from Phase 2 and the truthful result semantics from Phase 1. The current codebase already has the right long-lived seams for this: `AppDelegate.swift` owns one shared `SavedDeviceLibraryStore` and one retained `WOLSessionModel`, `WOLView.swift` already sends through that shared session, and `StatusBarController.swift` already owns the compact root menu where quick wake actions belong.

The main implementation gap is that saved-device usage metadata does not exist yet. `SavedDeviceRepository.swift` only persists the ordered device array, `SavedDeviceLibraryStore.swift` only publishes devices, and `WOLSessionModel.swift` only knows the active picker selection and current send state. Phase 3 therefore needs one deliberate extension of the shared persistence/store/session seam before any menu work: store recent-device IDs and last-used saved-device ID, prune them when devices disappear, and expose them through the same shared store that both the menu and WOL window already read.

**Primary recommendation:** extend the existing saved-device repository/store to own recent-device and last-used metadata, then let the single retained `WOLSessionModel` remain the authoritative send-state owner for both the status menu and the WOL window. Build the menu from that shared state instead of introducing a second wake controller, queue, or menu-local model.

## Project Constraints

- Stay within the existing native AppKit + SwiftUI menu-bar architecture.
- Preserve the dedicated device-management window from Phase 2; do not move editing into the menu.
- Keep the menu short and scannable; no long flat list of device rows in the root menu.
- Continue using truthful local-send semantics from Phase 1; do not imply the remote device is awake.
- Follow existing repo conventions: flat Swift file layout, English identifiers, Chinese runtime strings, and small feature-scoped types rather than a subsystem rewrite.

## Standard Stack

### Core
| Library | Version | Purpose | Why Standard |
|---------|---------|---------|--------------|
| SwiftUI | macOS SDK 26.2, deployment target 15.6 | WOL window bindings and picker state | Already used by `WOLView.swift`; sufficient for preset/manual switching and reopen behavior |
| AppKit/Cocoa | macOS SDK 26.2 | Status menu structure, submenu wiring, retained windows | Required for the existing menu-bar shell and dynamic wake-action menu |
| Foundation `Codable` | macOS SDK 26.2 | Persist recent-device and last-used metadata | Extends the Phase 2 local persistence seam without adding a database |
| `UserDefaults` | macOS SDK 26.2 | Local storage for saved-device metadata | Right-sized for a tiny personal device library and short usage history |

### Supporting
| Library | Version | Purpose | When to Use |
|---------|---------|---------|-------------|
| Combine `ObservableObject` | macOS SDK 26.2 | Shared menu/window send state and store updates | Use for the retained `WOLSessionModel` and `SavedDeviceLibraryStore` already in the app |
| XCTest | Xcode 26.2 | Store, session, and menu-controller unit coverage | Use for all phase logic that can be verified without live menu-bar automation |
| XCUITest / manual smoke | Xcode 26.2 | Narrow smoke verification for visible native menu/window behavior | Use only where AppKit status menus remain awkward to prove through pure unit tests |

### Alternatives Considered
| Instead of | Could Use | Tradeoff |
|------------|-----------|----------|
| Extending the shared repository/store | A second `UserDefaults` helper or menu-only metadata cache | Faster to spike, but guarantees drift between menu and WOL window state |
| Shared `WOLSessionModel` send ownership | Separate menu wake sender | Simpler menu code short-term, but breaks `RELY-04` because duplicate sends can escape cross-surface gating |
| Short recents + full-library path | Flat root-menu device list | Slightly fewer clicks with 1-2 devices, but violates the locked compact-menu direction as the library grows |
| Successful-send-only recents | Selection-driven recents | Easier to implement, but pollutes history with clicks that never actually sent a packet |

## Architecture Patterns

### Recommended Project Structure
```text
Mac OS Swiss Knife/
├── SavedDeviceRepository.swift          # Extend protocol + defaults implementation for wake metadata
├── SavedDeviceLibraryStore.swift        # Publish devices, recentDeviceIDs, lastUsedDeviceID, recentDevices(limit:)
├── WOLSessionModel.swift                # Shared send-state owner for menu + WOL window
├── WakeSendPresentation.swift           # Truthful local-send copy reused by both surfaces
├── StatusBarController.swift            # Compact recents section, 所有设备 path, and persistent status row
├── AppDelegate.swift                    # Inject shared store/session into the status controller
├── WOLView.swift                        # Reopen with last-used preset when safe
└── WOLWindow.swift                      # Keep retained window ownership unchanged
```

Keep the flat file layout. Add narrow feature files only if an extracted presentation/helper becomes necessary.

### Pattern 1: Repository-Backed Wake Metadata
**What:** Extend the existing saved-device repository seam with one explicit metadata payload for `recentDeviceIDs` and `lastUsedDeviceID`.
**When to use:** Every successful saved-device wake send and every destructive library change that may orphan remembered IDs.
**Example:**
```swift
struct SavedDeviceWakeMetadata: Codable, Equatable {
    var recentDeviceIDs: [UUID]
    var lastUsedDeviceID: UUID?
}

protocol SavedDeviceRepository: AnyObject {
    func loadDevices() throws -> [SavedDevice]
    func saveDevices(_ devices: [SavedDevice]) throws
    func loadWakeMetadata() throws -> SavedDeviceWakeMetadata
    func saveWakeMetadata(_ metadata: SavedDeviceWakeMetadata) throws
}
```
Store metadata under one dedicated defaults key such as `saved_device_wake_metadata`; do not scatter new scalar keys through views.

### Pattern 2: One Shared WOL Session Owns Send Truth
**What:** Keep `WOLSessionModel` as the single owner of `isSending`, current send target, and last completed wake result for both the menu and the WOL window.
**When to use:** Any wake action, regardless of whether it starts from the menu or the WOL window.
**Example:**
```swift
struct CompletedWakeAttempt: Equatable {
    let deviceID: UUID?
    let message: String
    let wasSuccessful: Bool
}

final class WOLSessionModel: ObservableObject {
    @Published private(set) var sendState: WakeSendState = .idle
    @Published private(set) var lastCompletedWake: CompletedWakeAttempt?

    func sendSavedDevice(id: UUID) { /* shared send path */ }
    func sendCurrentSelection() { /* delegates into shared send path */ }
}
```
This is the cleanest way to satisfy `RELY-04` without creating a second queue or controller for menu sends.

### Pattern 3: Status Menu Rebuilds from Published Store + Session State
**What:** Let `StatusBarController` observe the shared library store and session model, then rebuild only the wake-related menu section when devices, recents, or status change.
**When to use:** Rendering the recent-devices section, the `所有设备` submenu, and the persistent last-result row.
**Example:**
```swift
final class StatusBarController: NSObject {
    private let deviceLibrary: SavedDeviceLibraryStore
    private let wolSession: WOLSessionModel
    private var cancellables: Set<AnyCancellable> = []

    private func rebuildWakeMenu() {
        let recentDevices = deviceLibrary.recentDevices(limit: 3)
        let isWakeDisabled = wolSession.isSending
        // rebuild recent rows, 所有设备 submenu, and status item here
    }
}
```
Keep the root menu compact; use one submenu item for the full library instead of flattening every device into the root.

### Pattern 4: Reopen Defaults Must Respect Draft Ownership
**What:** Apply last-used saved-device preselection only when the user is not already partway through manual entry.
**When to use:** `handleWindowWillShow()` or equivalent WOL window reopen logic.
**Example:**
```swift
if inputMode == .custom, !customMac.isEmpty {
    return
}

if let rememberedID = deviceLibrary.lastUsedDeviceID,
   deviceLibrary.device(id: rememberedID) != nil {
    inputMode = .preset
    selectedSavedDeviceID = rememberedID
} else {
    selectedSavedDeviceID = deviceLibrary.devices.first?.id
}
```
This carries forward Phase 1's unfinished-draft decision while still satisfying `WOL-03`.

## Common Pitfalls

### Pitfall 1: Polluting Recents on Selection Instead of Success
**What goes wrong:** Recent-device order changes even when the user never completed a send.
**How to avoid:** Only call `markWakeSucceeded(deviceID:)` after the local WOL send succeeds.

### Pitfall 2: Menu and Window Using Separate Send Paths
**What goes wrong:** The menu can start a second send while the WOL window is already in-flight.
**How to avoid:** Route both surfaces through the same retained `WOLSessionModel`.

### Pitfall 3: Flattening the Entire Library into the Root Menu
**What goes wrong:** The menu becomes long and stops feeling like a small native utility.
**How to avoid:** Keep only three recents inline and route the full library through `所有设备`.

### Pitfall 4: Overwriting Manual Drafts on Reopen
**What goes wrong:** The user loses their partial custom MAC input when reopening the WOL window.
**How to avoid:** Apply last-used preset defaults only when manual mode is effectively inactive.

### Pitfall 5: Using Window-Local Result Reset as the Only Status Source
**What goes wrong:** The app clears the wake result when the window reopens, leaving the menu with no truthful status history.
**How to avoid:** Keep a menu-visible `lastCompletedWake` snapshot separate from any window-only reset behavior.

## Code Examples

### Success-Only Recent Metadata Update
```swift
func markWakeSucceeded(deviceID: UUID) throws {
    var metadata = try repository.loadWakeMetadata()
    metadata.recentDeviceIDs.removeAll { $0 == deviceID }
    metadata.recentDeviceIDs.insert(deviceID, at: 0)
    metadata.recentDeviceIDs = Array(metadata.recentDeviceIDs.prefix(3))
    metadata.lastUsedDeviceID = deviceID
    try repository.saveWakeMetadata(metadata)
}
```

### Persistent Menu Status Row
```swift
private func wakeStatusText() -> String? {
    switch wolSession.sendState {
    case .sending:
        return WakeSendMessage.sending.text
    case .idle:
        return wolSession.lastCompletedWake?.message
    case .success(let message), .failure(let message):
        return message
    }
}
```

## Don't Hand-Roll

| Problem | Don't Build | Use Instead | Why |
|---------|-------------|-------------|-----|
| Duplicate-send protection | A second boolean flag inside `StatusBarController` only | `WOLSessionModel.isSending` shared across both surfaces | Keeps one authoritative in-flight state |
| Recent-device persistence | Multiple unrelated defaults keys or menu-local caches | One `SavedDeviceWakeMetadata` payload behind the repository seam | Prevents drift and makes pruning testable |
| Root-menu scaling | Multiple nested recent/favorite submenus | One short recent section plus one `所有设备` path | Matches the locked compact-menu direction |
| Wake result wording | Menu copy that claims the device woke up | Reuse `WakeSendPresentation` truthful local-send messaging | Preserves Phase 1 reliability semantics |

## Open Questions

None — Phase 03 context is specific enough to plan directly.

## Environment Availability

No new packages or platform capabilities are required for this phase. The current repo already has:
- Xcode/XCTest-based test targets in `Mac OS Swiss Knife.xcodeproj`
- Existing `ObservableObject` seams in `WOLSessionModel.swift` and `SavedDeviceLibraryStore.swift`
- AppKit menu/window ownership in `StatusBarController.swift` and `AppDelegate.swift`

## Validation Architecture

### Test Framework

- Use XCTest/XCUITest through the existing Xcode project.
- Keep per-task feedback targeted with `-only-testing:` commands.
- Reserve broader unit/full-suite runs for wave gates.

### Phase Requirements -> Test Map

| Requirement | Primary Automated Coverage | Secondary / Manual Coverage |
|-------------|----------------------------|-----------------------------|
| WOL-01 | `StatusBarControllerWakeMenuTests` for recent rows, full-library path, and wake-action dispatch | Manual live-menu smoke to confirm native menu scanning and submenu behavior |
| WOL-03 | `WOLSessionModelTests` for reopen defaults, deleted-last-used fallback, and manual-draft preservation | Manual reopen smoke in the real WOL window |
| WOL-04 | `SavedDeviceLibraryStoreTests` + `StatusBarControllerWakeMenuTests` for recent ordering and three-item trimming | Manual menu-bar smoke with repeated wakes |
| RELY-04 | `WOLSessionModelTests` + `StatusBarControllerWakeMenuTests` for cross-surface duplicate-send blocking and disabled wake actions | Manual smoke to confirm menu items visually disable during an in-flight send |
| UX-03 | `StatusBarControllerWakeMenuTests` for persistent last-result row | Manual check that the status row stays legible in the real menu bar |

### Sampling Rate

- **After every task commit:** Run that task's exact `-only-testing:` command from the active plan task.
- **After every plan wave:** Run `xcodebuild test -scheme 'Mac OS Swiss Knife' -destination 'platform=macOS' -only-testing:'Mac OS Swiss KnifeTests'`.
- **Before `$gsd-verify-work`:** Run `xcodebuild test -scheme 'Mac OS Swiss Knife' -destination 'platform=macOS'`.
- **Max feedback latency:** Target <20 seconds for task-level unit checks; reserve broader ~60-second runs for wave gates.
