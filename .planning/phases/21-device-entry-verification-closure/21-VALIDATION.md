---
phase: 21
slug: device-entry-verification-closure
status: draft
nyquist_compliant: true
wave_0_complete: true
created: 2026-05-06
---

# Phase 21 — Validation Strategy

> Per-phase validation contract for feedback sampling during execution.

---

## Test Infrastructure

| Property | Value |
|----------|-------|
| **Framework** | File-truth verification via markdown artifacts plus focused `xcodebuild` regression reruns |
| **Config file** | none — planning files and Xcode targets are the verification inputs |
| **Quick run command** | `test -f .planning/phases/19-deferred-device-form-validation/19-VERIFICATION.md && test -f .planning/phases/20-first-use-device-seed/20-VERIFICATION.md && rg -n "status: passed|DEVS-10|DEVS-11|DEVS-12" .planning/phases/19-deferred-device-form-validation/19-VERIFICATION.md && rg -n "status: passed|DEVS-13|DEVS-14" .planning/phases/20-first-use-device-seed/20-VERIFICATION.md` |
| **Full suite command** | `xcodebuild test -project "Tools Cat.xcodeproj" -scheme "Tools Cat" -destination 'platform=macOS' -parallel-testing-enabled NO -only-testing:'Tools CatTests/DeviceLibrarySessionModelTests' -only-testing:'Tools CatUITests/Tools_CatUITests/testLaunchWithSeededDeviceLibraryShowsManagementWindow' -only-testing:'Tools CatUITests/Tools_CatUITests/testDeviceLibraryNameValidationRevealsAfterBlurOrSubmit' -only-testing:'Tools CatUITests/Tools_CatUITests/testDeviceLibraryMACValidationRevealsAfterBlurOrSubmit' -only-testing:'Tools CatTests/SavedDeviceRepositoryTests' -only-testing:'Tools CatTests/SavedDeviceLibraryStoreTests' -only-testing:'Tools CatUITests/Tools_CatUITests/testLaunchWithFreshDeviceLibrarySeedsDefaultDevice' -only-testing:'Tools CatUITests/Tools_CatUITests/testLaunchWithExplicitlyEmptyDeviceLibraryShowsPolishedEmptyState' -only-testing:'Tools CatUITests/Tools_CatUITests/testLaunchWithSeededDeviceLibraryShowsManagementWindow'` |
| **Audit refresh command** | `codex exec -C /Users/hailinpan/Documents/GitHub/Tools-Cat -s workspace-write -a never '$gsd-audit-milestone v1.7'` |
| **Estimated runtime** | ~60-120 seconds |

---

## Sampling Rate

- **After every task commit:** Run the quick run command above
- **After every plan wave:** Run the full suite command above plus the audit refresh command
- **Before `$gsd-complete-milestone v1.7`:** The refreshed milestone audit must be green
- **Max feedback latency:** 120 seconds

---

## Per-Task Verification Map

