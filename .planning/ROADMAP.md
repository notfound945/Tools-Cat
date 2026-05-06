# Roadmap: Tools Cat

## Milestones

- ✅ **v1.0 MVP** — Phases 1-5 shipped 2026-04-13. Archive: `.planning/milestones/v1.0-ROADMAP.md`
- ✅ **v1.1 Hardening** — Phases 6-9 shipped 2026-04-13. Archive: `.planning/milestones/v1.1-ROADMAP.md`
- ✅ **v1.2 Menu Truth** — Phases 10-11 shipped 2026-04-15. Archive: `.planning/milestones/v1.2-ROADMAP.md`
- ✅ **v1.3 Duration Management** — Phases 12-13 shipped 2026-04-16. Archive: `.planning/milestones/v1.3-ROADMAP.md`
- ✅ **v1.4 Duration UI Polish** — Phase 14 shipped 2026-04-16. Archive: `.planning/milestones/v1.4-ROADMAP.md`
- ✅ **v1.5 Device Library UI Parity** — Phase 15 shipped 2026-04-16. Archive: `.planning/milestones/v1.5-ROADMAP.md`
- ✅ **v1.6 Distribution Hardening** — Phases 16-18 shipped 2026-04-19. Archive: `.planning/milestones/v1.6-ROADMAP.md`
- 🚧 **v1.7 WOL Device Entry Polish** — Phases 19-20 planned 2026-05-06

## Overview

This milestone returns to one small product-facing gap in the already-shipped saved-device flow. The device library already has native list presentation and stable CRUD truth, but the add/edit form still surfaces validation too early while the user is typing, and a first-use empty library still starts completely blank even though one stable NAS target is known. The goal is to improve form timing and first-use seeding without reopening the shipped wake/menu contract.

## Phases

**Phase Numbering:**
- Integer phases continue from the last shipped milestone
- v1.7 therefore starts at Phase 19

- [ ] **Phase 19: Deferred Device Form Validation** - Make saved-device validation hints appear on blur or explicit field submission while preserving the current save-time truth barrier.
- [ ] **Phase 20: First-Use Device Seed** - Seed one default `UGREEN NAS` device for first-use empty libraries without touching existing non-empty libraries.

## Phase Details

### Phase 19: Deferred Device Form Validation
**Goal**: The `设备库` add/edit form feels native and non-noisy by revealing validation only after blur or explicit submit, while invalid drafts still cannot be saved.
**Depends on**: Phase 18
**Requirements**: DEVS-10, DEVS-11, DEVS-12
**Plans**: 0/0 plans complete
**Success Criteria** (what must be TRUE):
  1. The required-name hint does not appear during in-progress typing and only appears after the user leaves the field or explicitly submits it.
  2. MAC validation hints do not appear during in-progress typing and only appear after the user leaves the field or explicitly submits it.
  3. Tapping save without valid inputs still reveals the correct validation feedback and refuses to persist an invalid saved device.

### Phase 20: First-Use Device Seed
**Goal**: A brand-new empty saved-device library gets one practical default NAS entry exactly once, without mutating existing personal libraries.
**Depends on**: Phase 19
**Requirements**: DEVS-13, DEVS-14
**Plans**: 0/0 plans complete
**Success Criteria** (what must be TRUE):
  1. A first-use empty library automatically contains exactly one saved device named `UGREEN NAS` with normalized MAC `6C:1F:F7:75:C7:0E`.
  2. Reloading after the first-use seed does not duplicate the default device.
  3. Existing non-empty libraries never receive the default seed implicitly.

## Progress

**Execution Order:**
Phases execute in numeric order: 19, 20

| Phase | Plans Complete | Status | Completed |
|-------|----------------|--------|-----------|
| 19. Deferred Device Form Validation | 0/0 | Pending | — |
| 20. First-Use Device Seed | 0/0 | Pending | — |
