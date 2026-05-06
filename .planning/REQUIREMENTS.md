# Requirements: Tools Cat

**Defined:** 2026-05-06
**Core Value:** From the menu bar, I can reliably wake the devices I care about and trust the app's status without editing code or fighting the UI.

## v1 Requirements

Requirements for the v1.7 WOL device-entry polish milestone. This milestone stays tightly scoped to saved-device onboarding and form feedback timing: the underlying validation rules and wake/menu truth remain the same, but the device-library form should stop warning too early and a brand-new empty library should get one practical default device.

### Device Entry Experience

- [x] **DEVS-10**: User sees the saved-device name required-field hint only after the name field loses focus or is explicitly submitted
- [x] **DEVS-11**: User sees saved-device MAC validation hints only after the MAC field loses focus or is explicitly submitted
- [x] **DEVS-12**: User still cannot save a saved-device draft with an invalid name or invalid MAC address even when inline validation reveal is deferred

### Device Library Seeding

- [x] **DEVS-13**: First-use empty saved-device libraries seed exactly one default device named `UGREEN NAS` with MAC address `6C:1F:F7:75:C7:0E`
- [x] **DEVS-14**: Existing non-empty saved-device libraries are never modified by the default-device seed path

## v2 Requirements

Deferred until after the v1.7 device-entry polish milestone is complete.

### Convenience

- **CONV-04**: User can access a short recent-devices list for faster repeat wake actions
- **AWAKE-12**: User can create a one-off timed keep-awake duration without saving it into the managed list
- **AWAKE-13**: User can assign custom labels or notes to managed keep-awake durations

### Distribution

- **DIST-01**: App can move toward packaging hardening such as signing or notarization once the maintenance baseline is stable

## Out of Scope

Explicitly excluded to keep v1.7 focused on saved-device form timing and first-use seeding.

| Feature | Reason |
|---------|--------|
| Rewriting the MAC or name validation rules themselves | The issue is when validation appears, not what counts as valid input |
| Weakening save-time validation so invalid drafts can slip through | Save must remain the final truth boundary for device correctness |
| Seeding the default NAS device into an already non-empty library | This milestone only fixes first-use empty-library onboarding |
| Changing the shipped `快速 WOL` / `发送 WOL …` wake surface | Menu wake behavior is already shipped and not being reopened here |
| Pulling in third-party form/state libraries for blur tracking | The existing native SwiftUI/AppKit stack should be enough for this scope |

## Traceability

Phase mapping assigned during roadmap creation.

| Requirement | Phase | Status |
|-------------|-------|--------|
| DEVS-10 | Phase 19 | Complete |
| DEVS-11 | Phase 19 | Complete |
| DEVS-12 | Phase 19 | Complete |
| DEVS-13 | Phase 20 | Complete |
| DEVS-14 | Phase 20 | Complete |

**Coverage:**
- v1 requirements: 5 total
- Mapped to phases: 5
- Unmapped: 0 ✓

---
*Requirements defined: 2026-05-06*
*Last updated: 2026-05-06 after Phase 21 verification closure execution*
