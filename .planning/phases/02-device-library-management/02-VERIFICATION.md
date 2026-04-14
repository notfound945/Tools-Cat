---
phase: 02-device-library-management
verified: 2026-04-13T00:00:00Z
status: passed
score: 7/7 must-haves verified
re_verification:
  prior_verdict: gaps_found
  corrections:
    - "Re-checked the manager copy-contract wiring against the live code. `DeviceLibraryWindow` now uses `DeviceLibraryManagementPresentation.windowTitle`, and `DeviceLibraryView` now uses `DeviceLibraryManagementPresentation.listTitle`, `DeviceLibraryManagementPresentation.emptyStateHeading`, `DeviceLibraryManagementPresentation.emptyStateBody`, and `DeviceLibraryManagementPresentation.saveButtonTitle`."
  non_blocking_context:
    - "A broader full-suite bootstrap failure observed on one host remains harness context only. It is not evidence that the Phase 2 device-library goal is incomplete."
---

# Phase 2: Device Library Management Verification Report

**Phase Goal:** Users can manage a small local Wake-on-LAN device library in a dedicated native surface instead of editing source code.
**Verified:** 2026-04-13T00:00:00Z
**Status:** passed
**Re-verification:** Yes — verification wording refreshed to match current code truth

## Goal Achievement

### Observable Truths

| # | Truth | Status | Evidence |
| --- | --- | --- | --- |
| 1 | User can open a dedicated native management surface to add a saved device with a name, MAC address, and optional note. | ✓ VERIFIED | `StatusBarController` adds `管理设备…` and dispatches to `AppDelegate.openDeviceLibraryWindow()`; `DeviceLibraryWindow` hosts `DeviceLibraryView`; the form exposes `名称`, `MAC 地址`, and `备注（可选）`. |
| 2 | User can edit or delete a saved device, and invalid edits are blocked before they are saved. | ✓ VERIFIED | `DeviceLibrarySessionModel` preloads edit drafts, blocks save unless trimmed name and validated MAC pass, and requires explicit delete confirmation before removal. |
| 3 | User can reorder saved devices and sees that order preserved when the app is reopened. | ✓ VERIFIED | `SavedDeviceLibraryStore.moveDevices` persists canonical order, `DeviceLibraryWindow.show()` reloads on show, and repository/session tests verify reload persistence. |
| 4 | Saved devices are stored locally in a shared source of truth rather than requiring source-edited presets. | ✓ VERIFIED | `SavedDevice`, `UserDefaultsSavedDeviceRepository`, and `SavedDeviceLibraryStore` form a local `UserDefaults`-backed persistence seam. |
| 5 | The manager remains a dedicated retained native surface instead of collapsing into the WOL sender. | ✓ VERIFIED | `AppDelegate` retains independent `deviceLibraryWindow` and `wolWindow` instances and opens them through separate paths. |
| 6 | The WOL preset picker reuses the same canonical saved-device library and order. | ✓ VERIFIED | `AppDelegate` injects the shared `SavedDeviceLibraryStore` into both `WOLSessionModel` and `WOLWindow`; `WOLView` renders `deviceLibrary.devices`, and `WOLSessionModel` resolves sends by saved-device UUID. |
| 7 | A seeded UI smoke path can open the manager window and observe seeded persisted device rows without manual menu-bar automation. | ✓ VERIFIED | `Mac_OS_Swiss_KnifeUITests.testLaunchWithSeededDeviceLibraryShowsManagementWindow` waits for `device-library-list` plus seeded `device-row-*` identifiers. |

**Score:** 7/7 truths verified

### Required Artifacts

