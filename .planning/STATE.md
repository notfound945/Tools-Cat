---
gsd_state_version: 1.0
milestone: v1.6
milestone_name: Distribution Hardening
status: executing
stopped_at: Completed 17-01-PLAN.md
last_updated: "2026-04-16T10:21:18.536Z"
last_activity: 2026-04-16
progress:
  total_phases: 3
  completed_phases: 1
  total_plans: 4
  completed_plans: 3
---

# Project State

## Project Reference

See: `.planning/PROJECT.md` (updated 2026-04-16)

**Core value:** From the menu bar, I can reliably wake the devices I care about and trust the app's status without editing code or fighting the UI.
**Current focus:** Phase 17 — signed-dmg-notarization-pipeline

## Current Position

Phase: 17 (signed-dmg-notarization-pipeline) — EXECUTING
Plan: 2 of 2
Status: Ready to execute
Last activity: 2026-04-16

Progress: [██████████] 2/2 currently planned plans complete

## Performance Metrics

**Velocity:**

- Total plans completed: 2
- Average duration: 2.5 min
- Total execution time: 0.08 hours
- Current milestone plans completed: 2

**By Phase:**

| Phase | Plans | Total | Avg/Plan |
|-------|-------|-------|----------|
| 16 | 2 | 5min | 2.5min |
| 17 | 0 | - | - |
| 18 | 0 | - | - |

**Recent Trend:**

- Last 5 plans: Phase 16-release-signing-readiness Plan 01 (3min), Plan 02 (2min)
- Trend: Phase 16 completed
- v1.6 is ready to move into Phase 17 planning/execution.

| Phase 16-release-signing-readiness P01 | 3min | 2 tasks | 6 files |
| Phase 16-release-signing-readiness P02 | 2min | 2 tasks | 3 files |
| Phase 17 P01 | 8 min | 2 tasks | 4 files |

## Milestone Summary

- Active milestone: `v1.6 Distribution Hardening`
- Latest archived milestone: `v1.5 Device Library UI Parity`
- Scope planned: friend-installable signed/notarized distribution without manual Gatekeeper overrides
- Active roadmap: `.planning/ROADMAP.md`
- Working files:
  - `.planning/PROJECT.md`
  - `.planning/REQUIREMENTS.md`
  - `.planning/ROADMAP.md`
  - `.planning/MILESTONES.md`
- Latest shipped summary: `.planning/MILESTONES.md`

## Accumulated Context

### Decisions

Decisions are logged in `PROJECT.md` under **Key Decisions**.
The latest completed milestone established these durable decisions:

- Keep the shipped wake surface as `快速 WOL` plus the dedicated `发送 WOL …` row, with shortcut recovery deferred to `CONV-04`.
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

### Roadmap Evolution

- Phase 12.1 inserted after Phase 12: macOS 14.8.3 compatibility support (URGENT)
- Phase 12.1 planned as a single compatibility-truth fix covering deployment target, doc alignment, and explicit Sonoma verification boundary
- Milestone v1.4 started: refine the duration-management list using native list semantics and semantic edit/delete action colors
- Phase 14 added: duration-management UI polish with native list presentation and semantic edit/delete actions

### Open Follow-Up Themes

- Active milestone theme: `DIST-01` distribution hardening.
- Deferred themes after v1.6: `CONV-04`, `AWAKE-12`, `AWAKE-13`.

## Session Continuity

Last session: 2026-04-16T10:21:18.534Z
Stopped at: Completed 17-01-PLAN.md
Resume file: None
