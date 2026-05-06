---
phase: 19-deferred-device-form-validation
verified: 2026-05-06T12:05:00+08:00
status: passed
score: 3/3 must-haves verified
---

# Phase 19: Deferred Device Form Validation Verification Report

**Phase Goal:** The saved-device form reveals validation only after blur or explicit submit while preserving the existing save-time truth boundary for invalid drafts.  
**Verified:** 2026-05-06T12:05:00+08:00  
**Status:** passed  
**Re-verification:** Yes - this verification closes the missing artifact gap using the shipped Phase 19 implementation plus focused regression evidence

## Goal Achievement

### Observable Truths

| # | Truth | Status | Evidence |
| --- | --- | --- | --- |
| 1 | Name validation no longer appears during in-progress typing and is revealed only after blur or explicit submit. | ✓ VERIFIED | [`Tools Cat/DeviceLibrarySessionModel.swift`](../../../Tools%20Cat/DeviceLibrarySessionModel.swift) keeps reveal state separate from raw validation truth through `revealedValidationFields` and `visibleNameValidationMessage`, while [`Tools Cat/DeviceLibraryView.swift`](../../../Tools%20Cat/DeviceLibraryView.swift) wires `@FocusState` blur handling and submit-driven reveal for the name field. |
| 2 | MAC validation no longer appears during in-progress typing and is revealed only after blur or explicit submit. | ✓ VERIFIED | [`Tools Cat/DeviceLibrarySessionModel.swift`](../../../Tools%20Cat/DeviceLibrarySessionModel.swift) exposes `visibleMACAddressValidationMessage` and preserves `ManualMACValidator` as the canonical rule source, while [`Tools Cat/DeviceLibraryView.swift`](../../../Tools%20Cat/DeviceLibraryView.swift) reveals the MAC warning only from blur/submit transitions. |
| 3 | Invalid drafts still cannot be saved; `saveDraft()` remains the persistence truth boundary and explicit submit path. | ✓ VERIFIED | [`Tools Cat/DeviceLibrarySessionModel.swift`](../../../Tools%20Cat/DeviceLibrarySessionModel.swift) calls `revealValidationForSubmit()` inside `saveDraft()` and returns early on invalid name or MAC; [`Tools CatTests/DeviceLibrarySessionModelTests.swift`](../../../Tools%20CatTests/DeviceLibrarySessionModelTests.swift) and [`Tools CatUITests/Tools_CatUITests.swift`](../../../Tools%20CatUITests/Tools_CatUITests.swift) cover invalid-submit reveal and the sheet staying open. |

**Score:** 3/3 truths verified

### Required Artifacts

| Artifact | Expected | Status | Details |
| --- | --- | --- | --- |
| `19-01-SUMMARY.md` | Shipped implementation summary for the phase | ✓ VERIFIED | Exists and records the reveal-state/session split, focused regression coverage, and the explicit submit/save boundary outcome. |
| `19-VALIDATION.md` | Canonical regression contract for DEVS-10 through DEVS-12 | ✓ VERIFIED | Exists and maps the phase requirements to focused unit and UI commands, plus one explicit manual-only feel boundary. |
| `Tools Cat/DeviceLibrarySessionModel.swift` | Session-owned reveal state and save-boundary truth | ✓ VERIFIED | Exists and contains `revealedValidationFields`, `visibleNameValidationMessage`, `visibleMACAddressValidationMessage`, and submit-time validation reveal. |
| `Tools Cat/DeviceLibraryView.swift` | Blur-driven UI wiring for reveal timing | ✓ VERIFIED | Exists and contains `@FocusState`, `.focused(...)`, and `revealValidationIfNeeded(afterBlurFrom:to:)`. |
| `Tools CatTests/DeviceLibrarySessionModelTests.swift` | Focused unit coverage for hidden-before-reveal and invalid submit behavior | ✓ VERIFIED | Exists and covers reveal reset, field-specific reveal, and invalid draft blocking. |
| `Tools CatUITests/Tools_CatUITests.swift` | Direct-launch UI evidence for submit/blur timing | ✓ VERIFIED | Exists and contains `testLaunchWithSeededDeviceLibraryShowsManagementWindow`, `testDeviceLibraryNameValidationRevealsAfterSubmit`, and `testDeviceLibraryMACValidationRevealsAfterBlurOrSubmit`. |

### Key Link Verification

