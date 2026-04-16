# Phase 16: Release Signing Readiness - Research

**Researched:** 2026-04-16
**Domain:** macOS Developer ID signing readiness for direct distribution
**Confidence:** HIGH

<user_constraints>
## User Constraints (from CONTEXT.md)

### Locked Decisions
### Release entrypoint shape
- **D-01:** `release.sh` remains the single canonical maintainer-facing release entrypoint for this milestone.
- **D-02:** Additional release-chain steps may be factored into helpers internally, but maintainers should not need to choose between multiple public release commands.

### Signing configuration model
- **D-03:** Day-to-day development may continue using Xcode automatic signing.
- **D-04:** The release flow must require explicit release-time identity configuration instead of trusting whichever signing choice Xcode picks locally.
- **D-05:** Release preflight must validate the expected Team / Developer ID Application identity / named notary profile inputs before any long build work starts.

### Distribution build boundary
- **D-06:** Phase 16 should move the app release path to an archive/export-style distribution build boundary rather than extending the current DerivedData-picked `xcodebuild clean build` flow.
- **D-07:** Later release hardening phases must build on that same archive/export seam instead of introducing a second competing distribution build path.

### Documentation and preflight strictness
- **D-08:** The repo must update `README.md` and add a dedicated release document or checklist for signing, notarization bootstrap, and release preflight.
- **D-09:** Release automation must fail fast before the build when required tools, identity inputs, or notarization-profile prerequisites are missing.

### the agent's Discretion
- Exact helper-script layout behind `release.sh`, as long as the maintainer-facing release entrypoint stays singular.
- Exact names of release environment variables / flags, as long as release-time identity selection is explicit and validated.
- Exact archive/export command shape and output staging, as long as the resulting `.app` comes from a distribution-grade archive/export boundary rather than the current DerivedData app pickup.
- Exact document split between `README.md` and the dedicated release checklist, as long as the README stays the short entrypoint and the detailed release procedure lives in a focused standalone doc.

### Deferred Ideas (OUT OF SCOPE)
None — discussion stayed within phase scope.
</user_constraints>

## Project Constraints (from CLAUDE.md)

- Stay on the native macOS stack already in the repo: AppKit/SwiftUI app target plus Apple command-line tooling.
- Preserve the current Xcode-project build system; no alternative package/build system is in use.
- Keep release automation explicit and readable rather than hidden behind opaque wrappers.
- Do not introduce runtime secret files or store release credentials in the repo; the project currently has no `.env`-style secret configuration.
- Keep work inside the GSD workflow surface; direct repo edits outside the workflow are not the project default.

<phase_requirements>
## Phase Requirements

| ID | Description | Research Support |
|----|-------------|------------------|
| DIST-01 | Maintainer can produce a Developer ID signed `Tools Cat.app` that is suitable for direct distribution outside the Mac App Store | Use `xcodebuild archive` + `xcodebuild -exportArchive` with `method=developer-id`, explicit Team/identity preflight, and Release hardened runtime enabled. |
| DIST-05 | Repo documentation explains the required signing identity, notarization credential setup, and release preflight without storing sensitive credentials in the repo | Document `notarytool store-credentials`, required env inputs, fail-fast checks, and a short README entrypoint plus a dedicated release checklist. |
</phase_requirements>

## Summary

Phase 16 should convert the current local `xcodebuild clean build` release path into a distribution-grade `archive`/`export` pipeline that emits a Developer ID signed `Tools Cat.app`. The important boundary change is not “sign the existing DerivedData app later”; it is “make `release.sh` build through `xcodebuild archive` and `xcodebuild -exportArchive` with an explicit Developer ID export policy now,” because Phase 17 must build on that same seam for DMG signing and notarization.

The current repo is not release-ready yet. The app target still uses `CODE_SIGN_STYLE = Automatic`, Release currently reports `ENABLE_HARDENED_RUNTIME = NO`, the project has no fixed Team ID, the machine only has an `Apple Development` identity in the keychain, and no named notary profile is configured. At the same time, current build settings report `PROVISIONING_PROFILE_REQUIRED = NO`, so the phase should not invent provisioning-profile management unless later capabilities change that requirement. That is exactly why this phase needs strong preflight and documentation: the code changes alone are not enough unless maintainers can see missing prerequisites before the build starts.

