---
phase: 25
slug: expiry-reminder-truth
status: draft
nyquist_compliant: false
wave_0_complete: false
created: 2026-05-10
---

# Phase 25 — Validation Strategy

> Per-phase validation contract for feedback sampling during execution.

---

## Test Infrastructure

| Property | Value |
|----------|-------|
| **Framework** | XCTest via Xcode 26.2 |
| **Config file** | none — Xcode project target configuration only |
| **Quick run command** | `xcodebuild test -project "Tools Cat.xcodeproj" -scheme "Tools Cat" -destination 'platform=macOS' -parallel-testing-enabled NO -only-testing:'Tools CatTests/AppDelegateNotificationTests' -only-testing:'Tools CatTests/KeepAwakeSessionModelTests' -only-testing:'Tools CatTests/StatusBarControllerKeepAwakeMenuTests'` |
| **Full suite command** | `xcodebuild test -project "Tools Cat.xcodeproj" -scheme "Tools Cat" -destination 'platform=macOS'` |
| **Estimated runtime** | ~120 seconds |

---

## Sampling Rate

- **After every task commit:** Run `xcodebuild test -project "Tools Cat.xcodeproj" -scheme "Tools Cat" -destination 'platform=macOS' -parallel-testing-enabled NO -only-testing:'Tools CatTests/KeepAwakeSessionModelTests' -only-testing:'Tools CatTests/StatusBarControllerKeepAwakeMenuTests'`
- **After every plan wave:** Run `xcodebuild test -project "Tools Cat.xcodeproj" -scheme "Tools Cat" -destination 'platform=macOS' -parallel-testing-enabled NO -only-testing:'Tools CatTests/AppDelegateNotificationTests' -only-testing:'Tools CatTests/KeepAwakeSessionModelTests' -only-testing:'Tools CatTests/StatusBarControllerKeepAwakeMenuTests'`
- **Before `$gsd-verify-work`:** Full suite must be green
- **Max feedback latency:** 120 seconds

---

## Per-Task Verification Map

| Task ID | Plan | Wave | Requirement | Test Type | Automated Command | File Exists | Status |
|---------|------|------|-------------|-----------|-------------------|-------------|--------|
| 25-01-01 | 01 | 1 | NOTF-03 | unit | `xcodebuild test -project "Tools Cat.xcodeproj" -scheme "Tools Cat" -destination 'platform=macOS' -parallel-testing-enabled NO -only-testing:'Tools CatTests/KeepAwakeSessionModelTests'` | ✅ | ⬜ pending |
| 25-01-02 | 01 | 1 | NOTF-05 | controller | `xcodebuild test -project "Tools Cat.xcodeproj" -scheme "Tools Cat" -destination 'platform=macOS' -parallel-testing-enabled NO -only-testing:'Tools CatTests/StatusBarControllerKeepAwakeMenuTests'` | ✅ | ⬜ pending |
| 25-01-03 | 01 | 1 | NOTF-03, NOTF-05 | unit | `xcodebuild test -project "Tools Cat.xcodeproj" -scheme "Tools Cat" -destination 'platform=macOS' -parallel-testing-enabled NO -only-testing:'Tools CatTests/AppDelegateNotificationTests'` | ✅ | ⬜ pending |

*Status: ⬜ pending · ✅ green · ❌ red · ⚠️ flaky*

---

## Wave 0 Requirements

- None — existing XCTest infrastructure, fake power/reminder schedulers, and controller seams already exist. Phase 25 should extend `Tools CatTests/AppDelegateNotificationTests.swift`, `Tools CatTests/KeepAwakeSessionModelTests.swift`, and `Tools CatTests/StatusBarControllerKeepAwakeMenuTests.swift` rather than creating new targets or helper frameworks.

---

## Manual-Only Verifications

| Behavior | Requirement | Why Manual | Test Instructions |
|----------|-------------|------------|-------------------|
| A real timed keep-awake session that expires while notifications are allowed produces one truthful end reminder after the session actually turns off | NOTF-03 | Notification Center delivery timing and foreground/background presentation remain OS-managed boundaries | Start a timed keep-awake session, wait for expiry, confirm the menu returns to off, and confirm one end reminder arrives only after shutdown |
| A timed keep-awake session still runs and ends correctly while notifications are denied, and the keep-awake status area shows countdown truth plus reminder-unavailable truth together | NOTF-05 | Real macOS notification denial state and menu rendering inside the live status item are not fully covered by XCTest | Deny notifications for `Tools Cat`, start both a `> 2 分钟` and a `<= 2 分钟` timed session, confirm the countdown still runs and confirm the existing keep-awake status area shows the unavailable reminder state without blocking expiry |
| If foreground presentation is implemented, the end reminder visibly presents while the app is active/frontmost | NOTF-03 | Foreground notification presentation behavior depends on live `UNUserNotificationCenterDelegate` and OS UI policy | Launch the app, keep it frontmost near expiry, and verify the end reminder still presents with the expected Apple-native notification surface |

---

## Validation Sign-Off

- [ ] All tasks have `<automated>` verify or Wave 0 dependencies
- [ ] Sampling continuity: no 3 consecutive tasks without automated verify
- [ ] Wave 0 covers all MISSING references
- [ ] No watch-mode flags
- [ ] Feedback latency < 120s
- [ ] `nyquist_compliant: true` set in frontmatter

**Approval:** pending
