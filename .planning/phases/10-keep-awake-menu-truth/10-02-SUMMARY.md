---
phase: 10-keep-awake-menu-truth
plan: 02
subsystem: testing
tags: [keep-awake, validation, xctest, appkit, menu-bar]
requires:
  - phase: 10-keep-awake-menu-truth
    provides: "The stop-row visibility rule implemented in plan 10-01"
provides:
  - "Focused startup, replacement, stopping, and compact-idle regressions for the keep-awake menu truth contract"
  - "A Phase 10 validation document that maps MENU-01 through MENU-03 to exact automated and manual checks"
affects: [phase-validation, keep-awake-regressions, menu-polish]
tech-stack:
  added: []
  patterns: ["State-specific menu regression coverage", "Requirement-to-test validation mapping"]
key-files:
  created: [".planning/phases/10-keep-awake-menu-truth/10-02-SUMMARY.md"]
  modified:
    - "Tools CatTests/KeepAwakeMenuStateTests.swift"
    - "Tools CatTests/StatusBarControllerKeepAwakeMenuTests.swift"
    - "Tools CatTests/StatusBarControllerMenuPolishTests.swift"
    - ".planning/phases/10-keep-awake-menu-truth/10-VALIDATION.md"
key-decisions:
  - "Keep extending the existing controller and menu-polish seams instead of adding a new broad menu suite"
  - "Assert compact idle structure through separator-scoped wake-group expectations rather than assuming hidden items change `menuIndex`"
  - "Make the validation contract name one concrete live-tray smoke boundary and the exact automated Phase 10 slice"
patterns-established:
  - "Small menu-truth phases should ship with explicit requirement coverage tables, not just generic validation notes"
requirements-completed: [MENU-02, MENU-03]
duration: 15min
completed: 2026-04-15
---

# Phase 10 Plan 2: Regression And Validation Lock-In Summary

**Phase 10 now has durable startup, replacement, stopping, and compact-idle keep-awake regressions, plus a validation contract that maps each menu-truth requirement to exact automated checks and one live-tray smoke.**

## Performance

- **Duration:** 15min
- **Completed:** 2026-04-15
- **Tasks:** 2
- **Files modified:** 4

## Accomplishments
- Added controller regressions for startup-from-off and replacement-while-active so stop-row visibility stays truthful before and after activation confirmation.
- Added a compact-idle menu polish test proving the hidden stop row does not reopen broader root-menu churn.
- Expanded the Phase 10 validation contract with requirement coverage, exact test references, and an explicit live-menu manual boundary.

## Verification

- `xcodebuild test -project "Tools Cat.xcodeproj" -scheme "Tools Cat" -destination 'platform=macOS' -parallel-testing-enabled NO -only-testing:'Tools CatTests/KeepAwakeMenuStateTests' -only-testing:'Tools CatTests/StatusBarControllerKeepAwakeMenuTests' -only-testing:'Tools CatTests/StatusBarControllerMenuPolishTests'`
- `grep -E 'MENU-01|MENU-02|MENU-03|10-01-01|10-02-02|StatusBarControllerKeepAwakeMenuTests|StatusBarControllerMenuPolishTests' .planning/phases/10-keep-awake-menu-truth/10-VALIDATION.md`

## Issues Encountered

- The first compact-idle polish assertion assumed that hiding `关闭常亮` would shift `wolItem` to the first slot after the separator.
- The menu still retains hidden rows in the underlying structure, so the test was corrected to assert separator-scoped wake-group contents and the stable `wolItem` offset instead.

## Next Phase Readiness

All Phase 10 plans now have summaries and green targeted verification, so the next GSD step is phase verification and completion rather than more execution.

## Self-Check: PASSED
