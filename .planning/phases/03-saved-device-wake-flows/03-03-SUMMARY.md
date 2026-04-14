---
phase: 03-saved-device-wake-flows
plan: 03
subsystem: ui
tags: [swift, xctest, wol, swiftui, appkit]
requires:
  - phase: 03-saved-device-wake-flows
    provides: shared wake metadata and session contracts from 03-01
  - phase: 03-saved-device-wake-flows
    provides: compact menu wake actions and shared wake status from 03-02
provides:
  - safe WOL window reopen defaults driven by last-used saved-device memory
  - preserved unfinished manual MAC drafts across close and reopen
  - deleted-device fallback to canonical saved-device order
affects: [phase-05-native-menu-polish, wake-window, session-state]
tech-stack:
  added: []
  patterns: [shared session-owned reopen defaults, test-seeded wake metadata]
key-files:
  created: []
  modified:
    - Mac OS Swiss Knife/WOLSessionModel.swift
    - Mac OS Swiss KnifeTests/WOLSessionModelTests.swift
key-decisions:
  - "Keep reopen selection in WOLSessionModel so the retained AppKit window and SwiftUI picker continue to share one source of truth."
  - "Clear stale completed status on reopen without taking ownership away from unfinished manual drafts."
patterns-established:
  - "Pattern: handleWindowWillShow applies last-used preset defaults only when manual draft ownership allows it."
  - "Pattern: reopen regressions are covered by in-memory wake metadata seeded through the SavedDeviceRepository test double."
requirements-completed: [WOL-03, UX-03]
duration: 3 min
completed: 2026-04-12
---

# Phase 3 Plan 3: Reopen Defaults Summary

**WOL window reopen logic now restores the last-used saved device, preserves unfinished manual drafts, and falls back cleanly when remembered devices disappear**

## Performance

- **Duration:** 3 min
- **Started:** 2026-04-12T03:14:40Z
- **Completed:** 2026-04-12T03:17:19Z
- **Tasks:** 1
- **Files modified:** 2

## Accomplishments

- Added reopen-focused XCTest coverage for last-used preselection, manual-draft preservation, and deleted-last-used fallback.
- Updated `WOLSessionModel.handleWindowWillShow()` to preselect `lastUsedDeviceID` or the first canonical saved device when it is safe to do so.
- Preserved Phase 1 behavior by still clearing stale completed status on reopen while leaving unfinished manual input untouched.

## Task Commits

Each task was committed atomically:

1. **Task 1: Apply last-used saved-device defaults on reopen without overriding manual drafts**
   - `e74bf56` (`test`) RED: add failing reopen-default tests
   - `38d3786` (`feat`) GREEN: implement reopen selection and fallback behavior

## Files Created/Modified

- `Mac OS Swiss Knife/WOLSessionModel.swift` - Applies reopen selection, fallback, and stale-result handling in the shared session model.
- `Mac OS Swiss KnifeTests/WOLSessionModelTests.swift` - Seeds wake metadata in-memory and locks the reopen decision order with regression coverage.

## Decisions Made

- Kept the reopen decision logic inside `WOLSessionModel` instead of moving it into `WOLWindow` or `WOLView`, preserving the retained AppKit ownership model and one picker source of truth.
- Preserved the Phase 1 stale-result reset contract alongside the new Phase 3 reopen defaults by clearing completed results separately from input ownership.

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 1 - Bug] Restored stale-result clearing after adding manual-draft reopen protection**
- **Found during:** Task 1 (Apply last-used saved-device defaults on reopen without overriding manual drafts)
- **Issue:** The first reopen-default implementation returned early for manual drafts before clearing completed failure/success status, regressing the existing Phase 1 reopen contract.
- **Fix:** Reordered `handleWindowWillShow()` so hidden completion results still win, stale completed status still resets on reopen, and manual drafts still keep their input ownership.
- **Files modified:** `Mac OS Swiss Knife/WOLSessionModel.swift`
- **Verification:** `xcodebuild test -project "Mac OS Swiss Knife.xcodeproj" -scheme "Mac OS Swiss Knife" -destination 'platform=macOS' -only-testing:'Mac OS Swiss KnifeTests/WOLSessionModelTests'`
- **Committed in:** `38d3786`

---

**Total deviations:** 1 auto-fixed (1 bug)
**Impact on plan:** The auto-fix preserved an existing correctness contract without changing scope. Final behavior matches both Phase 1 and Phase 3 requirements.

## Issues Encountered

- `HEAD` advanced between commands during the parallel executor run, so commit tracking used commit-message lookups instead of assuming `HEAD` still pointed at this task’s commit.
- The manual reopen smoke from `03-VALIDATION.md` was not run in this non-interactive CLI execution; the targeted XCTest suite covers the reopen contract automatically.

## User Setup Required

None - no external service configuration required.

## Next Phase Readiness

- Phase 3 is functionally complete from the code and unit-test perspective; the saved-device reopen contract is now stable for future menu polish work.
- No code blockers remain for the next phase. A human GUI smoke can still be run later if the retained-window reopen feel needs confirmation on a live app build.

## Self-Check: PASSED

- FOUND: `.planning/phases/03-saved-device-wake-flows/03-03-SUMMARY.md`
- FOUND: `e74bf56`
- FOUND: `38d3786`

---
*Phase: 03-saved-device-wake-flows*
*Completed: 2026-04-12*
