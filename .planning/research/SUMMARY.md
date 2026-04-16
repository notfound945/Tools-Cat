# Project Research Summary

**Project:** Tools Cat
**Milestone:** v1.6 Distribution Hardening
**Researched:** 2026-04-16
**Confidence:** HIGH

## Executive Summary

`Tools Cat` does not need a new product stack for this milestone. It needs a complete Apple-native distribution chain: distribution-signed app, signed DMG, notarization of the outermost DMG, stapling, and explicit verification. The current repo already has a workable local packaging base, but it stops one layer too early and openly documents the resulting Gatekeeper friction.

The strongest recommendation is to keep the existing DMG-based distribution shape and harden it rather than replacing it. `release.sh` should become the release orchestrator, `build_dmg.sh` should stay focused on deterministic DMG creation, and the repo should add identity selection, notarization, stapling, and verification around that flow.

## Key Findings

### Stack Additions

- Add a Developer ID Application-based release path for the `.app` and `.dmg`
- Use `notarytool` with a keychain profile for notarization authentication
- Sign the DMG after creation with `codesign --timestamp`
- Staple the notarization ticket to the final DMG
- Verify with `codesign` and `spctl`, plus one clean-environment install smoke

### Feature Table Stakes

- Produce a distribution-signed app
- Produce a signed `Tools-Cat.dmg`
- Notarize the outermost DMG
- Staple the DMG before sharing it
- Document release prerequisites and friend-install verification

### Watch Out For

- Do not confuse a successful local build with a distributable artifact
- Do not skip hardened-runtime verification
- Do not notarize arbitrary intermediate files while shipping a different final artifact
- Do not leave notarization secrets in shell scripts
- Do not validate only on the maintainer’s development Mac

## Repo-Specific Implications

### Good News

- The repo already has a fixed bundle identifier and automatic signing baseline in the Xcode project
- The entitlement surface is small: App Sandbox plus outbound network client access
- The DMG pipeline already uses Apple-native `ditto` + `hdiutil`

### Gaps To Close

- `release.sh` only builds; it does not yet handle distribution signing, notarization, stapling, or verification
- `build_dmg.sh` creates a `UDZO` DMG but does not sign it
- `README.md` currently documents the exact failure mode this milestone exists to remove
- The release path needs an explicit credential and identity contract

## Recommended Roadmap Shape

The milestone should likely break into:

1. release-signing prerequisites and project readiness
2. signed DMG packaging plus notarization automation
3. verification and release-documentation closure

That build order matches both Apple’s documented container/signing model and the repo’s existing release-script layout.

## Sources

- Apple Developer: Developer ID - https://developer.apple.com/developer-id/
- Apple Developer Documentation: Packaging Mac software for distribution - https://developer.apple.com/documentation/xcode/packaging-mac-software-for-distribution
- Apple Developer Documentation: Customizing the notarization workflow - https://developer.apple.com/documentation/security/customizing-the-notarization-workflow
- Apple Developer Documentation: Configuring the hardened runtime - https://developer.apple.com/documentation/xcode/configuring-the-hardened-runtime
- Apple Developer Documentation: Resolving common notarization issues - https://developer.apple.com/documentation/security/resolving-common-notarization-issues
- Local repo: `README.md`, `release.sh`, `build_dmg.sh`, `Tools Cat.xcodeproj/project.pbxproj`, `Tools Cat/Tools_Cat.entitlements`

---
*Research completed: 2026-04-16*
*Ready for requirements: yes*
