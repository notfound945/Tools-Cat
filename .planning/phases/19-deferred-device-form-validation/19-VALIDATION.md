---
phase: 19
slug: deferred-device-form-validation
status: draft
nyquist_compliant: true
wave_0_complete: true
created: 2026-05-06
---

# Phase 19 — Validation Strategy

> Per-phase validation contract for feedback sampling during execution.

---

## Test Infrastructure

| Property | Value |
|----------|-------|
| **Framework** | XCTest + XCUITest via Xcode 26.2 |
| **Config file** | none — Xcode project targets drive test config |
| **Quick run command** | `xcodebuild test -project "Tools Cat.xcodeproj" -scheme "Tools Cat" -destination 'platform=macOS' -parallel-testing-enabled NO -only-testing:'Tools CatTests/DeviceLibrarySessionModelTests' -only-testing:'Tools CatUITests/Tools_CatUITests/testLaunchWithSeededDeviceLibraryShowsManagementWindow'` |
| **Full suite command** | `xcodebuild test -project "Tools Cat.xcodeproj" -scheme "Tools Cat" -destination 'platform=macOS' -parallel-testing-enabled NO -only-testing:'Tools CatTests/DeviceLibrarySessionModelTests' -only-testing:'Tools CatTests/MACAddressValidatorTests' -only-testing:'Tools CatUITests/Tools_CatUITests/testLaunchWithSeededDeviceLibraryShowsManagementWindow' -only-testing:'Tools CatUITests/Tools_CatUITests/testLaunchWithSeededDeviceLibraryShowsManagementListSurface' -only-testing:'Tools CatUITests/Tools_CatUITests/testLaunchWithEmptyDeviceLibraryShowsPolishedEmptyState'` |
| **Estimated runtime** | ~45 seconds |

---

## Sampling Rate

- **After every task commit:** Run the quick run command above
- **After every plan wave:** Run the full suite command above plus any new Phase 19 UI validation tests
- **Before `$gsd-verify-work`:** Full suite must be green
- **Max feedback latency:** 60 seconds

---

## Per-Task Verification Map

| Task ID | Plan | Wave | Requirement | Test Type | Automated Command | File Exists | Status |
|---------|------|------|-------------|-----------|-------------------|-------------|--------|
| 19-01-01 | 01 | 1 | DEVS-10, DEVS-11, DEVS-12 | unit | `xcodebuild test -project "Tools Cat.xcodeproj" -scheme "Tools Cat" -destination 'platform=macOS' -parallel-testing-enabled NO -only-testing:'Tools CatTests/DeviceLibrarySessionModelTests'` | ✅ | ⬜ pending |
| 19-01-02 | 01 | 1 | DEVS-10, DEVS-11, DEVS-12 | ui | `xcodebuild test -project "Tools Cat.xcodeproj" -scheme "Tools Cat" -destination 'platform=macOS' -parallel-testing-enabled NO -only-testing:'Tools CatUITests/Tools_CatUITests/testLaunchWithSeededDeviceLibraryShowsManagementWindow' -only-testing:'Tools CatUITests/Tools_CatUITests/testDeviceLibraryNameValidationRevealsAfterBlurOrSubmit' -only-testing:'Tools CatUITests/Tools_CatUITests/testDeviceLibraryMACValidationRevealsAfterBlurOrSubmit'` | ✅ (created in Task 19-01-02) | ⬜ pending |

*Status: ⬜ pending · ✅ green · ❌ red · ⚠️ flaky*

---

## Wave 0 Requirements

Existing infrastructure covers the phase. The only missing UI checks are created inside Task `19-01-02`, so no standalone Wave 0 bootstrap plan is required.

---

## Manual-Only Verifications

| Behavior | Requirement | Why Manual | Test Instructions |
|----------|-------------|------------|-------------------|
| macOS native focus-ring feel and blur timing feel natural during real keyboard navigation | DEVS-10, DEVS-11 | UI automation can prove reveal timing functionally, but not whether the interaction feels native in real use | Open `设备库`, tab between 名称 and MAC fields, type invalid values, confirm warnings appear only after leaving a field or pressing return/save |

---

## Validation Sign-Off

- [ ] All tasks have `<automated>` verify or Wave 0 dependencies
- [ ] Sampling continuity: no 3 consecutive tasks without automated verify
- [x] Wave 0 covers all MISSING references
- [ ] No watch-mode flags
- [ ] Feedback latency < 60s
- [ ] `nyquist_compliant: true` set in frontmatter

**Approval:** 2026-05-06 planning self-approved after checker-aligned doc cleanup
