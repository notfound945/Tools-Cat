---
phase: 15-device-library-ui-parity
verified: 2026-04-16T07:00:36Z
status: passed
score: 4/4 must-haves verified
human_verification:
  - test: "Compare `设备库` and `常亮时长` windows side by side on macOS"
    expected: "Both managers read as the same product family: retained shell, native list density, compact sheet sizing, and restrained action styling."
    why_human: "Visual parity and overall polish are subjective and cannot be fully proven from source inspection."
  - test: "Exercise add, edit, reorder, and delete manually in the `设备库` window"
    expected: "Add/edit open as a sheet over the list, reorder exits before the form appears, and the interaction feels native without focus or animation glitches."
    why_human: "Sheet animation, focus behavior, and interaction feel require a live UI check."
---

# Phase 15: Device Library UI Parity Verification Report

**Phase Goal:** The `设备库` manager feels visually and behaviorally aligned with the shipped `常亮时长` manager without changing saved-device truth.
**Verified:** 2026-04-16T07:00:36Z
**Status:** passed
**Re-verification:** Yes — initial automated verification plus approved human UAT

## Goal Achievement

### Observable Truths

| # | Truth | Status | Evidence |
| --- | --- | --- | --- |
| 1 | Saved WOL devices render inside a clearly native list surface instead of the prior custom stacked treatment. | ✓ VERIFIED | [`Tools Cat/DeviceLibraryView.swift`](../../../Tools%20Cat/DeviceLibraryView.swift) uses `List` for both normal and reorder modes at lines 69-108, with no `switch session.screen` or normal-path `ScrollView`; the direct-launch UI smokes in [`Tools CatUITests/Tools_CatUITests.swift`](../../../Tools%20CatUITests/Tools_CatUITests.swift) assert the seeded list surface at lines 45-98 and 101-139. |
| 2 | Add/edit flows use a compact in-place management presentation that keeps the list context visible, matching the duration manager pattern. | ✓ VERIFIED | [`Tools Cat/DeviceLibraryView.swift`](../../../Tools%20Cat/DeviceLibraryView.swift) drives a shared sheet from `formSheetIsPresented` at lines 7-13 and `formSheetContent` at lines 29-36; [`Tools Cat/DeviceLibrarySessionModel.swift`](../../../Tools%20Cat/DeviceLibrarySessionModel.swift) makes `currentFormMode` the presentation truth at lines 11-25 and lines 69-92; the UI smoke proves the list still exists while the sheet opens at [`Tools CatUITests/Tools_CatUITests.swift`](../../../Tools%20CatUITests/Tools_CatUITests.swift) lines 81-98. |
| 3 | Edit uses accent semantics and delete uses destructive red semantics so device actions match the duration manager at a glance. | ✓ VERIFIED | [`Tools Cat/DeviceLibraryView.swift`](../../../Tools%20Cat/DeviceLibraryView.swift) styles `编辑` with `.foregroundStyle(Color.accentColor)` and `删除` with `role: .destructive` at lines 278-285, matching [`Tools Cat/KeepAwakeDurationManagementView.swift`](../../../Tools%20Cat/KeepAwakeDurationManagementView.swift) lines 255-261. |
| 4 | Existing add, edit, delete, reorder, and direct-launch management behavior remain truthful after the UI polish. | ✓ VERIFIED | [`Tools Cat/DeviceLibrarySessionModel.swift`](../../../Tools%20Cat/DeviceLibrarySessionModel.swift) still persists through `SavedDeviceLibraryStore` on save/delete/reorder at lines 95-145 and 171-194; [`Tools Cat/SavedDeviceLibraryStore.swift`](../../../Tools%20Cat/SavedDeviceLibraryStore.swift) writes real data through `replaceAll`, `upsert`, `deleteDevice`, and `moveDevices` at lines 33-84; the full regression slice passed with 13 selected tests green, including the three direct-launch UI tests plus ten session/presentation tests. |

**Score:** 4/4 truths verified

### Required Artifacts

