# Feature Research

**Domain:** Friend-installable macOS distribution for `Tools Cat`
**Researched:** 2026-04-16
**Confidence:** HIGH

## Feature Landscape

This milestone is operational. The "features" are release-chain capabilities that make direct installation trustworthy and repeatable.

### Table Stakes

| Feature | Why Required | Complexity | Notes |
|---------|--------------|------------|-------|
| Distribution-signed `.app` | A friend-installable macOS app must be signed for distribution, not merely built locally | MEDIUM | The exported app must carry the correct Developer ID signature and be suitable for notarization. |
| Signed `.dmg` | Apple’s packaging guidance explicitly supports signed disk images for direct distribution | LOW to MEDIUM | The repo already creates `UDZO` DMGs; signing the DMG closes the container-integrity gap. |
| Notarization of the delivered artifact | Directly distributed macOS software is expected to be notarized for Gatekeeper confidence | MEDIUM | For a DMG-based flow, notarize the outermost DMG rather than trying to notarize multiple nested deliverables separately. |
| Stapled ticket on the shipped DMG | Makes the final artifact self-contained for installation checks | LOW | The release artifact should not require the recipient to hit a manual allow path. |
| Repeatable verification commands | The milestone should prove installability, not just assume it | LOW | `codesign`, `spctl`, and fresh-machine/manual smoke steps belong in the documented release checklist. |
| Credential-safe notarization setup | Release automation must not depend on plaintext secrets in repo scripts | LOW | `notarytool store-credentials` with a named keychain profile is the clean Apple-native path. |

### Differentiators

| Feature | Value | Complexity | Notes |
|---------|-------|------------|-------|
| Single-command release pipeline | Reduces operator error and makes future releases practical | MEDIUM | `release.sh` can become the main entrypoint for build, sign, notarize, staple, and verify. |
| Notary log surfacing in the script | Makes failures diagnosable without digging manually | LOW | Pulling `notarytool log` on failure would tighten the feedback loop. |
| Preflight checks for missing identities or credentials | Makes release failures earlier and clearer | LOW | The script should fail before a long build if the signing identity or keychain profile is missing. |
| Fresh-install validation checklist | Keeps the milestone anchored to the actual user outcome | LOW | Document testing on a Mac/environment that has not previously run the app. |

### Anti-Features

| Feature | Why It’s Tempting | Why It’s Out of Scope | Alternative |
|---------|-------------------|----------------------|-------------|
| App Store submission support | It sounds like the “full” Apple distribution path | It is a different release channel with different packaging and review requirements | Stay on Developer ID direct distribution |
| Auto-update framework integration | It often appears next to notarization conversations | It expands runtime scope and support burden beyond installability | Keep manual DMG distribution for this milestone |
| New end-user UI features | It can feel efficient to combine with a release pass | It weakens milestone focus and makes release regressions harder to isolate | Keep the milestone release-only |
| CI/CD-first release automation | It sounds more complete | The repo first needs a working local distribution chain before remote automation adds value | Get the local signed/notarized release path stable first |

## Dependency Map

```text
[Developer ID Application certificate]
    ├──enables──> [Distribution-signed app]
    └──enables──> [Signed DMG]

[Distribution-signed app]
    └──required for──> [Notarization submission]

[Signed DMG]
    └──submitted as──> [Outermost notarized artifact]

[Notary credentials]
    └──required for──> [notarytool submit --wait]

[Successful notarization]
    └──enables──> [Stapled DMG]

[Stapled DMG]
    └──verified by──> [Friend-install smoke / Gatekeeper assessment]
```

## MVP Definition

### Must Ship in v1.6

- [ ] Release process can produce a distribution-signed `Tools Cat.app`
- [ ] Release process can produce a signed `Tools-Cat.dmg`
- [ ] The final DMG is notarized and stapled
- [ ] Repo docs explain required credentials and release verification steps
- [ ] A friend-install smoke path is defined and used as the acceptance boundary

### Nice to Have if Cheap

- [ ] Release script prints clear preflight failures for missing signing identity or keychain profile
- [ ] Release script surfaces notarization logs automatically on rejection
- [ ] Verification commands are bundled into a helper or README subsection

### Defer

- [ ] CI release automation
- [ ] Auto-update / background update framework
- [ ] App Store packaging or TestFlight work

## Sources

- Apple Developer: Developer ID - https://developer.apple.com/developer-id/
- Apple Developer Documentation: Packaging Mac software for distribution - https://developer.apple.com/documentation/xcode/packaging-mac-software-for-distribution
- Apple Developer Documentation: Customizing the notarization workflow - https://developer.apple.com/documentation/security/customizing-the-notarization-workflow
- Local repo: `README.md`, `release.sh`, `build_dmg.sh`

---
*Feature research for: v1.6 Distribution Hardening*
