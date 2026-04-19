# Roadmap: Tools Cat

## Milestones

- ✅ **v1.0 MVP** — Phases 1-5 shipped 2026-04-13. Archive: `.planning/milestones/v1.0-ROADMAP.md`
- ✅ **v1.1 Hardening** — Phases 6-9 shipped 2026-04-13. Archive: `.planning/milestones/v1.1-ROADMAP.md`
- ✅ **v1.2 Menu Truth** — Phases 10-11 shipped 2026-04-15. Archive: `.planning/milestones/v1.2-ROADMAP.md`
- ✅ **v1.3 Duration Management** — Phases 12-13 shipped 2026-04-16. Archive: `.planning/milestones/v1.3-ROADMAP.md`
- ✅ **v1.4 Duration UI Polish** — Phase 14 shipped 2026-04-16. Archive: `.planning/milestones/v1.4-ROADMAP.md`
- ✅ **v1.5 Device Library UI Parity** — Phase 15 shipped 2026-04-16. Archive: `.planning/milestones/v1.5-ROADMAP.md`
- ✅ **v1.6 Distribution Hardening** — Phases 16-18 shipped 2026-04-19. Archive: `.planning/milestones/v1.6-ROADMAP.md`
- 🚧 **v1.7 Convenience Shortcuts** — Phases 19-21 planned 2026-04-19

## Overview

This milestone returns to the product surface after distribution hardening. `Tools Cat` already has truthful wake and keep-awake behavior; the remaining daily friction is convenience. The app already persists recent wake metadata and managed keep-awake durations, so the milestone should expose faster repeat actions and richer recognition without reopening the shipped wake/menu/session contracts.

## Phases

**Phase Numbering:**
- Integer phases continue from the last shipped milestone
- v1.7 therefore starts at Phase 19

- [ ] **Phase 19: Recent Wake Shortcuts** - Surface a short root-menu recent-devices area from existing wake metadata while keeping `快速 WOL` and `发送 WOL …` as the durable wake contract.
- [ ] **Phase 20: One-Off Keep-Awake** - Add a transient timed keep-awake action that does not persist or reorder managed durations.
- [ ] **Phase 21: Duration Labels and Notes** - Extend managed durations with optional recognition metadata while preserving current sorting, session truth, and native management flows.

## Phase Details

### Phase 19: Recent Wake Shortcuts
**Goal**: The root menu exposes a compact recent-device shortcut area that makes repeat wakes faster while keeping the shipped wake surface structure truthful and restrained.
**Depends on**: Phase 18
**Requirements**: CONV-04
**Plans**: 0/0 plans complete
**Success Criteria** (what must be TRUE):
  1. The root menu surfaces up to three recent-device shortcuts only when successful wake history exists, and hides that shortcut area otherwise.
  2. Recent shortcut rows dispatch through the shared WOL session, disable during in-flight sends, and coexist cleanly with `快速 WOL` plus `发送 WOL …`.
  3. Successful wakes continue to update recency ordering without reviving the removed shortcut-first or all-devices-root wake model.

### Phase 20: One-Off Keep-Awake
**Goal**: The user can start one temporary timed keep-awake session without turning that duration into persisted managed data.
**Depends on**: Phase 19
**Requirements**: AWAKE-12
**Plans**: 0/0 plans complete
**Success Criteria** (what must be TRUE):
  1. The user can choose a one-off timed keep-awake duration through a native flow without adding that duration to the managed list.
  2. The one-off session uses the same keep-awake confirmation, countdown, stop, and expiry truth as the existing timed actions.
  3. Managed duration persistence, ordering, and root-menu rows remain unchanged after one-off use and across relaunch.

### Phase 21: Duration Labels and Notes
**Goal**: Managed keep-awake durations carry richer user-facing metadata so the user can recognize them faster without losing canonical duration truth.
**Depends on**: Phase 20
**Requirements**: AWAKE-13
**Plans**: 0/0 plans complete
**Success Criteria** (what must be TRUE):
  1. The user can create or edit optional labels or notes for managed durations in the existing native management flow.
  2. Menu and management surfaces show richer recognition metadata without obscuring the canonical duration value.
  3. Sorting, activation state, countdown/status presentation, and duration persistence all remain correct after metadata changes.

## Progress

**Execution Order:**
Phases execute in numeric order: 19, 20, 21

| Phase | Plans Complete | Status | Completed |
|-------|----------------|--------|-----------|
| 19. Recent Wake Shortcuts | 0/0 | Not started | - |
| 20. One-Off Keep-Awake | 0/0 | Not started | - |
| 21. Duration Labels and Notes | 0/0 | Not started | - |
