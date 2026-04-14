# Phase 2: Device Library Management - Research

**Researched:** 2026-04-11
**Domain:** Native macOS device-library management for a small local Wake-on-LAN utility
**Confidence:** MEDIUM

<user_constraints>
## User Constraints (from CONTEXT.md)

### Locked Decisions

### Management Surface Shape
- **D-01:** Device management lives in a dedicated native window, not inside the existing WOL send window or menu hierarchy.
- **D-02:** The management surface should feel like a small, compact utility window rather than a heavy settings panel or split-view management app.
- **D-03:** The device management window and the WOL send window should be fully independent and allowed to stay open at the same time.
- **D-04:** The primary entry point should be a dedicated `管理设备…` menu item.

### Device List Presentation
- **D-05:** The saved-device list should use a balanced row layout rather than minimal or dense full-detail rows.
- **D-06:** Each row should show both the device name and MAC address as equally important information.
- **D-07:** If a note exists, the list may show a lighter, shorter note preview.

### Add and Edit Flow
- **D-08:** The default management view should focus on the device list; add/edit should transition into a dedicated form view instead of leaving a permanent side editor visible.
- **D-09:** Create and edit should share the same form layout and interaction model.
- **D-10:** The form must cover name, MAC address, and optional note, with invalid edits blocked before save.

### Reorder and Delete Behavior
- **D-11:** Reordering should appear only after the user enters an explicit editing or reordering mode.
- **D-12:** Device deletion should require confirmation before removal.
- **D-13:** The preserved user order is the canonical display order and must survive app reopen.

### the agent's Discretion
- Exact compact-window dimensions, spacing, and control chrome.
- Exact note preview truncation rules.
- Exact copy for validation and delete confirmation.
- Exact form transition implementation, as long as it remains distinct from the passive list view.

### Deferred Ideas (OUT OF SCOPE)
- Recent devices and last-used device behavior
- Direct menu-bar wake actions for saved devices
- Import/export of device libraries
- Auto discovery or network scanning
- Deep inline editing inside the menu bar menu
</user_constraints>

<phase_requirements>
## Phase Requirements

| ID | Description | Research Support |
|----|-------------|------------------|
| DEVS-01 | User can save a WOL device locally with name and MAC | Requires a local persistence seam plus add form and save path |
| DEVS-02 | User can edit saved device name, MAC, and note | Requires stable item identity, draft editing state, and save-time validation |
| DEVS-03 | User can delete a saved device | Requires explicit destructive action path and confirmation |
| DEVS-04 | User can reorder saved devices | Requires stable persisted order and explicit reorder mode |
| DEVS-05 | User can add an optional short note | Requires note storage, form field, and compact list preview rules |
| RELY-01 | Validation errors appear before invalid device save | Reuse Phase 1 MAC validation seam and add name/note save rules |
| UX-02 | User can open a dedicated native management surface | Requires a second retained native window and a clear menu entry |
</phase_requirements>

## Summary

Phase 2 is a product-surface expansion built on Phase 1's truth seams. The current app already has the key shell pieces needed for this work: `AppDelegate.swift` retains long-lived UI controllers, `StatusBarController.swift` owns the menu structure, `WOLWindow.swift` demonstrates the retained AppKit-window-plus-SwiftUI-host pattern, and `ManualMACValidator.swift` already defines the manual MAC contract the device form should reuse. The current gap is that saved devices do not exist as persisted app state yet; `WOLView.swift` still hardcodes a single `DeviceOption` inside the view.

**Primary recommendation:** introduce a small persisted saved-device repository plus a dedicated management window/session model, then rewire the WOL send flow to read device options from that shared source of truth instead of a hardcoded array.

For this project's scale, the cleanest path is not a database and not a broad settings system. A `Codable` saved-device model backed by a dedicated repository around `UserDefaults` is sufficient for a small personal library, keeps the code native and lightweight, and leaves room for Phase 3 to add recent-device metadata without reopening every UI seam. The key design choice is to keep persistence calls out of the views: AppKit owns the window lifecycle, a session model owns form/list state, and the repository owns serialization and ordering.

## Project Constraints

