---
phase: 22
slug: wol-result-timeout
status: draft
nyquist_compliant: false
wave_0_complete: false
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
| 22-01-01 | 01 | 1 | WOLF-01, WOLF-02 | unit | `xcodebuild test -project "Tools Cat.xcodeproj" -scheme "Tools Cat" -destination 'platform=macOS' -parallel-testing-enabled NO -only-testing:'Tools CatTests/WOLSessionModelTests/testCompletedWakeResultClearsAfterThreeSeconds' -only-testing:'Tools CatTests/WOLSessionModelTests/testNewSendCancelsPreviousWakeResultClear' -only-testing:'Tools CatTests/WOLSessionModelTests/testHiddenWindowReceivesFinalResult'` | ✅ | ⬜ pending |
| 22-01-02 | 01 | 1 | WOLF-01, WOLF-02 | controller | `xcodebuild test -project "Tools Cat.xcodeproj" -scheme "Tools Cat" -destination 'platform=macOS' -parallel-testing-enabled NO -only-testing:'Tools CatTests/StatusBarControllerWakeMenuTests'` | ✅ | ⬜ pending |

*Status: ⬜ pending · ✅ green · ❌ red · ⚠️ flaky*

---

## Wave 0 Requirements

- [ ] `Tools CatTests/WOLSessionModelTests.swift` — stabilize the hidden-window regression path so the focused WOL session suite is green before relying on the timeout tests as the phase safety net.
- [ ] `Tools CatTests/StatusBarControllerWakeMenuTests.swift` — add coverage that the menu-bar wake status row hides after the shared timeout clear, not just that it shows completed wake text.

---

## Manual-Only Verifications

| Behavior | Requirement | Why Manual | Test Instructions |
|----------|-------------|------------|-------------------|
| WOL window status text and menu-bar wake status both feel transient but readable in real use | WOLF-01, WOLF-02 | Automated tests can prove timing state transitions, but not whether the 3-second confirmation feels natural in a live menu-bar workflow | Launch the app, send one successful wake and one failed wake, confirm both surfaces show the result briefly and both clear on their own without leaving stale text behind |

---

## Validation Sign-Off

- [ ] All tasks have `<automated>` verify or Wave 0 dependencies
- [ ] Sampling continuity: no 3 consecutive tasks without automated verify
- [ ] Wave 0 covers all MISSING references
- [ ] No watch-mode flags
- [ ] Feedback latency < 90s
- [ ] `nyquist_compliant: true` set in frontmatter

**Approval:** pending
