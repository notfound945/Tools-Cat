# Requirements: Tools Cat

**Defined:** 2026-04-16
**Core Value:** From the menu bar, I can reliably wake the devices I care about and trust the app's status without editing code or fighting the UI.

## v1 Requirements

Requirements for the v1.4 duration UI polish milestone. This milestone keeps scope tight: it refines the `常亮时长` management surface so the timed-duration list feels more natively macOS and the edit/delete actions communicate their meaning at a glance.

### Keep-Awake Duration UI

- [ ] **AWAKE-14**: User sees managed keep-awake durations inside a clearly native macOS list or table presentation instead of rows blending into the window background
- [ ] **AWAKE-15**: User sees the edit action styled with the app accent/theme color and the delete action styled with destructive red semantics
- [ ] **AWAKE-16**: User can use the polished duration list without regressing existing add, edit, delete, sorting, or live root-menu synchronization behavior

## v2 Requirements

Deferred until after the duration UI polish milestone is complete.

### Convenience

- **CONV-04**: User can access a short recent-devices list for faster repeat wake actions
- **AWAKE-12**: User can create a one-off timed keep-awake duration without saving it into the managed list
- **AWAKE-13**: User can assign custom labels or notes to managed keep-awake durations

### Distribution

- **DIST-01**: App can move toward packaging hardening such as signing or notarization once the maintenance baseline is stable

## Out of Scope

Explicitly excluded to keep v1.4 focused on UI polish for the duration-management surface.

| Feature | Reason |
|---------|--------|
| Reworking managed-duration persistence, validation, or menu ordering | Those behavior contracts shipped in v1.3 and are not being reopened here |
| Reintroducing a separate dynamic-menu integration phase | Live root-menu synchronization already shipped in Phase 13 |
| Adopting a third-party component library before trying native list/table components | Native macOS consistency and lower maintenance are the preferred default for this pass |
| Broad redesign of the WOL or root status menu surfaces | The milestone only polishes the `常亮时长` manager UI |

## Traceability

Phase mapping assigned during roadmap creation.

| Requirement | Phase | Status |
|-------------|-------|--------|
| AWAKE-14 | Phase 14 | Pending |
| AWAKE-15 | Phase 14 | Pending |
| AWAKE-16 | Phase 14 | Pending |

**Coverage:**
- v1 requirements: 3 total
- Mapped to phases: 3
- Unmapped: 0

---
*Requirements defined: 2026-04-16*
*Last updated: 2026-04-16 after defining the v1.4 duration UI polish scope*
