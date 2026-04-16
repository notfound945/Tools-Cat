# Requirements: Tools Cat

**Defined:** 2026-04-16
**Core Value:** From the menu bar, I can reliably wake the devices I care about and trust the app's status without editing code or fighting the UI.

## v1 Requirements

Requirements for the v1.5 device-library UI parity milestone. This milestone keeps scope tight: it aligns the WOL device-library management surface with the shipped duration-manager visual language without reopening saved-device data truth or the wake menu contract.

### Device Library UI

- [ ] **DEVS-06**: User sees saved WOL devices inside a clearly native macOS list surface instead of the current custom stacked list treatment
- [ ] **DEVS-07**: User can add or edit a saved WOL device through a compact in-place management presentation that matches the duration manager instead of replacing the entire device-library screen
- [ ] **DEVS-08**: User sees the device-library edit action styled with the app accent/theme color and the delete action styled with destructive red semantics to match the duration manager
- [ ] **DEVS-09**: User can use the polished device-library manager without regressing saved-device add, edit, delete, reorder, or direct-launch management behavior

## v2 Requirements

Deferred until after the device-library UI parity milestone is complete.

### Convenience

- **CONV-04**: User can access a short recent-devices list for faster repeat wake actions
- **AWAKE-12**: User can create a one-off timed keep-awake duration without saving it into the managed list
- **AWAKE-13**: User can assign custom labels or notes to managed keep-awake durations

### Distribution

- **DIST-01**: App can move toward packaging hardening such as signing or notarization once the maintenance baseline is stable

## Out of Scope

Explicitly excluded to keep v1.5 focused on device-library UI parity.

| Feature | Reason |
|---------|--------|
| Reworking saved-device persistence, validation, or reorder truth | Those behavior contracts already shipped and this milestone is presentation-only |
| Changing the shipped `快速 WOL` / `发送 WOL …` wake surface or recent-device behavior | Menu wake behavior remains out of scope for this pass |
| Redesigning the WOL sender window at the same time as the device library | Keep the milestone scoped to one management surface |
| Pulling in a third-party UI library for list or form styling | Native macOS consistency and lower maintenance remain the preferred default |

## Traceability

Phase mapping assigned during roadmap creation.

| Requirement | Phase | Status |
|-------------|-------|--------|
| DEVS-06 | Phase 15 | Pending |
| DEVS-07 | Phase 15 | Pending |
| DEVS-08 | Phase 15 | Pending |
| DEVS-09 | Phase 15 | Pending |

**Coverage:**
- v1 requirements: 4 total
- Mapped to phases: 4
- Unmapped: 0

---
*Requirements defined: 2026-04-16*
*Last updated: 2026-04-16 after defining the v1.5 device-library UI parity scope*
