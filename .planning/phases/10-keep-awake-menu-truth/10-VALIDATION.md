---
phase: 10
slug: keep-awake-menu-truth
status: draft
nyquist_compliant: true
wave_0_complete: true
created: 2026-04-14
---

# Phase 10 — Validation Strategy

> Canonical validation contract for the keep-awake idle-versus-active menu-truth fix.

---

## Test Infrastructure

| Property | Value |
|----------|-------|
| **Framework** | XCTest on macOS |
| **Config file** | `Tools Cat.xcodeproj/project.pbxproj` |
| **Quick run command** | `xcodebuild test -project "Tools Cat.xcodeproj" -scheme "Tools Cat" -destination 'platform=macOS' -parallel-testing-enabled NO -only-testing:'Tools CatTests/KeepAwakeMenuStateTests' -only-testing:'Tools CatTests/StatusBarControllerKeepAwakeMenuTests' -only-testing:'Tools CatTests/StatusBarControllerMenuPolishTests'` |
| **Full suite command** | `xcodebuild test -project "Tools Cat.xcodeproj" -scheme "Tools Cat" -destination 'platform=macOS' -parallel-testing-enabled NO -only-testing:'Tools CatTests/KeepAwakeMenuStateTests' -only-testing:'Tools CatTests/StatusBarControllerKeepAwakeMenuTests' -only-testing:'Tools CatTests/StatusBarControllerMenuPolishTests'` |
| **Estimated runtime** | ~10-20 seconds for the targeted keep-awake/menu slice |

---

## Sampling Rate

- **After every task commit:** Run the narrowest matching keep-awake/menu slice for the touched task.
- **After every plan wave:** Re-run the full Phase 10 targeted slice above.
- **Before `$gsd-verify-work`:** The full Phase 10 targeted slice must be green.
- **Max feedback latency:** 20 seconds

---

## Per-Task Verification Map

| Task ID | Plan | Wave | Requirement | Test Type | Automated Command | File Exists | Status |
|---------|------|------|-------------|-----------|-------------------|-------------|--------|
| 10-01-01 | 01 | 1 | MENU-01 | unit | `xcodebuild test -project "Tools Cat.xcodeproj" -scheme "Tools Cat" -destination 'platform=macOS' -parallel-testing-enabled NO -only-testing:'Tools CatTests/KeepAwakeMenuStateTests'` | ✅ | ⬜ pending |
| 10-01-02 | 01 | 1 | MENU-01, MENU-02 | controller | `xcodebuild test -project "Tools Cat.xcodeproj" -scheme "Tools Cat" -destination 'platform=macOS' -parallel-testing-enabled NO -only-testing:'Tools CatTests/StatusBarControllerKeepAwakeMenuTests'` | ✅ | ⬜ pending |
| 10-02-01 | 02 | 2 | MENU-02, MENU-03 | controller | `xcodebuild test -project "Tools Cat.xcodeproj" -scheme "Tools Cat" -destination 'platform=macOS' -parallel-testing-enabled NO -only-testing:'Tools CatTests/StatusBarControllerKeepAwakeMenuTests' -only-testing:'Tools CatTests/StatusBarControllerMenuPolishTests'` | ✅ | ⬜ pending |
| 10-02-02 | 02 | 2 | MENU-03 | docs + regression | `xcodebuild test -project "Tools Cat.xcodeproj" -scheme "Tools Cat" -destination 'platform=macOS' -parallel-testing-enabled NO -only-testing:'Tools CatTests/KeepAwakeMenuStateTests' -only-testing:'Tools CatTests/StatusBarControllerKeepAwakeMenuTests' -only-testing:'Tools CatTests/StatusBarControllerMenuPolishTests'` | ✅ | ⬜ pending |

*Status: ⬜ pending · ✅ green · ❌ red · ⚠ manual-only boundary*

---

## Wave 0 Requirements

- [x] `Tools CatTests/KeepAwakeMenuStateTests.swift` exists and already covers keep-awake presentation semantics.
- [x] `Tools CatTests/StatusBarControllerKeepAwakeMenuTests.swift` exists and already covers keep-awake controller/menu behavior.
- [x] `Tools CatTests/StatusBarControllerMenuPolishTests.swift` exists and already covers compact root-menu grouping and idle status-row collapse.
- [x] `Tools Cat.xcodeproj/project.pbxproj` already exposes the XCTest infrastructure needed for the targeted keep-awake/menu slice.

Existing infrastructure covers all Phase 10 validation references.

---

## Manual-Only Verifications

| Behavior | Requirement | Why Manual | Test Instructions |
|----------|-------------|------------|-------------------|
| Live tray menu visually omits `关闭常亮` while idle and still shows it while an active keep-awake session is running | MENU-01, MENU-02 | Controller tests prove state truth, but one real AppKit smoke confirms the hidden row behaves correctly in the live status-item menu | Launch the app, open the live menu while idle, confirm `关闭常亮` is absent; start `无限常亮` or a timed session, reopen the menu, confirm `关闭常亮` is present; click `关闭常亮`, reopen during the stop transition, confirm it remains visible but disabled until the session returns to off |

---

## Validation Sign-Off

- [x] All tasks have automated verify commands or one explicit manual-only boundary
- [x] Sampling continuity: no three consecutive tasks without automated verify
- [x] Wave 0 covers all required test infrastructure
- [x] No watch-mode flags
- [x] Feedback latency < 60s
- [x] `nyquist_compliant: true` is justified by the targeted Phase 10 slice plus one explicit live-menu smoke

**Approval:** pending
