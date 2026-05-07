---
phase: 23
slug: device-form-save-guard
status: complete
nyquist_compliant: true
wave_0_complete: true
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
| 23-01-01 | 01 | 1 | DEVS-15, DEVS-16 | unit | `xcodebuild test -project "Tools Cat.xcodeproj" -scheme "Tools Cat" -destination 'platform=macOS' -parallel-testing-enabled NO -only-testing:'Tools CatTests/DeviceLibrarySessionModelTests'` | ✅ | ✅ green |
| 23-01-02 | 01 | 1 | DEVS-15, DEVS-16 | ui | `xcodebuild test -project "Tools Cat.xcodeproj" -scheme "Tools Cat" -destination 'platform=macOS' -parallel-testing-enabled NO -only-testing:'Tools CatUITests/Tools_CatUITests/testDeviceLibrarySaveButtonEnablesAfterRequiredInput' -only-testing:'Tools CatUITests/Tools_CatUITests/testDeviceLibraryNameValidationRevealsAfterSubmit' -only-testing:'Tools CatUITests/Tools_CatUITests/testDeviceLibraryMACValidationRevealsAfterBlurOrSubmit'` | ✅ existing file, new test method needed | ✅ green |

*Status: ⬜ pending · ✅ green · ❌ red · ⚠️ flaky*

---

## Wave 0 Requirements

Existing session-model and direct-launch UI coverage now satisfy the Wave 0 needs. No standalone bootstrap plan is required.

---

## Manual-Only Verifications

| Behavior | Requirement | Why Manual | Test Instructions |
|----------|-------------|------------|-------------------|
| Save button affordance feels consistent with the keep-awake duration form in real keyboard/mouse use | DEVS-15, DEVS-16 | Automated checks can prove state and validation timing, but not whether the live sheet feels naturally gated in native macOS use | Open `设备库`, enter only 名称 or only MAC and confirm `保存设备` stays disabled; then fill both fields and confirm the button enables without prematurely showing validation text |

---

## Validation Sign-Off

- [x] All tasks have `<automated>` verify or Wave 0 dependencies
- [x] Sampling continuity: no 3 consecutive tasks without automated verify
- [x] Wave 0 covers all MISSING references
- [x] No watch-mode flags
- [x] Feedback latency < 75s
- [x] `nyquist_compliant: true` set in frontmatter

**Approval:** 2026-05-07 validated after focused unit and UI regression passes
