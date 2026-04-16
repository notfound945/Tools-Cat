# Architecture Research

**Domain:** Direct-distribution release chain for `Tools Cat`
**Researched:** 2026-04-16
**Confidence:** HIGH

## Current Architecture

Today’s release chain is:

1. `release.sh` runs `xcodebuild clean build`
2. It locates the Release `.app` in DerivedData
3. It calls `build_dmg.sh`
4. `build_dmg.sh` stages the app with `ditto` and emits a `UDZO` DMG
5. The repo explicitly tells users the DMG is not notarized and must be manually allowed

That architecture is good enough for local packaging, but not for friend distribution.

## Target Architecture

The target release chain should be:

1. Build or export a distribution-signed `.app`
2. Verify the app signature and hardened-runtime/notarization readiness
3. Stage the app into a DMG source directory
4. Create a `UDZO` DMG
5. Sign the DMG with a Developer ID Application identity
6. Submit the DMG to Apple using `notarytool submit --wait`
7. On success, staple the notarization ticket to the DMG
8. Verify the DMG locally with `codesign` and `spctl`
9. Perform a fresh-install smoke on a clean machine/environment

## Recommended Component Layout

| Component | Responsibility | Repo Fit |
|-----------|----------------|----------|
| `release.sh` | Orchestrate the end-to-end release pipeline | Best place to become the main release entrypoint |
| `build_dmg.sh` | Keep focused on deterministic DMG creation | Can stay small and reusable if signing/notarization happen around it |
| Notarization helper (shell or inline release step) | Submit, wait, log, staple | Could live inside `release.sh` or a dedicated helper if clarity improves |
| README release docs | Document prerequisites, credentials, and verification | Necessary because this repo is currently explicit about the opposite behavior |
| Xcode project signing config | Provide correct distribution signing inputs | Needs review for hardened runtime and predictable Team/identity selection |

## Credential and Identity Flow

The release flow should separate:

- **Build/signing identity**
  - Developer ID Application certificate
  - Chosen deterministically at release time
- **Notarization authentication**
  - `notarytool` keychain profile or API-key credentials
  - Kept outside the repo and outside plaintext shell variables where possible

This separation matters because code signing and notarization are related but not the same step.

## Build Order Recommendation

The safest build order for this repo is:

1. **Preflight**
   - Check that required tools exist: `xcodebuild`, `codesign`, `notarytool`, `stapler`, `spctl`, `hdiutil`
   - Check that signing identity is available
   - Check that notarization keychain profile exists
2. **Signed app**
   - Build or export the app for distribution
   - Verify the app signature
3. **Signed DMG**
   - Create the DMG
   - Sign the DMG with Developer ID Application
4. **Notarization**
   - Submit the DMG
   - Wait for completion
   - Retrieve log on failure
5. **Staple + verify**
   - Staple the ticket to the DMG
   - Assess with `spctl`
   - Keep a final manual smoke step documented

## Architectural Choices

### Prefer: notarize the outermost DMG

Apple’s packaging guidance is explicit that for nested containers you sign each signable layer, but notarize the outermost container you distribute. For this repo’s current DMG-based workflow, that points to:

- sign the `.app`
- create the DMG
- sign the DMG
- notarize the DMG
- staple the DMG

### Prefer: fail-fast release automation

This repo is small; opaque release scripts create more pain than they save. The release chain should stop immediately on:

- missing Developer ID identity
- missing notarization credentials
- notarization rejection
- failed staple
- failed Gatekeeper assessment

### Prefer: local-first release automation before CI

The milestone should first make local release work reliably on the maintainer’s Mac. CI can come later, once the exact identity, credential, and verification model is stable.

## Integration Points With Current Repo

| File | Change Pressure | Why |
|------|-----------------|-----|
| `release.sh` | HIGH | It is the natural place to grow from local build orchestration into full release orchestration |
| `build_dmg.sh` | MEDIUM | It may need a signing seam or at least a clean handoff for post-create signing |
| `README.md` | HIGH | Current docs promise an unnotarized DMG and manual security bypasses |
| `Tools Cat.xcodeproj/project.pbxproj` | MEDIUM | Signing behavior needs review for distribution readiness and hardened runtime visibility |
| `Tools Cat/Tools_Cat.entitlements` | LOW to MEDIUM | Current entitlement surface is small, but runtime exceptions should stay minimal and intentional |

## Sources

- Apple Developer Documentation: Packaging Mac software for distribution - https://developer.apple.com/documentation/xcode/packaging-mac-software-for-distribution
- Apple Developer Documentation: Customizing the notarization workflow - https://developer.apple.com/documentation/security/customizing-the-notarization-workflow
- Apple Developer Documentation: Resolving common notarization issues - https://developer.apple.com/documentation/security/resolving-common-notarization-issues
- Local repo: `release.sh`, `build_dmg.sh`, `README.md`, `Tools Cat.xcodeproj/project.pbxproj`, `Tools Cat/Tools_Cat.entitlements`

---
*Architecture research for: v1.6 Distribution Hardening*
