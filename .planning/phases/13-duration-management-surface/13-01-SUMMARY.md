---
phase: 13-duration-management-surface
plan: 01
subsystem: state
tags: [swift, combine, keep-awake, management, validation]
requires:
  - phase: 12-duration-preset-persistence
    provides: "Shared persisted timed-duration store with exact-once seeding and canonical validation."
provides:
  - "Duration-management screen and form state machine backed by the shared duration store"
  - "Chinese presentation copy for manager window, form validation, and delete confirmation"
  - "Focused XCTest coverage for add, edit, delete, sorting, and duplicate rejection"
affects: [phase-13-02, phase-14-managed-duration-menu-integration, keep-awake-management]
tech-stack:
  added: []
  patterns:
    - "Timed keep-awake CRUD state is owned by a dedicated session model, not by SwiftUI view-local persistence."
key-files:
  created:
    - Tools Cat/KeepAwakeDurationManagementPresentation.swift
    - Tools Cat/KeepAwakeDurationManagementSessionModel.swift
    - Tools CatTests/KeepAwakeDurationManagementSessionModelTests.swift
  modified:
    - Tools Cat.xcodeproj/project.pbxproj
key-decisions:
  - "The management form accepts whole minutes in the UI, then converts exactly once to canonical duration seconds before calling the shared store."
  - "Duplicate and non-positive duration truth remains in `KeepAwakeDurationStore`; the session model only maps those store errors into stable Chinese copy."
patterns-established:
  - "Duration CRUD list/form/delete behavior mirrors the device-library session pattern, with one observable owner and explicit delete confirmation."
  - "Timed duration identity remains stable across edits because the manager calls `updateDuration(id:seconds:)` instead of recreating rows blindly."
requirements-completed: []
duration: 7 min
completed: 2026-04-15
---

# Phase 13 Plan 01: Duration Management Session Summary

**The keep-awake duration manager now has a real store-backed state machine for timed CRUD, validation, and delete confirmation**

## Performance

- **Duration:** 7 min
- **Started:** 2026-04-15T16:21:20+08:00
- **Completed:** 2026-04-15T16:28:57+08:00
- **Tasks:** 1
- **Files modified:** 4

## Accomplishments

- Added `KeepAwakeDurationManagementSessionModel` as the single owner of duration list, add/edit form, delete confirmation, and reload behavior.
- Added `KeepAwakeDurationManagementPresentation` to centralize Chinese window titles, form labels, validation copy, and delete-confirmation text.
- Kept whole-minute input in the manager UI contract, then converted it to canonical seconds only at the shared store boundary.
- Mapped store validation errors into stable Chinese messages without creating a second persistence or duplicate-detection path.
- Locked the new state machine with focused tests for seeded reload, invalid draft blocking, sorted add, identity-preserving edit, duplicate rejection, and delete confirmation.

## Task Commit

The plan shipped in one atomic task commit:

1. **Task 1: Build the duration-management session model and CRUD validation contract** - `7d10106` (feat)

## Files Created/Modified

- `Tools Cat/KeepAwakeDurationManagementPresentation.swift` - Defines the manager window title, form copy, validation strings, and delete-confirmation message.
- `Tools Cat/KeepAwakeDurationManagementSessionModel.swift` - Owns list/form/delete state, minutes parsing, store-backed reload/save/delete flows, and error mapping.
- `Tools CatTests/KeepAwakeDurationManagementSessionModelTests.swift` - Covers seeded reload, invalid draft blocking, sorted add, edit identity preservation, duplicate rejection, and delete confirmation.
- `Tools Cat.xcodeproj/project.pbxproj` - Registers the new manager/session Swift files in the synced project roots.

## Decisions Made

- Used a single `draftMinutesText` field instead of split hour/minute controls so the manager stays compact and matches the user’s requested “custom duration” flow.
- Left `无限常亮` completely outside this session model because it remains a fixed root-menu action, not managed data.

## Deviations from Plan

None - the plan executed as written.

## Issues Encountered

None.

## User Setup Required

None.

## Next Phase Readiness

- The app now has a durable state owner that a native window can bind to directly.
- Phase `13-02` can focus on the visible management surface and menu-entry wiring without reopening CRUD or validation semantics.

## Self-Check: PASSED

---
*Phase: 13-duration-management-surface*
*Completed: 2026-04-15*
