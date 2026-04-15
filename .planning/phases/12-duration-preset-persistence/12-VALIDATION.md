---
phase: 12
slug: duration-preset-persistence
status: ready-for-verification
nyquist_compliant: true
wave_0_complete: true
created: 2026-04-15
---

# Phase 12 — Validation Strategy

> Canonical validation contract for the duration preset persistence foundation.

---

## Test Infrastructure

| Property | Value |
|----------|-------|
| **Framework** | XCTest on macOS |
| **Config file** | `Tools Cat.xcodeproj/project.pbxproj` |
| **Quick run command** | `xcodebuild test -project "Tools Cat.xcodeproj" -scheme "Tools Cat" -destination 'platform=macOS' -parallel-testing-enabled NO -only-testing:'Tools CatTests/KeepAwakeDurationRepositoryTests' -only-testing:'Tools CatTests/KeepAwakeDurationStoreTests' -only-testing:'Tools CatTests/KeepAwakeSessionModelTests' -only-testing:'Tools CatTests/StatusBarControllerKeepAwakeMenuTests'` |
| **Full suite command** | `xcodebuild test -project "Tools Cat.xcodeproj" -scheme "Tools Cat" -destination 'platform=macOS' -parallel-testing-enabled NO -only-testing:'Tools CatTests/KeepAwakeDurationRepositoryTests' -only-testing:'Tools CatTests/KeepAwakeDurationStoreTests' -only-testing:'Tools CatTests/KeepAwakeSessionModelTests' -only-testing:'Tools CatTests/StatusBarControllerKeepAwakeMenuTests'` |
| **Estimated runtime** | ~15-25 seconds for the targeted persistence plus keep-awake slice |

---

## Sampling Rate

- **After every task commit:** Run the narrowest matching duration/keep-awake slice for the touched task.
- **After every plan wave:** Re-run the full Phase 12 targeted slice above.
- **Before `$gsd-verify-work`:** The full Phase 12 targeted slice must be green.
- **Max feedback latency:** 25 seconds

---

## Per-Task Verification Map

| Task ID | Plan | Wave | Requirement | Test Type | Automated Command | File Exists | Status |
|---------|------|------|-------------|-----------|-------------------|-------------|--------|
| 12-01-01 | 01 | 1 | AWAKE-06, AWAKE-11 | repository | `xcodebuild test -project "Tools Cat.xcodeproj" -scheme "Tools Cat" -destination 'platform=macOS' -parallel-testing-enabled NO -only-testing:'Tools CatTests/KeepAwakeDurationRepositoryTests'` | ✅ | ⬜ pending |
| 12-01-02 | 01 | 1 | AWAKE-10, AWAKE-11 | store | `xcodebuild test -project "Tools Cat.xcodeproj" -scheme "Tools Cat" -destination 'platform=macOS' -parallel-testing-enabled NO -only-testing:'Tools CatTests/KeepAwakeDurationStoreTests'` | ✅ | ⬜ pending |
| 12-02-01 | 02 | 2 | AWAKE-11 | unit | `xcodebuild test -project "Tools Cat.xcodeproj" -scheme "Tools Cat" -destination 'platform=macOS' -parallel-testing-enabled NO -only-testing:'Tools CatTests/KeepAwakeSessionModelTests'` | ✅ | ⬜ pending |
| 12-02-02 | 02 | 2 | AWAKE-06, AWAKE-11 | controller | `xcodebuild test -project "Tools Cat.xcodeproj" -scheme "Tools Cat" -destination 'platform=macOS' -parallel-testing-enabled NO -only-testing:'Tools CatTests/StatusBarControllerKeepAwakeMenuTests'` | ✅ | ⬜ pending |

*Status: ⬜ pending · ✅ green · ❌ red · ⚠ manual-only boundary*

---

## Requirement Coverage

| Requirement | Truth Locked | Automated Evidence | Manual Boundary |
|-------------|--------------|--------------------|-----------------|
| AWAKE-06 | The managed timed-duration source of truth always starts from the seeded four defaults when storage is first initialized | `KeepAwakeDurationRepositoryTests.testFirstLoadSeedsDefaultDurationsExactlyOnce`, `KeepAwakeDurationStoreTests.testStoreSeedsDefaultDurationsExactlyOnce`, `StatusBarControllerKeepAwakeMenuTests.testSeededDurationStoreCanStartFixedTimedAction` | None required if the controller test proves the seeded transitional store can drive a fixed timed action |
| AWAKE-10 | Invalid and duplicate managed durations are rejected by canonical duration seconds before persistence | `KeepAwakeDurationRepositoryTests.testLoadNormalizesDuplicateDurationSeconds`, `KeepAwakeDurationStoreTests.testStoreRejectsDuplicateDurationSeconds`, `KeepAwakeDurationStoreTests.testStoreRejectsNonPositiveDurationSeconds` | None |
| AWAKE-11 | Managed durations persist across reload and still drive truthful timed keep-awake behavior in sorted order | `KeepAwakeDurationRepositoryTests.testReloadDoesNotReseedDeletedDefaults`, `KeepAwakeDurationStoreTests.testSuccessfulMutationsPersistAcrossReload`, `KeepAwakeSessionModelTests.testStartTimedSessionStoresManagedDurationAndEndDateAfterConfirmedEnable`, `StatusBarControllerKeepAwakeMenuTests.testKeepAwakeActionItemsDispatchThroughSharedSession` | Optional one-time relaunch smoke only if the new store initialization reveals a live startup regression not covered by XCTest |

---

## Wave 0 Requirements

- [x] `Tools CatTests/KeepAwakeSessionModelTests.swift` already exists and covers timed start, replacement, expiry, and failure semantics.
- [x] `Tools CatTests/StatusBarControllerKeepAwakeMenuTests.swift` already exists and covers keep-awake controller/menu state.
- [x] `Tools Cat.xcodeproj/project.pbxproj` already exposes the XCTest infrastructure needed for new repository/store test targets.
- [x] New Phase 12 test files `Tools CatTests/KeepAwakeDurationRepositoryTests.swift` and `Tools CatTests/KeepAwakeDurationStoreTests.swift` are part of the planned work and become the main persistence evidence.

Existing infrastructure covers the phase once the two new XCTest files are added.

---

## Manual-Only Verifications

All in-scope Phase 12 behaviors should be covered by XCTest. If a one-off relaunch smoke is run during execution, treat it as supporting evidence rather than a gating requirement.

---

## Validation Sign-Off

- [x] All tasks have automated verify commands
- [x] Sampling continuity: no three consecutive tasks without automated verify
- [x] Wave 0 covers all required test infrastructure
- [x] No watch-mode flags
- [x] Feedback latency < 60s
- [x] `nyquist_compliant: true` is justified by repository, store, session, and controller coverage without relying on manual-only proof

**Approval:** verification-ready
