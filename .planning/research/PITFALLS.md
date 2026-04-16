# Pitfalls Research

**Domain:** Apple signing and notarization pitfalls for direct macOS distribution
**Researched:** 2026-04-16
**Confidence:** HIGH

## Critical Pitfalls

### Pitfall 1: Using a local-development build as if it were a distribution build

**What goes wrong:**
The app launches locally, the DMG gets created, but the artifact is still tied to local signing state or lacks the exact Developer ID distribution path needed for friend installs.

**Why it happens:**
The repo’s current release flow is centered on `xcodebuild clean build`, which is enough for local packaging and smoke tests.

**How to avoid:**
Make the release path explicitly distribution-oriented. Verify which identity signed the `.app`, and avoid assuming that a successful local build equals a distributable artifact.

**Warning signs:**
- The release script never prints the final signing identity
- The only proof of success is “the app runs on my machine”
- Different Macs produce differently signed artifacts

### Pitfall 2: Missing hardened runtime

**What goes wrong:**
Notarization fails even though the app is signed.

**Why it happens:**
Apple only notarizes macOS apps that enable hardened runtime. Small utility apps often overlook this because they don’t need unusual runtime exceptions.

**How to avoid:**
Explicitly verify hardened-runtime readiness in the distribution path and keep runtime exceptions minimal. Do not assume it is configured correctly just because Xcode signs the app.

**Warning signs:**
- Notary log reports “The executable does not have the hardened runtime enabled”
- The project has no explicit verification step for runtime hardening

### Pitfall 3: Notarizing the wrong file

**What goes wrong:**
The app is notarized separately, or multiple nested artifacts are submitted inconsistently, creating a confused or non-repeatable release process.

**Why it happens:**
Teams mix “sign every signable layer” with “submit every layer for notarization.”

**How to avoid:**
For the current DMG-based distribution path, sign the app, sign the DMG, and notarize the outermost DMG that will be sent to users.

**Warning signs:**
- The scripts submit both `.app` and `.dmg` separately without a clear reason
- The shipped file is not the same file that was notarized

### Pitfall 4: Forgetting to sign the DMG

**What goes wrong:**
The app bundle is signed, but the disk image container can still be modified after packaging.

**Why it happens:**
Many simple release scripts stop after `hdiutil create`.

**How to avoid:**
Treat the DMG as a real distribution container: create it, sign it with Developer ID Application, then notarize that signed DMG.

**Warning signs:**
- `build_dmg.sh` never calls `codesign`
- The release checklist mentions notarization but not DMG signing

### Pitfall 5: Storing notarization credentials unsafely

**What goes wrong:**
Secrets leak into shell history, CI logs, or the repo.

**Why it happens:**
It is tempting to pass Apple ID credentials directly to scripts because it is the fastest first implementation.

**How to avoid:**
Use `notarytool store-credentials` with a named keychain profile and make the release script consume that profile.

**Warning signs:**
- README tells users to paste passwords into environment variables directly
- Shell scripts contain literal Apple ID or app-specific password placeholders

### Pitfall 6: Verifying only on the development Mac

**What goes wrong:**
The artifact appears installable because the maintainer’s machine already trusts local signing state, cached notarization tickets, or previously allowed launches.

**Why it happens:**
Developer machines are contaminated by prior builds and trust decisions.

**How to avoid:**
Keep a clean-machine or fresh-environment install smoke as a milestone acceptance boundary. At minimum, use Gatekeeper assessment commands plus one real friend-install test.

**Warning signs:**
- There is no verification step beyond “double-clicked it locally”
- The release docs never mention testing on a fresh Mac/environment

### Pitfall 7: Expanding scope into App Store or updater work

**What goes wrong:**
The milestone turns into a generalized release-platform rewrite and never closes the immediate installability problem.

**Why it happens:**
Signing, notarization, App Store packaging, CI release automation, and auto-update all live in the same mental bucket.

**How to avoid:**
Hold the line on the actual user need: send the app to friends and let them install it directly. Anything beyond that is a later milestone.

**Warning signs:**
- Requirements start mentioning TestFlight, App Store review, or auto-update
- The roadmap can’t explain why each task is necessary for friend installs

## Sources

- Apple Developer: Developer ID - https://developer.apple.com/developer-id/
- Apple Developer Documentation: Resolving common notarization issues - https://developer.apple.com/documentation/security/resolving-common-notarization-issues
- Apple Developer Documentation: Configuring the hardened runtime - https://developer.apple.com/documentation/xcode/configuring-the-hardened-runtime
- Apple Developer Documentation: Packaging Mac software for distribution - https://developer.apple.com/documentation/xcode/packaging-mac-software-for-distribution
- Local repo: `release.sh`, `build_dmg.sh`, `README.md`

---
*Pitfall research for: v1.6 Distribution Hardening*
