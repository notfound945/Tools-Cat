---
phase: 16-release-signing-readiness
verified: 2026-04-16T09:58:00Z
status: passed
score: 3/3 must-haves verified
---

# Phase 16: Release Signing Readiness Verification Report

**Phase Goal:** The maintainer can build a Developer ID signed `Tools Cat.app` through a release flow that clearly surfaces the required signing identity and notarization prerequisites.
**Verified:** 2026-04-16T09:58:00Z
**Status:** passed
**Re-verification:** Yes — regression slice rerun after an initial flaky UI failure

## Goal Achievement

### Observable Truths

| # | Truth | Status | Evidence |
| --- | --- | --- | --- |
| 1 | `release.sh` is the single public release entrypoint and fails before build work when the signing inputs are missing. | ✓ VERIFIED | [`release.sh`](../../../release.sh) runs [`scripts/release/preflight-signing.sh`](../../../scripts/release/preflight-signing.sh) before archive/export work at lines 16-19; `env -u RELEASE_TEAM_ID -u RELEASE_SIGNING_IDENTITY -u RELEASE_NOTARY_PROFILE bash ./release.sh` exits immediately with `[ERROR] RELEASE_TEAM_ID is required`. |
| 2 | The release seam now produces a distribution-grade exported app from archive plus export settings instead of the old DerivedData path. | ✓ VERIFIED | [`release.sh`](../../../release.sh) archives to `build/archive/Tools Cat.xcarchive` and exports to `dist/export/Tools Cat.app` at lines 8-12 and 27-45; [`scripts/release/export-options-developer-id.plist.template`](../../../scripts/release/export-options-developer-id.plist.template) encodes `developer-id`, `manual`, and `Developer ID Application`; [`scripts/release/verify-release-readiness.sh`](../../../scripts/release/verify-release-readiness.sh) passed. |
| 3 | Maintainers can bootstrap signing/notary prerequisites from repo docs without following the old unsigned/manual-install path. | ✓ VERIFIED | [`README.md`](../../../README.md) lines 20-39 now point only to `sh ./release.sh`, the required env vars, and [`docs/release/signing-readiness.md`](../../../docs/release/signing-readiness.md); the dedicated doc covers certificate bootstrap, `TOOLS_CAT_NOTARY` setup, expected outputs, and the Phase 17 boundary at lines 21-84; [`scripts/release/verify-release-docs.sh`](../../../scripts/release/verify-release-docs.sh) passed. |

**Score:** 3/3 truths verified

### Required Artifacts

| Artifact | Expected | Status | Details |
| --- | --- | --- | --- |
| `release.sh` | Canonical release orchestration via preflight, archive, export, and signature inspection | ✓ VERIFIED | Exists, substantive, and no longer contains `clean build`, DerivedData pickup, or `build_dmg.sh`. |
| `scripts/release/preflight-signing.sh` | Fail-fast validation of Team ID, Developer ID identity, notary profile, and required tools | ✓ VERIFIED | Exists and enforces `RELEASE_TEAM_ID`, `RELEASE_SIGNING_IDENTITY`, `RELEASE_NOTARY_PROFILE`, `security find-identity`, and `notarytool history`. |
| `scripts/release/export-options-developer-id.plist.template` | Deterministic Developer ID export policy | ✓ VERIFIED | Exists and contains `developer-id`, `manual`, `Developer ID Application`, and `__TEAM_ID__`. |
| `scripts/release/inspect-signature.sh` | Post-export signature and entitlement inspection | ✓ VERIFIED | Exists and runs both `codesign -d --entitlements :- --verbose=4` and `codesign -v --verbose=4`. |
| `scripts/release/verify-release-readiness.sh` | Fast static gate for the signing/export seam and Release settings | ✓ VERIFIED | Passed during verification. |
| `README.md` | Short maintainer release entrypoint pointing to the dedicated signing doc | ✓ VERIFIED | Exists and no longer advertises the unsigned DMG/manual Gatekeeper flow. |
| `docs/release/signing-readiness.md` | Detailed certificate/notary bootstrap plus Phase 16 runbook | ✓ VERIFIED | Exists and documents the exact env vars, outputs, and Phase 17 deferral. |
| `scripts/release/verify-release-docs.sh` | Fast docs drift gate for the new release contract | ✓ VERIFIED | Passed during verification. |
| `Tools Cat.xcodeproj/project.pbxproj` | Release configuration keeps automatic signing while making Team ID and hardened runtime explicit | ✓ VERIFIED | Release build settings show `CODE_SIGN_STYLE = Automatic`, `DEVELOPMENT_TEAM = Y2YJ48R9GL`, and `ENABLE_HARDENED_RUNTIME = YES`. |

