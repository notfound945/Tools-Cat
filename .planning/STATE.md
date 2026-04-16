---
gsd_state_version: 1.0
milestone: v1.4
milestone_name: Duration UI Polish
status: defining_requirements
stopped_at: Milestone v1.4 started; requirements and roadmap are being defined
last_updated: "2026-04-16T10:05:00+08:00"
last_activity: 2026-04-16 -- started v1.4 to polish the duration-management list UI and semantic action colors
progress:
  total_phases: 1
  completed_phases: 0
  total_plans: 0
  completed_plans: 0
---

# Project State

## Project Reference

See: `.planning/PROJECT.md` (updated 2026-04-16)

**Core value:** From the menu bar, I can reliably wake the devices I care about and trust the app's status without editing code or fighting the UI.
**Current focus:** Milestone v1.4 — define requirements and roadmap for duration UI polish

## Current Position

Phase: not started (defining requirements)
Plan: —
Status: Defining requirements
Last activity: 2026-04-16 -- milestone v1.4 started for duration-manager UI polish

Progress: [░░░░░░░░░░] 0/0 plans complete

## Milestone Summary

- Active milestone: `v1.4 Duration UI Polish`
- Latest archived milestone: `v1.3 Duration Management`
- Scope planned: phase numbering continues after Phase 13 with a narrow duration-manager UI polish slice
- Active roadmap: `.planning/ROADMAP.md` (to be created in this milestone setup flow)
- Working files:
  - `.planning/PROJECT.md`
  - `.planning/REQUIREMENTS.md`
  - `.planning/ROADMAP.md`
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

### Roadmap Evolution

- Phase 12.1 inserted after Phase 12: macOS 14.8.3 compatibility support (URGENT)
- Phase 12.1 planned as a single compatibility-truth fix covering deployment target, doc alignment, and explicit Sonoma verification boundary
- Milestone v1.4 started: refine the duration-management list using native list semantics and semantic edit/delete action colors

### Open Follow-Up Themes

- Define v1.4 requirements and create the new roadmap.

## Session Continuity

Last session: 2026-04-16T10:05:00+08:00
Stopped at: Milestone v1.4 started; requirements and roadmap are being defined
Resume file: .planning/PROJECT.md
