---
phase: 3
slug: saved-device-wake-flows
status: approved
nyquist_compliant: true
wave_0_complete: true
created: 2026-04-12
---

# Phase 3 — Validation Strategy

> Current validation contract for the shipped compact wake flow centered on `快速 WOL` plus the dedicated `发送 WOL …` window entry.

---

## Test Infrastructure

| Property | Value |
|----------|-------|
| **Framework** | XCTest plus targeted XCUITest smoke and focused live AppKit checks |
| **Config file** | `Mac OS Swiss Knife.xcodeproj/project.pbxproj` |
| **Quick run command** | `xcodebuild test -project "Mac OS Swiss Knife.xcodeproj" -scheme "Mac OS Swiss Knife" -destination 'platform=macOS' -parallel-testing-enabled NO -only-testing:'Mac OS Swiss KnifeTests/SavedDeviceLibraryStoreTests' -only-testing:'Mac OS Swiss KnifeTests/StatusBarControllerWakeMenuTests' -only-testing:'Mac OS Swiss KnifeTests/WOLSessionModelTests'` |
| **Full suite command** | `xcodebuild test -project "Mac OS Swiss Knife.xcodeproj" -scheme "Mac OS Swiss Knife" -destination 'platform=macOS' -parallel-testing-enabled NO -only-testing:'Mac OS Swiss KnifeTests/SavedDeviceLibraryStoreTests' -only-testing:'Mac OS Swiss KnifeTests/StatusBarControllerWakeMenuTests' -only-testing:'Mac OS Swiss KnifeTests/WOLSessionModelTests' -only-testing:'Mac OS Swiss KnifeUITests/Mac_OS_Swiss_KnifeUITests/testLaunchWithSeededDeviceLibraryShowsManagementListSurface' -only-testing:'Mac OS Swiss KnifeUITests/Mac_OS_Swiss_KnifeUITests/testLaunchWithWOLWindowShowsPolishedSections'` |
| **Estimated runtime** | ~10-20 seconds for the targeted slice |

---

## Sampling Rate

- **After every task commit:** Run the targeted wake-flow unit slice above.
- **After every plan wave:** Re-run the wake-flow unit slice and add the current launch-argument smoke when window presentation or shared-library ownership changed.
- **Before `$gsd-verify-work`:** Shared wake-state tests and the compact wake/window smoke evidence must both remain green.
- **Max feedback latency:** 20 seconds

---

## Per-Task Verification Map

| Task ID | Plan | Wave | Requirement | Test Type | Automated Command | File Exists | Status |
|---------|------|------|-------------|-----------|-------------------|-------------|--------|
| 3-01-01 | 01 | 1 | WOL-04, WOL-03 | unit | `xcodebuild test -project "Mac OS Swiss Knife.xcodeproj" -scheme "Mac OS Swiss Knife" -destination 'platform=macOS' -parallel-testing-enabled NO -only-testing:'Mac OS Swiss KnifeTests/SavedDeviceLibraryStoreTests'` | ✅ | ✅ green |
| 3-01-02 | 01 | 1 | RELY-04, UX-03, WOL-03 | unit | `xcodebuild test -project "Mac OS Swiss Knife.xcodeproj" -scheme "Mac OS Swiss Knife" -destination 'platform=macOS' -parallel-testing-enabled NO -only-testing:'Mac OS Swiss KnifeTests/WOLSessionModelTests'` | ✅ | ✅ green |
| 3-02-01 | 02 | 2 | WOL-01, WOL-04, RELY-04 | unit | `xcodebuild test -project "Mac OS Swiss Knife.xcodeproj" -scheme "Mac OS Swiss Knife" -destination 'platform=macOS' -parallel-testing-enabled NO -only-testing:'Mac OS Swiss KnifeTests/StatusBarControllerWakeMenuTests'` | ✅ | ✅ green |
| 3-02-02 | 02 | 2 | UX-03, RELY-04 | unit | `xcodebuild test -project "Mac OS Swiss Knife.xcodeproj" -scheme "Mac OS Swiss Knife" -destination 'platform=macOS' -parallel-testing-enabled NO -only-testing:'Mac OS Swiss KnifeTests/StatusBarControllerWakeMenuTests'` | ✅ | ✅ green |
| 3-03-01 | 03 | 3 | WOL-03, UX-03 | unit + UI smoke | `xcodebuild test -project "Mac OS Swiss Knife.xcodeproj" -scheme "Mac OS Swiss Knife" -destination 'platform=macOS' -parallel-testing-enabled NO -only-testing:'Mac OS Swiss KnifeTests/WOLSessionModelTests' -only-testing:'Mac OS Swiss KnifeUITests/Mac_OS_Swiss_KnifeUITests/testLaunchWithWOLWindowShowsPolishedSections'` | ✅ | ✅ green |

*Status: ✅ green · ⚠ manual-only boundary*

---

## Wave 0 Requirements

- [x] `Mac OS Swiss KnifeTests/SavedDeviceLibraryStoreTests.swift` exists and covers wake metadata persistence, recent-device trimming, and delete-time metadata pruning.
- [x] `Mac OS Swiss KnifeTests/StatusBarControllerWakeMenuTests.swift` exists and covers the compact `快速 WOL` section, durable wake-status row, and disabled wake actions while sending.
- [x] `Mac OS Swiss KnifeTests/WOLSessionModelTests.swift` exists and covers `sendSavedDevice(id:)`, success-only recent updates, deleted-last-used fallback, and manual-draft-preserving reopen behavior.
- [x] `StatusBarController` and `WOLSessionModel` already expose the fakeable wake and shared-session seams these tests rely on.

Existing infrastructure covers all Phase 3 validation references.

---

## Manual-Only Verifications

| Behavior | Requirement | Why Manual | Evidence Boundary |
|----------|-------------|------------|-------------------|
| The live menu keeps the wake surface compact and scanable with one `快速 WOL` section plus the separate `发送 WOL …` row | WOL-01, WOL-04 | XCTest proves structure and wiring, but real AppKit menu density still needs live interaction | Still a live AppKit/manual boundary |
| Saved-device wake actions visibly disable while another send is in flight | RELY-04 | Unit tests prove the shared session state and menu-item enable rules, but not the exact native-menu timing feel | Still a live AppKit/manual boundary |
| Reopening the retained WOL window restores last-used saved-device context without erasing an unfinished manual draft | WOL-03 | Unit tests prove ownership and fallback logic, but the retained AppKit window lifecycle still benefits from one live smoke | Still a live AppKit/manual boundary |

---

## Validation Sign-Off

- [x] All tasks have automated verify or explicit manual-only boundaries
- [x] Sampling continuity is preserved
- [x] Wave 0 coverage references are now real artifacts, not placeholders
- [x] No watch-mode flags
- [x] Feedback latency < 60s
- [x] `nyquist_compliant: true` remains accurate

**Approval:** approved 2026-04-13