This phase should stay scoped to the signed `.app` and readiness documentation. Do not pull signed DMG creation, notarization submission, stapling, or Gatekeeper closure forward from Phases 17-18. Instead, make hardened runtime explicit, require explicit release-time Team/identity/profile inputs, export a Developer ID signed app, and document the credential bootstrap that later notarization phases will consume.

**Primary recommendation:** Make `release.sh` fail-fast on explicit `TEAM_ID` / `Developer ID Application` identity / notary profile inputs, then build the app only through `xcodebuild archive` + `xcodebuild -exportArchive` with `method=developer-id` and Release hardened runtime enabled.

## Standard Stack

### Core
| Tool | Version | Purpose | Why Standard |
|------|---------|---------|--------------|
| `xcodebuild archive` + `xcodebuild -exportArchive` | Xcode 26.2 (verified locally 2026-04-16) | Produce a distribution-grade archive/export boundary for the `.app` | Official Xcode export flow supports `method=developer-id`, explicit `teamID`, `signingStyle`, and `signingCertificate`. |
| Export options plist (`method=developer-id`) | Xcode 26.2 schema (verified via `xcodebuild -help`) | Encode release export policy deterministically | Keeps release signing policy explicit and reviewable instead of buried in Xcode UI state. |
| `security find-identity` | macOS system tool | Discover and verify the expected `Developer ID Application` identity before the build | Apple-native way to inspect installed signing identities; avoids trusting local Xcode account state. |
| `codesign` | macOS system tool | Inspect and verify the exported app signature and entitlements | Official verification tool for the exported artifact. |

### Supporting
| Tool | Version | Purpose | When to Use |
|------|---------|---------|-------------|
| `xcrun notarytool` | 1.1.0 (39), verified locally 2026-04-16 | Bootstrap and validate a named keychain profile for later notarization phases | Documented and preflighted in Phase 16 even though submit/staple work is Phase 17. |
| `plutil` | macOS system tool | Validate or generate the export-options plist | Use when the release flow materializes plist content from env vars or templates. |
| `hdiutil` + `ditto` | macOS system tools | Downstream DMG packaging seam | Keep as the Phase 17 packaging step, but do not use them as Phase 16’s primary success boundary. |
| `spctl` + `stapler` | macOS system tools | Future assessment and stapling tools | Mention in docs as upcoming prerequisites; full use belongs to later phases. |

### Alternatives Considered
| Instead of | Could Use | Tradeoff |
|------------|-----------|----------|
| `xcodebuild archive` + `-exportArchive` | `xcodebuild clean build` plus picking the `.app` from DerivedData | Simpler today, but it violates the locked archive/export boundary and leaves signing policy implicit. |
| Xcode export re-signing with explicit policy | Handwritten `codesign` passes over the built bundle | Harder to reason about, easy to get wrong with nested content, and reintroduces a second release path. |
| Named notary keychain profile | Plaintext env vars or repo-stored secrets | Simpler to type once, but violates the repo’s no-secret-in-source requirement and makes future notarization unsafe. |

**Tool verification (2026-04-16):**
```bash
xcodebuild -version
xcrun notarytool --version
security find-identity -v -p codesigning
```

**Observed local state (2026-04-16):**
- `xcodebuild`: `Xcode 26.2 (17C52)`
- `notarytool`: `1.1.0 (39)`
- Installed signing identities: only `Apple Development`, no `Developer ID Application`
- Named notary profile check (`TOOLS_CAT_NOTARY`): missing
- Current app build settings: `PROVISIONING_PROFILE_REQUIRED = NO`

## Architecture Patterns

### Recommended Project Structure
```text
release.sh                          # sole maintainer-facing release entrypoint
scripts/release/
├── preflight-signing.sh           # tools, Team ID, identity, profile validation
├── export-options-developer-id.plist
└── inspect-signature.sh           # post-export signature / entitlement checks
docs/release/
└── signing-readiness.md           # detailed bootstrap + preflight checklist
dist/
└── export/                        # exported Developer ID signed app output
build/
└── archive/                       # local xcarchive staging
```

