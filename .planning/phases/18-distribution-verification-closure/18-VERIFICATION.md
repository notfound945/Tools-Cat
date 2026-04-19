---
phase: 18-distribution-verification-closure
verified: 2026-04-17T02:46:24Z
status: passed
score: 3/3 must-haves verified
---

# Phase 18: Distribution Verification Closure Verification Report

**Phase Goal:** The repo closes the milestone with a repeatable verification path for the non-notarized friend-share artifact, while proving the release-flow pivot does not regress shipped WOL or keep-awake behavior.
**Verified:** 2026-04-17T02:46:24Z
**Status:** passed
**Re-verification:** Yes - the final verification used the real Release DMG built in this session and reran the focused regression slice end-to-end

## Goal Achievement

### Observable Truths

| # | Truth | Status | Evidence |
| --- | --- | --- | --- |
| 1 | The repo now provides one repeatable post-release verification command for the current friend-share DMG contract. | ✓ VERIFIED | [`scripts/release/verify-distribution-closure.sh`](../../../scripts/release/verify-distribution-closure.sh) composes the readiness gate, docs gate, mounted-DMG artifact check, focused WOL/keep-awake model regressions, and the existing menu-bar verification slice. |
| 2 | The shipped `dist/Tools-Cat.dmg` is verified as a friend-share artifact with the expected install layout and truthful manual-open instructions. | ✓ VERIFIED | [`scripts/release/verify-friend-share-artifact.sh`](../../../scripts/release/verify-friend-share-artifact.sh) mounted the DMG built by [`release.sh`](../../../release.sh) and proved `Tools Cat.app` plus the `/Applications` shortcut exist; [`README.md`](../../../README.md) and [`docs/release/signing-readiness.md`](../../../docs/release/signing-readiness.md) now document drag-to-`/Applications`, `右键打开`, and the `xattr` fallback. |
| 3 | The friend-share pivot did not regress shipped WOL or keep-awake behavior across the focused Phase 18 verification boundary. | ✓ VERIFIED | `bash scripts/release/verify-distribution-closure.sh` passed with 26 WOL/keep-awake model tests, 30 controller/menu tests, and 3 UI smoke tests, including [`Tools CatTests/WOLSessionModelTests.swift`](../../../Tools%20CatTests/WOLSessionModelTests.swift), [`Tools CatTests/KeepAwakeSessionModelTests.swift`](../../../Tools%20CatTests/KeepAwakeSessionModelTests.swift), [`Tools CatTests/KeepAwakeMenuStateTests.swift`](../../../Tools%20CatTests/KeepAwakeMenuStateTests.swift), and [`scripts/run_menu_bar_verification_slice.sh`](../../../scripts/run_menu_bar_verification_slice.sh). |

**Score:** 3/3 truths verified

### Required Artifacts

| Artifact | Expected | Status | Details |
| --- | --- | --- | --- |
| `scripts/release/verify-friend-share-artifact.sh` | Mount-and-inspect validation for the shipped DMG | ✓ VERIFIED | Exists and checks for the built Release app, `dist/Tools-Cat.dmg`, `Tools Cat.app` inside the mounted DMG, and the `/Applications` symlink target. |
| `scripts/release/verify-distribution-closure.sh` | Single maintainer-facing Phase 18 verification command | ✓ VERIFIED | Exists and passed end-to-end in this session. |
| `README.md` | Short public release entrypoint that also names the post-release verification command | ✓ VERIFIED | Exists and now points to `bash scripts/release/verify-distribution-closure.sh` plus the manual-open boundary. |
| `docs/release/signing-readiness.md` | Canonical friend-share release runbook with exact verification and first-launch steps | ✓ VERIFIED | Exists and now documents the Phase 18 automated verification plus the step-by-step manual-open path. |
| `scripts/release/verify-release-docs.sh` | Static docs gate for the Phase 18 verification/manual-open contract | ✓ VERIFIED | Passed during verification. |
| `dist/Tools-Cat.dmg` | Real friend-share DMG built in the current release flow | ✓ VERIFIED | Produced by `sh ./release.sh` and mounted successfully during Phase 18 artifact verification. |

