# Roadmap: Tools Cat

## Milestones

- ✅ **v1.0 MVP** — Phases 1-5 shipped 2026-04-13. Archive: `.planning/milestones/v1.0-ROADMAP.md`
- ✅ **v1.1 Hardening** — Phases 6-9 shipped 2026-04-13. Archive: `.planning/milestones/v1.1-ROADMAP.md`
- ✅ **v1.2 Menu Truth** — Phases 10-11 shipped 2026-04-15. Archive: `.planning/milestones/v1.2-ROADMAP.md`
- 🚧 **v1.3 Duration Management** — Phases 12-14 in progress

## Overview

This milestone extends the keep-awake menu without reopening its broader truth contract. Instead of hardcoding four timed presets forever, the app will treat timed durations as managed user data: seeded with sensible defaults, editable through a dedicated management flow, persisted across relaunch, and rendered into the keep-awake menu in ascending duration order after the fixed `无限常亮` row.

## Phases

**Phase Numbering:**
- Integer phases continue from the last shipped milestone
- v1.3 therefore starts at Phase 12

- [x] **Phase 12: Duration Preset Persistence** - Establish the persisted keep-awake duration list, default seeded presets, and validation rules. (completed 2026-04-15)
- [x] **Phase 12.1: macOS 14.8.3 Compatibility Support** - Restore runtime support for macOS 14.8.3 by aligning the deployment target and shipped app baseline. (completed 2026-04-15)
- [ ] **Phase 13: Duration Management Surface** - Let users add, edit, and delete managed keep-awake durations from a dedicated native flow. (UAT found one cosmetic list-surface gap; 13-04 ready to execute)
- [ ] **Phase 14: Managed Duration Menu Integration** - Render the keep-awake menu from the managed duration list while keeping `无限常亮` fixed first.

## Phase Details

### Phase 12: Duration Preset Persistence
**Goal**: The app owns timed keep-awake durations as persisted, validated data instead of hardcoded menu rows.
**Depends on**: Phase 11
**Requirements**: AWAKE-06, AWAKE-10, AWAKE-11
**Plans**: 2/2 plans complete
Plans:
- [x] 12-01-PLAN.md - Persist managed keep-awake durations with exact-once seeding, normalization, and validation.
- [x] 12-02-PLAN.md - Migrate keep-awake timed state off the preset enum and keep the current root menu as a fixed-row bridge.
**Success Criteria** (what must be TRUE):
  1. A duration store exists and seeds `15 分钟`, `30 分钟`, `1 小时`, and `2 小时` exactly once for existing users.
  2. Invalid or duplicate managed durations cannot be saved.
  3. Managed durations persist across relaunch and reload in sorted order.

### Phase 12.1: macOS 14.8.3 compatibility support (INSERTED)

**Goal:** Restore app launch support on macOS 14.8.3 without reopening broader product scope.
**Requirements**: TBD
**Depends on:** Phase 12
**Plans:** 1/1 plans complete

Plans:
- [x] 12.1-01-PLAN.md - Align the deployment target, documentation truth, and compatibility verification boundary for macOS 14.8.3 support.
**Success Criteria** (what must be TRUE):
  1. The Xcode project no longer declares macOS 15.6 as the minimum deployment target for the app or test targets.
  2. Repo guidance now matches the 14.x compatibility baseline instead of describing 15.6-only support.
  3. Compatibility evidence clearly separates automated build proof from the manual-only real macOS 14.8.3 launch smoke.

### Phase 13: Duration Management Surface
**Goal**: Users can manage timed keep-awake durations themselves through a small native management flow.
**Depends on**: Phase 12, Phase 12.1
**Requirements**: AWAKE-05, AWAKE-06, AWAKE-07, AWAKE-08, AWAKE-09
**Plans**: 3/4 plans complete
Plans:
- [x] 13-01-PLAN.md - Build the store-backed duration-management session model and CRUD validation contract.
- [x] 13-02-PLAN.md - Add the native duration-management window, direct-launch coverage, and status-menu entry wiring.
- [x] 13-03-PLAN.md - Close UAT gaps for keep-awake menu placement, compact add/edit modal flow, and live root-menu synchronization.
- [ ] 13-04-PLAN.md - Give the timed-duration area a distinct native list surface so it no longer blends into the window background.
**Success Criteria** (what must be TRUE):
  1. User can open a duration-management surface and inspect the current managed duration list.
  2. User can add or edit a managed duration and see the list update into the correct sorted position after save.
  3. User can delete a managed duration, while `无限常亮` remains fixed and unavailable for deletion.
  4. The root keep-awake menu immediately reflects managed-duration CRUD truth in sorted order, with `管理常亮时长…` grouped at the bottom of the keep-awake section.

### Phase 14: Managed Duration Menu Integration
**Goal**: The keep-awake menu consumes the managed duration list while preserving the current truthful menu structure.
**Depends on**: Phase 12, Phase 13
**Requirements**: AWAKE-05
**Status Note**: Most planned scope was pulled forward into Phase 13 gap closure. Re-evaluate after `$gsd-verify-work 13` before creating any new plans here.
**Success Criteria** (what must be TRUE):
  1. `无限常亮` remains the first keep-awake action in the root menu.
  2. All timed keep-awake rows after it come from the managed duration list and are sorted from shortest to longest.
  3. Menu rendering stays truthful and updates correctly after duration-list changes without regressing the existing stop-row truth contract.

## Progress

**Execution Order:**
Phases execute in numeric order: 12 → 12.1 → 13 → 14

| Phase | Plans Complete | Status | Completed |
|-------|----------------|--------|-----------|
| 12. Duration Preset Persistence | 2/2 | Complete   | 2026-04-15 |
| 12.1. macOS 14.8.3 Compatibility Support | 1/1 | Complete   | 2026-04-15 |
| 13. Duration Management Surface | 3/4 | Cosmetic gap plan ready | - |
| 14. Managed Duration Menu Integration | 0/0 | Re-evaluate after Phase 13 verify-work | - |
