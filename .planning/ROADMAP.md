# Roadmap: Tools Cat

## Milestones

- ✅ **v1.0 MVP** — Phases 1-5 shipped 2026-04-13. Archive: `.planning/milestones/v1.0-ROADMAP.md`
- ✅ **v1.1 Hardening** — Phases 6-9 shipped 2026-04-13. Archive: `.planning/milestones/v1.1-ROADMAP.md`
- ✅ **v1.2 Menu Truth** — Phases 10-11 shipped 2026-04-15. Archive: `.planning/milestones/v1.2-ROADMAP.md`
- ✅ **v1.3 Duration Management** — Phases 12-13 shipped 2026-04-16. Archive: `.planning/milestones/v1.3-ROADMAP.md`
- 🚧 **v1.4 Duration UI Polish** — Phase 14 complete, milestone ready for archive

## Overview

This milestone keeps scope intentionally narrow. The duration-management behavior shipped in v1.3 stays intact; the next step is to make the `常亮时长` timed-duration area feel more obviously native and scannable. The preferred route is to lean on built-in macOS list or table presentation, then make the edit and delete affordances visually self-explanatory through semantic action colors.

## Phases

**Phase Numbering:**
- Integer phases continue from the last shipped milestone
- v1.4 therefore starts at Phase 14

- [x] **Phase 14: Duration Management UI Polish** - Refine the managed-duration list with native macOS list semantics and explicit edit/delete action styling. (completed 2026-04-16)

## Phase Details

### Phase 14: Duration Management UI Polish
**Goal**: The `常亮时长` manager feels unmistakably native and communicates action intent clearly without changing the shipped duration behavior.
**Depends on**: Phase 13
**Requirements**: AWAKE-14, AWAKE-15, AWAKE-16
**Plans**: 2/2 plans complete
**Success Criteria** (what must be TRUE):
  1. Managed durations render inside a clearly native macOS list or table presentation instead of visually blending into the window background.
  2. Edit affordances use the app accent/theme color and delete affordances use destructive red semantics so the two actions are distinguishable at a glance.
  3. Existing add, edit, delete, sorting, and live root-menu synchronization behavior remain truthful after the UI polish.

## Progress

**Execution Order:**
Phases execute in numeric order: 14

| Phase | Plans Complete | Status | Completed |
|-------|----------------|--------|-----------|
| 14. Duration Management UI Polish | 2/2 | Complete | 2026-04-16 |
