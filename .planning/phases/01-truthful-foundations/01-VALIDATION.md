---
phase: 1
slug: truthful-foundations
status: approved
nyquist_compliant: true
wave_0_complete: true
created: 2026-04-11
---

# Phase 1 — Validation Strategy

> Current validation contract for the Phase 1 truthful WOL and keep-awake foundations.

---

## Test Infrastructure

| Property | Value |
|----------|-------|
| **Framework** | XCTest plus one resolved live AppKit smoke |
| **Config file** | `Mac OS Swiss Knife.xcodeproj/project.pbxproj` |
| **Quick run command** | `xcodebuild test -project "Mac OS Swiss Knife.xcodeproj" -scheme "Mac OS Swiss Knife" -destination 'platform=macOS' -parallel-testing-enabled NO -only-testing:'Mac OS Swiss KnifeTests/MACAddressValidatorTests' -only-testing:'Mac OS Swiss KnifeTests/WOLSendPresentationTests' -only-testing:'Mac OS Swiss KnifeTests/WOLSessionModelTests' -only-testing:'Mac OS Swiss KnifeTests/KeepAwakeMenuStateTests'` |
| **Full suite command** | `xcodebuild test -project "Mac OS Swiss Knife.xcodeproj" -scheme "Mac OS Swiss Knife" -destination 'platform=macOS' -only-testing:'Mac OS Swiss KnifeTests'` |
| **Estimated runtime** | ~2-5 seconds for the targeted slice |

---

## Sampling Rate

- **After every task commit:** Run the targeted Phase 1 slice above
- **After every plan wave:** Run the same slice or the full unit target when cross-task confidence matters
- **Before `$gsd-verify-work`:** Unit evidence must be green and the live keep-awake menu smoke must remain approved in `01-HUMAN-UAT.md`
- **Max feedback latency:** 5 seconds

---

## Per-Task Verification Map

| Task ID | Plan | Wave | Requirement | Test Type | Automated Command | File Exists | Status |
|---------|------|------|-------------|-----------|-------------------|-------------|--------|
| 1-01-01 | 01 | 1 | WOL-02, RELY-02, RELY-03, RELY-05 | unit harness | `xcodebuild test -project "Mac OS Swiss Knife.xcodeproj" -scheme "Mac OS Swiss Knife" -destination 'platform=macOS' -parallel-testing-enabled NO -only-testing:'Mac OS Swiss KnifeTests/MACAddressValidatorTests' -only-testing:'Mac OS Swiss KnifeTests/WOLSendPresentationTests' -only-testing:'Mac OS Swiss KnifeTests/WOLSessionModelTests' -only-testing:'Mac OS Swiss KnifeTests/KeepAwakeMenuStateTests'` | ✅ | ✅ green |
| 1-01-02 | 01 | 1 | WOL-02, RELY-02 | unit | `xcodebuild test -project "Mac OS Swiss Knife.xcodeproj" -scheme "Mac OS Swiss Knife" -destination 'platform=macOS' -parallel-testing-enabled NO -only-testing:'Mac OS Swiss KnifeTests/MACAddressValidatorTests'` | ✅ | ✅ green |
| 1-01-03 | 01 | 1 | RELY-03 | unit | `xcodebuild test -project "Mac OS Swiss Knife.xcodeproj" -scheme "Mac OS Swiss Knife" -destination 'platform=macOS' -parallel-testing-enabled NO -only-testing:'Mac OS Swiss KnifeTests/WOLSendPresentationTests'` | ✅ | ✅ green |
| 1-02-01 | 02 | 2 | WOL-02, RELY-02, RELY-03 | unit | `xcodebuild test -project "Mac OS Swiss Knife.xcodeproj" -scheme "Mac OS Swiss Knife" -destination 'platform=macOS' -parallel-testing-enabled NO -only-testing:'Mac OS Swiss KnifeTests/WOLSessionModelTests'` | ✅ | ✅ green |
| 1-02-02 | 02 | 2 | WOL-02, RELY-02, RELY-03 | unit | `xcodebuild test -project "Mac OS Swiss Knife.xcodeproj" -scheme "Mac OS Swiss Knife" -destination 'platform=macOS' -parallel-testing-enabled NO -only-testing:'Mac OS Swiss KnifeTests/WOLSessionModelTests'` | ✅ | ✅ green |
| 1-03-01 | 03 | 2 | RELY-05 | unit | `xcodebuild test -project "Mac OS Swiss Knife.xcodeproj" -scheme "Mac OS Swiss Knife" -destination 'platform=macOS' -parallel-testing-enabled NO -only-testing:'Mac OS Swiss KnifeTests/KeepAwakeMenuStateTests'` | ✅ | ✅ green |
| 1-03-02 | 03 | 2 | RELY-05 | unit + manual smoke | `xcodebuild test -project "Mac OS Swiss Knife.xcodeproj" -scheme "Mac OS Swiss Knife" -destination 'platform=macOS' -parallel-testing-enabled NO -only-testing:'Mac OS Swiss KnifeTests/KeepAwakeMenuStateTests'` | ✅ | ✅ green |

*Status: ✅ green · ⚠ manual-only boundary*

---

## Wave 0 Requirements

- [x] `Mac OS Swiss KnifeTests/MACAddressValidatorTests.swift` exists and covers the manual MAC validation contract
- [x] `Mac OS Swiss KnifeTests/WOLSessionModelTests.swift` exists and covers session-owned send gating and state transitions
- [x] `Mac OS Swiss KnifeTests/WOLSendPresentationTests.swift` exists and covers local-send feedback wording
- [x] `Mac OS Swiss KnifeTests/KeepAwakeMenuStateTests.swift` exists and covers confirmed/pending keep-awake presentation rules
- [x] The fakeable WOL and power-control seams required by these tests already exist in the shipped codebase

Existing infrastructure covers all Phase 1 validation references.

---

## Manual-Only Verifications

| Behavior | Requirement | Why Manual | Evidence |
|----------|-------------|------------|----------|
| Keep-awake menu item shows transitional copy while toggling and returns to the last confirmed state on failure | RELY-05 | XCTest proves the controller and presentation logic, but the real menu-bar surface timing still needs live AppKit confirmation | Resolved in `.planning/phases/01-truthful-foundations/01-HUMAN-UAT.md` on 2026-04-11 |

---

## Validation Sign-Off

- [x] All tasks have automated verify or resolved manual evidence
- [x] Sampling continuity is preserved
- [x] Wave 0 coverage references are now real artifacts, not placeholders
- [x] No watch-mode flags
- [x] Feedback latency < 60s
- [x] `nyquist_compliant: true` remains accurate

**Approval:** approved 2026-04-13
