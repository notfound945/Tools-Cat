---
phase: 17-signed-dmg-notarization-pipeline
verified: 2026-04-16T10:25:23Z
status: human_needed
score: 3/3 must-haves verified
---

# Phase 17: Signed DMG Notarization Pipeline Verification Report

**Phase Goal:** The release flow produces the final signed `Tools-Cat.dmg`, notarizes it with `notarytool`, staples the result, and fails clearly on any notarization rejection.
**Verified:** 2026-04-16T10:25:23Z
**Status:** human_needed
**Re-verification:** No - automated checks passed on the first verification pass, but the real Apple notarization run is still pending because this machine has no `RELEASE_*` credentials loaded.

## Goal Achievement

### Observable Truths

| # | Truth | Status | Evidence |
| --- | --- | --- | --- |
| 1 | `release.sh` now drives the full outer release artifact chain from signed app export through signed DMG, notarization submission, stapling, and local assessment. | ✓ VERIFIED | [`release.sh`](../../../release.sh) now packages `dist/export/Tools Cat.app` into `dist/Tools-Cat.dmg`, signs it, calls [`scripts/release/notarize-dmg.sh`](../../../scripts/release/notarize-dmg.sh), runs `xcrun stapler staple`, and calls [`scripts/release/assess-notarized-dmg.sh`](../../../scripts/release/assess-notarized-dmg.sh). |
| 2 | The repo has deterministic notarization evidence paths and actionable rejection handling instead of a blind `notarytool --wait` step. | ✓ VERIFIED | [`scripts/release/notarize-dmg.sh`](../../../scripts/release/notarize-dmg.sh) writes `build/notary/Tools-Cat-notary-submit.plist`, extracts `id` and `status` with `plutil`, and fetches `build/notary/Tools-Cat-notary-log.json` with `xcrun notarytool log` when the status is not `Accepted`. |
| 3 | Maintainer docs now describe the notarized DMG contract truthfully and keep only the explicit Phase 18 verification boundary open. | ✓ VERIFIED | [`README.md`](../../../README.md) now points the release story at `dist/Tools-Cat.dmg` and the `build/notary/` metadata outputs, [`docs/release/signing-readiness.md`](../../../docs/release/signing-readiness.md) documents the full sign/notarize/staple/assess flow, and [`scripts/release/verify-release-docs.sh`](../../../scripts/release/verify-release-docs.sh) passed while rejecting stale `Phase 17+`, `未公证`, `隐私与安全`, and `右键-打开` guidance. |

**Score:** 3/3 truths verified

### Required Artifacts

| Artifact | Expected | Status | Details |
| --- | --- | --- | --- |
| `17-01-SUMMARY.md` | Signed DMG seam completion summary | ✓ VERIFIED | Exists and records the signed DMG packaging boundary that Wave 2 builds on. |
| `17-02-SUMMARY.md` | Notarization/docs completion summary | ✓ VERIFIED | Exists and records the new helpers, docs contract, and pending credentialed verification boundary. |
| `release.sh` | Canonical release orchestration through notarization and local assessment | ✓ VERIFIED | Exists and contains the expected DMG build, sign, notarize, staple, and assess flow. |
| `scripts/release/notarize-dmg.sh` | Deterministic notary submit/wait/log helper | ✓ VERIFIED | Exists and contains `xcrun notarytool submit`, `plutil -extract id`, `plutil -extract status`, and `xcrun notarytool log`. |
| `scripts/release/assess-notarized-dmg.sh` | Post-staple local assessment helper | ✓ VERIFIED | Exists and runs both `xcrun stapler validate` and `spctl --assess --type open -v`. |
| `scripts/release/verify-release-notarization.sh` | Static notarization seam gate | ✓ VERIFIED | Passed during verification. |
| `README.md` | Short maintainer release entrypoint for the notarized DMG flow | ✓ VERIFIED | Exists and now names `dist/Tools-Cat.dmg`, `RELEASE_NOTARY_PROFILE`, and the dedicated release doc. |
| `docs/release/signing-readiness.md` | Detailed signed-DMG release runbook | ✓ VERIFIED | Exists and documents the final artifact, metadata paths, stapling, assessment, and Phase 18 boundary. |
| `scripts/release/verify-release-docs.sh` | Docs drift gate for the notarized DMG contract | ✓ VERIFIED | Passed during verification. |

### Requirements Coverage

