# Requirements: Tools Cat

**Defined:** 2026-04-19
**Core Value:** From the menu bar, I can reliably wake the devices I care about and trust the app's status without editing code or fighting the UI.

## v1 Requirements

Requirements for the v1.7 convenience-shortcuts milestone. This milestone is intentionally incremental: it adds faster repeat actions on top of the shipped wake and keep-awake contracts, using the existing recent-device metadata and managed-duration seams instead of reopening the broader release or truth work.

### Wake Convenience

- [ ] **CONV-04**: User can access a short recent-devices list from the root menu for faster repeat wake actions

### One-Off Keep-Awake

- [ ] **AWAKE-12**: User can start a one-off timed keep-awake session without saving that duration into the managed list

### Duration Metadata

- [ ] **AWAKE-13**: User can assign custom labels or notes to managed keep-awake durations for quicker recognition

## v2 Requirements

Deferred until after the convenience-shortcuts milestone is complete.

### Convenience

- **CONV-01**: User can pin favorite devices separately from recents
- **CONV-02**: User can trigger Wake Last Device with a dedicated keyboard shortcut
- **CONV-03**: User can import or export their saved device list

## Out of Scope

Explicitly excluded to keep v1.7 focused on layering convenience on top of the shipped baseline.

| Feature | Reason |
|---------|--------|
| Restoring the old root-level wake history or replacing `快速 WOL` with a shortcut-first wake structure | The shipped wake contract stays compact; this milestone only adds a small recent shortcut layer |
| Replacing managed keep-awake durations with arbitrary freeform presets | One-off timing should layer on top of the managed-duration model, not replace it |
| Reopening signing, notarization, or broader distribution automation | v1.6 already closed the distribution milestone; this pass is product-surface convenience only |
| Cloud sync or multi-machine profiles for devices and durations | The app remains a local personal utility |

## Traceability

Phase mapping assigned during roadmap creation.

| Requirement | Phase | Status |
|-------------|-------|--------|
| CONV-04 | Phase 19 | Pending |
| AWAKE-12 | Phase 20 | Pending |
| AWAKE-13 | Phase 21 | Pending |

**Coverage:**
- v1 requirements: 3 total
- Mapped to phases: 3
- Unmapped: 0 ✓

---
*Requirements defined: 2026-04-19*
*Last updated: 2026-04-19 after starting v1.7 Convenience Shortcuts*
