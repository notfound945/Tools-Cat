---
phase: 15
slug: device-library-ui-parity
status: ready-for-verification
nyquist_compliant: true
wave_0_complete: true
created: 2026-04-16
---

# Phase 15 — Validation Strategy

> Canonical validation contract for the device-library UI parity pass.

---

## Test Infrastructure

| Property | Value |
|----------|-------|
| **Framework** | XCTest plus focused direct-launch XCUITest smokes |
| **Config file** | `Tools Cat.xcodeproj/project.pbxproj` |
| **Quick run command** | `xcodebuild test -project "Tools Cat.xcodeproj" -scheme "Tools Cat" -destination 'platform=macOS' -parallel-testing-enabled NO -only-testing:'Tools CatTests/DeviceLibrarySessionModelTests' -only-testing:'Tools CatUITests/Tools_CatUITests/testLaunchWithSeededDeviceLibraryShowsManagementWindow'` |
| **Full suite command** | `xcodebuild test -project "Tools Cat.xcodeproj" -scheme "Tools Cat" -destination 'platform=macOS' -parallel-testing-enabled NO -only-testing:'Tools CatTests/DeviceLibrarySessionModelTests' -only-testing:'Tools CatTests/DeviceLibraryManagementPresentationTests' -only-testing:'Tools CatUITests/Tools_CatUITests/testLaunchWithSeededDeviceLibraryShowsManagementWindow' -only-testing:'Tools CatUITests/Tools_CatUITests/testLaunchWithSeededDeviceLibraryShowsManagementListSurface' -only-testing:'Tools CatUITests/Tools_CatUITests/testLaunchWithEmptyDeviceLibraryShowsPolishedEmptyState'` |
| **Estimated runtime** | ~20-30 seconds |

---

## Sampling Rate

- **After every task commit:** Run the quick command above
- **After every plan wave:** Run the full suite command above
- **Before `$gsd-verify-work`:** Full suite must be green
- **Max feedback latency:** 30 seconds

---

## Per-Task Verification Map

| Task ID | Plan | Wave | Requirement | Test Type | Automated Command | File Exists | Status |
|---------|------|------|-------------|-----------|-------------------|-------------|--------|
| 15-01-01 | 01 | 1 | DEVS-06, DEVS-07 | ui + session | `xcodebuild test -project "Tools Cat.xcodeproj" -scheme "Tools Cat" -destination 'platform=macOS' -parallel-testing-enabled NO -only-testing:'Tools CatTests/DeviceLibrarySessionModelTests' -only-testing:'Tools CatUITests/Tools_CatUITests/testLaunchWithSeededDeviceLibraryShowsManagementWindow' -only-testing:'Tools CatUITests/Tools_CatUITests/testLaunchWithSeededDeviceLibraryShowsManagementListSurface'` | ✅ | ⬜ pending |
| 15-02-01 | 02 | 2 | DEVS-08, DEVS-09 | ui + regression | `xcodebuild test -project "Tools Cat.xcodeproj" -scheme "Tools Cat" -destination 'platform=macOS' -parallel-testing-enabled NO -only-testing:'Tools CatTests/DeviceLibrarySessionModelTests' -only-testing:'Tools CatTests/DeviceLibraryManagementPresentationTests' -only-testing:'Tools CatUITests/Tools_CatUITests/testLaunchWithSeededDeviceLibraryShowsManagementWindow' -only-testing:'Tools CatUITests/Tools_CatUITests/testLaunchWithSeededDeviceLibraryShowsManagementListSurface' -only-testing:'Tools CatUITests/Tools_CatUITests/testLaunchWithEmptyDeviceLibraryShowsPolishedEmptyState'` | ✅ | ⬜ pending |

Phase 15 uses the same focused device-library regression slice for wave 2 because `DEVS-09` is explicitly about preserving already-shipped add/edit/delete/reorder/direct-launch truth while the surface is polished.

*Status: ⬜ pending · ✅ green · ❌ red · ⚠️ flaky*

---

## Wave 0 Requirements

- [x] `Tools Cat/DeviceLibraryView.swift` — existing device-library manager surface
- [x] `Tools Cat/DeviceLibrarySessionModel.swift` — existing CRUD/reorder truth seam
- [x] `Tools CatTests/DeviceLibrarySessionModelTests.swift` — session regression coverage already exists
- [x] `Tools CatTests/DeviceLibraryManagementPresentationTests.swift` — presentation string seam already exists
- [x] `Tools CatUITests/Tools_CatUITests.swift` — direct-launch device-library smokes already exist

Existing infrastructure covers all phase requirements.

---

## Manual-Only Verifications

All phase behaviors should remain provable through the focused device-library session tests plus direct-launch UI smokes. No new manual-only boundary is required if the new list and shared-sheet seams remain structurally assertable.

---

## Validation Sign-Off

- [x] All tasks have automated verify commands
- [x] Sampling continuity is preserved
- [x] Wave 0 covers all required infrastructure
- [x] No watch-mode flags
- [x] Feedback latency < 60s
- [x] `nyquist_compliant: true` is justified by the existing device-library session tests plus direct-launch UI smokes

**Approval:** verification-ready