### Pattern 1: Fail-Fast Release Preflight
**What:** `release.sh` should validate required tools and explicit release inputs before archiving.
**When to use:** Always, before any long-running `xcodebuild archive`.
**Example:**
```bash
# Source: local Apple tool help (`security`, `notarytool`) and phase decisions D-04/D-05/D-09
: "${RELEASE_TEAM_ID:?Set RELEASE_TEAM_ID to the Apple Developer Team ID}"
: "${RELEASE_SIGNING_IDENTITY:?Set RELEASE_SIGNING_IDENTITY to the full 'Developer ID Application: ...' label}"
: "${RELEASE_NOTARY_PROFILE:?Set RELEASE_NOTARY_PROFILE to the stored notarytool keychain profile name}"

command -v xcodebuild >/dev/null
command -v security >/dev/null
command -v codesign >/dev/null
command -v xcrun >/dev/null

security find-identity -v -p codesigning | grep -F "$RELEASE_SIGNING_IDENTITY" >/dev/null
xcrun notarytool history --keychain-profile "$RELEASE_NOTARY_PROFILE" >/dev/null 2>&1 || {
  echo "[ERROR] notarytool profile '$RELEASE_NOTARY_PROFILE' is missing or invalid" >&2
  exit 1
}
```

### Pattern 2: Archive Then Export with Developer ID Policy
**What:** Build a macOS archive, then export the distributable app with `method=developer-id`.
**When to use:** For every maintainer release build; never pick the app from DerivedData.
**Example:**
```bash
# Source: `xcodebuild -help` (Xcode 26.2)
xcodebuild archive \
  -project "Tools Cat.xcodeproj" \
  -scheme "Tools Cat" \
  -configuration Release \
  -destination "generic/platform=macOS" \
  -archivePath "$ARCHIVE_PATH" \
  DEVELOPMENT_TEAM="$RELEASE_TEAM_ID"

xcodebuild -exportArchive \
  -archivePath "$ARCHIVE_PATH" \
  -exportPath "$EXPORT_PATH" \
  -exportOptionsPlist "$EXPORT_OPTIONS_PLIST"
```

### Pattern 3: Keep Export Policy Explicit in Plist
**What:** Check in or deterministically generate one export-options plist for Developer ID export.
**When to use:** Whenever the release flow exports the archive.
**Example:**
```xml
<!-- Source: `xcodebuild -help` exportOptionsPlist keys -->
<plist version="1.0">
<dict>
  <key>method</key>
  <string>developer-id</string>
  <key>signingStyle</key>
  <string>manual</string>
  <key>signingCertificate</key>
  <string>Developer ID Application</string>
  <key>teamID</key>
  <string>Y2YJ48R9GL</string>
</dict>
</plist>
```

### Pattern 4: Make Hardened Runtime Explicit in Release
**What:** Turn on hardened runtime for the Release app target and verify it after export.
**When to use:** In project configuration, before Phase 17 notarization work.
**Example:**
```text
# Source: current project build settings + Apple hardened-runtime docs
ENABLE_HARDENED_RUNTIME = YES;
CODE_SIGN_ENTITLEMENTS = "Tools Cat/Tools_Cat.entitlements";
```

### Anti-Patterns to Avoid
- **DerivedData app pickup:** Pulling `build/Build/Products/Release/Tools Cat.app` directly keeps the release boundary ad hoc and violates D-06/D-07.
- **Implicit signing choice:** Letting Xcode choose whichever account/certificate is locally active can silently produce development-signed output or fail differently per machine.
- **Plaintext notarization secrets:** Do not add Apple ID passwords, API keys, or app-specific passwords to repo files, shell defaults, or committed docs.
- **`codesign --deep` as the main release flow:** It hides signing problems instead of fixing project/export policy.
- **Extra entitlements without evidence:** The current entitlement file is minimal; do not add hardened-runtime exceptions unless later notarization logs prove they are required.

## Don't Hand-Roll

| Problem | Don't Build | Use Instead | Why |
|---------|-------------|-------------|-----|
| Distribution app export | A custom script that walks build output and re-signs arbitrary bundle paths | `xcodebuild archive` + `xcodebuild -exportArchive` | Xcode already knows how to export a Developer ID app and keep the release boundary coherent. |
| Signing identity detection | Grepping random Keychain UI state or trusting Xcode Preferences | `security find-identity -v -p codesigning` | Produces a stable CLI check that can fail before the build. |
| Notary credential storage | Repo files, shell defaults, or copied passwords in README examples | `xcrun notarytool store-credentials <profile>` | Keeps secrets in Keychain and matches Apple’s current notarization auth flow. |
| Hardened runtime readiness | A post-build “fixup” re-sign step | Explicit Release build setting plus `codesign -d` inspection | The build configuration should be correct before export, not repaired afterward. |
| Export policy serialization | Echo-built plist strings without validation | Checked-in plist template plus `plutil -lint` | Keeps the export contract reviewable and less brittle. |

