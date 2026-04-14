---
phase: 08
slug: validation-debt-closure
status: approved
nyquist_compliant: true
wave_0_complete: true
created: 2026-04-13
---

# Phase 08 — Validation Contract

> Canonical validation contract for closing stale validation debt across Phase 01-04.

---

## Test Infrastructure

| Property | Value |
|----------|-------|
| **Framework** | XCTest and targeted XCUITest via Xcode 26.2 |
| **Config file** | `Mac OS Swiss Knife.xcodeproj/project.pbxproj` |
| **Quick run command** | `xcodebuild test -project "Mac OS Swiss Knife.xcodeproj" -scheme "Mac OS Swiss Knife" -destination 'platform=macOS' -parallel-testing-enabled NO -only-testing:'Mac OS Swiss KnifeTests/MACAddressValidatorTests' -only-testing:'Mac OS Swiss KnifeTests/WOLSendPresentationTests' -only-testing:'Mac OS Swiss KnifeTests/WOLSessionModelTests' -only-testing:'Mac OS Swiss KnifeTests/KeepAwakeMenuStateTests' -only-testing:'Mac OS Swiss KnifeTests/SavedDeviceRepositoryTests' -only-testing:'Mac OS Swiss KnifeTests/DeviceLibrarySessionModelTests' -only-testing:'Mac OS Swiss KnifeTests/DeviceLibraryManagementPresentationTests' -only-testing:'Mac OS Swiss KnifeTests/SavedDeviceLibraryStoreTests' -only-testing:'Mac OS Swiss KnifeTests/StatusBarControllerWakeMenuTests' -only-testing:'Mac OS Swiss KnifeTests/KeepAwakeSessionModelTests' -only-testing:'Mac OS Swiss KnifeTests/StatusBarControllerKeepAwakeMenuTests'` |
| **Full suite command** | `bash scripts/run_menu_bar_verification_slice.sh` |
| **Estimated runtime** | ~30 seconds for the UI smoke slice, ~3 seconds for the targeted unit slice |

---

## Sampling Rate

- **After every task commit:** Run the targeted unit slice plus the Phase 7 direct-launch UI smoke slice
- **After every plan wave:** Re-run the same commands and then grep the touched validation docs for current truth markers
- **Before `$gsd-verify-work`:** Validation docs and commands must agree on current evidence
- **Max feedback latency:** 30 seconds

---

## Per-Task Verification Map

| Task ID | Plan | Wave | Requirement | Test Type | Automated Command | File Exists | Status |
|---------|------|------|-------------|-----------|-------------------|-------------|--------|
| 08-01-01 | 01 | 1 | VAL-01, VAL-02 | doc audit + unit/UI proof | `xcodebuild test -project "Mac OS Swiss Knife.xcodeproj" -scheme "Mac OS Swiss Knife" -destination 'platform=macOS' -parallel-testing-enabled NO -only-testing:'Mac OS Swiss KnifeTests/MACAddressValidatorTests' -only-testing:'Mac OS Swiss KnifeTests/WOLSendPresentationTests' -only-testing:'Mac OS Swiss KnifeTests/WOLSessionModelTests' -only-testing:'Mac OS Swiss KnifeTests/KeepAwakeMenuStateTests' -only-testing:'Mac OS Swiss KnifeTests/SavedDeviceRepositoryTests' -only-testing:'Mac OS Swiss KnifeTests/DeviceLibrarySessionModelTests' -only-testing:'Mac OS Swiss KnifeTests/DeviceLibraryManagementPresentationTests'` | ✅ | ✅ green |
| 08-02-01 | 02 | 2 | VAL-01, VAL-02, VAL-03 | doc audit + unit/UI proof | `xcodebuild test -project "Mac OS Swiss Knife.xcodeproj" -scheme "Mac OS Swiss Knife" -destination 'platform=macOS' -parallel-testing-enabled NO -only-testing:'Mac OS Swiss KnifeTests/SavedDeviceLibraryStoreTests' -only-testing:'Mac OS Swiss KnifeTests/StatusBarControllerWakeMenuTests' -only-testing:'Mac OS Swiss KnifeTests/KeepAwakeSessionModelTests' -only-testing:'Mac OS Swiss KnifeTests/StatusBarControllerKeepAwakeMenuTests' && xcodebuild test -project "Mac OS Swiss Knife.xcodeproj" -scheme "Mac OS Swiss Knife" -destination 'platform=macOS' -parallel-testing-enabled NO -only-testing:'Mac OS Swiss KnifeUITests/Mac_OS_Swiss_KnifeUITests/testLaunchWithSeededDeviceLibraryShowsManagementListSurface' -only-testing:'Mac OS Swiss KnifeUITests/Mac_OS_Swiss_KnifeUITests/testLaunchWithEmptyDeviceLibraryShowsPolishedEmptyState' -only-testing:'Mac OS Swiss KnifeUITests/Mac_OS_Swiss_KnifeUITests/testLaunchWithWOLWindowShowsPolishedSections'` | ✅ | ✅ green |

*Status: ⬜ pending · ✅ green · ❌ red · ⚠️ flaky*

---

## Wave 0 Requirements

- [x] Existing test and UAT artifacts already cover the validation-doc claims that were originally marked as missing.
- [x] No new harness, seam, or feature work is required in Phase 8.
- [x] Phase 8 only needs the validation contracts rewritten to match the current test and human-verification truth.

---

## Manual-Only Verifications

None. Phase 8 updates validation documents to reflect already-resolved HUMAN-UAT and live AppKit smoke evidence; it does not introduce new manual-only product behavior.

---

## Validation Sign-Off

- [x] All tasks have `<automated>` verify or explicit evidence sources
- [x] Sampling continuity: no 3 consecutive tasks without automated verify
- [x] Wave 0 covers all missing validation references
- [x] No watch-mode flags
- [x] Feedback latency < 30s
- [x] `nyquist_compliant: true` set in frontmatter

**Approval:** approved 2026-04-13