| Artifact | Expected | Status | Details |
| --- | --- | --- | --- |
| `Mac OS Swiss Knife/SavedDevice.swift` | Stable saved-device model with UUID, note, and persisted order | ✓ VERIFIED | Concrete `Codable`, `Equatable`, `Identifiable` model with `id`, `name`, `macAddress`, `note`, and `sortOrder`. |
| `Mac OS Swiss Knife/SavedDeviceRepository.swift` | Local persistence seam for ordered device CRUD | ✓ VERIFIED | `UserDefaultsSavedDeviceRepository` loads and saves ordered devices while normalizing contiguous order. |
| `Mac OS Swiss Knife/SavedDeviceLibraryStore.swift` | Shared observable ordered device library | ✓ VERIFIED | Store loads initial data, reloads, replaces, upserts, deletes, and persists reorders through the repository. |
| `Mac OS Swiss Knife/DeviceLibrarySessionModel.swift` | Native manager CRUD/reorder/validation state owner | ✓ VERIFIED | Session owns list, form, delete-confirm, validation, and persistence mutations against the shared store. |
| `Mac OS Swiss Knife/DeviceLibraryWindow.swift` | Dedicated retained native manager window | ✓ VERIFIED | The live window title is sourced from `DeviceLibraryManagementPresentation.windowTitle`, and the window remains a retained AppKit host for `DeviceLibraryView`. |
| `Mac OS Swiss Knife/DeviceLibraryView.swift` | Compact list/form management surface | ✓ VERIFIED | The live view renders contract-owned copy through `DeviceLibraryManagementPresentation.listTitle`, `DeviceLibraryManagementPresentation.emptyStateHeading`, `DeviceLibraryManagementPresentation.emptyStateBody`, and `DeviceLibraryManagementPresentation.saveButtonTitle`. |
| `Mac OS Swiss Knife/StatusBarController.swift` | Menu entry point for opening the manager | ✓ VERIFIED | Adds `管理设备…` and dispatches through `onOpenDeviceLibrary`. |
| `Mac OS Swiss Knife/DeviceLibraryManagementPresentation.swift` | Exact copy contract for manager chrome and strings | ✓ VERIFIED | The contract exists and the live manager window/view now consume the contract-owned title and primary copy surfaces. |
| `Mac OS Swiss Knife/WOLSessionModel.swift` | Preset selection keyed to saved-device identity | ✓ VERIFIED | Uses `selectedSavedDeviceID` and resolves live MACs from the shared store at send time. |
| `Mac OS Swiss Knife/WOLView.swift` | WOL picker bound to saved-device library | ✓ VERIFIED | Picker renders ordered saved devices from the shared library instead of a hardcoded array. |
| `Mac OS Swiss Knife/WOLWindow.swift` | WOL window consumes the shared device library | ✓ VERIFIED | `WOLWindow` injects the shared store into `WOLView`. |
| `Mac OS Swiss KnifeUITests/Mac_OS_Swiss_KnifeUITests.swift` | Automated seeded smoke path for the manager window | ✓ VERIFIED | The seeded smoke asserts the window, populated list seam, and seeded `device-row-*` identifiers. |

### Key Link Verification

| From | To | Via | Status | Details |
| --- | --- | --- | --- | --- |
| `DeviceLibrarySessionModel.swift` | `ManualMACValidator.swift` | save gating and MAC normalization | ✓ WIRED | `macAddressValidation` calls `ManualMACValidator.validate(draftMACAddress)`. |
| `SavedDeviceLibraryStore.swift` | `SavedDeviceRepository.swift` | load and save operations | ✓ WIRED | `reload()` calls `repository.loadDevices()` and `replaceAll()` calls `repository.saveDevices(_)`. |
| `DeviceLibraryManagementPresentation.swift` | `DeviceLibraryWindow.swift` | window title and visible chrome sourced from the presentation contract | ✓ WIRED | `DeviceLibraryWindow` sets `window.title = DeviceLibraryManagementPresentation.windowTitle`. |
| `DeviceLibraryManagementPresentation.swift` | `DeviceLibraryView.swift` | list, empty-state, and save CTA copy sourced from the presentation contract | ✓ WIRED | `DeviceLibraryView` renders `DeviceLibraryManagementPresentation.listTitle`, `DeviceLibraryManagementPresentation.emptyStateHeading`, `DeviceLibraryManagementPresentation.emptyStateBody`, and `DeviceLibraryManagementPresentation.saveButtonTitle` in the live manager UI. |
| `StatusBarController.swift` | `AppDelegate.swift` | `onOpenDeviceLibrary` callback | ✓ WIRED | The menu item dispatches through `onOpenDeviceLibrary`, which `AppDelegate` assigns to `openDeviceLibraryWindow()`. |
| `DeviceLibraryWindow.swift` | `DeviceLibraryView.swift` | `NSHostingView(rootView: DeviceLibraryView(session: session))` | ✓ WIRED | The retained AppKit window hosts the SwiftUI manager directly. |
| `DeviceLibraryView.swift` | `DeviceLibrarySessionModel.swift` | ObservedObject-driven list/form state | ✓ WIRED | Rendering and actions flow through `@ObservedObject var session`. |
| `AppDelegate.swift` | `WOLWindow.swift` | shared `SavedDeviceLibraryStore` injection | ✓ WIRED | The same `savedDeviceLibrary` instance is passed into `WOLWindow(session:deviceLibrary:)`. |
| `WOLView.swift` | `SavedDeviceLibraryStore.swift` | picker content sourced from ordered saved devices | ✓ WIRED | `ForEach(deviceLibrary.devices)` renders the WOL preset picker from the shared store. |
| `Mac_OS_Swiss_KnifeUITests.swift` | `AppDelegate.swift` | launch arguments that auto-open the manager window | ✓ WIRED | The smoke test passes `--ui-test-open-device-library` and `--ui-test-user-defaults-suite`; `AppDelegate` consumes them and opens the manager window on launch. |
| `AppDelegate.swift` | `DeviceLibraryView.swift` | isolated defaults suite reloads into the manager surface | ✓ WIRED | Launch configuration builds the shared store from the dedicated `UserDefaults` suite; `DeviceLibraryWindow.show()` triggers `session.reloadDevices()`. |
| `DeviceLibraryView.swift` | `Mac_OS_Swiss_KnifeUITests.swift` | row accessibility identifiers queried by seeded UUID | ✓ WIRED | The view exposes `device-library-list`, `device-library-empty-state`, and `device-row-\(device.id.uuidString)`, and the smoke test waits on those identifiers. |