- Stay within the current native AppKit + SwiftUI menu-bar architecture.
- Optimize for a small personal library, not a generalized inventory tool.
- Preserve restrained macOS utility feel; avoid turning the surface into a settings-heavy panel or admin console.
- Validation must block invalid saves before persistence.
- New code should reduce coupling and avoid duplicating validation or persistence logic inside views.
- Follow current repo conventions: flat Swift file layout, one main type per file, English identifiers, Chinese runtime strings.

## Standard Stack

### Core
| Library | Version | Purpose | Why Standard |
|---------|---------|---------|--------------|
| SwiftUI | macOS SDK 26.2, deployment target 15.6 | Device list and add/edit form inside the management window | Already used for app UI and sufficient for compact native forms and lists |
| AppKit/Cocoa | macOS SDK 26.2 | Menu item, retained management window, and lifecycle ownership | Required for the menu-bar shell and second dedicated window |
| Foundation `Codable` | macOS SDK 26.2 | Serialize saved devices and persisted order | Native, dependency-free fit for a small local library |
| `UserDefaults` | macOS SDK 26.2 | Backing storage for the saved-device repository | Lightweight and appropriate for a small local personal dataset |

### Supporting
| Library | Version | Purpose | When to Use |
|---------|---------|---------|-------------|
| Combine `ObservableObject` | macOS SDK 26.2 | Shared list/editing session state between AppKit owner and SwiftUI view | Use for the management window session and any shared device-library state |
| XCTest | Xcode 26.2 | Repository, validation, editing, and reorder persistence coverage | Use for all new phase logic and session state contracts |
| XCUITest / manual smoke | Xcode 26.2 | Native drag-reorder and window-flow confirmation | Use only for behaviors that are awkward to prove in pure unit tests |

### Alternatives Considered
| Instead of | Could Use | Tradeoff |
|------------|-----------|----------|
| `UserDefaults`-backed repository | JSON file in Application Support | More explicit file ownership, but more plumbing than this small app needs today |
| Dedicated management window | Sheet from WOL window | Less surface area, but conflicts with the locked decision to keep management independent |
| Dedicated form view | Permanent split editor | Faster heavy management, but feels too large/admin-like for this utility and contradicts the compact-window direction |
| Reorder mode | Always-on drag handles | Slightly faster, but higher accidental-move risk in a small utility window |

## Architecture Patterns

### Recommended Project Structure
```text
Mac OS Swiss Knife/
├── SavedDevice.swift                 # Codable device model + identity/order fields
├── SavedDeviceRepository.swift       # Protocol + UserDefaults-backed implementation
├── DeviceLibrarySessionModel.swift   # ObservableObject for list, edit mode, drafts, and errors
├── DeviceLibraryView.swift           # SwiftUI list and form-flow surface
├── DeviceLibraryWindow.swift         # Retained AppKit window hosting the management UI
├── AppDelegate.swift                 # Owns/reuses the management window
├── StatusBarController.swift         # Adds the 管理设备… menu entry
└── WOLView.swift                     # Consumes saved devices from shared library data instead of hardcoded options
```

Keep the app-target layout flat. Add narrowly scoped files rather than a large subsystem or nested feature directory.

### Pattern 1: Repository Owns Persistence, Views Own Nothing
**What:** Introduce a small repository abstraction for loading and saving ordered saved devices. Keep serialization and storage keys inside that layer.
**When to use:** Any CRUD or reorder operation that changes the persisted library.
**Example:**
```swift
struct SavedDevice: Codable, Equatable, Identifiable {
    let id: UUID
    var name: String
    var macAddress: String
    var note: String
    var order: Int
}

protocol SavedDeviceRepository {
    func loadDevices() throws -> [SavedDevice]
    func saveDevices(_ devices: [SavedDevice]) throws
}
```

### Pattern 2: Session Model Mediates Between Repository and UI
**What:** Put list data, selected device, draft form state, reorder mode, and validation errors into one `ObservableObject` owned by the management window.
**When to use:** Any behavior that spans list browsing, add/edit transitions, delete confirmation, or reorder mode.
**Example:**
```swift
final class DeviceLibrarySessionModel: ObservableObject {
    @Published private(set) var devices: [SavedDevice] = []
    @Published var draftName = ""
    @Published var draftMAC = ""
    @Published var draftNote = ""
    @Published var isShowingForm = false
    @Published var isReordering = false
}
```

