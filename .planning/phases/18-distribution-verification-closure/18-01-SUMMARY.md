---
phase: 18-distribution-verification-closure
plan: 01
subsystem: infra
tags: [release, verification, dmg, docs]
requires:
  - phase: 17-signed-dmg-notarization-pipeline
    provides: superseded release-chain context and historical verification boundary
provides:
  - repeatable Phase 18 distribution verification command
  - mounted DMG layout validation for the friend-share artifact
  - focused WOL and keep-awake regression proof after the friend-share pivot
affects: [release-docs, verification, milestone-v1.6]
tech-stack:
  added: []
  patterns:
    - release verification composes small shell helpers under scripts/release
    - friend-share DMG verification mounts the real artifact instead of trusting script text alone
key-files:
  created: [scripts/release/verify-friend-share-artifact.sh, scripts/release/verify-distribution-closure.sh]
  modified: [README.md, docs/release/signing-readiness.md, scripts/release/verify-release-docs.sh]
key-decisions:
  - "Keep `release.sh` as the only public build command and add one separate post-release verification command for Phase 18."
  - "Verify the shipped DMG by mounting it and checking for `Tools Cat.app` plus the `/Applications` shortcut."
  - "Reuse existing WOL and keep-awake test seams instead of inventing a new release-only harness."
patterns-established:
  - "Post-release maintainer verification command: `bash scripts/release/verify-distribution-closure.sh`."
  - "Manual-open instructions stay explicit and bounded: drag to `/Applications`, then `右键打开`, then `xattr` only if still blocked."
requirements-completed: [DIST-06, DIST-07]
duration: 2026-04-17 session
completed: 2026-04-17
---

# Phase 18 Plan 01: Distribution Verification Closure Summary

**Repeatable friend-share artifact verification and focused WOL/keep-awake regression proof now close the v1.6 release story**

## Performance

- **Completed:** 2026-04-17
- **Tasks:** 2
- **Core repo files changed:** 5
- **Phase artifacts added:** 4

## Accomplishments
- Added `scripts/release/verify-friend-share-artifact.sh` to mount `dist/Tools-Cat.dmg` and prove the shipped artifact contains `Tools Cat.app` plus the `/Applications` shortcut.
- Added `scripts/release/verify-distribution-closure.sh` as the single Phase 18 verification command that composes static release/doc gates, artifact inspection, focused WOL/keep-awake model regressions, and the existing menu-bar verification slice.
- Updated `README.md`, `docs/release/signing-readiness.md`, and `scripts/release/verify-release-docs.sh` so the manual-open instructions and verification command now match the current friend-share DMG contract.
- Added Phase 18 planning and verification artifacts so the repo state now reflects the closure work instead of stopping at the 2026-04-17 pivot.

## Task Commits

No git commit was created in this workspace session.

## Files Created/Modified
- `scripts/release/verify-friend-share-artifact.sh` - Mounted DMG layout verification for the shipped friend-share artifact.
- `scripts/release/verify-distribution-closure.sh` - One-shot Phase 18 verification entrypoint.
- `README.md` - Public release section now names the post-release verification command and manual-open boundary.
- `docs/release/signing-readiness.md` - Canonical runbook now documents the Phase 18 verification flow and exact friend-side first-launch steps.
- `scripts/release/verify-release-docs.sh` - Docs gate now enforces the Phase 18 verification/manual-open contract.
- `.planning/phases/18-distribution-verification-closure/18-CONTEXT.md` - Phase boundary and locked decisions.
- `.planning/phases/18-distribution-verification-closure/18-01-PLAN.md` - Executed plan for Phase 18.
- `.planning/phases/18-distribution-verification-closure/18-VERIFICATION.md` - Phase verification report.

## Verification Highlights
- `sh ./release.sh` produced `build/DerivedData/Build/Products/Release/Tools Cat.app` and `dist/Tools-Cat.dmg`.
- `bash scripts/release/verify-distribution-closure.sh` passed end-to-end.
- The focused regression coverage inside that command passed cleanly: 26 WOL/keep-awake model tests, 30 controller/menu tests, and 3 UI smoke tests.

## Issues Encountered

None.

## Next Phase Readiness

Phase 18 is complete. The remaining boundary is not another release-hardening phase; it is milestone-level closure and any optional future roadmap work after v1.6.

---
*Phase: 18-distribution-verification-closure*
*Completed: 2026-04-17*
