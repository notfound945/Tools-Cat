---
phase: 22
slug: wol-result-timeout
status: complete
nyquist_compliant: true
wave_0_complete: true
created: 2026-05-06
---

# Phase 22 — Validation Strategy

> Per-phase validation contract for feedback sampling during execution.

---

## Test Infrastructure

| Property | Value |
|----------|-------|
| **Framework** | XCTest + XCUITest via Xcode 26.2 |
| **Config file** | none — Xcode project targets drive test config |
| **Quick run command** | `xcodebuild test -project "Tools Cat.xcodeproj" -scheme "Tools Cat" -destination 'platform=macOS' -parallel-testing-enabled NO -only-testing:'Tools CatTests/WOLSessionModelTests' -only-testing:'Tools CatTests/StatusBarControllerWakeMenuTests'` |
| **Full suite command** | `xcodebuild test -project "Tools Cat.xcodeproj" -scheme "Tools Cat" -destination 'platform=macOS' -parallel-testing-enabled NO` |
| **Estimated runtime** | ~90 seconds |

---

## Sampling Rate

- **After every task commit:** Run the quick run command above
- **After every plan wave:** Run the full suite command above
- **Before `$gsd-verify-work`:** Full suite must be green
- **Max feedback latency:** 90 seconds

---

## Per-Task Verification Map

| Task ID | Plan | Wave | Requirement | Test Type | Automated Command | File Exists | Status |
|---------|------|------|-------------|-----------|-------------------|-------------|--------|
| 22-01-01 | 01 | 1 | WOLF-01, WOLF-02 | unit | `xcodebuild test -project "Tools Cat.xcodeproj" -scheme "Tools Cat" -destination 'platform=macOS' -parallel-testing-enabled NO -only-testing:'Tools CatTests/WOLSessionModelTests/testCompletedWakeResultClearsAfterThreeSeconds' -only-testing:'Tools CatTests/WOLSessionModelTests/testNewSendCancelsPreviousWakeResultClear' -only-testing:'Tools CatTests/WOLSessionModelTests/testHiddenWindowReceivesFinalResult'` | ✅ | ✅ green |
| 22-01-02 | 01 | 1 | WOLF-01, WOLF-02 | controller | `xcodebuild test -project "Tools Cat.xcodeproj" -scheme "Tools Cat" -destination 'platform=macOS' -parallel-testing-enabled NO -only-testing:'Tools CatTests/StatusBarControllerWakeMenuTests'` | ✅ | ✅ green |

*Status: ⬜ pending · ✅ green · ❌ red · ⚠️ flaky*

---

## Wave 0 Requirements

Existing WOL session and wake-menu controller coverage now close the former Wave 0 needs. No standalone bootstrap plan is required.

---

## Manual-Only Verifications

| Behavior | Requirement | Why Manual | Test Instructions |
|----------|-------------|------------|-------------------|
| WOL window status text and menu-bar wake status both feel transient but readable in real use | WOLF-01, WOLF-02 | Automated tests can prove timing state transitions, but not whether the 3-second confirmation feels natural in a live menu-bar workflow | Completed 2026-05-07: confirmed both surfaces show the result briefly and both clear on their own without leaving stale text behind |

---

## Validation Sign-Off

- [x] All tasks have `<automated>` verify or Wave 0 dependencies
- [x] Sampling continuity: no 3 consecutive tasks without automated verify
- [x] Wave 0 covers all MISSING references
- [x] No watch-mode flags
- [x] Feedback latency < 90s
- [x] `nyquist_compliant: true` set in frontmatter

**Approval:** 2026-05-07 validated after focused regression passes and completed live dwell confirmation
