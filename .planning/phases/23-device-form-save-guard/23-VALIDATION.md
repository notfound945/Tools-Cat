---
phase: 23
slug: device-form-save-guard
status: draft
nyquist_compliant: false
wave_0_complete: false
created: 2026-05-06
---

# Phase 23 — Validation Strategy

> Per-phase validation contract for feedback sampling during execution.

---

## Test Infrastructure

| Property | Value |
|----------|-------|
| **Framework** | XCTest + XCUITest via Xcode 26.2 |
| **Config file** | none — Xcode project targets drive test config |
| **Quick run command** | `xcodebuild test -project "Tools Cat.xcodeproj" -scheme "Tools Cat" -destination 'platform=macOS' -parallel-testing-enabled NO -only-testing:'Tools CatTests/DeviceLibrarySessionModelTests'` |
| **Full suite command** | `xcodebuild test -project "Tools Cat.xcodeproj" -scheme "Tools Cat" -destination 'platform=macOS' -parallel-testing-enabled NO -only-testing:'Tools CatTests/DeviceLibrarySessionModelTests' -only-testing:'Tools CatUITests/Tools_CatUITests/testDeviceLibrarySaveButtonEnablesAfterRequiredInput' -only-testing:'Tools CatUITests/Tools_CatUITests/testDeviceLibraryNameValidationRevealsAfterSubmit' -only-testing:'Tools CatUITests/Tools_CatUITests/testDeviceLibraryMACValidationRevealsAfterBlurOrSubmit'` |
| **Estimated runtime** | ~75 seconds |

---

## Sampling Rate

- **After every task commit:** Run the quick run command above
- **After every plan wave:** Run the full suite command above
- **Before `$gsd-verify-work`:** Full suite must be green
- **Max feedback latency:** 75 seconds

---

## Per-Task Verification Map

| Task ID | Plan | Wave | Requirement | Test Type | Automated Command | File Exists | Status |
|---------|------|------|-------------|-----------|-------------------|-------------|--------|
| 23-01-01 | 01 | 1 | DEVS-15, DEVS-16 | unit | `xcodebuild test -project "Tools Cat.xcodeproj" -scheme "Tools Cat" -destination 'platform=macOS' -parallel-testing-enabled NO -only-testing:'Tools CatTests/DeviceLibrarySessionModelTests'` | ✅ | ⬜ pending |
| 23-01-02 | 01 | 1 | DEVS-15, DEVS-16 | ui | `xcodebuild test -project "Tools Cat.xcodeproj" -scheme "Tools Cat" -destination 'platform=macOS' -parallel-testing-enabled NO -only-testing:'Tools CatUITests/Tools_CatUITests/testDeviceLibrarySaveButtonEnablesAfterRequiredInput' -only-testing:'Tools CatUITests/Tools_CatUITests/testDeviceLibraryNameValidationRevealsAfterSubmit' -only-testing:'Tools CatUITests/Tools_CatUITests/testDeviceLibraryMACValidationRevealsAfterBlurOrSubmit'` | ✅ existing file, new test method needed | ⬜ pending |

*Status: ⬜ pending · ✅ green · ❌ red · ⚠️ flaky*

---

## Wave 0 Requirements

- [ ] `Tools CatTests/DeviceLibrarySessionModelTests.swift` — add `canSaveDraft` coverage for empty, whitespace-only, partially filled, malformed-but-non-empty, fully filled, and prefilled edit-form states.
- [ ] `Tools CatUITests/Tools_CatUITests.swift` — add one focused save-button enabled/disabled transition test using the existing device-library form helpers.
- [ ] `Tools CatUITests/Tools_CatUITests.swift` — ensure the new UI test proves malformed-but-non-empty MAC input can enable the button without weakening submit-time validation.

---

## Manual-Only Verifications

| Behavior | Requirement | Why Manual | Test Instructions |
|----------|-------------|------------|-------------------|
| Save button affordance feels consistent with the keep-awake duration form in real keyboard/mouse use | DEVS-15, DEVS-16 | Automated checks can prove state and validation timing, but not whether the live sheet feels naturally gated in native macOS use | Open `设备库`, enter only 名称 or only MAC and confirm `保存设备` stays disabled; then fill both fields and confirm the button enables without prematurely showing validation text |

---

## Validation Sign-Off

- [ ] All tasks have `<automated>` verify or Wave 0 dependencies
- [ ] Sampling continuity: no 3 consecutive tasks without automated verify
- [ ] Wave 0 covers all MISSING references
- [ ] No watch-mode flags
- [ ] Feedback latency < 75s
- [ ] `nyquist_compliant: true` set in frontmatter

**Approval:** pending