### Pattern 3: Validation Contract Reuse Beats New Parsing Rules
**What:** Reuse `ManualMACValidator.validate(_:)` for the saved-device MAC field so save-time validation and manual-send validation cannot drift.
**When to use:** Add/edit form gating, save-button enablement, and inline validation copy.
**Example:**
```swift
let macValidation = ManualMACValidator.validate(draftMAC)
let canSave = !draftName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    && macValidation.isValid
```

### Pattern 4: Stable Identity Plus Explicit Order
**What:** Saved devices need a stable identifier independent of order, plus a persisted integer order or a persisted array order that survives edits and reordering.
**When to use:** Delete, edit, reorder, and future Phase 3 references to saved devices.
**Example:**
```swift
struct SavedDevice: Codable, Identifiable {
    let id: UUID
    var name: String
    var macAddress: String
    var note: String
}
```

Persist array order directly, or persist an `order` property and normalize it on save. Avoid index-as-identity designs.

### Pattern 5: AppKit Owns Windows, Not View Navigation
**What:** Mirror the current `WOLWindow.swift` pattern by letting `AppDelegate.swift` retain `DeviceLibraryWindow`, while the SwiftUI view handles internal list/form transitions.
**When to use:** Opening the manager from the menu and keeping it independent from the WOL send window.
**Example:**
```swift
final class AppDelegate: NSObject, NSApplicationDelegate {
    private var deviceLibraryWindow: DeviceLibraryWindow?

    func openDeviceLibraryWindow() {
        if deviceLibraryWindow == nil {
            deviceLibraryWindow = DeviceLibraryWindow(session: deviceLibrarySession)
        }
        deviceLibraryWindow?.show()
    }
}
```

## Common Pitfalls

### Pitfall 1: View-Local Persistence Logic
**What goes wrong:** `DeviceLibraryView` starts calling `UserDefaults` directly, making testing and shared-state updates brittle.
**How to avoid:** Keep persistence in a repository and inject it into a session model.

### Pitfall 2: Duplicated MAC Validation Rules
**What goes wrong:** The add/edit form and manual send path accept different MAC formats.
**How to avoid:** Reuse `ManualMACValidator` instead of introducing a second parser or save-only format rules.

### Pitfall 3: Using Array Index as Device Identity
**What goes wrong:** Editing, deleting, and reordering become fragile once rows move.
**How to avoid:** Give every device a stable UUID and treat list order separately from identity.

### Pitfall 4: Always-On Reordering in a Small Window
**What goes wrong:** Accidental drags change persisted order without the user's intent.
**How to avoid:** Gate drag reordering behind an explicit reorder/edit mode.

### Pitfall 5: Hardcoded WOL Options Survive Beside the New Library
**What goes wrong:** The manager writes real devices, but `WOLView.swift` still reads the old hardcoded `options` array.
**How to avoid:** Plan an explicit integration step that moves WOL preset selection onto the shared saved-device source of truth.

## Code Examples

### UserDefaults-Backed Codable Repository
```swift
final class UserDefaultsSavedDeviceRepository: SavedDeviceRepository {
    private let defaults: UserDefaults
    private let key = "saved_devices"

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    func loadDevices() throws -> [SavedDevice] {
        guard let data = defaults.data(forKey: key) else { return [] }
        return try JSONDecoder().decode([SavedDevice].self, from: data)
    }

    func saveDevices(_ devices: [SavedDevice]) throws {
        let data = try JSONEncoder().encode(devices)
        defaults.set(data, forKey: key)
    }
}
```

### Shared Library Options Feeding WOL
```swift
struct DeviceOption: Identifiable, Equatable {
    let id: UUID
    let label: String
    let value: String
    let note: String
}
```

The manager can own richer `SavedDevice` data while `WOLView` consumes a mapped options list from the same stored library.

## Don't Hand-Roll

| Problem | Don't Build | Use Instead | Why |
|---------|-------------|-------------|-----|
| Persistence layer | SQLite/Core Data for this phase | `Codable` plus repository-backed local storage | The dataset is tiny and local-first; heavier persistence adds cost without product value |
| Cross-window synchronization | Notification-only library invalidation | Shared repository/session ownership injected by AppKit | Fewer hidden state paths and easier tests |
| MAC validation | Second save-form parser | `ManualMACValidator` | Prevents drift between send-time and save-time rules |
| Delete safety | Silent direct removal | Native confirmation step | Matches the locked deletion decision and reduces accidental loss |
| Reorder interaction | Always-editing list | Explicit reorder mode | Better fit for a compact utility window |