| Artifact | Expected | Status | Details |
| --- | --- | --- | --- |
| `Tools Cat/DeviceLibraryView.swift` | Native list shell, shared sheet form, accent/destructive row actions | ✓ VERIFIED | Exists, substantive, and wired via [`Tools Cat/DeviceLibraryWindow.swift`](../../../Tools%20Cat/DeviceLibraryWindow.swift) line 9. |
| `Tools Cat/DeviceLibrarySessionModel.swift` | Form presentation truth plus persisted add/edit/delete/reorder behavior | ✓ VERIFIED | Exists, substantive, and wired from [`Tools Cat/AppDelegate.swift`](../../../Tools%20Cat/AppDelegate.swift) line 106 into the shared store. |
| `Tools Cat/AppDelegate.swift` | Direct-launch path opens the device-library manager with the shared saved-device store | ✓ VERIFIED | `--ui-test-open-device-library` routes to `openDeviceLibraryWindow()` at lines 44-46 and 129-148. |
| `Tools Cat/DeviceLibraryWindow.swift` | Manager window hosts the verified SwiftUI view and reloads data when shown | ✓ VERIFIED | Hosts `DeviceLibraryView(session:)` and calls `session.reloadDevices()` before showing at lines 9 and 28-36. |
| `Tools CatTests/DeviceLibrarySessionModelTests.swift` | Regression lock on saved-device CRUD and reorder truth | ✓ VERIFIED | Six focused tests cover invalid save, add normalization, edit persistence, delete confirmation, and reorder persistence. |
| `Tools CatTests/DeviceLibraryManagementPresentationTests.swift` | Regression lock on management copy seams | ✓ VERIFIED | Four focused tests cover titles, delete copy, and form titles. |
| `Tools CatUITests/Tools_CatUITests.swift` | Direct-launch UI smokes for seeded list, retained sheet, and empty state | ✓ VERIFIED | Three targeted UI tests exist and passed in the verification slice. |

### Key Link Verification

| From | To | Via | Status | Details |
| --- | --- | --- | --- | --- |
| `Tools Cat/DeviceLibraryView.swift` | `Tools Cat/KeepAwakeDurationManagementView.swift` | Retained shell + shared sheet + native list structure | ✓ WIRED | Both views use `listContent` as the shell, `.sheet(isPresented:)` for add/edit, and `List` as the populated browse surface. |
| `Tools Cat/DeviceLibraryView.swift` | `Tools Cat/KeepAwakeDurationManagementView.swift` | Accent edit + destructive delete semantics | ✓ WIRED | Device row actions at [`Tools Cat/DeviceLibraryView.swift`](../../../Tools%20Cat/DeviceLibraryView.swift) lines 278-285 mirror duration-row actions at [`Tools Cat/KeepAwakeDurationManagementView.swift`](../../../Tools%20Cat/KeepAwakeDurationManagementView.swift) lines 255-261. |
| `Tools Cat/DeviceLibrarySessionModel.swift` | `Tools CatTests/DeviceLibrarySessionModelTests.swift` | `beginAdd`, `beginEdit`, `saveDraft`, `confirmDelete`, `moveDevices` truth locked by tests | ✓ WIRED | The session methods under verification are exercised directly by six unit tests. |
| `Tools Cat/AppDelegate.swift` | `Tools CatUITests/Tools_CatUITests.swift` | Direct-launch argument `--ui-test-open-device-library` opens the manager surface under test | ✓ WIRED | Launch arguments are parsed in `LaunchConfiguration` and consumed in `applicationDidFinishLaunching`; UI tests pass the same flag through `makeApplication(...)`. |

### Data-Flow Trace (Level 4)

| Artifact | Data Variable | Source | Produces Real Data | Status |
| --- | --- | --- | --- | --- |
| `Tools Cat/DeviceLibraryView.swift` | `session.devices` | [`Tools Cat/DeviceLibrarySessionModel.swift`](../../../Tools%20Cat/DeviceLibrarySessionModel.swift) `@Published var devices` populated from `SavedDeviceLibraryStore` | Yes | ✓ FLOWING |
| `Tools Cat/DeviceLibraryView.swift` | `session.currentFormMode` | Session methods `beginAdd`, `beginEdit`, `cancelForm`, `saveDraft` mutate the sheet state directly | Yes | ✓ FLOWING |
| `Tools Cat/DeviceLibrarySessionModel.swift` | `devices` persistence | [`Tools Cat/SavedDeviceLibraryStore.swift`](../../../Tools%20Cat/SavedDeviceLibraryStore.swift) calls `repository.saveDevices(...)` through `replaceAll`/`upsert`/`deleteDevice`/`moveDevices` | Yes | ✓ FLOWING |
| `Tools Cat/AppDelegate.swift` | Seeded direct-launch device data | `LaunchConfiguration` reads `--ui-test-seeded-device-library`; `configureSharedStores()` writes that data into defaults before instantiating `SavedDeviceLibraryStore` | Yes | ✓ FLOWING |

### Behavioral Spot-Checks

