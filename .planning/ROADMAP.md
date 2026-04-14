# Roadmap: Tools Cat

## Milestones

- ✅ **v1.0 MVP** — Phases 1-5 shipped 2026-04-13. Archive: `.planning/milestones/v1.0-ROADMAP.md`
- ✅ **v1.1 Hardening** — Phases 6-9 shipped 2026-04-13. Archive: `.planning/milestones/v1.1-ROADMAP.md`
- 🚧 **v1.2 Menu Truth** — Phase 10 planned

## Overview

This milestone is intentionally small. It fixes one keep-awake menu truth leak that remained after the hardening pass: when keep-awake is already off, the root menu still shows `关闭常亮` even though there is nothing to stop. The milestone keeps the existing timed / indefinite model and only tightens which keep-awake actions are visible in idle versus active states.

## Phases

**Phase Numbering:**
- Integer phases continue from the last shipped milestone
- v1.2 therefore starts at Phase 10

- [ ] **Phase 10: Keep-Awake Menu Truth** - Make the keep-awake action group truthful in idle and active states without reopening the broader menu structure.

## Phase Details

### Phase 10: Keep-Awake Menu Truth
**Goal**: Users only see keep-awake actions that are truthful for the current state, so idle menus stop advertising a meaningless stop row while active sessions still keep a clear stop path.
**Depends on**: Phase 9
**Requirements**: MENU-01, MENU-02, MENU-03
**Success Criteria** (what must be TRUE):
  1. When keep-awake is off and no transition is pending, the root menu omits `关闭常亮`.
  2. When keep-awake is active or currently stopping, the root menu still exposes `关闭常亮` as the direct manual stop action.
  3. Existing indefinite and timed start rows remain available and truthful, and focused regression coverage locks the new visibility contract.
**Plans**: 0/2 plans complete
Plans:
- [ ] 10-01-PLAN.md — Rework keep-awake row visibility so `关闭常亮` only appears in actionable states
- [ ] 10-02-PLAN.md — Add regression coverage and validation updates for idle-versus-active keep-awake menu truth

## Progress

**Execution Order:**
Phases execute in numeric order: 10

| Phase | Plans Complete | Status | Completed |
|-------|----------------|--------|-----------|
| 10. Keep-Awake Menu Truth | 0/2 | Not started | - |
