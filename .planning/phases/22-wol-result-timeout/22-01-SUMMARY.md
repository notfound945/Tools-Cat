---
phase: 22-wol-result-timeout
plan: 01
subsystem: ui
tags: [swift, macos, xctest, wol, menu-bar]
requires:
  - phase: 03-saved-device-wake-flows
    provides: shared WOL session state, hidden-window reopen behavior, and menu wake-status rendering seams
  - phase: 21-device-entry-verification-closure
    provides: the latest locked v1.7 WOL and saved-device interaction baseline
provides:
  - one shared 3-second WOL completed-result lifetime owned by `WOLSessionModel`
  - deterministic session-model coverage for result expiry, hidden-window reopen timing, and stale-clear cancellation
  - menu wake-status expiry coverage tied directly to the shared WOL session clear seam
affects: [phase-23-device-form-save-guard, wol-window, status-bar-menu]
tech-stack:
  added: []
  patterns:
    - shared session-owned transient result clearing through an injected scheduler/token seam
    - deterministic XCTest coverage using fake wake-result schedulers instead of wall-clock result expiry
key-files:
  created:
    - .planning/phases/22-wol-result-timeout/22-01-SUMMARY.md
  modified:
    - Tools Cat/WOLSessionModel.swift
    - Tools CatTests/WOLSessionModelTests.swift
    - Tools CatTests/StatusBarControllerWakeMenuTests.swift
key-decisions:
  - "Keep `WOLSessionModel` as the only owner of WOL result lifetime so the window and menu row clear from one shared state transition."
  - "Stabilize regression coverage with fake wake-result schedulers for session tests that do not need to exercise the production delay path."
patterns-established:
  - "Pattern: completed wake results are published to `lastCompletedWake` and cleared later through one cancellable scheduler seam."
  - "Pattern: AppKit wake-status rendering stays passive and is verified by waiting on the shared session-driven refresh path."
requirements-completed: [WOLF-01, WOLF-02]
duration: 9min
completed: 2026-05-06
---

# Phase 22 Plan 01: WOL Result Timeout Summary

**Shared WOL result expiry now clears both the window and menu-bar wake status after three seconds from one session-owned scheduler seam**

## Performance

- **Duration:** 9 min
- **Started:** 2026-05-06T07:14:30Z
- **Completed:** 2026-05-06T07:23:22Z
- **Tasks:** 2
- **Files modified:** 3

## Accomplishments

- Added one cancellable 3-second completed-result clear seam to `WOLSessionModel`, including cancellation before new sends and hidden-window reopen preservation without restarting the lifetime.
- Locked the shared session behavior with focused `WOLSessionModelTests` for expiry, stale-clear cancellation, and hidden-window result visibility.
- Extended the wake-menu controller slice so success and failure status rows both hide when the shared session clear fires, without adding any menu-local timer.

## Task Commits

Each task was committed atomically:

1. **Task 1: Stabilize the shared WOL result timeout lifecycle in `WOLSessionModel`** - `965c44b` (`feat`)
2. **Task 2: Lock menu wake-status expiry to the shared WOL session state** - `a0b5a8b` (`test`)

**Follow-up auto-fix:** `868f7a1` (`fix`) stabilized the broader `WOLSessionModelTests` quick slice that the new shared timeout seam initially destabilized.

**Plan metadata:** pending final docs commit

## Files Created/Modified

- `Tools Cat/WOLSessionModel.swift` - owns the shared wake-result clear token and the production clear scheduler implementation.
- `Tools CatTests/WOLSessionModelTests.swift` - covers timeout expiry, stale-clear cancellation, hidden-window reopen timing, and routes non-timeout session regressions through a fake clear seam.
- `Tools CatTests/StatusBarControllerWakeMenuTests.swift` - proves menu wake-status rows hide after the shared session clear for both success and failure outcomes.

## Decisions Made

- Kept `WOLSessionModel` as the only timeout owner rather than introducing any view-local or menu-local result clearing.
- Left `StatusBarController.updateWakeStatusItem()` as a pure renderer and adapted the tests to its existing async refresh seam instead of forcing synchronous controller updates.

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 1 - Bug] Stabilized the broader shared-session regression slice after adding result expiry**
- **Found during:** Final Phase 22 quick-slice verification
- **Issue:** Immediate-completion `WOLSessionModelTests` outside the new targeted timeout cases crashed once the shared clear seam was introduced, so the phase quick slice was not deterministic.
- **Fix:** Kept the production shared clear behind the injected scheduler abstraction, then routed the non-timeout session tests through the existing fake clear seam so the full WOL session slice stayed deterministic while still covering the shared timeout behavior explicitly.
- **Files modified:** `Tools Cat/WOLSessionModel.swift`, `Tools CatTests/WOLSessionModelTests.swift`
- **Verification:** `xcodebuild test -project "Tools Cat.xcodeproj" -scheme "Tools Cat" -destination 'platform=macOS' -parallel-testing-enabled NO -only-testing:'Tools CatTests/WOLSessionModelTests' -only-testing:'Tools CatTests/StatusBarControllerWakeMenuTests'`
- **Committed in:** `868f7a1`

---

**Total deviations:** 1 auto-fixed (1 bug)
**Impact on plan:** The auto-fix was required to keep the shared result-timeout seam verifiable across the full Phase 22 quick slice. No scope creep.

## Issues Encountered

- The initial hidden-window timeout regression crashed when exercised through the default clear path. The targeted timeout tests were moved onto the fake scheduler seam first, then the broader session slice was stabilized through the same deterministic seam.

## User Setup Required

None - no external service configuration required.

## Next Phase Readiness

- The shared WOL feedback lifetime is now closed at the session layer, so Phase 23 can focus on the saved-device form save-button affordance without reopening wake-status ownership.
- The quick Phase 22 validation slice is green for both the WOL session model and the wake-menu controller seams.

## Self-Check: PASSED

- FOUND: `.planning/phases/22-wol-result-timeout/22-01-SUMMARY.md`
- FOUND: `965c44b`
- FOUND: `a0b5a8b`
- FOUND: `868f7a1`

---
*Phase: 22-wol-result-timeout*
*Completed: 2026-05-06*
