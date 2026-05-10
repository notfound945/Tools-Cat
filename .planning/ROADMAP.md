# Roadmap: Tools Cat

## Milestones

- ✅ **v1.0 MVP** — Phases 1-5 shipped 2026-04-13. Archive: `.planning/milestones/v1.0-ROADMAP.md`
- ✅ **v1.1 Hardening** — Phases 6-9 shipped 2026-04-13. Archive: `.planning/milestones/v1.1-ROADMAP.md`
- ✅ **v1.2 Menu Truth** — Phases 10-11 shipped 2026-04-15. Archive: `.planning/milestones/v1.2-ROADMAP.md`
- ✅ **v1.3 Duration Management** — Phases 12-13 shipped 2026-04-16. Archive: `.planning/milestones/v1.3-ROADMAP.md`
- ✅ **v1.4 Duration UI Polish** — Phase 14 shipped 2026-04-16. Archive: `.planning/milestones/v1.4-ROADMAP.md`
- ✅ **v1.5 Device Library UI Parity** — Phase 15 shipped 2026-04-16. Archive: `.planning/milestones/v1.5-ROADMAP.md`
- ✅ **v1.6 Distribution Hardening** — Phases 16-18 shipped 2026-04-19. Archive: `.planning/milestones/v1.6-ROADMAP.md`
- ✅ **v1.7 WOL Device Entry Polish** — Phases 19-21 shipped 2026-05-06. Archive: `.planning/milestones/v1.7-ROADMAP.md`
- ✅ **v1.8 WOL Feedback Guardrails** — Phases 22-23 shipped 2026-05-07. Archive: `.planning/milestones/v1.8-ROADMAP.md`

## Overview

This milestone adds one narrow layer of truthful feedback to the already-shipped timed keep-awake flow. The app already knows exactly when a timed session will end, but that truth currently stays trapped in the menu bar countdown. v1.9 exposes that same timing through Apple-native local notifications: one reminder shortly before expiry when there is enough time left, and one reminder when the session actually ends. The milestone must keep reminder delivery aligned with the active timed session and must stay honest when notification permission is unavailable, without turning into a broader notification-settings project.

## Phases

**Phase Numbering:**
- Integer phases continue from the last shipped milestone
- v1.9 therefore starts at Phase 24

- [x] **Phase 24: Timed Reminder Scheduling** - Add local notification authorization, pre-expiry reminder scheduling, and stale-reminder cancellation that stay aligned with the active timed keep-awake session. (completed 2026-05-09)
- [x] **Phase 25: Expiry Reminder Truth** - Deliver the end-of-session reminder and make notification-unavailable states visible without breaking the existing timed keep-awake truth boundary. (completed 2026-05-10)

## Phase Details

### Phase 24: Timed Reminder Scheduling
**Goal**: The app can request local-notification permission when needed and keep pre-expiry reminder scheduling tied to the currently active timed keep-awake session.
**Depends on**: Phase 23
**Requirements**: NOTF-01, NOTF-02, NOTF-04
**Plans**: 1/1 plans complete
**Success Criteria** (what must be TRUE):
  1. Starting a timed keep-awake session that has more than two minutes remaining schedules exactly one local reminder for about two minutes before the session ends.
  2. Starting a timed keep-awake session with two minutes or less remaining skips the pre-expiry reminder instead of sending an immediate or misleading notification.
  3. Replacing a timed session, stopping it early, or switching to `无限常亮` cancels stale scheduled reminders so only the currently active timed session can still notify.
Plans:
- [x] `24-01-PLAN.md` — Add launch-time notification authorization plus session-scoped pre-expiry reminder scheduling, skip, and stale-cancellation truth. Summary: `.planning/phases/24-timed-reminder-scheduling/24-01-SUMMARY.md`

### Phase 25: Expiry Reminder Truth
**Goal**: Timed keep-awake ending now produces one truthful local notification, and reminder-unavailable states stay visible to the user without breaking keep-awake behavior.
**Depends on**: Phase 24
**Requirements**: NOTF-03, NOTF-05
**Plans**: 1/1 plans complete
**Success Criteria** (what must be TRUE):
  1. When a timed keep-awake session actually reaches its end and turns off, the app sends one local notification that the session has ended.
  2. If local notifications are denied or otherwise unavailable, timed keep-awake still starts, counts down, and ends correctly while the app surfaces that reminder delivery is unavailable.
  3. The end reminder never fires for an older replaced session or for a session the user already stopped manually.
Plans:
- [x] `25-01-PLAN.md` — Extend the existing reminder scheduler and keep-awake session truth so confirmed timed expiry sends one `.expiry` notification, unavailable reminder state stays visible in the current keep-awake status area, and the menu surface remains unchanged. Summary: `.planning/phases/25-expiry-reminder-truth/25-01-SUMMARY.md`

## Progress

**Execution Order:**
Phases execute in numeric order: 24, 25

| Phase | Plans Complete | Status | Completed |
|-------|----------------|--------|-----------|
| 24. Timed Reminder Scheduling | 1/1 | Complete    | 2026-05-10 |
| 25. Expiry Reminder Truth | 1/1 | Complete    | 2026-05-10 |
