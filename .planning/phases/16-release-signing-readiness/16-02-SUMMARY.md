---
phase: 16-release-signing-readiness
plan: 02
subsystem: docs
tags: [release, docs, signing, notarization, maintainers]
requires:
  - phase: 16-release-signing-readiness
    provides: Developer ID archive/export release contract from plan 01
provides:
  - canonical maintainer release entrypoint in `README.md`
  - dedicated signing bootstrap and runbook doc in `docs/release/signing-readiness.md`
  - static docs drift gate in `scripts/release/verify-release-docs.sh`
affects: [17-signed-dmg-notarization-pipeline, 18-distribution-verification-closure]
tech-stack:
  added: [rg-based docs gate]
  patterns: [single release entrypoint, focused release runbook, explicit phase boundary]
key-files:
  created:
    - docs/release/signing-readiness.md
    - scripts/release/verify-release-docs.sh
  modified:
    - README.md
key-decisions:
  - "Keep README.md as the short maintainer entrypoint and move the full signing bootstrap/runbook into a dedicated release doc."
  - "Document the Phase 16 boundary explicitly so DMG signing, notarization, stapling, and Gatekeeper verification stay deferred to Phase 17+."
patterns-established:
  - "Release docs must name the exact env vars and exported app path from `release.sh`."
  - "Docs drift back to unsigned/manual-install guidance is blocked by a fast shell gate."
requirements-completed: [DIST-05]
duration: 2min
completed: 2026-04-16
---

# Phase 16 Plan 02: Release Signing Documentation Summary

**Maintainer-facing signing bootstrap, Phase 16 runbook, and release docs drift gate**

## Performance

- **Duration:** 2 min
- **Started:** 2026-04-16T09:46:30Z
- **Completed:** 2026-04-16T09:49:44Z
- **Tasks:** 2
- **Files modified:** 3

## Accomplishments
- Replaced the old README release story with one canonical `sh ./release.sh` entrypoint that names the required signing env vars and the exported app output.
- Added `docs/release/signing-readiness.md` with prerequisites, Developer ID certificate bootstrap, `TOOLS_CAT_NOTARY` setup, and the Phase 16 release runbook.
- Added `scripts/release/verify-release-docs.sh` so the repo can statically reject stale unsigned-DMG and manual Gatekeeper-bypass instructions.

## Task Commits

Each task was committed atomically:

1. **Task 1: Rewrite the maintainer release docs around the new signed-app export contract** - `f2b27c3` (docs)
2. **Task 2: Add a docs drift gate for release prerequisites and stale manual-allow language** - `a1d4520` (chore)

## Files Created/Modified
- `README.md` - short maintainer release entrypoint for `sh ./release.sh` plus env vars and Phase 17 deferral
- `docs/release/signing-readiness.md` - detailed signing/bootstrap/runbook doc for Phase 16
- `scripts/release/verify-release-docs.sh` - rg-based docs contract gate

## Decisions Made
- Kept README concise and operational, with the detailed release procedure moved to a dedicated document.
- Kept the public release story aligned with the new archive/export seam and explicitly deferred notarized DMG work to Phase 17+.

## Deviations from Plan

None - plan executed exactly as written.

## Issues Encountered

None.

## User Setup Required

Maintainers still need to provision their Apple Developer certificate and `TOOLS_CAT_NOTARY` profile locally before running the documented release flow.

## Next Phase Readiness

- Phase 17 can now build on a documented release contract instead of the old unsigned/manual-install README path.
- The repo now has a reusable docs gate that will flag regressions if later release work drifts away from the signed-app export contract.

## Self-Check: PASSED

- Found `.planning/phases/16-release-signing-readiness/16-02-SUMMARY.md`
- Found task commit `f2b27c3`
- Found task commit `a1d4520`

---
*Phase: 16-release-signing-readiness*
*Completed: 2026-04-16*
