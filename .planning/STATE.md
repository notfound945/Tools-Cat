---
gsd_state_version: 1.0
milestone: v1.7
milestone_name: WOL Device Entry Polish
status: ready_for_milestone_audit
stopped_at: Completed 20-01-PLAN.md
last_updated: "2026-05-06T02:42:14Z"
last_activity: 2026-05-06
progress:
  total_phases: 2
  completed_phases: 2
  total_plans: 2
  completed_plans: 2
---

# Project State

## Project Reference

See: `.planning/PROJECT.md` (updated 2026-05-06)

**Core value:** From the menu bar, I can reliably wake the devices I care about and trust the app's status without editing code or fighting the UI.
**Current focus:** Milestone v1.7 closure

## Current Position

Phase: 20 (first-use-device-seed) — COMPLETE
Plan: 1 of 1
Status: Milestone scope complete — ready for audit/archive
Last activity: 2026-05-06

Progress: [██████████] 2/2 current milestone plans complete

## Performance Metrics

**Velocity:**

- Total plans completed: 6
- Average duration: 4.3 min
- Total execution time: 0.43 hours
- Current milestone plans completed: 2

**By Phase:**

| Phase | Plans | Total | Avg/Plan |
|-------|-------|-------|----------|
| 16 | 2 | 5min | 2.5min |
| 17 | 2 | 11min | 5.5min |
| 18 | 1 | 3min | 3min |

**Recent Trend:**

- Last 5 plans: Phase 16-release-signing-readiness Plan 01 (3min), Plan 02 (2min), Phase 17-signed-dmg-notarization-pipeline Plan 01 (8min), Plan 02 (3min), Phase 18-distribution-verification-closure Plan 01 (3min)
- Trend: Phase 17 was superseded by the 2026-04-17 friend-share pivot, and Phase 18 closed the replacement verification contract in one plan.
- v1.7 implementation scope is complete; next workflow step should be milestone audit/archive.

| Phase 16-release-signing-readiness P01 | 3min | 2 tasks | 6 files |
| Phase 16-release-signing-readiness P02 | 2min | 2 tasks | 3 files |
| Phase 17 P01 | 8 min | 2 tasks | 4 files |
| Phase 17 P02 | 3 min | 2 tasks | 7 files |
| Phase 18 P01 | 3 min | 2 tasks | 5 files |
| Phase 19 P01 | 7min | 2 tasks | 4 files |

## Milestone Summary

- Active milestone: `v1.7 WOL Device Entry Polish`
- Latest archived milestone: `v1.6 Distribution Hardening`
- New scope: defer device-library validation error reveal until blur/submit and seed one default `UGREEN NAS` device only for first-use empty libraries
- Active roadmap: `.planning/ROADMAP.md` (Phases 19-20 complete; milestone ready for audit)
- Working files:
  - `.planning/PROJECT.md`
  - `.planning/ROADMAP.md`
  - `.planning/MILESTONES.md`
- Latest shipped summary: `.planning/MILESTONES.md`

## Accumulated Context

### Decisions

Decisions are logged in `PROJECT.md` under **Key Decisions**.
The latest completed milestone established these durable decisions:

- Keep the shipped wake surface as `快速 WOL` plus the dedicated `发送 WOL …` row.
- Keep menu-bar verification layered: controller seams and direct-launch UI smoke are automated, live tray entry remains manual.
- Treat Phase 01-04 validation debt as documentation-truth work, not new harness work.
- Keep runtime persistence on `UserDefaults.standard` and migrate legacy bundle-ID defaults only once.
- Keep rename residue cleanup explicit and manual instead of destructive automation.
- [Phase 12.1]: Treat macOS 14.0 as the deployment-target truth and keep real macOS 14.8.3 launch proof as an explicit manual boundary.
- [Phase 12]: Seed managed keep-awake durations exactly once from one defaults key and bridge the fixed root menu through canonical duration seconds until dynamic rendering lands.
- [Phase 13]: Manage timed keep-awake durations through a dedicated native window and shared session; after UAT, pull the minimum required root-menu sync slice forward so CRUD truth holds live.
- [Phase 13 gap closure]: Keep timed root-menu rows subscribed directly to the managed duration store, and keep add/edit inside one shared list-local sheet.
- [Phase 13 cosmetic gap]: The duration manager's timed rows need a distinct native list surface; functional correctness alone was not enough for discoverability.
- [Phase 13 cosmetic gap closure]: Use a grouped native list container and subtle row surfaces so timed durations read as a real list without altering the existing CRUD flow.
- [Phase 15-device-library-ui-parity]: Use currentFormMode as the only add/edit presentation truth and derive sheet visibility from it.
- [Phase 15-device-library-ui-parity]: Keep reorder mode on its existing dedicated List path while moving only the normal browse path to native list semantics.
- [Phase 15-device-library-ui-parity]: Apply device-library row semantics directly on the existing borderless actions so the polish stays presentation-only.
- [Phase 15-device-library-ui-parity]: Keep semantic-polish verification limited to the established session, presentation, and direct-launch device-library regression slice.
- [Phase 16-release-signing-readiness]: Keep release.sh as the only maintainer-facing release command while moving the build seam to archive/export.
- [Phase 16-release-signing-readiness]: Keep automatic signing for daily Xcode use but make Release hardened runtime and Team ID explicit for distribution readiness.
- [Phase 17]: Keep release.sh as the sole public release command while extending it to emit the final signed DMG. — Wave 2 notarization can extend one trusted release entrypoint instead of introducing a second maintainer flow.
- [Phase 17]: Keep build_dmg.sh limited to deterministic staging plus hdiutil create, leaving signing and notarization orchestration to release.sh. — This keeps packaging deterministic and makes the signed artifact boundary explicit for later notary and assessment steps.
- [Phase 17]: Persist notary submission metadata and rejection logs under build/notary so Apple failures are actionable without rerunning uploads. — Phase 17 depends on deterministic failure evidence, not transient terminal output.
- [Phase 17]: Keep notarization submission and post-staple assessment in separate helpers so the release flow stays readable and statically verifiable. — The repo now verifies the notarization seam via shell gates, so each concern needs a small, grepable boundary.
- [Phase 17/18 pivot]: Treat the notarized DMG path as historical work and make non-notarized friend sharing the current release truth because the maintainer chose not to join Apple Developer Program.
- [Phase 18]: Keep `release.sh` as the only public build command and add one separate post-release verification command that mounts the real DMG, reruns focused WOL/keep-awake regressions, and states the remaining manual boundary explicitly.
- [Phase 19]: Keep validation truth in DeviceLibrarySessionModel and expose reveal-aware messages instead of moving validation into the view.
- [Phase 19]: Remove the invalid-only disabled save gate so saveDraft() remains the explicit submit boundary for invalid drafts.

### Roadmap Evolution

- Phase 12.1 inserted after Phase 12: macOS 14.8.3 compatibility support (URGENT)
- Phase 12.1 planned as a single compatibility-truth fix covering deployment target, doc alignment, and explicit Sonoma verification boundary
- Milestone v1.4 started: refine the duration-management list using native list semantics and semantic edit/delete action colors
- Phase 14 added: duration-management UI polish with native list presentation and semantic edit/delete actions

### Open Follow-Up Themes

- New milestone theme activated from user request: device-library validation timing polish plus first-use default-device seeding.
- Phase 20 completed: first-use saved-device libraries now seed one canonical `UGREEN NAS` entry exactly once without mutating initialized libraries.

## Session Continuity

Last session: 2026-05-06T01:55:05.214Z
Stopped at: Completed 20-01-PLAN.md
Resume file: None
