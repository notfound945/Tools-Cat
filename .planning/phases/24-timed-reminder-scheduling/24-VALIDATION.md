---
phase: 24
slug: timed-reminder-scheduling
status: draft
nyquist_compliant: false
wave_0_complete: false
created: 2026-05-09
---

# Phase 24 — Validation Strategy

> Per-phase validation contract for feedback sampling during execution.

---

## Test Infrastructure

| Property | Value |
|----------|-------|
| **Framework** | XCTest via Xcode 26.2 |
| **Config file** | none — Xcode project target configuration only |
| **Quick run command** | `xcodebuild test -project "Tools Cat.xcodeproj" -scheme "Tools Cat" -destination 'platform=macOS' -parallel-testing-enabled NO -only-testing:'Tools CatTests/KeepAwakeSessionModelTests' -only-testing:'Tools CatTests/StatusBarControllerKeepAwakeMenuTests'` |
| **Full suite command** | `xcodebuild test -project "Tools Cat.xcodeproj" -scheme "Tools Cat" -destination 'platform=macOS' -parallel-testing-enabled NO` |
| **Estimated runtime** | ~90 seconds |

---

## Sampling Rate

- **After every task commit:** Run `xcodebuild test -project "Tools Cat.xcodeproj" -scheme "Tools Cat" -destination 'platform=macOS' -parallel-testing-enabled NO -only-testing:'Tools CatTests/KeepAwakeSessionModelTests'`
- **After every plan wave:** Run `xcodebuild test -project "Tools Cat.xcodeproj" -scheme "Tools Cat" -destination 'platform=macOS' -parallel-testing-enabled NO -only-testing:'Tools CatTests/KeepAwakeSessionModelTests' -only-testing:'Tools CatTests/StatusBarControllerKeepAwakeMenuTests'`
- **Before `$gsd-verify-work`:** Full suite must be green
- **Max feedback latency:** 90 seconds

---

## Per-Task Verification Map

| Task ID | Plan | Wave | Requirement | Test Type | Automated Command | File Exists | Status |
|---------|------|------|-------------|-----------|-------------------|-------------|--------|
| 24-01-01 | 01 | 1 | NOTF-01 | unit | `xcodebuild test -project "Tools Cat.xcodeproj" -scheme "Tools Cat" -destination 'platform=macOS' -parallel-testing-enabled NO -only-testing:'Tools CatTests/AppDelegateNotificationTests'` | ❌ Wave 0 | ⬜ pending |
| 24-01-02 | 01 | 1 | NOTF-02, NOTF-04 | unit | `xcodebuild test -project "Tools Cat.xcodeproj" -scheme "Tools Cat" -destination 'platform=macOS' -parallel-testing-enabled NO -only-testing:'Tools CatTests/KeepAwakeSessionModelTests'` | ✅ | ⬜ pending |
| 24-01-03 | 01 | 1 | NOTF-04 | controller | `xcodebuild test -project "Tools Cat.xcodeproj" -scheme "Tools Cat" -destination 'platform=macOS' -parallel-testing-enabled NO -only-testing:'Tools CatTests/StatusBarControllerKeepAwakeMenuTests'` | ✅ | ⬜ pending |

*Status: ⬜ pending · ✅ green · ❌ red · ⚠️ flaky*

---

## Wave 0 Requirements

- [ ] `Tools CatTests/AppDelegateNotificationTests.swift` — verify launch-time authorization request goes through an injected reminder service and remains non-blocking
- [ ] Fake reminder scheduler test double in `Tools CatTests/KeepAwakeSessionModelTests.swift` — record requested authorization, scheduled identifiers, delays, cancellations, and restore behavior
- [ ] Existing `Tools CatTests/StatusBarControllerKeepAwakeMenuTests.swift` seam coverage extended only if reminder-unavailable presentation state becomes visible in the menu during this phase

---

## Manual-Only Verifications

| Behavior | Requirement | Why Manual | Test Instructions |
|----------|-------------|------------|-------------------|
| Launch-time macOS notification authorization prompt appears once on a clean permission state and does not block menu-bar startup | NOTF-01 | XCTest should use an injected fake and must not trigger real system permission UI | On a clean macOS notification permission state for `Tools Cat`, launch the app normally, confirm the menu bar item appears immediately, and confirm the system notification authorization prompt can be answered without freezing app startup |
| A real timed keep-awake session longer than `2 分钟` produces one pre-expiry reminder close to `endDate - 120s`, while a `<= 2 分钟` session does not immediately notify | NOTF-02 | Real local-notification delivery timing and banner behavior are OS-managed | Run one timed session longer than two minutes and one session two minutes or shorter, then confirm only the longer session produces the pre-expiry reminder |

---

## Validation Sign-Off

- [ ] All tasks have `<automated>` verify or Wave 0 dependencies
- [ ] Sampling continuity: no 3 consecutive tasks without automated verify
- [ ] Wave 0 covers all MISSING references
- [ ] No watch-mode flags
- [ ] Feedback latency < 90s
- [ ] `nyquist_compliant: true` set in frontmatter

**Approval:** pending