| Behavior | Command | Result | Status |
| --- | --- | --- | --- |
| Direct-launch empty-state surface | `xcodebuild test ... -only-testing:'Tools CatUITests/Tools_CatUITests/testLaunchWithEmptyDeviceLibraryShowsPolishedEmptyState'` | Passed inside the phase-15 verification slice | ✓ PASS |
| Seeded manager retains the list while the add sheet opens | `xcodebuild test ... -only-testing:'Tools CatUITests/Tools_CatUITests/testLaunchWithSeededDeviceLibraryShowsManagementWindow' -only-testing:'Tools CatUITests/Tools_CatUITests/testLaunchWithSeededDeviceLibraryShowsManagementListSurface'` | Both direct-launch UI tests passed | ✓ PASS |
| CRUD, reorder, and copy truth stay intact | `xcodebuild test ... -only-testing:'Tools CatTests/DeviceLibrarySessionModelTests' -only-testing:'Tools CatTests/DeviceLibraryManagementPresentationTests'` | 10 selected unit tests passed | ✓ PASS |

### Requirements Coverage

| Requirement | Source Plan | Description | Status | Evidence |
| --- | --- | --- | --- | --- |
| `DEVS-06` | `15-01-PLAN.md` | User sees saved WOL devices inside a clearly native macOS list surface instead of the current custom stacked list treatment | ✓ SATISFIED | [`Tools Cat/DeviceLibraryView.swift`](../../../Tools%20Cat/DeviceLibraryView.swift) lines 69-108; seeded list UI tests in [`Tools CatUITests/Tools_CatUITests.swift`](../../../Tools%20CatUITests/Tools_CatUITests.swift) lines 45-98 and 101-139. |
| `DEVS-07` | `15-01-PLAN.md` | User can add or edit a saved WOL device through a compact in-place management presentation that matches the duration manager instead of replacing the entire device-library screen | ✓ SATISFIED | Shared sheet in [`Tools Cat/DeviceLibraryView.swift`](../../../Tools%20Cat/DeviceLibraryView.swift) lines 7-13 and 29-36; form state truth in [`Tools Cat/DeviceLibrarySessionModel.swift`](../../../Tools%20Cat/DeviceLibrarySessionModel.swift) lines 23-25 and 69-92; retained-list UI assertion in [`Tools CatUITests/Tools_CatUITests.swift`](../../../Tools%20CatUITests/Tools_CatUITests.swift) lines 81-98. |
| `DEVS-08` | `15-02-PLAN.md` | User sees the device-library edit action styled with the app accent/theme color and the delete action styled with destructive red semantics to match the duration manager | ✓ SATISFIED | Device row actions in [`Tools Cat/DeviceLibraryView.swift`](../../../Tools%20Cat/DeviceLibraryView.swift) lines 278-285 match the duration-manager row actions in [`Tools Cat/KeepAwakeDurationManagementView.swift`](../../../Tools%20Cat/KeepAwakeDurationManagementView.swift) lines 255-261. |
| `DEVS-09` | `15-02-PLAN.md` | User can use the polished device-library manager without regressing saved-device add, edit, delete, reorder, or direct-launch management behavior | ✓ SATISFIED | Persisted session/store path in [`Tools Cat/DeviceLibrarySessionModel.swift`](../../../Tools%20Cat/DeviceLibrarySessionModel.swift) lines 95-145 and 171-194 plus [`Tools Cat/SavedDeviceLibraryStore.swift`](../../../Tools%20Cat/SavedDeviceLibraryStore.swift) lines 33-84; 13-test regression slice passed. |

Orphaned requirements: None. All phase-15 requirement IDs in [`REQUIREMENTS.md`](../../REQUIREMENTS.md) are claimed by plan frontmatter and accounted for above.

### Anti-Patterns Found

| File | Line | Pattern | Severity | Impact |
| --- | --- | --- | --- | --- |
| None | - | No TODO/FIXME placeholders, empty stub returns, or hollow hardcoded UI state found in the phase-15 implementation files | ℹ️ Info | No blocker anti-patterns detected in the verified phase files. |

### Human Verification

### 1. Side-by-Side Visual Parity

**Test:** Open `设备库` and `常亮时长` management windows side by side on macOS.
**Expected:** The two managers read as the same product family: native list density, similar sheet framing, restrained controls, and obvious but not flashy edit/delete emphasis.
**Result:** Approved in [`15-HUMAN-UAT.md`](./15-HUMAN-UAT.md).

### 2. Live Interaction Feel

**Test:** In the `设备库` window, enter reorder mode, trigger add/edit, and cancel the sheet several times.
**Expected:** Reorder exits before the sheet appears, the list stays present underneath, and the interaction feels native with no focus or animation oddities.
**Result:** Approved in [`15-HUMAN-UAT.md`](./15-HUMAN-UAT.md).

### Gaps Summary

No code gaps were found. The implementation, wiring, persistence path, focused regression slice, and final human UAT all support the phase contract. The phase is now `passed`.

---

_Verified: 2026-04-16T07:00:36Z_  
_Verifier: Claude (gsd-verifier)_