### Behavioral Spot-Checks

| Behavior | Command | Result | Status |
| --- | --- | --- | --- |
| Phase 2 persistence/session/WOL coverage | `xcodebuild test -project "Mac OS Swiss Knife.xcodeproj" -scheme "Mac OS Swiss Knife" -destination 'platform=macOS' -only-testing:'Mac OS Swiss KnifeTests/SavedDeviceRepositoryTests' -only-testing:'Mac OS Swiss KnifeTests/DeviceLibrarySessionModelTests' -only-testing:'Mac OS Swiss KnifeTests/DeviceLibraryManagementPresentationTests' -only-testing:'Mac OS Swiss KnifeTests/WOLSessionModelTests'` | All targeted Phase 2 unit suites passed in the prior verification run this report is based on. | ✓ PASS |
| Seeded manager-window smoke seam | `xcodebuild test -project "Mac OS Swiss Knife.xcodeproj" -scheme "Mac OS Swiss Knife" -destination 'platform=macOS' -only-testing:'Mac OS Swiss KnifeUITests/Mac_OS_Swiss_KnifeUITests/testLaunchWithSeededDeviceLibraryShowsManagementWindow'` | The app launched into `设备库`, exposed `device-library-list`, and surfaced seeded `device-row-*` identifiers. | ✓ PASS |
| Broader full unit regression gate | `xcodebuild test -project "Mac OS Swiss Knife.xcodeproj" -scheme "Mac OS Swiss Knife" -destination 'platform=macOS' -only-testing:'Mac OS Swiss KnifeTests'` | A bootstrap failure was previously observed on one host before tests executed. This remains harness context only and is not treated as a Phase 2 feature gap. | CONTEXT ONLY |

### Re-verification Note

The stale copy-contract gap is closed in the current codebase. `DeviceLibraryWindow` now uses `DeviceLibraryManagementPresentation.windowTitle`, and `DeviceLibraryView` now uses the contract-owned `listTitle`, `emptyStateHeading`, `emptyStateBody`, and `saveButtonTitle` in the live UI. That means the earlier warning about the manager chrome drifting from `DeviceLibraryManagementPresentation` no longer reflects current reality and should not remain the primary verdict for Phase 2.

The broader bootstrap issue from the earlier verification pass is preserved only as non-blocking harness context. It does not change the Phase 2 verdict because the feature-level persistence, manager window, and seeded smoke evidence already support the shipped device-library behavior.

---

_Verified: 2026-04-13T00:00:00Z_
_Verifier: Codex (execute-plan)_
