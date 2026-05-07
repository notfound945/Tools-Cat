# Requirements: Tools Cat

**Defined:** 2026-05-06
**Core Value:** From the menu bar, I can reliably wake the devices I care about and trust the app's status without editing code or fighting the UI.

## v1 Requirements

Requirements for the v1.8 WOL feedback guardrails milestone. This milestone is deliberately narrow: it does not add new wake capabilities, but it makes result feedback transient again and aligns the saved-device add/edit affordance with the existing keep-awake duration form.

### Wake Feedback

- [x] **WOLF-01**: User sees a WOL send result in the WOL window for `3 秒`, after which it disappears automatically
- [x] **WOLF-02**: User sees the same WOL send result in the menu-bar wake section for `3 秒`, after which it disappears automatically

### Device Form Guardrails

- [x] **DEVS-15**: User can tap `保存设备` only after both the saved-device name and MAC address fields contain input
- [x] **DEVS-16**: The saved-device form still uses the current delayed validation-message reveal timing and save-time validation truth after the new save-button gating is added

## v2 Requirements

Deferred until after the v1.8 WOL feedback guardrails milestone is complete.

### Convenience

- **CONV-04**: User can access a short recent-devices list for faster repeat wake actions
- **AWAKE-12**: User can create a one-off timed keep-awake duration without saving it into the managed list
- **AWAKE-13**: User can assign custom labels or notes to managed keep-awake durations

### Distribution

- **DIST-01**: App can move toward packaging hardening such as signing or notarization once the maintenance baseline is stable

## Out of Scope

Explicitly excluded to keep v1.8 focused on transient feedback and button-enable affordances.

| Feature | Reason |
|---------|--------|
| Rewriting the WOL success/failure copy | The issue is how long the message stays visible, not what it says |
| Changing the shipped `快速 WOL` / `发送 WOL …` menu structure | This milestone only adjusts feedback timing within the current wake surface |
| Weakening save-time device validation so malformed drafts can be persisted | Save must remain the final truth boundary for device correctness |
| Reopening the delayed validation-message reveal behavior from v1.7 | The issue is button affordance, not when validation text appears |
| Adding new device-library fields or management flows | This pass only tightens the existing add/edit interaction |

## Traceability

Phase mapping assigned during roadmap creation.

| Requirement | Phase | Status |
|-------------|-------|--------|
| WOLF-01 | Phase 22 | Complete |
| WOLF-02 | Phase 22 | Complete |
| DEVS-15 | Phase 23 | Complete |
| DEVS-16 | Phase 23 | Complete |

**Coverage:**
- v1 requirements: 4 total
- Mapped to phases: 4
- Unmapped: 0 ✓

---
*Requirements defined: 2026-05-06*
*Last updated: 2026-05-07 after completing Phase 23*
