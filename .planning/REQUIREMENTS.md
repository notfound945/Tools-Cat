# Requirements: Tools Cat

**Defined:** 2026-04-16
**Core Value:** From the menu bar, I can reliably wake the devices I care about and trust the app's status without editing code or fighting the UI.

## v1 Requirements

Requirements for the v1.6 distribution-hardening milestone. This milestone stays release-only. On 2026-04-17, the maintainer chose not to join Apple Developer Program, so the current milestone truth pivoted from signed/notarized distribution to explicit non-notarized friend sharing without reopening the shipped wake or keep-awake feature surface.

### Distribution Signing

- [x] **DIST-01**: Maintainer can produce a Developer ID signed `Tools Cat.app` that is suitable for direct distribution outside the Mac App Store
- [x] **DIST-02**: Maintainer can produce a Developer ID signed `Tools-Cat.dmg` that contains the distributable app bundle

### Notarization

- [x] **DIST-03**: Maintainer can submit the final DMG to Apple with `notarytool`, wait for completion, and get actionable failure information when notarization is rejected
- [x] **DIST-04**: The DMG sent to friends is stapled with a successful notarization ticket and passes local Gatekeeper assessment

### Release Operations

- [x] **DIST-05**: Repo documentation explains the required signing identity, notarization credential setup, and release preflight without storing sensitive credentials in the repo
- [ ] **DIST-06**: Repo provides a repeatable local verification path for the shipped non-notarized artifact, including the exact manual-open steps friends may need
- [ ] **DIST-07**: Distribution hardening does not change the shipped WOL and keep-awake behavior beyond the release/share work needed for friend distribution

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
| Requiring Apple Developer Program membership for the default release flow | The current project goal explicitly accepts non-notarized friend sharing instead |
| Auto-update framework integration | Useful later, but not required to solve manual install approval friction |
| CI/CD-first release automation | A stable local signing/notarization flow should exist before remote automation is added |

## Traceability

Phase mapping assigned during roadmap creation.

| Requirement | Phase | Status |
|-------------|-------|--------|
| DIST-01 | Phase 16 | Complete |
| DIST-02 | Phase 17 | Complete |
| DIST-03 | Phase 17 | Complete |
| DIST-04 | Phase 17 | Complete |
| DIST-05 | Phase 16 | Complete |
| DIST-06 | Phase 18 | Pending |
| DIST-07 | Phase 18 | Pending |

**Coverage:**
- v1 requirements: 7 total
- Mapped to phases: 7
- Unmapped: 0 ✓

---
*Requirements defined: 2026-04-16*
*Last updated: 2026-04-17 after pivoting to non-notarized friend distribution*
