---
phase: 14
slug: duration-management-ui-polish
status: ready-for-verification
nyquist_compliant: true
wave_0_complete: true
created: 2026-04-16
---

# Phase 14 — Validation Strategy

> Canonical validation contract for the duration-management UI polish pass.

---

## Test Infrastructure

| Property | Value |
|----------|-------|
| **Framework** | XCTest plus one direct-launch XCUITest smoke |
| **Config file** | `Tools Cat.xcodeproj/project.pbxproj` |
| **Quick run command** | `xcodebuild test -project "Tools Cat.xcodeproj" -scheme "Tools Cat" -destination 'platform=macOS' -parallel-testing-enabled NO -only-testing:'Tools CatTests/KeepAwakeDurationManagementSessionModelTests' -only-testing:'Tools CatUITests/Tools_CatUITests/testLaunchWithSeededKeepAwakeDurationsShowsManagementSurface'` |
| **Full suite command** | `xcodebuild test -project "Tools Cat.xcodeproj" -scheme "Tools Cat" -destination 'platform=macOS' -parallel-testing-enabled NO -only-testing:'Tools CatTests/KeepAwakeDurationManagementSessionModelTests' -only-testing:'Tools CatTests/StatusBarControllerKeepAwakeMenuTests' -only-testing:'Tools CatTests/StatusBarControllerMenuPolishTests' -only-testing:'Tools CatUITests/Tools_CatUITests/testLaunchWithSeededKeepAwakeDurationsShowsManagementSurface'` |
| **Estimated runtime** | ~20-30 seconds |

---

## Sampling Rate

- **After every task commit:** Run the quick command above
- **After every plan wave:** Run the full suite command above
- **Before `$gsd-verify-work`:** Full suite must be green
- **Max feedback latency:** 30 seconds

---

## Per-Task Verification Map

| Task ID | Plan | Wave | Requirement | Test Type | Automated Command | File Exists | Status |
|---------|------|------|-------------|-----------|-------------------|-------------|--------|
| 14-01-01 | 01 | 1 | AWAKE-14 | ui | `xcodebuild test -project "Tools Cat.xcodeproj" -scheme "Tools Cat" -destination 'platform=macOS' -parallel-testing-enabled NO -only-testing:'Tools CatUITests/Tools_CatUITests/testLaunchWithSeededKeepAwakeDurationsShowsManagementSurface'` | ✅ | ⬜ pending |
| 14-02-01 | 02 | 2 | AWAKE-15, AWAKE-16 | ui + regression | `xcodebuild test -project "Tools Cat.xcodeproj" -scheme "Tools Cat" -destination 'platform=macOS' -parallel-testing-enabled NO -only-testing:'Tools CatTests/KeepAwakeDurationManagementSessionModelTests' -only-testing:'Tools CatTests/StatusBarControllerKeepAwakeMenuTests' -only-testing:'Tools CatTests/StatusBarControllerMenuPolishTests' -only-testing:'Tools CatUITests/Tools_CatUITests/testLaunchWithSeededKeepAwakeDurationsShowsManagementSurface'` | ✅ | ⬜ pending |

Phase 14 intentionally uses the full regression slice for task `14-02-01` because `AWAKE-16` is explicitly about preserving already-shipped CRUD and root-menu truth while the view polish lands.

*Status: ⬜ pending · ✅ green · ❌ red · ⚠️ flaky*

---

## Wave 0 Requirements

- [x] `Tools CatUITests/Tools_CatUITests.swift` — direct-launch duration-manager smoke already exists
- [x] `Tools CatTests/KeepAwakeDurationManagementSessionModelTests.swift` — CRUD/session regression coverage already exists
- [x] `Tools CatTests/StatusBarControllerKeepAwakeMenuTests.swift` — keep-awake menu truth coverage already exists
- [x] `Tools CatTests/StatusBarControllerMenuPolishTests.swift` — menu placement and live refresh coverage already exists

Existing infrastructure covers all phase requirements.

---

## Manual-Only Verifications

All phase behaviors should remain provable through the focused manager smoke plus existing regression tests. No new manual-only boundary is required if the polished list/action semantics can be asserted structurally in automation.

---

## Validation Sign-Off

- [x] All tasks have automated verify commands
- [x] Sampling continuity is preserved
- [x] Wave 0 covers all required infrastructure
- [x] No watch-mode flags
- [x] Feedback latency < 60s
- [x] `nyquist_compliant: true` is justified by the existing duration-manager smoke plus session/menu regressions

**Approval:** verification-ready
