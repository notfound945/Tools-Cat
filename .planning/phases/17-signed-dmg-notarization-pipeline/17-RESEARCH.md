# Phase 17: Signed DMG Notarization Pipeline - Research

**Researched:** 2026-04-16
**Domain:** macOS Developer ID signed DMG notarization, stapling, and release-failure surfacing
**Confidence:** HIGH

<phase_constraints>
## Phase Constraints (derived from ROADMAP.md, REQUIREMENTS.md, PROJECT.md, and Phase 16)

### Locked Decisions
- **R-01:** `release.sh` remains the single maintainer-facing release command. Phase 17 must extend the Phase 16 archive/export seam instead of inventing a second public release path.
- **R-02:** `build_dmg.sh` may stay as the deterministic DMG-packaging helper, but signing, notarization, stapling, and failure reporting must wrap around that seam in the main release flow.
- **R-03:** The milestone remains release-only. Phase 17 must not reopen shipped WOL or keep-awake behavior beyond the regression checks needed to prove release hardening did not disturb the app.
- **R-04:** Credentials must continue to stay out of source control. The release flow should keep using the named Keychain-backed `RELEASE_NOTARY_PROFILE` from Phase 16.
- **R-05:** Day-to-day Xcode automatic signing stays intact for development. Phase 17 should build on the explicit Release Team ID and hardened-runtime readiness that Phase 16 already introduced.
- **R-06:** Phase 17 should produce the final signed `Tools-Cat.dmg`, submit it to Apple with `notarytool`, wait for the result, surface rejection logs clearly, staple the accepted ticket, and run local assessment checks.

### The Agent's Discretion
- Exact helper-script split under `scripts/release/`, as long as the public maintainer story stays `sh ./release.sh`.
- Exact output paths for notary metadata, as long as the final artifact remains `dist/Tools-Cat.dmg` and the failure logs are deterministic and discoverable.
- Exact static-gate naming, as long as the repo can verify the signed-DMG and notarization seam without requiring real Apple credentials on every machine.
</phase_constraints>

<phase_requirements>
## Phase Requirements

| ID | Description | Research Support |
|----|-------------|------------------|
| DIST-02 | Maintainer can produce a Developer ID signed `Tools-Cat.dmg` that contains the distributable app bundle | Keep `release.sh` as the orchestrator, call `build_dmg.sh` on the exported app, sign the DMG, and inspect the DMG signature before notarization. |
| DIST-03 | Maintainer can submit the final DMG to Apple with `notarytool`, wait for completion, and get actionable failure information when notarization is rejected | Add a deterministic `notarytool submit` + `wait` flow, persist the submission result, and fetch `notarytool log` on rejection. |
| DIST-04 | The DMG sent to friends is stapled with a successful notarization ticket and passes local Gatekeeper assessment | Run `stapler staple`, `stapler validate`, and `spctl --assess` against the final DMG after a successful notarization. |
</phase_requirements>

## Summary

Phase 17 should harden the Phase 16 signed-app seam into the final signed and notarized DMG distribution path. The key architectural move is to keep `release.sh` as the public command, treat `build_dmg.sh` as the packaging helper that turns `dist/export/Tools Cat.app` into `dist/Tools-Cat.dmg`, then wrap DMG signing, notarization, stapling, and local assessment around that deterministic path.

The repo already has the hardest prerequisite in place: a fail-fast archive/export pipeline that emits a Developer ID signed app and validates the named `RELEASE_NOTARY_PROFILE` before the build. The remaining gap is entirely outside the app bundle itself. `build_dmg.sh` still creates an unsigned `UDZO` image, the repo does not submit anything to Apple, and the current release docs still stop at the `.app` boundary. Phase 17 must close that outer packaging and notarization loop without reopening the app-signing decisions that Phase 16 just locked.

**Primary recommendation:** Keep the current archive/export app seam unchanged, sign the produced `Tools-Cat.dmg` with the existing Developer ID Application identity, notarize the DMG with `notarytool`, fetch the notary log on rejection, staple the accepted DMG, and verify the stapled disk image locally with `stapler validate` and `spctl --assess`.

## Current Repo State

