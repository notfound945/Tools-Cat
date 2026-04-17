---
phase: 17-signed-dmg-notarization-pipeline
plan: 02
subsystem: infra
tags: [release, notarization, dmg, docs]
requires:
  - phase: 17-signed-dmg-notarization-pipeline
    provides: signed DMG seam and DMG signature inspection from plan 01
provides:
  - deterministic notary submission and rejection-log capture
  - stapling plus local DMG assessment flow
  - maintainer docs aligned to the notarized DMG contract
affects: [phase-18, release-docs, verification]
tech-stack:
  added: []
  patterns:
    - notary metadata is stored under build/notary
    - notarization and post-staple assessment stay in dedicated release helpers
key-files:
  created: [scripts/release/notarize-dmg.sh, scripts/release/assess-notarized-dmg.sh, scripts/release/verify-release-notarization.sh]
  modified: [release.sh, README.md, docs/release/signing-readiness.md, scripts/release/verify-release-docs.sh]
key-decisions:
  - "Persist notary submission metadata and rejection logs under `build/notary/` so Apple failures are actionable without rerunning uploads."
  - "Keep notarization submission and post-staple assessment in separate helpers so the release flow stays readable and statically verifiable."
patterns-established:
  - "Final release artifact contract: sign DMG -> notarytool submit/wait -> stapler staple -> stapler validate -> spctl assess."
  - "Public docs and docs gates must move in the same phase as release-contract changes."
requirements-completed: [DIST-03, DIST-04]
duration: 3 min
completed: 2026-04-16
---

# Phase 17 Plan 02: Signed DMG Notarization Pipeline Summary

**Notary submission, stapled DMG assessment, and maintainer docs aligned to the final `dist/Tools-Cat.dmg` release contract**

## Performance

- **Duration:** 3 min
- **Started:** 2026-04-16T10:22:04Z
- **Completed:** 2026-04-16T10:25:23Z
- **Tasks:** 2
- **Files modified:** 7

## Accomplishments
- Extended `release.sh` so the shipped DMG now flows through notarization submission, stapling, and local assessment hooks.
- Added deterministic `build/notary/` metadata outputs and a static gate that proves the notarization seam without requiring real credentials.
- Rewrote the public release docs so they describe the notarized DMG flow truthfully and reject stale manual-allow guidance.

## Task Commits

Each task was committed atomically:

1. **Task 1: Add the notarization, stapling, and local-assessment flow around the signed DMG** - `ad4bc8f` (feat)
2. **Task 2: Update the public release docs and docs gate for the notarized DMG contract** - `0607d8c` (docs)

## Files Created/Modified
- `release.sh` - Notarizes, staples, and assesses `dist/Tools-Cat.dmg` after DMG signing.
- `scripts/release/notarize-dmg.sh` - Submits the DMG to Apple, waits, parses the result, and saves rejection logs deterministically.
- `scripts/release/assess-notarized-dmg.sh` - Validates the stapled DMG with `stapler validate` and `spctl --assess`.
- `scripts/release/verify-release-notarization.sh` - Statically proves the notarization and assessment seam.
- `README.md` - Describes the final shipped artifact and the notary metadata outputs.
- `docs/release/signing-readiness.md` - Documents the end-to-end notarized DMG runbook and the remaining Phase 18 boundary.
- `scripts/release/verify-release-docs.sh` - Rejects stale `.app`-only or manual-allow release guidance.

## Decisions Made
- Persisted notary submission metadata and rejection logs under `build/notary/` so a maintainer can diagnose Apple failures from stable paths.
- Split notarization submission and post-staple assessment into dedicated helpers to keep `release.sh` readable and easy to statically verify.

## Deviations from Plan

None - plan executed exactly as written.

## Issues Encountered
None.

## User Setup Required

None - no new external service configuration was added beyond the existing Keychain-backed notary profile bootstrap.

## Next Phase Readiness
Phase 17 is preserved as completed historical implementation work, but its original Apple-backed verification requirement was superseded on 2026-04-17 when v1.6 pivoted to non-notarized friend sharing. The active next step is Phase 18 verification for the friend-share DMG and its manual first-launch guidance, not a credentialed notarization rerun.

---
*Phase: 17-signed-dmg-notarization-pipeline*
*Completed: 2026-04-16*