| From | To | Via | Status | Details |
| --- | --- | --- | --- | --- |
| `19-VERIFICATION.md` | `19-01-SUMMARY.md` | Verification artifact cites the shipped implementation outcome | WIRED | The summary records the reveal-state/session split and the saved explicit-submit boundary this report verifies. |
| `19-VERIFICATION.md` | `19-VALIDATION.md` | Verification artifact anchors DEVS-10 through DEVS-12 to the planned regression contract | WIRED | The validation file names the exact focused unit and UI slices that back this report. |
| `Tools Cat/DeviceLibraryView.swift` | `Tools Cat/DeviceLibrarySessionModel.swift` | View reports blur/submit transitions while the session owns reveal truth | WIRED | `revealValidationIfNeeded(afterBlurFrom:to:)` calls the session reveal helpers rather than duplicating validation rules in the view. |
| `Tools CatUITests/Tools_CatUITests.swift` | `Tools Cat/DeviceLibraryView.swift` | Direct-launch UI tests exercise the shipped device-library form seam | WIRED | The tests open the real form through `--ui-test-open-device-library` and assert user-visible blur/submit timing. |

### Requirements Coverage

| Requirement | Source Plan | Description | Status | Evidence |
| --- | --- | --- | --- | --- |
| `DEVS-10` | `19-01-PLAN.md` | Name validation appears only after blur or explicit submit | ✓ SATISFIED | `visibleNameValidationMessage` plus `testDeviceLibraryNameValidationRevealsAfterSubmit` prove the name warning stays hidden until reveal. |
| `DEVS-11` | `19-01-PLAN.md` | MAC validation appears only after blur or explicit submit | ✓ SATISFIED | `visibleMACAddressValidationMessage` plus `testDeviceLibraryMACValidationRevealsAfterBlurOrSubmit` prove the MAC warning stays hidden until reveal. |
| `DEVS-12` | `19-01-PLAN.md` | Invalid drafts still cannot be saved | ✓ SATISFIED | `saveDraft()` still blocks invalid persistence and both unit/UI tests prove invalid submit reveals feedback while the form remains open. |

Orphaned requirements: None. All Phase 19 requirement IDs claimed by the plan are covered by this verification evidence.

### Behavioral Spot-Checks

| Behavior | Command | Result | Status |
| --- | --- | --- | --- |
| Focused Phase 19 unit regression | `xcodebuild test -project "Tools Cat.xcodeproj" -scheme "Tools Cat" -destination 'platform=macOS' -parallel-testing-enabled NO -only-testing:'Tools CatTests/DeviceLibrarySessionModelTests'` | Passed in the Phase 19 execution session and remains the canonical unit slice recorded in `19-VALIDATION.md` | ✓ PASS |
| Focused Phase 19 UI regression | `xcodebuild test -project "Tools Cat.xcodeproj" -scheme "Tools Cat" -destination 'platform=macOS' -parallel-testing-enabled NO -only-testing:'Tools CatUITests/Tools_CatUITests/testLaunchWithSeededDeviceLibraryShowsManagementWindow' -only-testing:'Tools CatUITests/Tools_CatUITests/testDeviceLibraryNameValidationRevealsAfterSubmit' -only-testing:'Tools CatUITests/Tools_CatUITests/testDeviceLibraryMACValidationRevealsAfterBlurOrSubmit'` | Re-passed on 2026-05-06 when rerun serially to avoid desktop focus contention from overlapping UI sessions | ✓ PASS |

### Anti-Patterns Found

| File | Line | Pattern | Severity | Impact |
| --- | --- | --- | --- | --- |
| None | - | No placeholder markers, no duplicated validator logic, and no reopened persistence-scope changes were introduced by the shipped Phase 19 work. | - | No blocker anti-patterns found. |

### Human Verification Required

One non-blocking manual-only boundary remains and is already documented in `19-VALIDATION.md`:

1. Open `设备库` normally.
2. Navigate the form with the keyboard focus ring.
3. Confirm the interaction still feels native while warnings appear only after blur or submit.

This is not a failing gap; it is the subjective boundary left intentionally outside automation.

### Gaps Summary

No functional gaps remain against the Phase 19 goal. The only missing artifact was this formal verification report, and the shipped evidence chain now closes that gap without reopening app behavior.

---

_Verified: 2026-05-06T12:05:00+08:00_  
_Verifier: Codex_
