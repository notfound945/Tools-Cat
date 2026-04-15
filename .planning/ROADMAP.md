# Roadmap: Tools Cat

## Milestones

- ✅ **v1.0 MVP** — Phases 1-5 shipped 2026-04-13. Archive: `.planning/milestones/v1.0-ROADMAP.md`
- ✅ **v1.1 Hardening** — Phases 6-9 shipped 2026-04-13. Archive: `.planning/milestones/v1.1-ROADMAP.md`
- 🚧 **v1.2 Menu Truth** — Phases 10-11 complete and ready for milestone archive

## Overview

This milestone is intentionally small. It fixes one keep-awake menu truth leak that remained after the hardening pass: when keep-awake is already off, the root menu still shows `关闭常亮` even though there is nothing to stop. The milestone keeps the existing timed / indefinite model and only tightens which keep-awake actions are visible in idle versus active states. Phase 11 then closes the remaining audit gap by adding the missing Phase 10 verification artifact, restoring requirement traceability, and refreshing the milestone audit into a passing state.

## Phases

**Phase Numbering:**
- Integer phases continue from the last shipped milestone
- v1.2 therefore starts at Phase 10 and now includes Phase 11 for audit-driven verification closure

- [x] **Phase 10: Keep-Awake Menu Truth** - Make the keep-awake action group truthful in idle and active states without reopening the broader menu structure.
- [x] **Phase 11: Menu Truth Verification Closure** - Close the remaining milestone-audit gap by adding formal Phase 10 verification and requirement traceability evidence. (completed 2026-04-15)

## Phase Details

### Phase 10: Keep-Awake Menu Truth
**Goal**: Users only see keep-awake actions that are truthful for the current state, so idle menus stop advertising a meaningless stop row while active sessions still keep a clear stop path.
**Depends on**: Phase 9
**Requirements**: MENU-01, MENU-02, MENU-03
**Success Criteria** (what must be TRUE):
  1. When keep-awake is off and no transition is pending, the root menu omits `关闭常亮`.
  2. When keep-awake is active or currently stopping, the root menu still exposes `关闭常亮` as the direct manual stop action.
  3. Existing indefinite and timed start rows remain available and truthful, and focused regression coverage locks the new visibility contract.
**Plans**: 2/2 plans complete
Plans:
- [x] 10-01-PLAN.md — Rework keep-awake row visibility so `关闭常亮` only appears in actionable states
- [x] 10-02-PLAN.md — Add regression coverage and validation updates for idle-versus-active keep-awake menu truth

### Phase 11: Menu Truth Verification Closure
**Goal**: Close the remaining v1.2 audit gap so the milestone can pass completion checks without accepting process debt.
**Depends on**: Phase 10
**Requirements**: MENU-01, MENU-02, MENU-03
**Gap Closure**: Closes the missing `10-VERIFICATION.md` artifact and the open requirements traceability loop identified by `v1.2-MILESTONE-AUDIT.md`.
**Success Criteria** (what must be TRUE):
  1. Phase 10 has a `10-VERIFICATION.md` that maps MENU-01 through MENU-03 to concrete shipped evidence.
  2. `REQUIREMENTS.md` and milestone traceability no longer show MENU-01 through MENU-03 as orphaned pending requirements.
  3. Re-running `$gsd-audit-milestone` for v1.2 passes without critical gaps.
**Plans**: 1/1 plans complete
Plans:
- [x] 11-01-PLAN.md — Create the missing Phase 10 verification artifact and close Menu Truth requirements traceability

## Progress

**Execution Order:**
Phases execute in numeric order: 10 → 11

| Phase | Plans Complete | Status | Completed |
|-------|----------------|--------|-----------|
| 10. Keep-Awake Menu Truth | 2/2 | Complete | 2026-04-15 |
| 11. Menu Truth Verification Closure | 1/1 | Complete | 2026-04-15 |