- `release.sh` stops at `dist/export/Tools Cat.app`; it does not call `build_dmg.sh`, `notarytool`, `stapler`, or `spctl`.
- `build_dmg.sh` still creates a plain `UDZO` image in `dist/` and prints a stale note that the DMG is not notarized.
- The repo already has:
  - `scripts/release/preflight-signing.sh`
  - `scripts/release/export-options-developer-id.plist.template`
  - `scripts/release/inspect-signature.sh`
  - `scripts/release/verify-release-readiness.sh`
  - `scripts/release/verify-release-docs.sh`
- The current release docs in `docs/release/signing-readiness.md` explicitly defer DMG signing, notarization submission, stapling, and Gatekeeper verification to Phase 17+.

## Standard Stack

### Core
| Tool | Version / Surface | Purpose | Why Standard |
|------|-------------------|---------|--------------|
| `codesign` | macOS system tool | Sign and inspect the final DMG | The repo already relies on `codesign` for the exported app; extending it to the DMG keeps the trust chain explicit and Apple-native. |
| `hdiutil` + `ditto` | macOS system tools | Build the final `UDZO` DMG from the exported app | `build_dmg.sh` already uses these tools and is the correct seam to keep for deterministic packaging. |
| `xcrun notarytool submit` / `wait` / `log` | notarytool 1.1.0 (39) | Upload the DMG, wait for completion, and retrieve rejection logs | Local CLI help confirms all three subcommands are available and cover the complete notarization feedback loop. |
| `xcrun stapler` | macOS system tool | Attach and validate the notarization ticket on the DMG | Local help confirms `stapler` supports `staple` and `validate` for `UDIF` disk images. |
| `spctl` | macOS system tool | Run Gatekeeper-style local assessment against the final DMG | This is the native local assessment seam that should back the release flow before Phase 18 formalizes broader install verification. |

### Supporting
| Tool | Purpose | When to Use |
|------|---------|-------------|
| `plutil` | Parse `notarytool` plist output and verify generated metadata | Use in the notarization helper to extract submission IDs and statuses without introducing new dependencies. |
| `scripts/release/verify-release-readiness.sh` | Static gate for the app-signing seam from Phase 16 | Keep running this in Phase 17 so DMG work does not regress the archive/export boundary. |
| `scripts/release/verify-release-docs.sh` | Static gate for the maintainer-facing release docs | Update it once Phase 17 changes the public release contract. |

### Important Inference

- `xcodebuild -help` shows `installerSigningCertificate` as an export-options key for installer exports. This repo ships a `UDIF` disk image, not a flat installer package, so Phase 17 should keep using the existing `Developer ID Application` identity for app and DMG signing rather than introducing `Developer ID Installer`.

## Architecture Patterns

### Pattern 1: Keep `release.sh` as the sole orchestrator
**What:** Extend the Phase 16 release pipeline in place instead of introducing a second top-level release command.
**Why:** The repo has already committed to `sh ./release.sh` as the maintainer-facing truth. A second command or a sidecar notarization script would split the supported release story immediately after Phase 16 established it.

### Pattern 2: Treat `build_dmg.sh` as the packer seam, not the full release story
**What:** Keep `build_dmg.sh` small and deterministic: stage the exported app, add the `/Applications` symlink, and emit `dist/Tools-Cat.dmg`.
**Why:** The outer trust chain belongs in `release.sh`; the DMG helper should remain reusable and easy to inspect.

### Pattern 3: Persist notarization metadata in a deterministic build path
**What:** Save the notarization submission response and rejection log under a stable directory such as `build/notary/`.
**Why:** Rejections are only actionable if the maintainer can find the exact submission ID and Apple log without rerunning the upload or scraping stdout.

### Pattern 4: Separate submission from assessment
**What:** One helper should own `notarytool submit` / `wait` / `log`, and a second helper should own `stapler validate` plus `spctl --assess`.
**Why:** Submission failure handling and post-acceptance local verification are different concerns. Splitting them keeps the shell surface readable and easier to statically verify.

## Recommended Project Structure

```text
release.sh
build_dmg.sh
scripts/release/
├── preflight-signing.sh
├── export-options-developer-id.plist.template
├── inspect-signature.sh
├── inspect-dmg-signature.sh
├── notarize-dmg.sh
├── assess-notarized-dmg.sh
├── verify-release-readiness.sh
├── verify-release-notarization.sh
└── verify-release-docs.sh
build/
└── notary/
    ├── Tools-Cat-notary-submit.plist
    └── Tools-Cat-notary-log.json
dist/
├── export/Tools Cat.app
└── Tools-Cat.dmg
```

