# Roadmap: Tools Cat

## Milestones

- ✅ **v1.0 MVP** — Phases 1-5 shipped 2026-04-13. Archive: `.planning/milestones/v1.0-ROADMAP.md`
- ✅ **v1.1 Hardening** — Phases 6-9 shipped 2026-04-13. Archive: `.planning/milestones/v1.1-ROADMAP.md`
- ✅ **v1.2 Menu Truth** — Phases 10-11 shipped 2026-04-15. Archive: `.planning/milestones/v1.2-ROADMAP.md`
- ✅ **v1.3 Duration Management** — Phases 12-13 shipped 2026-04-16. Archive: `.planning/milestones/v1.3-ROADMAP.md`
- ✅ **v1.4 Duration UI Polish** — Phase 14 shipped 2026-04-16. Archive: `.planning/milestones/v1.4-ROADMAP.md`
- ✅ **v1.5 Device Library UI Parity** — Phase 15 shipped 2026-04-16

## Overview

This milestone keeps scope deliberately narrow. The saved-device CRUD and wake behavior already shipped; the next step is to make the `设备库` manager feel like the same family of native management surface as `常亮时长`: native list semantics, compact in-place add/edit presentation, and semantic edit/delete affordances without reopening device-truth logic.

## Phases

**Phase Numbering:**
- Integer phases continue from the last shipped milestone
- v1.5 therefore starts at Phase 15

- [x] **Phase 15: Device Library UI Parity** - Align the device-library management surface with the duration manager's native list and semantic action styling. (completed 2026-04-16)

## Phase Details

### Phase 15: Device Library UI Parity
**Goal**: The `设备库` manager feels visually and behaviorally aligned with the shipped `常亮时长` manager without changing saved-device truth.
**Depends on**: Phase 14
**Requirements**: DEVS-06, DEVS-07, DEVS-08, DEVS-09
**Plans**: 2/2 plans complete
**Success Criteria** (what must be TRUE):
  1. Saved WOL devices render inside a clearly native list surface instead of the current custom stacked list treatment.
  2. Add/edit flows use a compact in-place management presentation that keeps the list context visible, matching the duration manager's current pattern.
  3. Edit uses accent semantics and delete uses destructive red semantics so device actions match the duration manager at a glance.
  4. Existing add, edit, delete, reorder, and direct-launch management behavior remain truthful after the UI polish.

## Progress

**Execution Order:**
Phases execute in numeric order: 15

| Phase | Plans Complete | Status | Completed |
|-------|----------------|--------|-----------|
| 15. Device Library UI Parity | 2/2 | Complete | 2026-04-16 |