**Key insight:** The complex part of this phase is not shell scripting. It is choosing one truthful Apple-native release seam and making its prerequisites explicit. Xcode export and Keychain-backed notarization tooling already solve the hard parts; custom glue should stay thin.

## Common Pitfalls

### Pitfall 1: Automatic Signing Ambiguity
**What goes wrong:** The release flow builds with whichever signing context Xcode happens to have locally, producing non-distribution output or machine-specific failures.
**Why it happens:** The current target uses `CODE_SIGN_STYLE = Automatic` and has no fixed Team ID in the project.
**How to avoid:** Require `RELEASE_TEAM_ID` and `RELEASE_SIGNING_IDENTITY`, then verify the exact identity exists before `archive`.
**Warning signs:** `security find-identity` shows only `Apple Development`, `xcodebuild -showBuildSettings` reports `_DEVELOPMENT_TEAM_IS_EMPTY = YES`, or export defaults to a non-Developer-ID method.

### Pitfall 2: Hardened Runtime Left Off
**What goes wrong:** The app signs successfully for local use but later notarization work fails or requires a risky cleanup pass.
**Why it happens:** Current Release build settings report `ENABLE_HARDENED_RUNTIME = NO`.
**How to avoid:** Set Release `ENABLE_HARDENED_RUNTIME = YES` in the project now and verify the exported app signature/entitlements as part of the release script.
**Warning signs:** Build settings still show `ENABLE_HARDENED_RUNTIME = NO`, or the exported app is only validated with superficial existence checks.

### Pitfall 3: Keeping the Old `clean build` Release Path
**What goes wrong:** The repo ends up with two competing release boundaries: one for local packaging and one for notarization.
**Why it happens:** It is tempting to bolt signing onto the existing DerivedData pickup because it already works for local DMG creation.
**How to avoid:** Replace the current app pickup with archive/export inside `release.sh` now; leave `build_dmg.sh` as a downstream consumer for later phases.
**Warning signs:** The script still looks for `build/Build/Products/Release/*.app`, or archive/export is added beside the old flow instead of replacing it.

### Pitfall 4: Confusing Notary Bootstrap with Repo Configuration
**What goes wrong:** Maintainers paste credentials into env vars or docs because the repo needs a named profile but the setup story is unclear.
**Why it happens:** Notary authentication is related to signing, but it is a separate credential path with different tooling.
**How to avoid:** Document one bootstrap path using `notarytool store-credentials --validate`, require only the profile name in release env, and keep the secret material out of source control.
**Warning signs:** Docs include passwords, app-specific passwords, or `.env` files, or preflight cannot explain how to create the named profile.

### Pitfall 5: Over-correcting with New Entitlements
**What goes wrong:** The app gains unnecessary capabilities or hardened-runtime exceptions before any notarization evidence justifies them.
**Why it happens:** Teams often treat notarization failures as a reason to add broad exceptions preemptively.
**How to avoid:** Preserve the current minimal entitlement surface (`app-sandbox` + `network.client`) and only add exceptions when notarization logs demand them.
**Warning signs:** Entitlements expand during Phase 16 without a concrete failure log or Apple requirement driving the change.

### Pitfall 6: Inventing Provisioning-Profile Work
**What goes wrong:** The plan adds manual provisioning-profile setup even though the current app target does not require it for this direct-distribution flow.
**Why it happens:** Teams often import iOS/App Store assumptions into Developer ID work.
**How to avoid:** Keep preflight focused on Team ID, Developer ID Application identity, export options, and notary profile; revisit provisioning only if future capabilities change the target’s requirements.
**Warning signs:** The plan includes profile UUID plumbing even though `xcodebuild -showBuildSettings` reports `PROVISIONING_PROFILE_REQUIRED = NO`.

## Code Examples

Verified patterns from official tools and current repo state:

### Check Current Signing/Hardened-Runtime State
```bash
# Source: local Xcode 26.2 CLI
xcodebuild -project "Tools Cat.xcodeproj" -scheme "Tools Cat" \
  -destination "platform=macOS" -showBuildSettings \
  | rg 'CODE_SIGN|DEVELOPMENT_TEAM|ENABLE_HARDENED_RUNTIME|PRODUCT_BUNDLE_IDENTIFIER'
```