## Common Pitfalls

### Pitfall 1: Signing the wrong artifact
**What goes wrong:** The script notarizes the exported `.app` or a stale DMG path instead of the exact `dist/Tools-Cat.dmg` that will be shared.
**How to avoid:** Normalize on one DMG path, print it, sign it, notarize it, staple it, and assess that same path.

### Pitfall 2: Hiding notarization failures behind `--wait`
**What goes wrong:** `notarytool submit --wait` fails, but the release script does not fetch the Apple log, so the maintainer still has no actionable rejection details.
**How to avoid:** Persist the submit result, extract the submission ID, and run `notarytool log` automatically on non-accepted status.

### Pitfall 3: Leaving stale manual-allow language in public docs
**What goes wrong:** The code begins shipping a notarized DMG, but `README.md` or the release doc still tell people to use manual Gatekeeper overrides or still describe the Phase 16 `.app` boundary as current.
**How to avoid:** Update the docs and docs gate in the same phase that changes the release contract.

### Pitfall 4: Pulling fresh-machine install proof into Phase 17
**What goes wrong:** The phase bloats from release automation into full distribution verification closure.
**How to avoid:** Keep Phase 17 focused on producing and locally assessing the notarized/stapled DMG; leave repeatable fresh-machine/manual verification and broader regression closure to Phase 18.

### Pitfall 5: Introducing new credential surfaces
**What goes wrong:** The phase adds plaintext Apple ID, app-specific passwords, or API keys to repo files or shell defaults.
**How to avoid:** Keep using the named `RELEASE_NOTARY_PROFILE` and document only Keychain-backed setup.

## Anti-Patterns to Avoid

- Do not reintroduce a DerivedData-based release path just because the phase is DMG-focused.
- Do not bypass `build_dmg.sh` with an entirely separate packaging implementation.
- Do not make `build_dmg.sh` the only public command; Phase 16 already decided that `release.sh` is the sole maintainer-facing entrypoint.
- Do not rely on third-party notarization wrappers when the local Apple CLI already provides the required primitives.
- Do not claim Phase 18 verification outcomes in Phase 17 docs or scripts.

## Validation Architecture

### Quick Path
- `bash scripts/release/verify-release-readiness.sh`
- `bash scripts/release/verify-release-notarization.sh`
- `bash scripts/release/verify-release-docs.sh`

### Full Path
- Run all quick-path shell gates
- Run the established Phase 15 direct-launch regression slice:
  - `xcodebuild test -project "Tools Cat.xcodeproj" -scheme "Tools Cat" -destination 'platform=macOS' -parallel-testing-enabled NO -only-testing:'Tools CatTests/DeviceLibrarySessionModelTests' -only-testing:'Tools CatTests/DeviceLibraryManagementPresentationTests' -only-testing:'Tools CatUITests/Tools_CatUITests/testLaunchWithEmptyDeviceLibraryShowsPolishedEmptyState' -only-testing:'Tools CatUITests/Tools_CatUITests/testLaunchWithSeededDeviceLibraryShowsManagementWindow' -only-testing:'Tools CatUITests/Tools_CatUITests/testLaunchWithSeededDeviceLibraryShowsManagementListSurface'`

### Manual Boundary
- A credentialed maintainer must run the real `sh ./release.sh` flow on a machine that has:
  - the Developer ID Application certificate
  - the named `TOOLS_CAT_NOTARY` Keychain profile
- Phase 17 should prove:
  - `dist/Tools-Cat.dmg` exists
  - the notarization submission is accepted
  - the DMG is stapled and locally assessable
- Phase 18 still owns the broader repeatable verification contract and clean-environment install proof.

## References

- Local repo: `release.sh`, `build_dmg.sh`, `README.md`, `docs/release/signing-readiness.md`, `scripts/release/*`
- Phase 16 artifacts: `.planning/phases/16-release-signing-readiness/16-RESEARCH.md`, `.planning/phases/16-release-signing-readiness/16-VERIFICATION.md`
- Local tool help:
  - `xcodebuild -help`
  - `xcrun notarytool help submit`
  - `xcrun notarytool help wait`
  - `xcrun notarytool help log`
  - `xcrun stapler -h`
  - `spctl` basic usage

---
*Phase: 17-signed-dmg-notarization-pipeline*
*Research completed: 2026-04-16*
