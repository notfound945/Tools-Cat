---
phase: 03-saved-device-wake-flows
plan: 01
subsystem: state-management
tags: [swift, macos, xctest, userdefaults, wake-on-lan]
requires:
  - phase: 02-device-library-management
    provides: shared saved-device repository/store seams and canonical saved-device ordering
provides:
  - persisted recent-device and last-used saved-device wake metadata
  - shared WOL session snapshots for in-flight and last-completed wake state
  - regression coverage for metadata pruning and saved-device wake sends
affects: [03-02-PLAN, 03-03-PLAN, status-bar menu, wol-window]
tech-stack:
  added: []
  patterns:
    - repository-backed wake metadata persisted in UserDefaults
    - shared session state separates current sendState from lastCompletedWake snapshots
key-files:
  created:
    - Mac OS Swiss KnifeTests/SavedDeviceLibraryStoreTests.swift
  modified:
    - Mac OS Swiss Knife/SavedDeviceRepository.swift
    - Mac OS Swiss Knife/SavedDeviceLibraryStore.swift
    - Mac OS Swiss Knife/WOLSessionModel.swift
    - Mac OS Swiss KnifeTests/WOLSessionModelTests.swift
key-decisions:
  - "Wake recents and last-used selection stay behind the SavedDeviceRepository seam instead of adding view-local defaults keys."
  - "The shared WOL session keeps sendState for active work and lastCompletedWake for durable cross-surface status."
patterns-established:
  - "Repository-backed wake metadata: recentDeviceIDs and lastUsedDeviceID are loaded, saved, and pruned through the shared library store."
  - "Persistent wake snapshots: a new send may replace sendState immediately, but lastCompletedWake remains available until completion."
requirements-completed: [WOL-03, WOL-04, RELY-04, UX-03]
duration: 7min
completed: 2026-04-12
---

# Phase 3 Plan 1: Saved-Device Wake Contracts Summary

**Repository-backed saved-device wake metadata with a shared last-completed wake snapshot for menu and window flows**

## Performance

- **Duration:** 7 min
- **Started:** 2026-04-12T02:43:20Z
- **Completed:** 2026-04-12T02:50:17Z
- **Tasks:** 2
- **Files modified:** 5

## Accomplishments
- Added `SavedDeviceWakeMetadata` and defaults-backed persistence for recent-device and last-used saved-device memory.
- Extended `SavedDeviceLibraryStore` to publish recents and last-used identity, update them on successful wakes, and prune stale IDs when devices change.
- Added `CompletedWakeAttempt` plus `lastCompletedWake` so the shared WOL session preserves truthful last-result state while duplicate-send gating stays global.

## Task Commits

Each task was committed atomically:

1. **Task 1: Extend the saved-device repository and shared store with wake metadata** - `db82df3` (test), `e7156ab` (feat)
2. **Task 2: Extend the shared WOL session with saved-device send helpers and persistent last-result state** - `36ee593` (test), `c2f5b1d` (feat)

**Plan metadata:** pending

_Note: TDD tasks used separate red/green commits._

## Files Created/Modified
- `Mac OS Swiss Knife/SavedDeviceRepository.swift` - Added the wake metadata type and defaults-backed load/save APIs.
- `Mac OS Swiss Knife/SavedDeviceLibraryStore.swift` - Published recents/last-used state, success-only metadata updates, and pruning during device changes.
- `Mac OS Swiss Knife/WOLSessionModel.swift` - Added `CompletedWakeAttempt`, `lastCompletedWake`, and shared saved-device send helpers.
- `Mac OS Swiss KnifeTests/SavedDeviceLibraryStoreTests.swift` - Added regression coverage for metadata trimming, persistence, and pruning.
- `Mac OS Swiss KnifeTests/WOLSessionModelTests.swift` - Added coverage for saved-device sends, durable last-result snapshots, and success-only recent updates.

## Decisions Made
- Persist wake recents and last-used identity through the existing repository/store seam so menu and WOL-window flows stay on one source of truth.
- Keep `lastCompletedWake` separate from `sendState` so new sends can start immediately without erasing the previous truthful result until completion.

## Deviations from Plan

None - plan executed exactly as written.

## Issues Encountered

None.

## User Setup Required

None - no external service configuration required.

## Next Phase Readiness

- The menu layer can now consume `recentDevices(limit:)`, `lastUsedDeviceID`, `sendState`, and `lastCompletedWake` without inventing its own persistence or send model.
- The WOL window can safely reuse the shared store/session contracts for reopen defaults in the next plan.

## Self-Check

PASSED

---
*Phase: 03-saved-device-wake-flows*
*Completed: 2026-04-12*