### Requirements Coverage

| Requirement | Source Plan | Description | Status | Evidence |
| --- | --- | --- | --- | --- |
| `DIST-06` | `18-01-PLAN.md` | Repo provides a repeatable local verification path for the shipped non-notarized artifact, including the exact manual-open steps friends may need | ✓ SATISFIED | [`scripts/release/verify-distribution-closure.sh`](../../../scripts/release/verify-distribution-closure.sh), [`scripts/release/verify-friend-share-artifact.sh`](../../../scripts/release/verify-friend-share-artifact.sh), [`README.md`](../../../README.md), and [`docs/release/signing-readiness.md`](../../../docs/release/signing-readiness.md). |
| `DIST-07` | `18-01-PLAN.md` | Distribution hardening does not change the shipped WOL and keep-awake behavior beyond the release/share work needed for friend distribution | ✓ SATISFIED | Passing focused regression slice inside [`scripts/release/verify-distribution-closure.sh`](../../../scripts/release/verify-distribution-closure.sh), including WOL/keep-awake model seams and the established menu-bar verification slice. |

Orphaned requirements: None. All Phase 18 requirement IDs claimed by plan frontmatter are accounted for above.

### Behavioral Spot-Checks

| Behavior | Command | Result | Status |
| --- | --- | --- | --- |
| Local friend-share release build | `sh ./release.sh` | Passed and produced `build/DerivedData/Build/Products/Release/Tools Cat.app` plus `dist/Tools-Cat.dmg` | ✓ PASS |
| Static release readiness gate | `bash scripts/release/verify-release-readiness.sh` | Passed | ✓ PASS |
| Static release docs gate | `bash scripts/release/verify-release-docs.sh` | Passed | ✓ PASS |
| End-to-end Phase 18 verification | `bash scripts/release/verify-distribution-closure.sh` | Passed | ✓ PASS |
| Mounted DMG artifact layout | Included in `bash scripts/release/verify-distribution-closure.sh` via `bash scripts/release/verify-friend-share-artifact.sh` | Mounted the DMG and confirmed `Tools Cat.app` plus `/Applications` shortcut | ✓ PASS |
| Focused WOL/keep-awake model regressions | Included in `bash scripts/release/verify-distribution-closure.sh` | 26 tests passed with 0 failures | ✓ PASS |
| Existing controller/UI verification slice | Included in `bash scripts/release/verify-distribution-closure.sh` via `bash scripts/run_menu_bar_verification_slice.sh` | 33 tests passed with 0 failures | ✓ PASS |

### Anti-Patterns Found

| File | Line | Pattern | Severity | Impact |
| --- | --- | --- | --- | --- |
| None | - | No stale notarization requirement, no missing manual-open fallback, and no unverified DMG-layout assumption remain in the phase-owned files. | ℹ️ Info | No blocker anti-patterns detected in the verified Phase 18 implementation. |

### Manual Boundary

The remaining manual boundary is explicit and intentional:

- Automated verification does not prove a fresh-machine install end-to-end.
- Automated verification does not prove what a real friend-side Gatekeeper prompt sequence will look like on every machine.
- The documented manual path remains: drag to `/Applications`, then launch with `右键打开`, then remove quarantine only if Gatekeeper still blocks launch.

### Gaps Summary

No implementation gaps were found for the Phase 18 scope. The repo now has a repeatable local verification path for the friend-share DMG, truthful manual-open documentation, and focused regression evidence that the release pivot did not change shipped WOL or keep-awake behavior.

---

_Verified: 2026-04-17T02:46:24Z_  
_Verifier: Codex (gsd-verifier-equivalent)_
