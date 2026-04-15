---
phase: 12-duration-preset-persistence
plan: 02
subsystem: ui
tags: [swift, appkit, combine, keep-awake, menu-bar]
requires:
  - phase: 12-01
    provides: "Managed keep-awake duration entity, repository, and store used by the session and menu bridge."
provides:
  - "Managed-duration keep-awake session state instead of preset-enum payloads"
  - "Shared app-owned duration store injected into the status bar controller"
  - "Fixed keep-awake menu rows bridged through canonical duration seconds"
affects: [phase-13-duration-management-surface, phase-14-managed-duration-menu-integration, keep-awake-menu]
tech-stack:
  added: []
  patterns:
    - "Fixed root rows can bridge through managed duration data without rendering dynamic rows yet."
key-files:
  created: []
  modified:
    - Tools Cat/AppDelegate.swift
    - Tools Cat/KeepAwakePresentation.swift
    - Tools Cat/KeepAwakeSessionModel.swift
    - Tools Cat/StatusBarController.swift
    - Tools CatTests/KeepAwakeMenuStateTests.swift
    - Tools CatTests/KeepAwakeSessionModelTests.swift
    - Tools CatTests/StatusBarControllerKeepAwakeMenuTests.swift
key-decisions:
  - "Keep the shipped fixed row titles and order intact in Phase 12, but resolve each timed action through managed durations by canonical seconds."
  - "Allow an in-memory fallback `ManagedKeepAwakeDuration(durationSeconds:)` when a seed row is missing, without mutating the store during rendering or menu dispatch."
patterns-established:
  - "Timed keep-awake confirmation and pending state now carry managed duration values directly."
  - "Controller checkmarks and pending copy compare managed duration seconds rather than a dedicated preset enum."
requirements-completed: [AWAKE-11]
duration: 3 min
completed: 2026-04-15
---

# Phase 12 Plan 02: Keep-Awake Managed-Duration Bridge Summary

**The keep-awake session and fixed root menu now run on managed duration values and a shared duration store, while preserving the current shipped menu structure**

## Performance

- **Duration:** 3 min
- **Started:** 2026-04-15T16:03:00+08:00
- **Completed:** 2026-04-15T16:06:42+08:00
- **Tasks:** 2
- **Files modified:** 7

## Accomplishments

- Replaced timed keep-awake session state and pending-action payloads so they carry `ManagedKeepAwakeDuration` values directly.
- Updated keep-awake presentation helpers so pending copy, active selection, and countdown state derive from `menuTitle` and `durationSeconds` rather than `KeepAwakeDurationPreset`.
- Added one shared `KeepAwakeDurationStore` at app launch and injected it into `StatusBarController`.
- Kept the current fixed keep-awake root rows, but resolved the timed actions through managed durations by canonical seconds with a non-persisting runtime fallback.
- Updated the controller and session XCTest suites so they assert managed-duration behavior end-to-end.

## Task Commits

Each task was committed atomically:

1. **Task 1: Replace preset-enum timed session state with managed-duration values** - `8caa111` (feat)
2. **Task 2: Wire the shared duration store into app startup and keep the fixed root menu as a managed-duration bridge** - `4ef5aef` (feat)

**Plan metadata:** committed with this summary file

## Files Created/Modified

- `Tools Cat/KeepAwakeSessionModel.swift` - Migrates timed session state to managed durations and computes end dates from canonical seconds.
- `Tools Cat/KeepAwakePresentation.swift` - Exposes `activeTimedDuration` and derives pending copy from managed duration titles.
- `Tools Cat/AppDelegate.swift` - Creates one shared `KeepAwakeDurationStore` and injects it into the status bar controller at launch.
- `Tools Cat/StatusBarController.swift` - Bridges the fixed timed rows through canonical managed durations and duration-second-based checkmarks.
- `Tools CatTests/KeepAwakeSessionModelTests.swift` - Verifies managed-duration timed session lifecycle and countdown behavior.
- `Tools CatTests/KeepAwakeMenuStateTests.swift` - Verifies presentation copy and stop-row truth using managed-duration fixtures.
- `Tools CatTests/StatusBarControllerKeepAwakeMenuTests.swift` - Verifies the fixed action group still behaves correctly while resolving timed rows through the shared duration store.

## Decisions Made

- Preserved the fixed row titles and ordering in the status bar menu so Phase 12 only migrates data flow, leaving dynamic menu rendering to Phase 14.
- Used a non-persisting `ManagedKeepAwakeDuration(durationSeconds:)` fallback in the controller so runtime continuity survives deleted seed rows without silently re-seeding or mutating user data during menu rendering.

## Deviations from Plan

None - plan executed exactly as written.

## Issues Encountered

None.

## User Setup Required

None - no external service configuration required.

## Next Phase Readiness

- The keep-awake domain is now fully off the preset enum in production code paths that matter for session and menu behavior.
- Phase 13 can build a real duration-management surface on top of the shared store, and Phase 14 can switch root menu rendering from fixed rows to managed rows without reopening persistence work.

## Self-Check: PASSED

---
*Phase: 12-duration-preset-persistence*
*Completed: 2026-04-15*