| Requirement | Source Plan | Description | Status | Evidence |
| --- | --- | --- | --- | --- |
| `DIST-02` | `17-01-PLAN.md` | Maintainer can produce a Developer ID signed `Tools-Cat.dmg` that contains the distributable app bundle | ✓ SATISFIED | [`release.sh`](../../../release.sh), [`build_dmg.sh`](../../../build_dmg.sh), [`scripts/release/inspect-dmg-signature.sh`](../../../scripts/release/inspect-dmg-signature.sh), and passing [`scripts/release/verify-release-readiness.sh`](../../../scripts/release/verify-release-readiness.sh). |
| `DIST-03` | `17-02-PLAN.md` | Maintainer can submit the final DMG to Apple with `notarytool`, wait for completion, and get actionable failure information when notarization is rejected | ✓ SATISFIED | [`scripts/release/notarize-dmg.sh`](../../../scripts/release/notarize-dmg.sh) plus passing [`scripts/release/verify-release-notarization.sh`](../../../scripts/release/verify-release-notarization.sh); final live submission still requires the credentialed maintainer run tracked below. |
| `DIST-04` | `17-02-PLAN.md` | The DMG sent to friends is stapled with a successful notarization ticket and passes local Gatekeeper assessment | ✓ SATISFIED | [`release.sh`](../../../release.sh) runs `xcrun stapler staple`, [`scripts/release/assess-notarized-dmg.sh`](../../../scripts/release/assess-notarized-dmg.sh) runs both post-success checks, and the docs/static gates align to the same contract. |

Orphaned requirements: None. All Phase 17 requirement IDs claimed by plan frontmatter are accounted for above.

### Behavioral Spot-Checks

| Behavior | Command | Result | Status |
| --- | --- | --- | --- |
| Signed DMG seam gate | `bash scripts/release/verify-release-readiness.sh` | Passed | ✓ PASS |
| Notarization/stapling seam gate | `bash scripts/release/verify-release-notarization.sh` | Passed | ✓ PASS |
| Public release docs gate | `bash scripts/release/verify-release-docs.sh` | Passed | ✓ PASS |
| Focused regression slice | `bash scripts/release/verify-release-readiness.sh && bash scripts/release/verify-release-notarization.sh && bash scripts/release/verify-release-docs.sh && xcodebuild test -project "Tools Cat.xcodeproj" -scheme "Tools Cat" -destination 'platform=macOS' -parallel-testing-enabled NO -only-testing:'Tools CatTests/DeviceLibrarySessionModelTests' -only-testing:'Tools CatTests/DeviceLibraryManagementPresentationTests' -only-testing:'Tools CatUITests/Tools_CatUITests/testLaunchWithEmptyDeviceLibraryShowsPolishedEmptyState' -only-testing:'Tools CatUITests/Tools_CatUITests/testLaunchWithSeededDeviceLibraryShowsManagementWindow' -only-testing:'Tools CatUITests/Tools_CatUITests/testLaunchWithSeededDeviceLibraryShowsManagementListSurface'` | 13 tests passed with 0 failures | ✓ PASS |
| Credentialed notarized release run | `sh ./release.sh` with `RELEASE_TEAM_ID`, `RELEASE_SIGNING_IDENTITY`, and `RELEASE_NOTARY_PROFILE` exported | Not run here because all three environment variables are currently unset on this machine | HUMAN NEEDED |

### Anti-Patterns Found

| File | Line | Pattern | Severity | Impact |
| --- | --- | --- | --- | --- |
| None | - | No stale `.app`-only release contract, manual-allow guidance, plaintext Apple credentials, or `exportNotarizedApp` detour remains in the phase-owned files. | ℹ️ Info | No blocker anti-patterns detected in the verified implementation. |

### Human Verification Required

One phase-owned manual boundary remains before this phase can be marked fully complete:

1. Export `RELEASE_TEAM_ID`, `RELEASE_SIGNING_IDENTITY`, and `RELEASE_NOTARY_PROFILE`.
2. Run `sh ./release.sh`.
3. Confirm the notary submission is accepted, `xcrun stapler validate dist/Tools-Cat.dmg` passes, and `spctl --assess --type open -v dist/Tools-Cat.dmg` succeeds.

This machine currently reports all three `RELEASE_*` variables as unset, so the real Apple-backed release proof could not be executed inside this run.

### Gaps Summary

No implementation gaps were found in the Phase 17 code or documentation. The only remaining closure item is the credentialed maintainer release run captured in `17-HUMAN-UAT.md`.

---

_Verified: 2026-04-16T10:25:23Z_
_Verifier: Codex (gsd-verifier-equivalent)_