| Task ID | Plan | Wave | Requirement | Test Type | Automated Command | File Exists | Status |
|---------|------|------|-------------|-----------|-------------------|-------------|--------|
| 21-01-01 | 01 | 1 | DEVS-10, DEVS-11, DEVS-12 | docs + focused regression | `test -f .planning/phases/19-deferred-device-form-validation/19-VERIFICATION.md && rg -n "status: passed|DEVS-10|DEVS-11|DEVS-12|DeviceLibrarySessionModelTests|testDeviceLibraryNameValidationRevealsAfterBlurOrSubmit|testDeviceLibraryMACValidationRevealsAfterBlurOrSubmit" .planning/phases/19-deferred-device-form-validation/19-VERIFICATION.md && xcodebuild test -project "Tools Cat.xcodeproj" -scheme "Tools Cat" -destination 'platform=macOS' -parallel-testing-enabled NO -only-testing:'Tools CatTests/DeviceLibrarySessionModelTests' -only-testing:'Tools CatUITests/Tools_CatUITests/testLaunchWithSeededDeviceLibraryShowsManagementWindow' -only-testing:'Tools CatUITests/Tools_CatUITests/testDeviceLibraryNameValidationRevealsAfterBlurOrSubmit' -only-testing:'Tools CatUITests/Tools_CatUITests/testDeviceLibraryMACValidationRevealsAfterBlurOrSubmit'` | ✅ | ⬜ pending |
| 21-01-02 | 01 | 1 | DEVS-13, DEVS-14 | docs + focused regression | `test -f .planning/phases/20-first-use-device-seed/20-VERIFICATION.md && rg -n "status: passed|DEVS-13|DEVS-14|SavedDeviceRepositoryTests|SavedDeviceLibraryStoreTests|testLaunchWithFreshDeviceLibrarySeedsDefaultDevice|testLaunchWithExplicitlyEmptyDeviceLibraryShowsPolishedEmptyState" .planning/phases/20-first-use-device-seed/20-VERIFICATION.md && xcodebuild test -project "Tools Cat.xcodeproj" -scheme "Tools Cat" -destination 'platform=macOS' -parallel-testing-enabled NO -only-testing:'Tools CatTests/SavedDeviceRepositoryTests' -only-testing:'Tools CatTests/SavedDeviceLibraryStoreTests' -only-testing:'Tools CatUITests/Tools_CatUITests/testLaunchWithFreshDeviceLibrarySeedsDefaultDevice' -only-testing:'Tools CatUITests/Tools_CatUITests/testLaunchWithExplicitlyEmptyDeviceLibraryShowsPolishedEmptyState' -only-testing:'Tools CatUITests/Tools_CatUITests/testLaunchWithSeededDeviceLibraryShowsManagementWindow'` | ✅ | ⬜ pending |
| 21-01-03 | 01 | 1 | DEVS-10, DEVS-11, DEVS-12, DEVS-13, DEVS-14 | audit | `rg -n "^- \\[x\\] \\*\\*DEVS-10\\*\\*|^- \\[x\\] \\*\\*DEVS-11\\*\\*|^- \\[x\\] \\*\\*DEVS-12\\*\\*|^- \\[x\\] \\*\\*DEVS-13\\*\\*|^- \\[x\\] \\*\\*DEVS-14\\*\\*" .planning/REQUIREMENTS.md && rg -n "\\| DEVS-10 \\| Phase 19 \\| Complete \\||\\| DEVS-11 \\| Phase 19 \\| Complete \\||\\| DEVS-12 \\| Phase 19 \\| Complete \\||\\| DEVS-13 \\| Phase 20 \\| Complete \\||\\| DEVS-14 \\| Phase 20 \\| Complete \\|" .planning/REQUIREMENTS.md && codex exec -C /Users/hailinpan/Documents/GitHub/Tools-Cat -s workspace-write -a never '$gsd-audit-milestone v1.7' && rg -n "status: passed|requirements: 5/5|phases: 2/2|19-VERIFICATION.md|20-VERIFICATION.md" .planning/v1.7-MILESTONE-AUDIT.md && ! rg -n "orphaned|unsatisfied|missing verification artifacts" .planning/v1.7-MILESTONE-AUDIT.md` | ✅ | ⬜ pending |

*Status: ⬜ pending · ✅ green · ❌ red · ⚠️ flaky*

---

## Wave 0 Requirements

Phase 21 reuses shipped code and existing focused regression commands. No bootstrap harness work is required before execution.

---

## Manual-Only Verifications

None required for this gap-closure scope. The remaining issue is formal evidence closure, not subjective runtime behavior.

---

## Validation Sign-Off

- [ ] All tasks have `<automated>` verify or Wave 0 dependencies
- [ ] Sampling continuity: no 3 consecutive tasks without automated verify
- [x] Wave 0 covers all MISSING references
- [ ] No watch-mode flags
- [ ] Feedback latency < 120s
- [ ] `nyquist_compliant: true` set in frontmatter

**Approval:** 2026-05-06 planning self-approved for gap-closure verification mapping
