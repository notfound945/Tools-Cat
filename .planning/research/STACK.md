# Stack Research

**Domain:** macOS direct distribution hardening for `Tools Cat`
**Researched:** 2026-04-16
**Confidence:** HIGH

## Recommended Stack

This milestone should stay fully Apple-native. The stack change is not about app runtime features; it is about moving the existing release flow from "local build + unsigned/not-unnotarized DMG" to a repeatable Developer ID distribution pipeline.

### Core Technologies

| Technology | Purpose | Why Recommended |
|------------|---------|-----------------|
| Apple Developer Program + Developer ID Application certificate | Distribution signing identity for the `.app` and `.dmg` | Apple’s direct-distribution guidance is built around Developer ID signing for software distributed outside the Mac App Store. |
| Xcode archive/export flow or equivalent distribution-signed build | Produce release artifacts intended for distribution instead of only local build products | Apple’s distribution docs center on archive/export for outside-the-store releases; it creates a clearer seam between local debug builds and distributable artifacts. |
| `notarytool` + Keychain profile | Submit and authenticate notarization requests without embedding secrets into scripts | Apple’s notarization workflow has standardized on `notarytool`, and its credential storage flow fits local release automation safely. |
| `codesign` | Sign the app bundle and the final DMG | Apple’s packaging docs explicitly call out signing the app and signing any signable nested containers, including disk images. |
| `stapler` | Attach notarization tickets to shipped artifacts | Stapling lets the final deliverable carry notarization proof, which improves first-run and offline verification behavior. |
| `spctl` + `codesign --verify` | Local release verification on a fresh machine or fresh environment | Gatekeeper-facing verification should be part of the release flow rather than assumed from a successful build. |
| Existing `hdiutil` + `ditto` packaging flow | Keep DMG creation native and simple | The repo already uses the correct Apple-native primitives for DMG creation; they only need to be upgraded with signing and notarization. |

### Current Repo State

| Area | Current State | Implication |
|------|---------------|------------|
| Xcode signing | `CODE_SIGN_STYLE = Automatic`, fixed bundle ID, sandbox enabled in the app target | The project already has a signing baseline, but the release flow still depends on local Xcode account state and doesn’t yet describe a distribution-grade signing path. |
| Entitlements | `Tools Cat/Tools_Cat.entitlements` only enables App Sandbox and outbound network client access | The entitlement surface is small, which is good for notarization; hardened runtime still needs explicit verification in the distribution path. |
| Release build | `release.sh` runs `xcodebuild clean build` and picks the `.app` from DerivedData | This is enough for local packaging, but it does not yet encode a clear distribution/export boundary. |
| DMG packaging | `build_dmg.sh` stages the app with `ditto` and creates a `UDZO` DMG with `hdiutil` | The DMG format is compatible with Apple guidance, but the script currently leaves the DMG unsigned and unnotarized. |
| Documentation | `README.md` and `build_dmg.sh` both explicitly say the DMG is not notarized and requires manual security approval | This is the exact user-facing gap the milestone needs to close. |

### Recommended Additions

| Addition | Purpose | Notes |
|----------|---------|-------|
| Release-time identity configuration | Choose the correct Developer ID identity and Team context deterministically | Avoid relying on whichever local signing account Xcode happens to pick. |
| Notarization credential bootstrap | Store credentials once via `notarytool store-credentials` and reuse a keychain profile | Safer than hardcoding Apple ID or app-specific passwords into scripts. |
| Signed DMG step | Protect the final delivered container from tampering | Apple docs explicitly recommend signing the disk image with a Developer ID Application identity. |
| Notarization submit/wait/log step | Make the release script fail fast on notarization problems | The notary log is the primary debugging source for rejected uploads. |
| Staple + verify step | Ensure the shipped artifact is ready for friend installs | Verification should be scripted, not left as a manual memory task. |

## Recommended Build Shape

The strongest fit for this repo is:

1. Build or export a distribution-signed `.app`
2. Stage the app into a DMG source directory with `ditto`
3. Create a `UDZO` DMG with `hdiutil`
4. Sign the DMG with `codesign --timestamp`
5. Submit the outermost DMG to Apple with `notarytool submit --wait`
6. On success, staple the notarization ticket to the DMG
7. Verify the app and DMG with `codesign` and `spctl`
8. Document the release prerequisites and verification commands

This keeps the current native packaging shape but makes the artifact distributable.

## What NOT to Add

| Avoid | Why | Use Instead |
|-------|-----|-------------|
| App Store distribution work | The milestone goal is friend-to-friend installability, not App Store release | Developer ID direct distribution |
| New runtime features | This milestone should not mix release hardening with product scope | Keep the milestone release-only |
| Hardcoded notarization secrets in shell scripts | Unsafe and brittle | `notarytool` keychain profile |
| Third-party DMG/notarization wrappers as the primary path | Unnecessary abstraction over Apple’s own tooling for a small repo | `xcodebuild`, `codesign`, `hdiutil`, `notarytool`, `stapler`, `spctl` |

## Sources

- Apple Developer: Developer ID - https://developer.apple.com/developer-id/
- Apple Developer Documentation: Packaging Mac software for distribution - https://developer.apple.com/documentation/xcode/packaging-mac-software-for-distribution
- Apple Developer Documentation: Customizing the notarization workflow - https://developer.apple.com/documentation/security/customizing-the-notarization-workflow
- Apple Developer Documentation: Distributing your app for beta testing and releases - https://developer.apple.com/documentation/xcode/distributing-your-app-for-beta-testing-and-releases
- Apple Developer Documentation: Configuring the hardened runtime - https://developer.apple.com/documentation/xcode/configuring-the-hardened-runtime
- Local repo: `release.sh`, `build_dmg.sh`, `README.md`, `Tools Cat.xcodeproj/project.pbxproj`, `Tools Cat/Tools_Cat.entitlements`

---
*Stack research for: v1.6 Distribution Hardening*
