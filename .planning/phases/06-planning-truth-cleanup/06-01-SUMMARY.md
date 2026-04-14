---
phase: 06-planning-truth-cleanup
plan: 01
subsystem: docs
tags: [planning, documentation, audit, wol]
requires:
  - phase: 05-native-menu-polish
    provides: "The shipped v1.0 wake menu structure that this plan restates in current-facing docs"
provides:
  - "Current-facing project docs now describe the shipped `快速 WOL` and `发送 WOL …` wake surface first"
  - "The archived v1.0 milestone audit now labels stale wake-surface wording as non-blocking documentation debt"
affects: [06-02-PLAN, 06-03-PLAN, STATE.md, ROADMAP.md]
tech-stack:
  added: []
  patterns: [current-truth-first planning docs, non-blocking debt framing for stale archive wording]
key-files:
  created: [.planning/phases/06-planning-truth-cleanup/06-01-SUMMARY.md]
  modified: [.planning/PROJECT.md, .planning/milestones/v1.0-MILESTONE-AUDIT.md]
key-decisions:
  - "Project-facing docs now lead with the shipped `快速 WOL` plus `发送 WOL …` structure instead of the removed root-level recents model."
  - "Recent-device shortcut recovery remains explicitly deferred as `CONV-04`, not presented as shipped v1.0 behavior."
  - "The v1.0 audit keeps `tech_debt` status and treats wake-surface doc drift as non-blocking debt rather than a blocker."
patterns-established:
  - "When milestone scope changes after shipping, current-facing planning docs should be rewritten in place so maintainers see current truth first."
  - "Archived audits may keep historical context, but stale product wording must be framed as debt rather than an active blocker once scope changes are final."
requirements-completed: [DOC-01, DOC-03]
duration: 2min
completed: 2026-04-13
---

# Phase 6 Plan 1: Planning Truth Cleanup Summary

**Project and audit docs now describe the shipped `快速 WOL` wake surface with the dedicated `发送 WOL …` row, while deferring shortcut recovery to `CONV-04` as non-blocking debt**

## Performance

- **Duration:** 2 min
- **Started:** 2026-04-13T07:50:39Z
- **Completed:** 2026-04-13T07:52:37Z
- **Tasks:** 1
- **Files modified:** 2

## Accomplishments
- Rewrote `.planning/PROJECT.md` so current-state, milestone, context, and key-decision wording match the shipped `快速 WOL` plus `发送 WOL …` structure.
- Reframed the archived v1.0 audit so stale wake-surface wording is explicitly documented as non-blocking debt, not a shipped blocker.
- Kept future shortcut recovery clearly deferred as `CONV-04` instead of mixing it back into current v1.0 truth.

## Task Commits

Each task was committed atomically:

1. **Task 1: Rewrite current-facing project and audit wording around the shipped wake surface** - `e88d242` (fix)

## Files Created/Modified
- `.planning/PROJECT.md` - Restates current shipped wake-surface truth and removes the stale root-level recents decision from current-facing project context.
- `.planning/milestones/v1.0-MILESTONE-AUDIT.md` - Clarifies that wake-surface doc drift is non-blocking debt and names the current shipped menu structure.
- `.planning/phases/06-planning-truth-cleanup/06-01-SUMMARY.md` - Records execution details, task commit, and plan decisions.

## Decisions Made
- Lead with current wake-surface truth in project docs instead of preserving superseded Phase 3 wording as present tense.
- Keep `CONV-04` as the only forward reference for recent-device shortcut recovery.
- Tighten the v1.0 audit wording without changing its `tech_debt` verdict or pulling Phase 7/8 work into this plan.

## Deviations from Plan

None - plan executed exactly as written.

## Issues Encountered

- Parallel worktree activity changed `HEAD` after the task commit, so the task commit hash was recorded explicitly from the task commit rather than assuming the latest commit still belonged to this plan.

## User Setup Required

None - no external service configuration required.

## Next Phase Readiness

- The current project and milestone-audit surfaces now reflect the shipped v1.0 wake structure and debt framing required by `DOC-01` and `DOC-03`.
- Phase 06 can continue with the remaining verification-file cleanup plans without re-litigating the shipped wake-surface truth.

---
*Phase: 06-planning-truth-cleanup*
*Completed: 2026-04-13*

## Self-Check: PASSED
