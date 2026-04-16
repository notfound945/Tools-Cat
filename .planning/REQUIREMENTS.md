# Requirements: Tools Cat

**Defined:** 2026-04-16
**Core Value:** From the menu bar, I can reliably wake the devices I care about and trust the app's status without editing code or fighting the UI.

## v1 Requirements

Requirements for the v1.6 distribution-hardening milestone. This milestone stays release-only: the goal is to make `Tools Cat` installable for friends through a signed, notarized DMG flow without reopening the shipped wake or keep-awake feature surface.

### Distribution Signing

- [x] **DIST-01**: Maintainer can produce a Developer ID signed `Tools Cat.app` that is suitable for direct distribution outside the Mac App Store
- [ ] **DIST-02**: Maintainer can produce a Developer ID signed `Tools-Cat.dmg` that contains the distributable app bundle

### Notarization

- [ ] **DIST-03**: Maintainer can submit the final DMG to Apple with `notarytool`, wait for completion, and get actionable failure information when notarization is rejected
- [ ] **DIST-04**: The DMG sent to friends is stapled with a successful notarization ticket and passes local Gatekeeper assessment

### Release Operations

- [x] **DIST-05**: Repo documentation explains the required signing identity, notarization credential setup, and release preflight without storing sensitive credentials in the repo
- [ ] **DIST-06**: Repo provides a repeatable local verification path that proves the shipped artifact is ready for friend installation without manual `隐私与安全性` overrides
- [ ] **DIST-07**: Distribution hardening does not change the shipped WOL and keep-awake behavior beyond the release-chain work required for signing and notarization

## v2 Requirements

Deferred until after the distribution-hardening milestone is complete.

### Convenience

- **CONV-04**: User can access a short recent-devices list for faster repeat wake actions
- **AWAKE-12**: User can create a one-off timed keep-awake duration without saving it into the managed list
- **AWAKE-13**: User can assign custom labels or notes to managed keep-awake durations

## Out of Scope

Explicitly excluded to keep v1.6 focused on friend-installable direct distribution.

| Feature | Reason |
|---------|--------|
| New end-user WOL or keep-awake features during the release-hardening pass | This milestone is only about distribution and installability |
| Mac App Store submission or review preparation | The target outcome is direct friend-to-friend distribution, not App Store release |
| Auto-update framework integration | Useful later, but not required to solve manual install approval friction |
| CI/CD-first release automation | A stable local signing/notarization flow should exist before remote automation is added |

## Traceability

Phase mapping assigned during roadmap creation.

| Requirement | Phase | Status |
|-------------|-------|--------|
| DIST-01 | Phase 16 | Complete |
| DIST-02 | Phase 17 | Pending |
| DIST-03 | Phase 17 | Pending |
| DIST-04 | Phase 17 | Pending |
| DIST-05 | Phase 16 | Complete |
| DIST-06 | Phase 18 | Pending |
| DIST-07 | Phase 18 | Pending |

**Coverage:**
- v1 requirements: 7 total
- Mapped to phases: 7
- Unmapped: 0 ✓

---
*Requirements defined: 2026-04-16*
*Last updated: 2026-04-16 after completing Phase 16*