## Open Questions

1. **Where should the shared device-library object live?**
   - Recommendation: retain the repository in `AppDelegate.swift`, then pass session models or snapshots into both windows as needed.

2. **Should note previews appear in every row or only when non-empty?**
   - Recommendation: only render the preview when non-empty, keeping row height compact by default.

3. **Should the WOL window update live while the device manager is open?**
   - Recommendation: yes, if the shared repository/session publishes changes; Phase 2 should avoid requiring app relaunch or window reopen to see saved-device updates.

## Environment Availability

| Dependency | Required By | Available | Version | Fallback |
|------------|------------|-----------|---------|----------|
| macOS host runtime | App behavior and native window flows | ✓ | 15.7.4 | — |
| Xcode / `xcodebuild` | Build and automated tests | ✓ | 26.2 | — |
| Swift compiler | App and XCTest compilation | ✓ | 6.2.3 | — |
| Foundation/AppKit/SwiftUI | Persistence, windows, and views | ✓ | macOS 26.2 SDK | — |

## Validation Architecture

### Test Framework
| Property | Value |
|----------|-------|
| Framework | XCTest and XCUITest via Xcode 26.2 |
| Config file | `Mac OS Swiss Knife.xcodeproj/project.pbxproj` |
| Quick run command | `xcodebuild test -scheme 'Mac OS Swiss Knife' -destination 'platform=macOS' -only-testing:'Mac OS Swiss KnifeTests'` |
| Full suite command | `xcodebuild test -scheme 'Mac OS Swiss Knife' -destination 'platform=macOS'` |

### Phase Requirements -> Test Map
| Req ID | Behavior | Test Type | Automated Command | File Exists? |
|--------|----------|-----------|-------------------|-------------|
| DEVS-01 | Persist and reload a saved device with normalized MAC and name | unit | `xcodebuild test -scheme 'Mac OS Swiss Knife' -destination 'platform=macOS' -only-testing:'Mac OS Swiss KnifeTests/SavedDeviceRepositoryTests'` | ❌ Wave 0 |
| DEVS-02 / DEVS-05 | Edit existing device fields, including note, with pre-save validation | unit | `xcodebuild test -scheme 'Mac OS Swiss Knife' -destination 'platform=macOS' -only-testing:'Mac OS Swiss KnifeTests/DeviceLibrarySessionModelTests'` | ❌ Wave 0 |
| DEVS-03 | Confirm then delete a saved device | unit + manual smoke | `xcodebuild test -scheme 'Mac OS Swiss Knife' -destination 'platform=macOS' -only-testing:'Mac OS Swiss KnifeTests/DeviceLibrarySessionModelTests'` | ❌ Wave 0 |
| DEVS-04 | Reorder devices and preserve order after reload | unit + manual smoke | `xcodebuild test -scheme 'Mac OS Swiss Knife' -destination 'platform=macOS' -only-testing:'Mac OS Swiss KnifeTests/SavedDeviceRepositoryTests'` | ❌ Wave 0 |
| RELY-01 | Invalid name/MAC edits are blocked before save | unit | `xcodebuild test -scheme 'Mac OS Swiss Knife' -destination 'platform=macOS' -only-testing:'Mac OS Swiss KnifeTests/DeviceLibrarySessionModelTests'` | ❌ Wave 0 |
| UX-02 | Dedicated management window opens from the menu and supports add/edit/delete/reorder flow | unit + UI/manual | `xcodebuild test -scheme 'Mac OS Swiss Knife' -destination 'platform=macOS' -only-testing:'Mac OS Swiss KnifeUITests/Mac_OS_Swiss_KnifeUITests'` | ⚠ existing scaffold only |

### Sampling Rate
- **Per task commit:** run the task-scoped `-only-testing:` command for the file/class that changed.
- **Per plan wave:** run `xcodebuild test -scheme 'Mac OS Swiss Knife' -destination 'platform=macOS'`.
- **Before `$gsd-verify-work`:** the full suite must be green.
- **Max feedback latency:** keep targeted runs under 20 seconds; reserve broader runs for wave gates.

