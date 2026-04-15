---
phase: 13
slug: duration-management-surface
status: ready-for-verification
nyquist_compliant: true
wave_0_complete: true
created: 2026-04-15
---

# Phase 13 — Validation Strategy

> Canonical validation contract for the native keep-awake duration management surface.

---

## Test Infrastructure

| Property | Value |
|----------|-------|
| **Framework** | XCTest plus one direct-launch XCUITest smoke |
| **Config file** | `Tools Cat.xcodeproj/project.pbxproj` |
| **Quick run command** | `xcodebuild test -project "Tools Cat.xcodeproj" -scheme "Tools Cat" -destination 'platform=macOS' -parallel-testing-enabled NO -only-testing:'Tools CatTests/KeepAwakeDurationManagementSessionModelTests' -only-testing:'Tools CatTests/StatusBarControllerEntryFlowTests'` |
| **Full suite command** | `xcodebuild test -project "Tools Cat.xcodeproj" -scheme "Tools Cat" -destination 'platform=macOS' -parallel-testing-enabled NO -only-testing:'Tools CatTests/KeepAwakeDurationManagementSessionModelTests' -only-testing:'Tools CatTests/StatusBarControllerEntryFlowTests' -only-testing:'Tools CatUITests/Tools_CatUITests/testLaunchWithSeededKeepAwakeDurationsShowsManagementSurface'` |
| **Estimated runtime** | ~20-45 seconds depending on incremental UI-test startup |

---

## Sampling Rate

- **After every task commit:** Run the narrowest matching slice for the touched task.
- **After every plan wave:** Re-run the full Phase 13 slice above.
- **Before `$gsd-verify-work 13`:** The full Phase 13 slice must be green.
- **Max feedback latency:** 45 seconds

---

## Per-Task Verification Map

| Task ID | Plan | Wave | Requirement | Test Type | Automated Command | File Exists | Status |
|---------|------|------|-------------|-----------|-------------------|-------------|--------|
| 13-01-01 | 01 | 1 | AWAKE-07, AWAKE-08, AWAKE-09 | session | `xcodebuild test -project "Tools Cat.xcodeproj" -scheme "Tools Cat" -destination 'platform=macOS' -parallel-testing-enabled NO -only-testing:'Tools CatTests/KeepAwakeDurationManagementSessionModelTests'` | ✅ | ⬜ pending |
| 13-02-01 | 02 | 2 | AWAKE-06 | ui | `xcodebuild test -project "Tools Cat.xcodeproj" -scheme "Tools Cat" -destination 'platform=macOS' -parallel-testing-enabled NO -only-testing:'Tools CatUITests/Tools_CatUITests/testLaunchWithSeededKeepAwakeDurationsShowsManagementSurface'` | ✅ | ⬜ pending |
| 13-02-02 | 02 | 2 | AWAKE-06 | controller | `xcodebuild test -project "Tools Cat.xcodeproj" -scheme "Tools Cat" -destination 'platform=macOS' -parallel-testing-enabled NO -only-testing:'Tools CatTests/StatusBarControllerEntryFlowTests'` | ✅ | ⬜ pending |

*Status: ⬜ pending · ✅ green · ❌ red · ⚠ manual-only boundary*

---

## Requirement Coverage

| Requirement | Truth Locked | Automated Evidence | Manual Boundary |
|-------------|--------------|--------------------|-----------------|
| AWAKE-06 | User can open a native duration-management surface that shows the current seeded or persisted timed durations | `Tools_CatUITests.testLaunchWithSeededKeepAwakeDurationsShowsManagementSurface`, `StatusBarControllerEntryFlowTests.testKeepAwakeDurationManagementEntryDispatchesThroughCallback` | None |
| AWAKE-07 | User can add a custom managed duration and see the sorted list update | `KeepAwakeDurationManagementSessionModelTests.testAddDurationPersistsAndSortsBySeconds` | None |
| AWAKE-08 | User can edit an existing managed duration and preserve identity while the sorted list updates | `KeepAwakeDurationManagementSessionModelTests.testEditDurationPreservesIdentityAndResorts` | None |
| AWAKE-09 | User can delete a managed duration while `无限常亮` remains outside the managed list | `KeepAwakeDurationManagementSessionModelTests.testDeleteRequiresConfirmationAndPersists`, direct manager UI smoke proving only timed rows render in the surface | None |

---

## Wave 0 Requirements

- [x] `Tools Cat/KeepAwakeDurationStore.swift` already exists and is the only timed-duration mutation seam.
- [x] `Tools CatTests/StatusBarControllerEntryFlowTests.swift` already exists and covers callback-based menu entry dispatch.
- [x] `Tools CatUITests/Tools_CatUITests.swift` already provides direct-launch helpers and isolated defaults suites.
- [x] `Tools Cat.xcodeproj/project.pbxproj` already contains the XCTest and XCUITest infrastructure needed for new files.

Existing infrastructure covers the phase once the new management session, view/window, and tests are added.

---

## Manual-Only Verifications

All in-scope Phase 13 behaviors should be provable through the targeted unit and UI tests above. No manual-only boundary is required unless UI automation reveals a focus/activation issue specific to one local machine.

---

## Validation Sign-Off

- [x] All tasks have automated verify commands
- [x] Sampling continuity is preserved
- [x] Wave 0 covers required infrastructure
- [x] No watch-mode flags
- [x] Feedback latency < 60s
- [x] `nyquist_compliant: true` is justified by session, controller, and direct-launch UI coverage without needing live tray automation

**Approval:** verification-ready
