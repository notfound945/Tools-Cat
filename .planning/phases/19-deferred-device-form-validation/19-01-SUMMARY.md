---
phase: 19-deferred-device-form-validation
plan: 01
subsystem: ui
tags: [swiftui, macos, validation, xctest, xcuitest]
requires:
  - phase: 18-distribution-verification-closure
    provides: direct-launch device-library verification seam and current saved-device CRUD baseline
provides:
  - deferred saved-device validation reveal state owned by the device-library session
  - blur-driven reveal wiring in the device-library form with explicit submit kept as the save boundary
  - focused unit regressions for reveal timing and reset behavior
  - direct-launch ui tests for deferred validation timing, with remaining field-query verification gap documented
affects: [phase-20-first-use-device-seed, device-library, ui-tests]
tech-stack:
  added: []
  patterns: [per-field validation reveal state in session models, swiftui focus-driven blur reveal]
key-files:
  created: [.planning/phases/19-deferred-device-form-validation/19-01-SUMMARY.md]
  modified:
    - Tools Cat/DeviceLibrarySessionModel.swift
    - Tools Cat/DeviceLibraryView.swift
    - Tools CatTests/DeviceLibrarySessionModelTests.swift
    - Tools CatUITests/Tools_CatUITests.swift
key-decisions:
  - "Keep validation truth in DeviceLibrarySessionModel and expose reveal-aware visible messages instead of moving validation into the view."
  - "Remove the invalid-only disabled save gate so saveDraft() remains the explicit submit boundary for invalid drafts."
patterns-established:
  - "Session-owned reveal state: raw validation truth stays always available, but visible field messages require explicit reveal."
  - "SwiftUI blur reporting: the view tracks focus changes and only tells the session which field lost focus."
requirements-completed: [DEVS-10, DEVS-11, DEVS-12]
duration: 7min
completed: 2026-05-06
---

# Phase 19 Plan 01: Deferred Device Form Validation Summary

**Device-library validation now reveals per field after blur or explicit save attempts while invalid drafts still fail at the existing save boundary**

## Performance

- **Duration:** 7 min
- **Started:** 2026-05-06T01:46:00Z
- **Completed:** 2026-05-06T01:52:55Z
- **Tasks:** 2
- **Files modified:** 4

## Accomplishments
- Added per-field reveal state to the device-library session so name and MAC validation visibility is independent from validation truth.
- Updated the device-library form to use SwiftUI focus tracking and reveal-aware validation rendering while keeping save as the explicit submit path.
- Expanded unit and UI coverage around hidden-before-reveal, invalid submit, and direct-launch blur/submit validation timing.

## Task Commits

Each task was committed atomically:

1. **Task 1: Add field-level reveal state and keep invalid submit as the save-time truth boundary** - `e30e7c4` (feat)
2. **Task 2: Wire blur-driven reveal into the form and add direct-launch UI coverage for blur and submit timing** - `5b7909c` (feat)

## Files Created/Modified

- `Tools Cat/DeviceLibrarySessionModel.swift` - adds field-level reveal state, reveal helpers, and submit-driven validation exposure.
- `Tools Cat/DeviceLibraryView.swift` - wires `@FocusState` blur handling and renders only reveal-aware validation messages.
- `Tools CatTests/DeviceLibrarySessionModelTests.swift` - covers hidden-before-reveal, field-specific reveal, invalid submit reveal, and reveal reset.
- `Tools CatUITests/Tools_CatUITests.swift` - adds direct-launch validation timing tests and helper seams for opening the device form.

## Decisions Made

- Keep `ManualMACValidator` unchanged and continue treating `saveDraft()` as the only persistence truth boundary.
- Reveal state belongs in the session model, while the view only reports blur/submit events and shows reveal-aware messages.

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 3 - Blocking] Narrowed duplicate add-button UI lookup in empty device-library state**
- **Found during:** Task 2
- **Issue:** The new direct-launch validation tests hit two visible `添加设备` buttons in the empty-library surface and failed before opening the sheet.
- **Fix:** Adjusted the UI helper seam used by the new tests so add-form opening uses a stable first-match window button flow instead of the ambiguous raw query.
- **Files modified:** `Tools CatUITests/Tools_CatUITests.swift`
- **Verification:** Re-ran the focused UI slice; sheet opening progressed past the original ambiguity failure.
- **Committed in:** `5b7909c`

---

**Total deviations:** 1 auto-fixed (1 blocking)
**Impact on plan:** No scope change. The fix only stabilized the new UI test seam enough to reach the intended validation interactions.

## Issues Encountered

- Focused unit verification passed.
- Focused UI verification did not finish green after three bounded auto-fix attempts. The sheet opens, but the new `device-library-name-field` / `device-library-mac-field` queries were not resolved reliably by XCUITest in this environment, and one rerun also encountered an external `飞书` window interruption during clicks.

## Deferred Issues

- `Tools CatUITests/Tools_CatUITests.swift`: `testDeviceLibraryNameValidationRevealsAfterBlurOrSubmit` and `testDeviceLibraryMACValidationRevealsAfterBlurOrSubmit` still need a more reliable field-query seam or accessibility hook so the new direct-launch validation checks can pass consistently in XCUITest.

## User Setup Required

None - no external service configuration required.

## Next Phase Readiness

- Phase 20 can build on the new session/view validation timing split without reopening validation rules.
- Before final milestone verification, the new device-library UI tests should be stabilized so deferred validation timing is locked by automation instead of unit coverage plus manual inspection alone.

## Self-Check: PASSED

- Found `.planning/phases/19-deferred-device-form-validation/19-01-SUMMARY.md`
- Found commit `e30e7c4`
- Found commit `5b7909c`
