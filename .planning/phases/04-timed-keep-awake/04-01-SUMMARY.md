---
phase: 04-timed-keep-awake
plan: 01
subsystem: ui
tags: [swift, xctest, appkit, foundation]
requires:
  - phase: 01-truthful-foundations
    provides: truthful keep-awake power-control outcomes and failure retention semantics
  - phase: 03-saved-device-wake-flows
    provides: lifecycle-owned session-model pattern for menu-driven state
provides:
  - fixed keep-awake duration presets with exact Chinese menu titles
  - one shared timed keep-awake session owner with countdown and expiry semantics
  - presentation copy contract for off, indefinite, timed, pending, and failure states
affects: [04-02 menu wiring, 04-03 lifecycle cleanup, keep-awake ui]
tech-stack:
  added: []
  patterns: [lifecycle-owned session model, absolute end-date countdown, presentation-only menu copy contract]
key-files:
  created:
    - Mac OS Swiss Knife/KeepAwakeDurationPreset.swift
    - Mac OS Swiss Knife/KeepAwakeCountdownScheduler.swift
    - Mac OS Swiss Knife/KeepAwakeSessionModel.swift
  modified:
    - Mac OS Swiss Knife/KeepAwakePresentation.swift
    - Mac OS Swiss Knife/StatusBarController.swift
    - Mac OS Swiss Knife.xcodeproj/project.pbxproj
    - Mac OS Swiss KnifeTests/KeepAwakeSessionModelTests.swift
    - Mac OS Swiss KnifeTests/KeepAwakeMenuStateTests.swift
key-decisions:
  - "Timed keep-awake stores an absolute endDate and derives remaining time from now on each tick to avoid drift during replacement."
  - "Presentation keeps confirmed mode and pending action separate so failure copy never clears the active selection or icon."
patterns-established:
  - "KeepAwakeSessionModel owns confirmed keep-awake lifecycle above KeepAwakePowerControlling."
  - "KeepAwakePresentation is the single source for exact menu status copy, icon choice, and tooltip text."
requirements-completed: [AWAKE-01, AWAKE-02, AWAKE-03, AWAKE-04]
duration: 15m
completed: 2026-04-12
---

# Phase 4 Plan 1: Timed Keep-Awake Foundation Summary

**Timed keep-awake presets, countdown session ownership, and exact presentation copy built on top of the existing truthful power seam**

## Performance

- **Duration:** 15m
- **Started:** 2026-04-12T06:21:27Z
- **Completed:** 2026-04-12T06:37:04Z
- **Tasks:** 2
- **Files modified:** 8

## Accomplishments

- Added a fixed preset catalog plus a cancellable countdown scheduler so timed keep-awake has stable durations and one replaceable timer seam.
- Built `KeepAwakeSessionModel` to own off, indefinite, timed, pending, expiry, and disable-failure retention semantics above `KeepAwakePowerControlling`.
- Replaced the old keep-awake presentation toggle contract with exact status-row, icon, and tooltip copy for all Phase 4 states.

## Task Commits

Each task was committed atomically through the TDD cycle:

1. **Task 1 RED: timed session model tests** - `42663ef` (`test`)
2. **Task 1 GREEN: timed session foundation** - `bc47807` (`feat`)
3. **Task 2 RED: presentation contract tests** - `aa70343` (`test`)
4. **Task 2 GREEN: presentation contract implementation** - `b2297a6` (`feat`)

## Files Created/Modified

- `Mac OS Swiss Knife/KeepAwakeDurationPreset.swift` - Defines the four fixed timed presets with exact menu titles and durations.
- `Mac OS Swiss Knife/KeepAwakeCountdownScheduler.swift` - Adds the cancellable countdown scheduling seam plus the timer-backed implementation.
- `Mac OS Swiss Knife/KeepAwakeSessionModel.swift` - Owns confirmed keep-awake mode, pending action, message retention, countdown time, replacement, and expiry logic.
- `Mac OS Swiss Knife/KeepAwakePresentation.swift` - Formats exact keep-awake status text, icon state, tooltip copy, and active selection metadata.
- `Mac OS Swiss Knife/StatusBarController.swift` - Bridges the still-boolean menu controller to the new presentation API until Phase 4 rewires the menu actions.
- `Mac OS Swiss KnifeTests/KeepAwakeSessionModelTests.swift` - Covers start, replace, tick, expiry, and failure retention behavior for the new session owner.
- `Mac OS Swiss KnifeTests/KeepAwakeMenuStateTests.swift` - Locks the new presentation-only copy and countdown formatting contract.
- `Mac OS Swiss Knife.xcodeproj/project.pbxproj` - Registers the new app and test source files with the Xcode synchronized groups.

## Decisions Made

- Used an absolute `endDate` plus `countdownNow` updates instead of a mutable seconds-left counter so timed replacement stays deterministic.
- Let failure copy override only the status row while icon, tooltip, and active selection continue to reflect the last confirmed mode.

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 3 - Blocking] Adapted the existing status bar controller to the new presentation API**
- **Found during:** Task 2 (Expand the keep-awake presentation contract for fixed menu titles, countdown status copy, and exact accessibility text)
- **Issue:** Replacing `KeepAwakePresentation` with the new `confirmedMode` / `pendingAction` initializer broke `StatusBarController.swift`, so the app target no longer compiled.
- **Fix:** Updated `StatusBarController` to map its current toggle-era state into the new presentation contract and to apply the new tooltip/icon fields without starting menu rewiring early.
- **Files modified:** `Mac OS Swiss Knife/StatusBarController.swift`
- **Verification:** `xcodebuild test -project "Mac OS Swiss Knife.xcodeproj" -scheme "Mac OS Swiss Knife" -destination 'platform=macOS' -only-testing:'Mac OS Swiss KnifeTests/KeepAwakeMenuStateTests' -only-testing:'Mac OS Swiss KnifeTests/KeepAwakeSessionModelTests'`
- **Committed in:** `b2297a6`

---

**Total deviations:** 1 auto-fixed (1 blocking)
**Impact on plan:** The fix was necessary to keep the app target compiling after the presentation contract changed. No scope creep beyond the direct consumer bridge.

## Issues Encountered

- The targeted `xcodebuild test` slice spent most of its time in Xcode harness startup, so debugging relied on xcresult inspection for the one crashing replacement test before the fake clock sequence was corrected.

## User Setup Required

None - no external service configuration required.

## Next Phase Readiness

- The menu layer can now bind to one shared timed keep-awake session owner instead of inferring timed state from raw power assertions.
- Exact countdown, pending, and failure strings are locked in tests before Phase 4 menu rewiring begins.
- No functional blockers remain for `04-02`.

## Self-Check: PASSED

- Found `.planning/phases/04-timed-keep-awake/04-01-SUMMARY.md` on disk.
- Verified commits `42663ef`, `bc47807`, `aa70343`, and `b2297a6` in git history.

---
*Phase: 04-timed-keep-awake*
*Completed: 2026-04-12*
