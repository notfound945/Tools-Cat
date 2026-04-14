---
phase: 02-device-library-management
plan: 01
subsystem: ui
tags: [swift, xctest, userdefaults, observableobject, wake-on-lan]
requires:
  - phase: 01-truthful-foundations
    provides: truthful validation rules, session-model patterns, and XCTest coverage style
provides:
  - saved-device persistence model with stable UUID identity and sort order
  - UserDefaults-backed repository seam for device CRUD and reorder persistence
  - shared observable device-library store for downstream UI surfaces
  - device-library session model for add, edit, delete, and reorder flows
affects: [02-02, 02-03, 03-saved-device-wake-flows]
tech-stack:
  added: []
  patterns: [UserDefaults repository seam, main-actor observable session owner, nonisolated deinit for nested actor-owned teardown]
key-files:
  created:
    - Mac OS Swiss Knife/SavedDevice.swift
    - Mac OS Swiss Knife/DeviceLibrarySessionModel.swift
    - Mac OS Swiss KnifeTests/SavedDeviceRepositoryTests.swift
    - Mac OS Swiss KnifeTests/DeviceLibrarySessionModelTests.swift
  modified:
    - Mac OS Swiss Knife/SavedDeviceRepository.swift
    - Mac OS Swiss Knife/SavedDeviceLibraryStore.swift
    - Mac OS Swiss Knife.xcodeproj/project.pbxproj
key-decisions:
  - "Keep saved-device persistence behind a repository seam so later UI work can stay testable and local-first."
  - "Use nonisolated deinit for the nested session/store pair to avoid Swift/XCTest actor teardown aborts."
patterns-established:
  - "Saved-device mutations flow through SavedDeviceLibraryStore so later windows and menus share one ordered source of truth."
  - "Device-library form saves reuse ManualMACValidator validation and only persist normalized uppercase colon-separated MAC addresses."
requirements-completed: [DEVS-01, DEVS-02, DEVS-03, DEVS-04, DEVS-05, RELY-01]
duration: 9min
completed: 2026-04-11
---

# Phase 2 Plan 1: Device Library Management Summary

**Saved-device persistence, shared library state, and CRUD/reorder session logic for the native device-management flow**

## Performance

- **Duration:** 9 min
- **Started:** 2026-04-11T10:50:30Z
- **Completed:** 2026-04-11T10:59:40Z
- **Tasks:** 2
- **Files modified:** 7

## Accomplishments
- Added the `SavedDevice` contract, repository seam, and `UserDefaults` persistence coverage for ordered local devices.
- Added `SavedDeviceLibraryStore` as the shared observable source of truth for later menu and window surfaces.
- Implemented `DeviceLibrarySessionModel` with test-backed add, edit, delete, validation, and reorder behavior.

## Task Commits

Each task was committed atomically:

1. **Task 1: Create saved-device persistence contracts and repository coverage** - `948451b` (test), `2ff9928` (feat)
2. **Task 2: Implement device-library session logic for add, edit, delete, and reorder** - `8c4d9b2` (test), `7c9bf20` (feat)

## Files Created/Modified

- `Mac OS Swiss Knife/SavedDevice.swift` - Stable saved-device model with UUID identity, note, and persisted sort order.
- `Mac OS Swiss Knife/SavedDeviceRepository.swift` - Fakeable persistence contract and `UserDefaults` repository implementation.
- `Mac OS Swiss Knife/SavedDeviceLibraryStore.swift` - Main-actor observable store for reload, replace, delete, upsert, and reorder flows.
- `Mac OS Swiss Knife/DeviceLibrarySessionModel.swift` - Session owner for list/form/delete-confirm state and validation-gated saves.
- `Mac OS Swiss KnifeTests/SavedDeviceRepositoryTests.swift` - Persistence regression coverage for empty, save/reload, reorder, and delete scenarios.
- `Mac OS Swiss KnifeTests/DeviceLibrarySessionModelTests.swift` - Add/edit/delete/reorder coverage for the management-session state machine.
- `Mac OS Swiss Knife.xcodeproj/project.pbxproj` - Registers the new app and test files in the Xcode targets.

## Decisions Made

- Used `SavedDeviceLibraryStore` as the single ordered source of truth so later Phase 2/3 UI work does not reintroduce view-local persistence.
- Kept save validation aligned with Phase 1 by routing all draft MAC checks through `ManualMACValidator.validate(_:)`.

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 3 - Blocking] Fixed actor-owned teardown crashes in the session-model test suite**
- **Found during:** Task 2 (Implement device-library session logic for add, edit, delete, and reorder)
- **Issue:** `DeviceLibrarySessionModelTests` aborted in `swift_task_deinitOnExecutorImpl` while nested `DeviceLibrarySessionModel` and `SavedDeviceLibraryStore` instances were deallocating under XCTest memory checks.
- **Fix:** Made the repository class-constrained for stable ownership, converted the session-model suite to `@MainActor` synchronous execution, loaded initial store state directly in the initializer, and marked both nested actor-owned types with `nonisolated deinit`.
- **Files modified:** `Mac OS Swiss Knife/SavedDeviceRepository.swift`, `Mac OS Swiss Knife/SavedDeviceLibraryStore.swift`, `Mac OS Swiss Knife/DeviceLibrarySessionModel.swift`, `Mac OS Swiss KnifeTests/DeviceLibrarySessionModelTests.swift`
- **Verification:** `xcodebuild test -project "Mac OS Swiss Knife.xcodeproj" -scheme "Mac OS Swiss Knife" -destination 'platform=macOS' -only-testing:'Mac OS Swiss KnifeTests/SavedDeviceRepositoryTests' -only-testing:'Mac OS Swiss KnifeTests/DeviceLibrarySessionModelTests'`
- **Committed in:** `7c9bf20` (part of Task 2 commit)

---

**Total deviations:** 1 auto-fixed (1 blocking)
**Impact on plan:** The deviation was required to make the planned session-model coverage executable. No scope creep beyond correctness and test stability.

## Issues Encountered

- XCTest repeatedly crashed during nested actor-owned teardown until the session/store deinit path was made nonisolated.

## User Setup Required

None - no external service configuration required.

## Next Phase Readiness

- The saved-device source of truth and session-state contracts are ready for the dedicated device-library window in `02-02`.
- Later saved-device wake flows can now bind to persisted ordered devices instead of hardcoded presets.

## Deviations from Template

None.

## Known Stubs

None.

## Self-Check: PASSED

- FOUND: `.planning/phases/02-device-library-management/02-01-SUMMARY.md`
- FOUND: `948451b`
- FOUND: `2ff9928`
- FOUND: `8c4d9b2`
- FOUND: `7c9bf20`
