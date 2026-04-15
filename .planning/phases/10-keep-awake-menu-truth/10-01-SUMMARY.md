---
phase: 10-keep-awake-menu-truth
plan: 01
subsystem: menu-bar-ui
tags: [keep-awake, menu-bar, appkit, visibility, xctest]
requires:
  - phase: 09-mac-os-swiss-knife-tools-cat
    provides: "The current Tools Cat menu-bar surface and renamed verification targets"
provides:
  - "Keep-awake presentation now exposes a single truthful stop-row visibility contract"
  - "The root menu hides `关闭常亮` while idle and keeps it visible for confirmed active or stopping sessions"
  - "Focused presentation and controller regressions lock the new stop-row visibility rule"
affects: [keep-awake-menu, controller-rendering, regression-coverage]
tech-stack:
  added: []
  patterns: ["Presentation-driven NSMenuItem visibility", "Hosted AppKit test fixture lifetime flush before teardown"]
key-files:
  created: [".planning/phases/10-keep-awake-menu-truth/10-01-SUMMARY.md"]
  modified:
    - "Tools Cat/KeepAwakePresentation.swift"
    - "Tools Cat/StatusBarController.swift"
    - "Tools CatTests/KeepAwakeMenuStateTests.swift"
    - "Tools CatTests/StatusBarControllerKeepAwakeMenuTests.swift"
key-decisions:
  - "Keep the fixed keep-awake action group in memory and toggle the stop row with `isHidden` instead of rebuilding menu structure"
  - "Derive stop-row visibility from confirmed mode plus pending action so startup remains hidden while stopping stays visible"
  - "Stabilize the idle AppKit controller test with an async flush before fixture teardown instead of widening production changes"
patterns-established:
  - "Menu-truth fixes should prefer presentation contracts and focused controller assertions over structural NSMenu churn"
requirements-completed: [MENU-01, MENU-02, MENU-03]
duration: 30min
completed: 2026-04-15
---

# Phase 10 Plan 1: Keep-Awake Stop Row Truth Summary

**The keep-awake root menu now hides the idle `关闭常亮` row, keeps it available for real active or stopping sessions, and locks that contract with focused controller and presentation tests.**

## Performance

- **Duration:** 30min
- **Completed:** 2026-04-15
- **Tasks:** 1
- **Files modified:** 5

## Accomplishments
- Added `showsStopAction` to `KeepAwakePresentation` so stop-row visibility comes from confirmed keep-awake state plus pending action.
- Updated `StatusBarController.renderKeepAwakePresentation()` to hide `keepAwakeOffItem` whenever the stop action is not truthful.
- Added regression coverage for idle, active, and stopping stop-row visibility in the presentation and controller test seams.
- Fixed an AppKit-hosted test teardown crash by flushing controller updates before the idle fixture deallocates.

## Verification

- `xcodebuild test -project "Tools Cat.xcodeproj" -scheme "Tools Cat" -destination 'platform=macOS' -parallel-testing-enabled NO -only-testing:'Tools CatTests/StatusBarControllerKeepAwakeMenuTests/testIdleMenuHidesStopRowWhenKeepAwakeIsOff'`
- `xcodebuild test -project "Tools Cat.xcodeproj" -scheme "Tools Cat" -destination 'platform=macOS' -parallel-testing-enabled NO -only-testing:'Tools CatTests/StatusBarControllerKeepAwakeMenuTests' -only-testing:'Tools CatTests/KeepAwakeMenuStateTests'`

## Issues Encountered

- The first targeted controller run crashed in `testIdleMenuHidesStopRowWhenKeepAwakeIsOff()` during fixture destruction, not during the visibility assertions themselves.
- The failure was resolved by keeping the hosted AppKit fixture alive through an async controller flush before teardown.

## Next Phase Readiness

Plan `10-02` can now extend the same keep-awake/controller seams with compact-menu safety checks and update the Phase 10 validation contract without reopening the implementation surface.

## Self-Check: PASSED
