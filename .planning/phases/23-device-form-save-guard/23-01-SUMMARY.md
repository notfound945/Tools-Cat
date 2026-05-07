---
phase: 23-device-form-save-guard
plan: 01
subsystem: ui
tags: [swift, macos, xctest, xcuitest, device-library]
requires:
  - phase: 19-deferred-device-form-validation
    provides: delayed validation reveal timing and submit-time validation truth for the saved-device form
  - phase: 21-device-entry-verification-closure
    provides: the locked v1.7 device-entry baseline this affordance change must preserve
  - phase: 15-device-library-ui-parity
    provides: the current native device-library sheet structure and direct-launch UI test seams
provides:
  - a session-owned `canSaveDraft` predicate based on trimmed required-field presence for the saved-device form
  - disabled-state binding on `保存设备` that matches keep-awake duration affordance timing without changing submit-time validation truth
  - focused unit and UI coverage proving malformed-but-non-empty MAC input can enable save while submit still reveals the existing MAC validation error
affects: [device-library, saved-device-form, ui-tests]
tech-stack:
  added: []
  patterns:
    - session-owned save gating based on trimmed required-field presence while `saveDraft()` remains the validation and persistence truth boundary
    - direct-launch macOS UI tests that assert enablement transitions separately from validation-message reveal timing
key-files:
  created:
    - .planning/phases/23-device-form-save-guard/23-01-SUMMARY.md
  modified:
    - Tools Cat/DeviceLibrarySessionModel.swift
    - Tools Cat/DeviceLibraryView.swift
    - Tools CatTests/DeviceLibrarySessionModelTests.swift
    - Tools CatUITests/Tools_CatUITests.swift
key-decisions:
  - "Keep the save-button predicate in `DeviceLibrarySessionModel` so the view stays presentation-only and `saveDraft()` remains the only validation/persistence truth boundary."
  - "Enable `保存设备` as soon as both required fields have trimmed input, even if the MAC is malformed, so delayed validation reveal timing from Phase 19 remains unchanged."
patterns-established:
  - "Pattern: required-field affordance gating can be looser than submit-time validation, as long as the session model owns both seams explicitly."
  - "Pattern: device-library UI regressions are covered through direct-launch sheet tests using existing accessibility helpers."
requirements-completed: [DEVS-15, DEVS-16]
duration: 5min
completed: 2026-05-07
---

# Phase 23 Plan 01: Device Form Save Guard Summary

**The saved-device form now keeps `保存设备` disabled until trimmed name and MAC input exist, while preserving delayed validation reveal and submit-time MAC rejection**

## Performance

- **Duration:** 5 min
- **Started:** 2026-05-07T14:09:00+0800
- **Completed:** 2026-05-07T14:13:53+0800
- **Tasks:** 2
- **Files modified:** 5

## Accomplishments

- Rebased `DeviceLibrarySessionModel.canSaveDraft` from full validity to trimmed required-field presence only.
- Bound the saved-device form's primary action to that session predicate so the button stays disabled until both required fields are filled.
- Added focused unit and UI regressions proving malformed-but-non-empty MAC input can enable save while submit still leaves the sheet open and reveals `MAC 地址必须是 6 组两位十六进制字符`.

## Task Commits

Each task was committed atomically:

1. **Task 1: Redefine device-form save gating in the session model and lock it with focused unit coverage** - `4e50f8f` (`feat`)
2. **Task 2: Bind the save button to the session predicate and prove the direct-launch form behavior in UI tests** - `7367f2b` (`test`)

**Plan metadata:** `81b4542` (`docs(phase-23): complete phase execution`)

## Files Created/Modified

- `Tools Cat/DeviceLibrarySessionModel.swift` - changes `canSaveDraft` to require only trimmed non-empty name and MAC input.
- `Tools CatTests/DeviceLibrarySessionModelTests.swift` - adds required-field gating, malformed-MAC submit, and prefilled-edit coverage.
- `Tools Cat/DeviceLibraryView.swift` - disables `保存设备` from the shared session predicate.
- `Tools CatUITests/Tools_CatUITests.swift` - adds a direct-launch enablement regression for the saved-device sheet.
- `.planning/phases/23-device-form-save-guard/23-01-SUMMARY.md` - records execution outcome and verification.

## Decisions Made

- Kept validation timing unchanged by leaving `revealValidationForSubmit()`, field blur reveal, and `saveDraft()` early returns untouched.
- Matched the keep-awake duration form pattern at the affordance layer only, without weakening MAC normalization or validation rules.

## Deviations from Plan

None - plan executed exactly as written.

## Issues Encountered

- Running unit and UI `xcodebuild test` commands in parallel hit Xcode's shared DerivedData build database lock. The UI slice was allowed to finish, then the unit slice was rerun sequentially and passed without code changes.

## User Setup Required

None - no external service configuration required.

## Next Phase Readiness

- The saved-device form now has the requested affordance guardrail, with both session-level and UI-level regression coverage in place.
- Phase 23 is ready for verification/closure work without reopening WOL, seeding, or validation timing scope.

---
*Phase: 23-device-form-save-guard*
*Completed: 2026-05-07*
