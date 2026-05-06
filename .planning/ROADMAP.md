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

## Overview

This milestone tightens two small interaction seams in the already-shipped WOL flow. Wake feedback should feel transient instead of lingering in the window and menu forever, and the saved-device add/edit sheet should stop presenting an actionable `保存设备` button before the user has filled the two required fields. The goal is to align those affordances with the app's current validation and management patterns without reopening the underlying WOL or validation contracts.

## Phases

**Phase Numbering:**
- Integer phases continue from the last shipped milestone
- v1.8 therefore starts at Phase 22

- [x] **Phase 22: WOL Result Timeout** - Make WOL send result feedback in both the WOL window and the menu-bar wake section disappear automatically after three seconds. (completed 2026-05-06)
- [ ] **Phase 23: Device Form Save Guard** - Enable the saved-device `保存设备` button only after both required fields contain input while preserving the current delayed validation reveal behavior.

## Phase Details

### Phase 22: WOL Result Timeout
**Goal**: WOL send feedback stays visible long enough to confirm the action, then disappears automatically from both the WOL window and menu bar without manual cleanup.
**Depends on**: Phase 21
**Requirements**: WOLF-01, WOLF-02
**Plans**: 1/1 plans complete
Plans:
- [x] `22-01-PLAN.md` — Stabilize the shared WOL result-timeout seam in `WOLSessionModel` and lock menu/window expiry coverage. Summary: `22-01-SUMMARY.md`
**Success Criteria** (what must be TRUE):
  1. A successful or failed WOL result remains visible in the WOL window for approximately three seconds, then disappears automatically.
  2. The same WOL result remains visible in the menu-bar wake status row for approximately three seconds, then disappears automatically.
  3. Starting a new wake action cancels any stale result timeout so newer feedback is never cleared by an older timer.

### Phase 23: Device Form Save Guard
**Goal**: The saved-device add/edit form only exposes an actionable `保存设备` button after the user has entered the two required fields, while preserving the current validation and save-truth contract.
**Depends on**: Phase 22
**Requirements**: DEVS-15, DEVS-16
**Plans**: 0/1 plans complete
Plans:
- [ ] `23-01-PLAN.md` — Gate the saved-device `保存设备` button on trimmed required-field presence while preserving delayed validation reveal and save-time validation truth.
**Success Criteria** (what must be TRUE):
  1. `保存设备` is disabled when either the name field or MAC field is still empty.
  2. `保存设备` becomes enabled once both fields contain input, even though deeper validation still runs at the existing save boundary.
  3. The v1.7 delayed validation-message reveal behavior remains unchanged: validation text still appears only on blur or explicit submit, not during ordinary in-progress typing.

## Progress

**Execution Order:**
Phases execute in numeric order: 22, 23

| Phase | Plans Complete | Status | Completed |
|-------|----------------|--------|-----------|
| 22. WOL Result Timeout | 1/1 | Complete    | 2026-05-06 |
| 23. Device Form Save Guard | 0/1 | Not Started | — |
