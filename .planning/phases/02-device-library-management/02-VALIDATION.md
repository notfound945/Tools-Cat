---
phase: 2
slug: device-library-management
status: approved
nyquist_compliant: true
wave_0_complete: true
created: 2026-04-11
---

# Phase 2 — Validation Strategy

> Current validation contract for the saved-device manager and shared device-library flow.

---

## Test Infrastructure

| Property | Value |
|----------|-------|
| **Framework** | XCTest plus launch-argument XCUITest smoke and focused manual AppKit checks |
| **Config file** | `Mac OS Swiss Knife.xcodeproj/project.pbxproj` |
| **Quick run command** | `xcodebuild test -project "Mac OS Swiss Knife.xcodeproj" -scheme "Mac OS Swiss Knife" -destination 'platform=macOS' -parallel-testing-enabled NO -only-testing:'Mac OS Swiss KnifeTests/SavedDeviceRepositoryTests' -only-testing:'Mac OS Swiss KnifeTests/DeviceLibrarySessionModelTests' -only-testing:'Mac OS Swiss KnifeTests/DeviceLibraryManagementPresentationTests'` |
| **Full suite command** | `xcodebuild test -project "Mac OS Swiss Knife.xcodeproj" -scheme "Mac OS Swiss Knife" -destination 'platform=macOS' -parallel-testing-enabled NO -only-testing:'Mac OS Swiss KnifeTests/SavedDeviceRepositoryTests' -only-testing:'Mac OS Swiss KnifeTests/DeviceLibrarySessionModelTests' -only-testing:'Mac OS Swiss KnifeTests/DeviceLibraryManagementPresentationTests' -only-testing:'Mac OS Swiss KnifeTests/WOLSessionModelTests' -only-testing:'Mac OS Swiss KnifeUITests/Mac_OS_Swiss_KnifeUITests/testLaunchWithSeededDeviceLibraryShowsManagementListSurface' -only-testing:'Mac OS Swiss KnifeUITests/Mac_OS_Swiss_KnifeUITests/testLaunchWithEmptyDeviceLibraryShowsPolishedEmptyState'` |
| **Estimated runtime** | ~5-15 seconds for the targeted slice |

---

## Sampling Rate

- **After every task commit:** Run the targeted repository/session/presentation slice
- **After every plan wave:** Re-run the slice and, when UI-facing manager changes are involved, add the current launch-argument UI smoke
- **Before `$gsd-verify-work`:** Unit evidence and direct-launch manager smoke must both be green
- **Max feedback latency:** 15 seconds

---

## Per-Task Verification Map