### Bootstrap a Named Notary Profile
```bash
# Source: `xcrun notarytool help store-credentials`
xcrun notarytool store-credentials TOOLS_CAT_NOTARY \
  --apple-id "maintainer@example.com" \
  --team-id "Y2YJ48R9GL"
```

### Inspect the Exported App Signature
```bash
# Source: `codesign --help`
codesign -d --entitlements :- --verbose=4 "dist/export/Tools Cat.app"
codesign -v --verbose=4 "dist/export/Tools Cat.app"
```

## State of the Art

| Old Approach | Current Approach | When Changed | Impact |
|--------------|------------------|--------------|--------|
| `xcodebuild clean build` and pick the `.app` from DerivedData | `xcodebuild archive` then `xcodebuild -exportArchive` with `method=developer-id` | Current Xcode 26.2 export model | Makes the release boundary explicit and reusable by later notarization phases. |
| Implicit local Xcode signing | Explicit Team ID plus explicit `Developer ID Application` identity preflight | Current project need, aligned with Apple direct-distribution tooling | Prevents machine-specific release behavior. |
| Hidden hardened-runtime default | Explicit Release `ENABLE_HARDENED_RUNTIME = YES` | Required before later notarization work | Avoids a second signing boundary just to “fix” release settings. |
| Plaintext or ad hoc notarization credentials | Named Keychain profile via `notarytool store-credentials` | Current notarytool workflow | Keeps secrets out of source control and gives Phase 17 a stable input. |

**Deprecated/outdated:**
- `release.sh` as `clean build` plus DerivedData app pickup: outdated for the v1.6 release chain because it does not produce a distribution-grade export boundary.
- Release docs that instruct friends to bypass `隐私与安全性`: outdated for this milestone and must be replaced by maintainer-only signing/bootstrap instructions.

## Open Questions

1. **Does the maintainer already have a Developer ID Application certificate for Team `Y2YJ48R9GL`?**
   - What we know: local `security find-identity -v -p codesigning` shows only `Apple Development: 1617291164@qq.com (Y2YJ48R9GL)`.
   - What's unclear: whether the Developer ID certificate exists in another keychain or still needs to be created/downloaded from Apple.
   - Recommendation: Plan a manual bootstrap step plus a preflight failure message that prints the exact missing identity expectation.

2. **Should the release docs standardize on Apple ID + app-specific password bootstrap, or also document App Store Connect API key bootstrap for `notarytool`?**
   - What we know: `notarytool store-credentials` supports both Apple ID/app-specific password and API-key-based auth.
   - What's unclear: which credential path the maintainer prefers operationally.
   - Recommendation: Plan around the named profile contract only; document one primary bootstrap path and mention the other as an advanced alternative if needed.

## Environment Availability

| Dependency | Required By | Available | Version | Fallback |
|------------|------------|-----------|---------|----------|
| Xcode / `xcodebuild` | Archive/export build path | ✓ | Xcode 26.2 (17C52) | — |
| `xcrun notarytool` | Notary profile bootstrap and preflight | ✓ | 1.1.0 (39) | — |
| `codesign` | Signature inspection/verification | ✓ | Bundled system tool | — |
| `security` | Signing-identity discovery | ✓ | Bundled system tool | — |
| `plutil` | Export-options plist validation | ✓ | Bundled system tool | — |
| `hdiutil` | Later DMG packaging phases | ✓ | Bundled system tool | — |
| `spctl` | Later assessment phases | ✓ | Bundled system tool | — |
| `Developer ID Application` signing identity | Actual DIST-01 release execution | ✗ | — | None |
| Named notary keychain profile | Phase 16 preflight + Phase 17 notarization | ✗ | — | None |

**Missing dependencies with no fallback:**
- A `Developer ID Application: ...` identity is not installed in the checked keychain state; current machine output shows only `Apple Development`.
- The checked named notary profile (`TOOLS_CAT_NOTARY`) is not stored in Keychain.

**Missing dependencies with fallback:**
- None. The repo can implement the flow and docs without these prerequisites, but a real signed release cannot complete until the maintainer bootstraps them.

## Validation Architecture

