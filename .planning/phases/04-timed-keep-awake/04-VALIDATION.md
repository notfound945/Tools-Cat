---
phase: 04
slug: timed-keep-awake
status: approved
nyquist_compliant: true
wave_0_complete: true
created: 2026-04-12
---

# Phase 04 — Validation Strategy

> Current validation contract for the shipped timed keep-awake menu and session behavior.

---

## Test Infrastructure

| Property | Value |
|----------|-------|
| **Framework** | XCTest plus one resolved live AppKit smoke |
| **Config file** | `Mac OS Swiss Knife.xcodeproj/project.pbxproj` |
| **Quick run command** | `xcodebuild test -project "Mac OS Swiss Knife.xcodeproj" -scheme "Mac OS Swiss Knife" -destination 'platform=macOS' -parallel-testing-enabled NO -only-testing:'Mac OS Swiss KnifeTests/KeepAwakeSessionModelTests' -only-testing:'Mac OS Swiss KnifeTests/KeepAwakeMenuStateTests' -only-testing:'Mac OS Swiss KnifeTests/StatusBarControllerKeepAwakeMenuTests'` |
| **Full suite command** | `xcodebuild test -project "Mac OS Swiss Knife.xcodeproj" -scheme "Mac OS Swiss Knife" -destination 'platform=macOS' -parallel-testing-enabled NO -only-testing:'Mac OS Swiss KnifeTests/KeepAwakeSessionModelTests' -only-testing:'Mac OS Swiss KnifeTests/KeepAwakeMenuStateTests' -only-testing:'Mac OS Swiss KnifeTests/StatusBarControllerKeepAwakeMenuTests'` |
| **Estimated runtime** | ~10-20 seconds for the targeted slice |

---

## Sampling Rate

- **After every task commit:** Run the narrowest matching keep-awake slice for the touched task.
- **After every plan wave:** Re-run the keep-awake session, presentation, and controller suites together.
- **Before `$gsd-verify-work`:** Keep-awake unit evidence must stay green and the resolved live menu smoke in `04-HUMAN-UAT.md` must remain approved.
- **Max feedback latency:** 20 seconds

---

## Per-Task Verification Map

| Task ID | Plan | Wave | Requirement | Test Type | Automated Command | File Exists | Status |
|---------|------|------|-------------|-----------|-------------------|-------------|--------|
| 04-01-01 | 01 | 1 | AWAKE-01 | unit | `xcodebuild test -project "Mac OS Swiss Knife.xcodeproj" -scheme "Mac OS Swiss Knife" -destination 'platform=macOS' -parallel-testing-enabled NO -only-testing:'Mac OS Swiss KnifeTests/KeepAwakeSessionModelTests/testStartTimedSessionStoresPresetAndEndDateAfterConfirmedEnable'` | ✅ | ✅ green |
| 04-01-02 | 01 | 1 | AWAKE-02 | unit | `xcodebuild test -project "Mac OS Swiss Knife.xcodeproj" -scheme "Mac OS Swiss Knife" -destination 'platform=macOS' -parallel-testing-enabled NO -only-testing:'Mac OS Swiss KnifeTests/KeepAwakeMenuStateTests/testTimedPresentationShowsCountdownInStatusRowOnly'` | ✅ | ✅ green |
| 04-02-01 | 02 | 2 | AWAKE-03 | unit | `xcodebuild test -project "Mac OS Swiss Knife.xcodeproj" -scheme "Mac OS Swiss Knife" -destination 'platform=macOS' -parallel-testing-enabled NO -only-testing:'Mac OS Swiss KnifeTests/KeepAwakeSessionModelTests'` | ✅ | ✅ green |
| 04-02-02 | 02 | 2 | AWAKE-04 | unit | `xcodebuild test -project "Mac OS Swiss Knife.xcodeproj" -scheme "Mac OS Swiss Knife" -destination 'platform=macOS' -parallel-testing-enabled NO -only-testing:'Mac OS Swiss KnifeTests/StatusBarControllerKeepAwakeMenuTests'` | ✅ | ✅ green |

*Status: ✅ green · ⚠ manual-only boundary*

---

## Wave 0 Requirements

- [x] `Mac OS Swiss KnifeTests/KeepAwakeSessionModelTests.swift` exists and covers timed start, timed replacement, expiry disable, disable-failure retention, and timer-cancel behavior.
- [x] `Mac OS Swiss KnifeTests/KeepAwakeMenuStateTests.swift` exists and covers preset row copy, active checkmarks, pending-expiry wording, and the countdown-only status-row presentation.
- [x] `Mac OS Swiss KnifeTests/StatusBarControllerKeepAwakeMenuTests.swift` exists and covers row order, dispatch, countdown confinement, and manual stop availability.
- [x] The only remaining live-only evidence boundary is the real AppKit menu smoke already resolved in `.planning/phases/04-timed-keep-awake/04-HUMAN-UAT.md`.

Existing infrastructure covers all Phase 4 validation references.

---

## Manual-Only Verifications

| Behavior | Requirement | Why Manual | Evidence |
|----------|-------------|------------|----------|
| Root menu keep-awake rows remain compact and scanable while a timed session is active | AWAKE-01, AWAKE-02, AWAKE-03 | XCTest proves ordering and countdown confinement, but real AppKit scanability still needs live interaction | Resolved in `.planning/phases/04-timed-keep-awake/04-HUMAN-UAT.md` on 2026-04-12 |
| Timed keep-awake expires cleanly back to the off presentation on the live menu surface | AWAKE-04 | Unit tests prove expiry logic, but native redraw timing is still best confirmed once on the live menu | Resolved in `.planning/phases/04-timed-keep-awake/04-HUMAN-UAT.md` on 2026-04-12 |

---

## Validation Sign-Off

- [x] All tasks have automated verify or resolved manual evidence
- [x] Sampling continuity is preserved
- [x] Wave 0 coverage references are now real artifacts, not placeholders
- [x] No watch-mode flags
- [x] Feedback latency < 60s
- [x] `nyquist_compliant: true` remains accurate

**Approval:** approved 2026-04-13