| Task ID | Plan | Wave | Requirement | Test Type | Automated Command | File Exists | Status |
|---------|------|------|-------------|-----------|-------------------|-------------|--------|
| 2-01-01 | 01 | 1 | DEVS-01, DEVS-05, RELY-01 | unit | `xcodebuild test -project "Mac OS Swiss Knife.xcodeproj" -scheme "Mac OS Swiss Knife" -destination 'platform=macOS' -parallel-testing-enabled NO -only-testing:'Mac OS Swiss KnifeTests/SavedDeviceRepositoryTests'` | ✅ | ✅ green |
| 2-01-02 | 01 | 1 | DEVS-01, RELY-01 | unit | `xcodebuild test -project "Mac OS Swiss Knife.xcodeproj" -scheme "Mac OS Swiss Knife" -destination 'platform=macOS' -parallel-testing-enabled NO -only-testing:'Mac OS Swiss KnifeTests/DeviceLibrarySessionModelTests'` | ✅ | ✅ green |
| 2-02-01 | 02 | 2 | UX-02, DEVS-02, DEVS-05 | unit + UI smoke | `xcodebuild test -project "Mac OS Swiss Knife.xcodeproj" -scheme "Mac OS Swiss Knife" -destination 'platform=macOS' -parallel-testing-enabled NO -only-testing:'Mac OS Swiss KnifeTests/DeviceLibrarySessionModelTests' -only-testing:'Mac OS Swiss KnifeUITests/Mac_OS_Swiss_KnifeUITests/testLaunchWithSeededDeviceLibraryShowsManagementListSurface' -only-testing:'Mac OS Swiss KnifeUITests/Mac_OS_Swiss_KnifeUITests/testLaunchWithEmptyDeviceLibraryShowsPolishedEmptyState'` | ✅ | ✅ green |
| 2-02-02 | 02 | 2 | DEVS-02, RELY-01 | unit | `xcodebuild test -project "Mac OS Swiss Knife.xcodeproj" -scheme "Mac OS Swiss Knife" -destination 'platform=macOS' -parallel-testing-enabled NO -only-testing:'Mac OS Swiss KnifeTests/DeviceLibraryManagementPresentationTests'` | ✅ | ✅ green |
| 2-03-01 | 03 | 2 | DEVS-03, DEVS-04 | unit | `xcodebuild test -project "Mac OS Swiss Knife.xcodeproj" -scheme "Mac OS Swiss Knife" -destination 'platform=macOS' -parallel-testing-enabled NO -only-testing:'Mac OS Swiss KnifeTests/SavedDeviceRepositoryTests'` | ✅ | ✅ green |
| 2-03-02 | 03 | 2 | UX-02, DEVS-04 | unit + manual smoke | `xcodebuild test -project "Mac OS Swiss Knife.xcodeproj" -scheme "Mac OS Swiss Knife" -destination 'platform=macOS' -parallel-testing-enabled NO -only-testing:'Mac OS Swiss KnifeUITests/Mac_OS_Swiss_KnifeUITests/testLaunchWithSeededDeviceLibraryShowsManagementListSurface'` | ✅ | ✅ green |

*Status: ✅ green · ⚠ manual-only boundary*

---

## Wave 0 Requirements

- [x] `Mac OS Swiss KnifeTests/SavedDeviceRepositoryTests.swift` exists and covers CRUD persistence, canonical ordering, and reload behavior
- [x] `Mac OS Swiss KnifeTests/DeviceLibrarySessionModelTests.swift` exists and covers draft validation, add/edit/delete flow, and reorder persistence
- [x] `Mac OS Swiss KnifeTests/DeviceLibraryManagementPresentationTests.swift` exists and covers manager copy-contract behavior
- [x] `Mac OS Swiss KnifeUITests/Mac_OS_Swiss_KnifeUITests.swift` already contains the current launch-argument manager smoke paths, including `testLaunchWithSeededDeviceLibraryShowsManagementListSurface`
- [x] The shared repository/session/presentation seams needed by the tests already exist

Existing infrastructure covers all Phase 2 validation references.

---

## Manual-Only Verifications

| Behavior | Requirement | Why Manual | Evidence Boundary |
|----------|-------------|------------|-------------------|
| The dedicated `管理设备…` path opens a native manager window independently from the WOL window | UX-02 | Direct-launch smoke proves the manager surface, but not the live tray-entry feel of both retained windows together | Still a live AppKit/manual boundary |
| Reorder mode exposes drag sorting only when explicitly entered and feels native during drag interaction | DEVS-04 | Unit tests prove persistence and order results, but not drag gesture feel | Still a live AppKit/manual boundary |
| Delete confirmation presents a native confirmation flow before removal | DEVS-03 | Unit tests prove the guarded state machine, but not the exact native confirmation interaction feel | Still a live AppKit/manual boundary |

---

## Validation Sign-Off

- [x] All tasks have automated verify or explicit manual-only boundaries
- [x] Sampling continuity is preserved
- [x] Wave 0 coverage references are now real artifacts, not placeholders
- [x] No watch-mode flags
- [x] Feedback latency < 60s
- [x] `nyquist_compliant: true` remains accurate

**Approval:** approved 2026-04-13
