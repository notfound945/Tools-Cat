# Requirements: Tools Cat

**Defined:** 2026-04-13
**Core Value:** From the menu bar, I can reliably wake the devices I care about and trust the app's status without editing code or fighting the UI.

## v1 Requirements

Requirements for the v1.2 menu-truth milestone. This milestone keeps scope tight: it fixes keep-awake action truth in the menu instead of reopening the broader menu architecture, then closes the verification and traceability loop needed to archive the milestone cleanly.

### Menu Truth

- [ ] **MENU-01**: User does not see `关闭常亮` in the menu when keep-awake is already off and no keep-awake stop transition is running
- [ ] **MENU-02**: User still sees one direct `关闭常亮` action whenever infinite or timed keep-awake is active so the session can be ended from the menu
- [ ] **MENU-03**: User sees keep-awake menu rows whose visible actions match the real current keep-awake state without losing the existing start actions or truthful status feedback

## v2 Requirements

Deferred until after the menu-truth milestone is complete.

### Convenience

- **CONV-04**: User can access a short recent-devices list for faster repeat wake actions

### Distribution

- **DIST-01**: App can move toward packaging hardening such as signing or notarization once the maintenance baseline is stable

## Out of Scope

Explicitly excluded to keep v1.2 focused on one keep-awake truth correction.

| Feature | Reason |
|---------|--------|
| Reordering the full root menu or redesigning the WOL section | The milestone only corrects keep-awake action truth |
| New keep-awake presets, shortcuts, or notifications | Not required to fix the misleading idle stop action |
| Signing, notarization, or broader release automation work | Separate release-trust milestone |

## Traceability

Which phases cover which requirements. Updated during roadmap creation.

| Requirement | Phase | Status |
|-------------|-------|--------|
| MENU-01 | Phase 11 | Pending |
| MENU-02 | Phase 11 | Pending |
| MENU-03 | Phase 11 | Pending |

**Coverage:**
- v1 requirements: 3 total
- Mapped to phases: 3
- Unmapped: 0

---
*Requirements defined: 2026-04-13*
*Last updated: 2026-04-15 after adding the v1.2 verification-closure phase*
