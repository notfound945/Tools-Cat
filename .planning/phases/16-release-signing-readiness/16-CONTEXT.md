# Phase 16: Release Signing Readiness - Context

**Gathered:** 2026-04-16
**Status:** Ready for planning

<domain>
## Phase Boundary

Make the repo and release flow produce a Developer ID signed `Tools Cat.app` through a distribution-grade build path, while documenting the required signing identity and future notarization prerequisites clearly enough that later phases can add signed DMG notarization and verification without reopening the build boundary.

This phase is release-chain hardening only. It does not change shipped WOL or keep-awake behavior, and it does not yet own DMG signing, notarization, stapling, or distribution verification closure.

</domain>

<decisions>
## Implementation Decisions

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

</decisions>

<canonical_refs>
## Canonical References

**Downstream agents MUST read these before planning or implementing.**

### Phase scope and milestone constraints
- `.planning/ROADMAP.md` — Phase 16 goal, dependency boundary, and success criteria for release-signing readiness.
- `.planning/REQUIREMENTS.md` — `DIST-01` and `DIST-05`, plus the v1.6 out-of-scope rules that keep this milestone release-only.
- `.planning/PROJECT.md` — current milestone goals, release-only boundary, and active decision to keep v1.6 focused on installability rather than product expansion.
- `.planning/STATE.md` — current milestone state and active phase tracking.

### Release-chain research
- `.planning/research/ARCHITECTURE.md` — target release-chain shape, fail-fast philosophy, and preference to keep `release.sh` as the main orchestration seam.
- `.planning/research/FEATURES.md` — release-chain MVP, anti-features, and prerequisites expected for friend-installable distribution.
- `.planning/research/STACK.md` — Apple-native stack recommendation, explicit identity handling, and archive/export direction for distribution builds.

### Current repo release surface
- `.planning/codebase/CONCERNS.md` — current release-script concerns, archive/export recommendation, and distribution trust gap.
- `README.md` — current public release instructions that still describe the unnotarized/manual-allow flow and therefore must be superseded.

</canonical_refs>

<code_context>
## Existing Code Insights

### Reusable Assets
- `release.sh`: Existing maintainer-facing release entrypoint that already centralizes build orchestration and should absorb the Phase 16 signing/distribution flow.
- `build_dmg.sh`: Small deterministic DMG-packaging helper that can stay focused on packaging while the broader release chain grows around it.
- `Tools Cat.xcodeproj/project.pbxproj`: Current signing/build settings source, including automatic signing, bundle identifier, entitlements path, and the build configurations that the release path must harden.

### Established Patterns
- Release automation is shell-first, explicit, and Apple-native: `xcodebuild`, `ditto`, and `hdiutil` are the established primitives.
- Existing scripts use `set -euo pipefail` and simple environment overrides rather than hidden tool wrappers.
- The repo prefers one explicit operational path over multiple clever variants; prior project decisions already emphasize truthful, readable automation.

### Integration Points
- `release.sh` is the integration point for preflight checks, explicit identity selection, archive/export orchestration, and later handoff to DMG signing/notarization work.
- `build_dmg.sh` remains the downstream packaging seam after the signed/exported app is produced.
- `README.md` and the new release checklist/doc become the maintainer-facing documentation surface for prerequisites and supported release commands.
- `Tools Cat/Tools_Cat.entitlements` is the signing/notarization entitlement boundary and should stay minimal and intentional.

</code_context>

<specifics>
## Specific Ideas

- One maintainer command should stay canonical: `release.sh`.
- Release-time identity must be explicit instead of relying on whatever Xcode local state happens to choose.
- The app build boundary should become archive/export now, not in a later phase.
- Documentation should be split into a short README entrypoint plus a dedicated release checklist/procedure.
- Preflight should fail before build if required tools, signing identity inputs, or the named future notary profile are missing.

</specifics>

<deferred>
## Deferred Ideas

None — discussion stayed within phase scope.

</deferred>

---

*Phase: 16-release-signing-readiness*
*Context gathered: 2026-04-16*
