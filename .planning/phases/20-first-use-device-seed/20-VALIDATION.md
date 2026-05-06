---
phase: 20
slug: first-use-device-seed
status: draft
nyquist_compliant: true
wave_0_complete: true
created: 2026-05-06
---

# Phase 20 — Validation Strategy

> Per-phase validation contract for feedback sampling during execution.

---

## Test Infrastructure

| Property | Value |
|----------|-------|
| **Framework** | XCTest + XCUITest via Xcode 26.2 |
| **Config file** | none — Xcode project targets drive test config |
| **Quick run command** | `xcodebuild test -project "Tools Cat.xcodeproj" -scheme "Tools Cat" -destination 'platform=macOS' -parallel-testing-enabled NO -only-testing:'Tools CatTests/SavedDeviceRepositoryTests' -only-testing:'Tools CatTests/SavedDeviceLibraryStoreTests'` |
| **Full suite command** | `xcodebuild test -project "Tools Cat.xcodeproj" -scheme "Tools Cat" -destination 'platform=macOS' -parallel-testing-enabled NO -only-testing:'Tools CatTests/SavedDeviceRepositoryTests' -only-testing:'Tools CatTests/SavedDeviceLibraryStoreTests' -only-testing:'Tools CatUITests/Tools_CatUITests/testLaunchWithFreshDeviceLibrarySeedsDefaultDevice' -only-testing:'Tools CatUITests/Tools_CatUITests/testLaunchWithExplicitlyEmptyDeviceLibraryShowsPolishedEmptyState' -only-testing:'Tools CatUITests/Tools_CatUITests/testLaunchWithSeededDeviceLibraryShowsManagementWindow'` |
| **Estimated runtime** | ~45-70 seconds |

---

## Sampling Rate

- **After every task commit:** Run the quick run command above
- **After every plan wave:** Run the full suite command above
- **Before `$gsd-verify-work`:** Full suite must be green
- **Max feedback latency:** 60 seconds

---

## Per-Task Verification Map

| Task ID | Plan | Wave | Requirement | Test Type | Automated Command | File Exists | Status |
|---------|------|------|-------------|-----------|-------------------|-------------|--------|
| 20-01-01 | 01 | 1 | DEVS-13, DEVS-14 | unit | `xcodebuild test -project "Tools Cat.xcodeproj" -scheme "Tools Cat" -destination 'platform=macOS' -parallel-testing-enabled NO -only-testing:'Tools CatTests/SavedDeviceRepositoryTests' -only-testing:'Tools CatTests/SavedDeviceLibraryStoreTests'` | ✅ | ⬜ pending |
| 20-01-02 | 01 | 1 | DEVS-13, DEVS-14 | ui | `xcodebuild test -project "Tools Cat.xcodeproj" -scheme "Tools Cat" -destination 'platform=macOS' -parallel-testing-enabled NO -only-testing:'Tools CatUITests/Tools_CatUITests/testLaunchWithFreshDeviceLibrarySeedsDefaultDevice' -only-testing:'Tools CatUITests/Tools_CatUITests/testLaunchWithExplicitlyEmptyDeviceLibraryShowsPolishedEmptyState' -only-testing:'Tools CatUITests/Tools_CatUITests/testLaunchWithSeededDeviceLibraryShowsManagementWindow'` | ✅ (existing file; new tests added in task) | ⬜ pending |

*Status: ⬜ pending · ✅ green · ❌ red · ⚠️ flaky*

---

## Wave 0 Requirements

Existing repository, store, and direct-launch UI infrastructure already cover this phase. No standalone Wave 0 bootstrap plan is required.

---

## Manual-Only Verifications

None required beyond automated coverage for this scope. The phase changes persistence initialization truth, not subjective interaction feel.

---

## Validation Sign-Off

- [ ] All tasks have `<automated>` verify or Wave 0 dependencies
- [ ] Sampling continuity: no 3 consecutive tasks without automated verify
- [x] Wave 0 covers all MISSING references
- [ ] No watch-mode flags
- [ ] Feedback latency < 60s
- [ ] `nyquist_compliant: true` set in frontmatter

**Approval:** 2026-05-06 planning self-approved after Phase 20 verification mapping review
