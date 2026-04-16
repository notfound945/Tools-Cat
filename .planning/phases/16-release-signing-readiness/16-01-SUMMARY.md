---
phase: 16-release-signing-readiness
plan: 01
subsystem: infra
tags: [macos, xcodebuild, codesign, notarytool, release]
requires:
  - phase: 15-device-library-ui-parity
    provides: polished shipped app behavior that Phase 16 hardens for distribution
provides:
  - Developer ID archive/export release path in `release.sh`
  - fail-fast signing preflight helpers under `scripts/release/`
  - Release hardened-runtime and Team-ID readiness verification
affects: [16-02-plan, 17-signed-dmg-notarization-pipeline, 18-distribution-verification-closure]
tech-stack:
  added: [xcodebuild archive, xcodebuild -exportArchive, codesign inspection, notarytool profile checks]
  patterns: [single release entrypoint, fail-fast signing preflight, deterministic export policy, static readiness gate]
key-files:
  created:
    - scripts/release/preflight-signing.sh
    - scripts/release/export-options-developer-id.plist.template
    - scripts/release/inspect-signature.sh
    - scripts/release/verify-release-readiness.sh
  modified:
    - release.sh
    - Tools Cat.xcodeproj/project.pbxproj
key-decisions:
  - "Keep `release.sh` as the only maintainer-facing release entrypoint while moving its build seam to archive/export."
  - "Preserve automatic signing for day-to-day Xcode use, but make Release readiness explicit with hardened runtime and the fixed Team ID."
patterns-established:
  - "Release scripts fail fast on missing Team ID, Developer ID identity, and named notary profile before archive work begins."
  - "Later release phases can reuse a deterministic Developer ID export plist and the static readiness gate instead of reintroducing DerivedData pickup."
requirements-completed: [DIST-01]
duration: 3min
completed: 2026-04-16
---

# Phase 16 Plan 01: Release Signing Readiness Summary

**Developer ID archive/export release orchestration with fail-fast signing preflight and explicit Release hardened-runtime readiness**

## Performance

- **Duration:** 3 min
- **Started:** 2026-04-16T09:37:20Z
- **Completed:** 2026-04-16T09:40:04Z
- **Tasks:** 2
- **Files modified:** 6

## Accomplishments
- Replaced the old DerivedData plus DMG release path with a single `release.sh` archive/export flow that stops at a signed `Tools Cat.app`.
- Added release helpers for signing preflight, deterministic Developer ID export options, post-export signature inspection, and a reusable static readiness check.
- Made the app target's Release configuration explicitly ready for future notarization by setting the fixed Team ID and enabling hardened runtime while keeping automatic signing.

## Task Commits

Each task was committed atomically:

1. **Task 1: Replace the DerivedData release path with explicit preflight plus archive/export signing** - `1658683` (feat)
2. **Task 2: Make Release signing readiness explicit in project settings and add a reusable shell verification gate** - `4886514` (feat)

## Files Created/Modified
- `release.sh` - canonical release entrypoint now runs signing preflight, archive, export, and signature inspection
- `scripts/release/preflight-signing.sh` - validates required env vars, Apple tool presence, Developer ID identity, and named notary profile
- `scripts/release/export-options-developer-id.plist.template` - checked-in deterministic Developer ID export policy template
- `scripts/release/inspect-signature.sh` - inspects entitlements and verifies the exported app signature
- `scripts/release/verify-release-readiness.sh` - static shell gate for the release signing seam and project settings
- `Tools Cat.xcodeproj/project.pbxproj` - explicit Release Team ID and hardened-runtime readiness

## Decisions Made
- Kept `release.sh` as the sole public release command so later DMG/notarization work builds on the same seam.
- Kept `CODE_SIGN_STYLE = Automatic;` for normal development while explicitly hardening the Release configuration for distribution readiness.

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 3 - Blocking] Corrected stale human-readable plan progress in `STATE.md` after automated state updates**
- **Found during:** Planning artifact closeout
- **Issue:** `gsd-tools state update-progress` updated the state frontmatter but left the visible body showing `0/0` completed plans and empty milestone metrics.
- **Fix:** Patched the body of `.planning/STATE.md` to match the recorded 1/2 plan progress and the new phase metrics.
- **Files modified:** `.planning/STATE.md`
- **Verification:** Confirmed the body now reflects `1/2` completed plans and the recorded Phase 16 metrics.
- **Committed in:** final docs commit

---

**Total deviations:** 1 auto-fixed (1 blocking)
**Impact on plan:** No scope creep. The fix only brought planning state output back in sync with the executed plan.

## Issues Encountered

None.

## User Setup Required

Manual Apple Developer setup is still required on the maintainer machine: install the Developer ID Application certificate, store the named `notarytool` profile, and provide `RELEASE_TEAM_ID`, `RELEASE_SIGNING_IDENTITY`, and `RELEASE_NOTARY_PROFILE` when running `release.sh`.

## Next Phase Readiness

- `release.sh` now provides the distribution-grade archive/export seam Phase 17 can reuse for signed DMG packaging and notarization.
- The repo can statically prove Release hardened-runtime and Team-ID readiness without requiring a real Developer ID certificate on every verification run.

## Self-Check: PASSED

- Found `.planning/phases/16-release-signing-readiness/16-01-SUMMARY.md`
- Found task commit `1658683`
- Found task commit `4886514`

---
*Phase: 16-release-signing-readiness*
*Completed: 2026-04-16*
