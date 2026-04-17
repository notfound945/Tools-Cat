---
phase: 17
slug: signed-dmg-notarization-pipeline
status: superseded
nyquist_compliant: false
wave_0_complete: false
created: 2026-04-16
---

# Phase 17 — Validation Strategy

> Per-phase validation contract for feedback sampling during execution.

> Historical only: this validation plan was authored for the notarization path that was superseded on 2026-04-17 when v1.6 pivoted to non-notarized friend sharing. Pending boxes below are retained as execution history, not as current milestone work.

---

## Test Infrastructure

| Property | Value |
|----------|-------|
| **Framework** | shell verification scripts + targeted `xcodebuild` regression slice |
| **Config file** | none — bash helpers and XCTest targets already exist |
| **Quick run command** | `bash scripts/release/verify-release-readiness.sh && bash scripts/release/verify-release-notarization.sh && bash scripts/release/verify-release-docs.sh` |
| **Full suite command** | `bash scripts/release/verify-release-readiness.sh && bash scripts/release/verify-release-notarization.sh && bash scripts/release/verify-release-docs.sh && xcodebuild test -project "Tools Cat.xcodeproj" -scheme "Tools Cat" -destination 'platform=macOS' -parallel-testing-enabled NO -only-testing:'Tools CatTests/DeviceLibrarySessionModelTests' -only-testing:'Tools CatTests/DeviceLibraryManagementPresentationTests' -only-testing:'Tools CatUITests/Tools_CatUITests/testLaunchWithEmptyDeviceLibraryShowsPolishedEmptyState' -only-testing:'Tools CatUITests/Tools_CatUITests/testLaunchWithSeededDeviceLibraryShowsManagementWindow' -only-testing:'Tools CatUITests/Tools_CatUITests/testLaunchWithSeededDeviceLibraryShowsManagementListSurface'` |
| **Estimated runtime** | ~75 seconds |

---

## Sampling Rate

- **After every task commit:** Run `bash scripts/release/verify-release-readiness.sh && bash scripts/release/verify-release-notarization.sh && bash scripts/release/verify-release-docs.sh`
- **After every plan wave:** Run the full suite command
- **Before `$gsd-verify-work`:** Full suite must be green
- **Max feedback latency:** 75 seconds

---

## Per-Task Verification Map

| Task ID | Plan | Wave | Requirement | Test Type | Automated Command | File Exists | Status |
|---------|------|------|-------------|-----------|-------------------|-------------|--------|
| 17-01-01 | 01 | 1 | DIST-02 | shell | `bash scripts/release/verify-release-readiness.sh` | ✅ existing | ⬜ pending |
| 17-01-02 | 01 | 1 | DIST-02 | shell | `bash scripts/release/verify-release-readiness.sh` | ✅ existing | ⬜ pending |
| 17-02-01 | 02 | 2 | DIST-03 | shell | `bash scripts/release/verify-release-notarization.sh` | ❌ W0 | ⬜ pending |
| 17-02-02 | 02 | 2 | DIST-04 | shell + docs | `bash scripts/release/verify-release-notarization.sh && bash scripts/release/verify-release-docs.sh` | ❌ W0 | ⬜ pending |

*Status: ⬜ pending · ✅ green · ❌ red · ⚠️ flaky*

---

## Wave 0 Requirements

- [ ] `scripts/release/verify-release-notarization.sh` — static gate for notary submit, log capture, stapling, and assessment seam
- [ ] Existing Phase 15 direct-launch regression slice remains callable from the full suite command

---

## Manual-Only Verifications

| Behavior | Requirement | Why Manual | Test Instructions |
|----------|-------------|------------|-------------------|
| Real credentialed notarized release run | DIST-03, DIST-04 | The repo cannot submit to Apple without a real Developer ID certificate and valid Keychain notary profile on the executing machine | Export `RELEASE_TEAM_ID`, `RELEASE_SIGNING_IDENTITY`, and `RELEASE_NOTARY_PROFILE`; run `sh ./release.sh`; confirm the DMG is accepted, stapled, and assessed locally |
| Final artifact review | DIST-04 | Phase 17 should prove the DMG is the shipped artifact, but Phase 18 still owns repeatable clean-environment install proof | Confirm `dist/Tools-Cat.dmg` exists, `xcrun stapler validate dist/Tools-Cat.dmg` passes, and `spctl --assess --type open -v dist/Tools-Cat.dmg` succeeds |

---

## Validation Sign-Off

- [ ] All tasks have `<automated>` verify or Wave 0 dependencies
- [ ] Sampling continuity: no 3 consecutive tasks without automated verify
- [ ] Wave 0 covers all missing references
- [ ] No watch-mode flags
- [ ] Feedback latency < 75s
- [ ] `nyquist_compliant: true` set in frontmatter

**Approval:** pending
