---
gsd_state_version: 1.0
milestone: v1.9
milestone_name: Timed Keep-Awake Notifications
status: requirements_defined
stopped_at: Milestone initialized; ready for Phase 24 discussion/planning
last_updated: "2026-05-09T21:58:36+0800"
last_activity: 2026-05-09 -- Milestone v1.9 started and roadmap created
progress:
  total_phases: 2
  completed_phases: 0
  total_plans: 2
  completed_plans: 0
---

# Project State

## Project Reference

See: `.planning/PROJECT.md` (updated 2026-05-09)

**Core value:** From the menu bar, I can reliably wake the devices I care about and trust the app's status without editing code or fighting the UI.
**Current focus:** Defining and starting milestone v1.9 Timed Keep-Awake Notifications

## Current Position

Phase: Not started (defining requirements and roadmap)
Plan: —
Status: Ready for `$gsd-discuss-phase 24` or `$gsd-plan-phase 24`
Last activity: 2026-05-09 -- Milestone v1.9 started

Progress: [░░░░░░░░░░] 0/2 current milestone phases complete

## Performance Metrics

**Velocity:**

- Total plans completed: 0
- Average duration: —
- Total execution time: 0 hours
- Current milestone plans completed: 0

**By Phase:**

| Phase | Plans | Total | Avg/Plan |
|-------|-------|-------|----------|
| 24 | 0 | — | — |
| 25 | 0 | — | — |

**Recent Trend:**

- Last shipped milestone: v1.8 WOL Feedback Guardrails (Phases 22-23)
- Trend: recent milestones remain intentionally narrow and interaction-focused; v1.9 keeps that pattern by adding notification truth around an existing timed keep-awake flow.
- The next executable step is Phase 24 discussion or direct planning.

| Phase 24 | pending | roadmap only | 0 files |
| Phase 25 | pending | roadmap only | 0 files |

## Milestone Summary

- Active milestone: `v1.9 Timed Keep-Awake Notifications`
- Latest archived milestone: `v1.8 WOL Feedback Guardrails`
- New scope: add timed keep-awake reminder notifications at about two minutes before expiry and again when the session ends
- Active roadmap: `.planning/ROADMAP.md` (Phases 24-25 planned)
- Working files:
  - `.planning/PROJECT.md`
  - `.planning/ROADMAP.md`
  - `.planning/REQUIREMENTS.md`
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
- [Phase 20]: Keep first-use seeding inside `UserDefaultsSavedDeviceRepository.loadDevices()` so persistence truth stays in one repository-owned boundary.
- [Phase 20]: Treat a missing `saved_devices` payload as first use, but preserve an explicit persisted empty array as an already-initialized empty library.
- [Phase 22/23 planning]: Keep v1.8 limited to result-timeout and save-button affordance guardrails instead of reopening WOL copy or the saved-device validation rules.
- [Phase 22]: Keep WOLSessionModel as the only owner of wake-result lifetime so the window and menu row clear from one shared state transition.
- [Phase 22]: Stabilize shared-timeout regressions with fake wake-result schedulers in tests that do not need the production delay path.
- [v1.9 planning]: Keep timed keep-awake reminders tied to the active session lifecycle so pre-expiry and expiry notifications cannot drift away from the actual countdown truth.
- [v1.9 planning]: Keep local notification permission failure visible to the user but non-blocking for timed keep-awake itself.

### Roadmap Evolution

- Phase 12.1 inserted after Phase 12: macOS 14.8.3 compatibility support (URGENT)
- Phase 12.1 planned as a single compatibility-truth fix covering deployment target, doc alignment, and explicit Sonoma verification boundary
- Milestone v1.4 started: refine the duration-management list using native list semantics and semantic edit/delete action colors
- Phase 14 added: duration-management UI polish with native list presentation and semantic edit/delete actions

### Open Follow-Up Themes

- Active milestone theme: add truthful timed keep-awake reminders without expanding into general notification settings.
- Deferred themes after v1.9 planning: `CONV-04`, `AWAKE-12`, `AWAKE-13`.

## Session Continuity

Last session: 2026-05-09T21:58:36+0800
Stopped at: Milestone v1.9 initialized; next step is `$gsd-discuss-phase 24` or `$gsd-plan-phase 24`
Resume file: None