### Requirements Coverage

| Requirement | Source Plan | Description | Status | Evidence |
| --- | --- | --- | --- | --- |
| `DIST-01` | `16-01-PLAN.md` | Maintainer can produce a Developer ID signed `Tools Cat.app` suitable for direct distribution outside the Mac App Store | ✓ SATISFIED | Archive/export release seam in [`release.sh`](../../../release.sh), deterministic export policy in [`scripts/release/export-options-developer-id.plist.template`](../../../scripts/release/export-options-developer-id.plist.template), explicit Release settings in [`Tools Cat.xcodeproj/project.pbxproj`](../../../Tools%20Cat.xcodeproj/project.pbxproj), and passing [`scripts/release/verify-release-readiness.sh`](../../../scripts/release/verify-release-readiness.sh). |
| `DIST-05` | `16-02-PLAN.md` | Repo documentation explains the required signing identity, notarization credential setup, and release preflight without storing sensitive credentials in the repo | ✓ SATISFIED | Short entrypoint in [`README.md`](../../../README.md), detailed bootstrap/runbook in [`docs/release/signing-readiness.md`](../../../docs/release/signing-readiness.md), and passing [`scripts/release/verify-release-docs.sh`](../../../scripts/release/verify-release-docs.sh). |

Orphaned requirements: None. All Phase 16 requirement IDs claimed by plan frontmatter are accounted for above.

### Behavioral Spot-Checks

| Behavior | Command | Result | Status |
| --- | --- | --- | --- |
| Static signing readiness gate | `bash scripts/release/verify-release-readiness.sh` | Passed | ✓ PASS |
| Static release docs gate | `bash scripts/release/verify-release-docs.sh` | Passed | ✓ PASS |
| Release build setting truth | `xcodebuild -project "Tools Cat.xcodeproj" -scheme "Tools Cat" -configuration Release -destination 'platform=macOS' -showBuildSettings | rg 'ENABLE_HARDENED_RUNTIME = YES|DEVELOPMENT_TEAM = Y2YJ48R9GL|CODE_SIGN_STYLE = Automatic'` | Passed | ✓ PASS |
| Fail-fast preflight before build | `env -u RELEASE_TEAM_ID -u RELEASE_SIGNING_IDENTITY -u RELEASE_NOTARY_PROFILE bash ./release.sh` | Failed immediately with `[ERROR] RELEASE_TEAM_ID is required` before archive work began | ✓ PASS |
| Prior-phase regression gate | `xcodebuild test ... DeviceLibrarySessionModelTests ... DeviceLibraryManagementPresentationTests ... testLaunchWithEmptyDeviceLibraryShowsPolishedEmptyState ... testLaunchWithSeededDeviceLibraryShowsManagementWindow ... testLaunchWithSeededDeviceLibraryShowsManagementListSurface` | 10 unit tests passed on first run; 2 UI tests failed on first run, then both passed on immediate rerun without code changes; no Phase 16 regression vector found in code inspection | ✓ PASS WITH FLAKE NOTE |

### Anti-Patterns Found

| File | Line | Pattern | Severity | Impact |
| --- | --- | --- | --- | --- |
| None | - | No TODO/FIXME placeholders, stubbed release checks, or stale unsigned/manual-install release path found in the phase-owned files | ℹ️ Info | No blocker anti-patterns detected in the verified phase files. |

### Gaps Summary

No implementation gaps were found for the Phase 16 scope. The repo now has a fail-fast Developer ID archive/export seam, explicit Release hardened-runtime and Team-ID readiness, maintainable signing bootstrap documentation, and static verification gates for both code and docs. Phase 17 can build on this seam for signed DMG notarization work.

---

_Verified: 2026-04-16T09:58:00Z_  
_Verifier: Codex (gsd-verifier-equivalent)_