### Test Framework
| Property | Value |
|----------|-------|
| Framework | XCTest / XCUITest via Xcode 26.2 |
| Config file | none — project and scheme are defined in `Tools Cat.xcodeproj` |
| Quick run command | `xcodebuild -project 'Tools Cat.xcodeproj' -scheme 'Tools Cat' -destination 'platform=macOS' -only-testing:'Tools CatTests/KeepAwakeMenuStateTests' test -quiet` |
| Full suite command | `xcodebuild -project 'Tools Cat.xcodeproj' -scheme 'Tools Cat' -destination 'platform=macOS' test -quiet` |

### Phase Requirements → Test Map
| Req ID | Behavior | Test Type | Automated Command | File Exists? |
|--------|----------|-----------|-------------------|-------------|
| DIST-01 | `release.sh` preflight requires explicit Team/identity/profile inputs and the release flow exports a Developer ID signed `.app` from an archive/export boundary | shell smoke / manual | `bash ./release.sh` with fixture env on a signing-ready machine | ❌ Wave 0 |
| DIST-05 | README + release doc explain signing identity, notary bootstrap, and preflight without committed secrets | manual docs review / grep smoke | `rg -n 'notarytool|Developer ID Application|Team ID|preflight' README.md docs/release` | ❌ Wave 0 |

### Sampling Rate
- **Per task commit:** `xcodebuild -project 'Tools Cat.xcodeproj' -scheme 'Tools Cat' -destination 'platform=macOS' -only-testing:'Tools CatTests/KeepAwakeMenuStateTests' test -quiet`
- **Per wave merge:** `xcodebuild -project 'Tools Cat.xcodeproj' -scheme 'Tools Cat' -destination 'platform=macOS' test -quiet`
- **Phase gate:** On a signing-ready machine, run the release preflight and export flow successfully once before `/gsd:verify-work`

### Wave 0 Gaps
- [ ] Add a lightweight shell validation harness or scripted smoke for `release.sh` preflight branches; current automated tests cover app/runtime code, not release scripts.
- [ ] Add a static check that Release build settings include `ENABLE_HARDENED_RUNTIME = YES` and that the old DerivedData app-pickup path is gone.
- [ ] Add a documentation verification step that rejects committed secret examples and proves the README points to the dedicated release doc.

## Sources

### Primary (HIGH confidence)
- Local Xcode 26.2 CLI (`xcodebuild -help`, `xcodebuild -version`, `xcodebuild -showBuildSettings`) - verified export methods, export-options keys, current signing state, and hardened-runtime state
- Local Apple CLI help (`xcrun notarytool --help`, `xcrun notarytool help store-credentials`, `xcrun notarytool help submit`, `xcrun stapler --help`, `codesign --help`) - verified current notarization/bootstrap and verification commands
- Apple Developer: Developer ID - https://developer.apple.com/developer-id/
- Apple Developer Documentation: Packaging Mac software for distribution - https://developer.apple.com/documentation/xcode/packaging-mac-software-for-distribution
- Apple Developer Documentation: Configuring the hardened runtime - https://developer.apple.com/documentation/xcode/configuring-the-hardened-runtime
- Apple Developer Documentation: Notarizing macOS software before distribution - https://developer.apple.com/documentation/security/notarizing_macos_software_before_distribution
- Apple Developer Documentation: Customizing the notarization workflow - https://developer.apple.com/documentation/security/customizing-the-notarization-workflow
- Local repo files: `release.sh`, `build_dmg.sh`, `README.md`, `Tools Cat.xcodeproj/project.pbxproj`, `Tools Cat/Tools_Cat.entitlements`, `.planning/research/STACK.md`, `.planning/research/ARCHITECTURE.md`, `.planning/research/FEATURES.md`

### Secondary (MEDIUM confidence)
- None required; the critical claims were verified directly from Apple tooling/docs and local repo state.

### Tertiary (LOW confidence)
- None.

## Metadata

**Confidence breakdown:**
- Standard stack: HIGH - Xcode 26.2 CLI help and Apple docs explicitly describe the Developer ID export and notarytool profile model.
- Architecture: HIGH - phase decisions lock the entrypoint and archive/export boundary, and the repo’s current scripts clearly show what must change.
- Pitfalls: MEDIUM - strongly supported by current repo state and Apple workflow expectations, but some failure modes will only be fully proven once a real Developer ID identity is available.

**Research date:** 2026-04-16
**Valid until:** 2026-05-16
