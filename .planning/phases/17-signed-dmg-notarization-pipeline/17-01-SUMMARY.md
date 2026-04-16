---
phase: 17-signed-dmg-notarization-pipeline
plan: 01
subsystem: infra
tags: [release, dmg, codesign, notarization]
requires:
  - phase: 16-release-signing-readiness
    provides: signed app archive/export seam and release preflight
provides:
  - signed DMG packaging from the exported app
  - DMG signature inspection seam
  - static readiness proof for the signed-DMG release path
affects: [phase-17-plan-02, release-docs, notarization]
tech-stack:
  added: []
  patterns:
    - release.sh remains the only maintainer-facing release entrypoint
    - build_dmg.sh stays the deterministic DMG packer seam
key-files:
  created: [scripts/release/inspect-dmg-signature.sh]
  modified: [release.sh, build_dmg.sh, scripts/release/verify-release-readiness.sh]
key-decisions:
  - "Keep `release.sh` as the sole public release command while extending it to emit the final signed DMG."
  - "Keep `build_dmg.sh` limited to deterministic staging plus `hdiutil create`, leaving signing and later notarization orchestration to `release.sh`."
patterns-established:
  - "Release artifact progression: archive -> exported signed app -> signed DMG."
  - "Credential-free shell gates assert release seams before real Apple signing or notarization runs."
requirements-completed: [DIST-02]
duration: 8 min
completed: 2026-04-16
---

# Phase 17 Plan 01: Signed DMG Notarization Pipeline Summary

**Signed DMG packaging from the exported app with explicit DMG signature inspection and a static release-readiness gate**

## Performance

- **Duration:** 8 min
- **Started:** 2026-04-16T10:12:00Z
- **Completed:** 2026-04-16T10:20:11Z
- **Tasks:** 2
- **Files modified:** 4

## Accomplishments
- Extended `release.sh` so the release flow now packages `dist/export/Tools Cat.app` into `dist/Tools-Cat.dmg`.
- Signed the final DMG and added a dedicated inspection script to verify the packaged artifact before Wave 2 notarization work.
- Expanded the static release-readiness gate so the repo proves the signed-DMG seam without needing credentials.

## Task Commits

Each task was committed atomically:

1. **Task 1: Package and sign the final `Tools-Cat.dmg` from the exported app** - `2632e8d` (feat)
2. **Task 2: Expand the static release-readiness gate so it proves the signed-DMG seam exists** - `b616ac1` (test)

## Files Created/Modified
- `release.sh` - Packages, signs, and inspects `dist/Tools-Cat.dmg` after the signed app export.
- `build_dmg.sh` - Keeps deterministic DMG packing but drops stale manual-allow messaging.
- `scripts/release/inspect-dmg-signature.sh` - Verifies the final DMG signature boundary.
- `scripts/release/verify-release-readiness.sh` - Proves the signed-DMG seam alongside the existing Phase 16 archive/export checks.

## Decisions Made
- Kept `release.sh` as the only maintainer-facing release command so later notarization work extends one trusted entrypoint.
- Kept `build_dmg.sh` focused on deterministic packaging only, with DMG signing handled in `release.sh` to keep artifact ownership clear.

## Deviations from Plan

None - plan executed exactly as written.

## Issues Encountered
Parallel commit attempts collided on `.git/index.lock` while I was cutting the two task commits. I resolved it by retrying the remaining commit sequentially; no code or artifact changes were lost.

## User Setup Required

None - no external service configuration required.

## Next Phase Readiness
Wave 1 is complete and the repo now has a stable signed `dist/Tools-Cat.dmg` seam for notarization, stapling, assessment, and docs work in `17-02-PLAN.md`.

---
*Phase: 17-signed-dmg-notarization-pipeline*
*Completed: 2026-04-16*
