# Phase 18: Distribution Verification Closure - Context

**Gathered:** 2026-04-17
**Status:** Ready for planning

<domain>
## Phase Boundary

Close the v1.6 milestone around the current non-notarized friend-share DMG contract. This phase does not reopen signing or notarization work, and it does not add new end-user WOL or keep-awake features. Its job is to make the verification story repeatable: prove the shipped `dist/Tools-Cat.dmg` has the expected friend-share layout, document the exact manual-open path friends may need, and rerun a focused regression slice that shows release hardening did not change shipped WOL or keep-awake behavior.

</domain>

<decisions>
## Implementation Decisions

### Verification entrypoint
- **D-01:** `release.sh` remains the single public release build command.
- **D-02:** Phase 18 should add one explicit post-release verification command so maintainers can rerun the friend-share checks without remembering multiple scripts.

### Artifact verification scope
- **D-03:** Automated verification must inspect the real shipped `dist/Tools-Cat.dmg`, not just static script text.
- **D-04:** The artifact check must prove the DMG contains `Tools Cat.app` plus the `/Applications` shortcut that friends use during install.

### Manual-open truth
- **D-05:** The maintainer docs must spell out the exact friend-side first-launch path: drag to `/Applications`, then use “右键打开”.
- **D-06:** The docs must keep the quarantine-removal command as the fallback only when Gatekeeper still blocks launch.

### Regression boundary
- **D-07:** Verification must include focused WOL and keep-awake regressions so distribution hardening does not claim to be release-only without evidence.
- **D-08:** The regression slice should reuse existing test seams where possible instead of inventing a new harness just for this phase.

### Verification limit
- **D-09:** Phase 18 should state clearly that automated/local verification still does not prove a fresh-machine or real friend-side Gatekeeper experience end-to-end.

### the agent's Discretion
- Exact split between helper scripts, as long as maintainers get one clear verification command and the lower-level checks stay readable.
- Exact focused regression mix, as long as both WOL and keep-awake behavior are covered by existing trustworthy tests.
- Exact wording split between `README.md` and the dedicated release doc, as long as the README stays short and the detailed verification/manual-open contract lives in `docs/release/signing-readiness.md`.

</decisions>

<canonical_refs>
## Canonical References

**Downstream agents MUST read these before planning or implementing.**

### Phase scope and milestone truth
- `.planning/ROADMAP.md` — Defines Phase 18 goal, dependency chain, and success criteria.
- `.planning/REQUIREMENTS.md` — `DIST-06` and `DIST-07`, plus the v1.6 out-of-scope rule that keeps this phase release-only.
- `.planning/PROJECT.md` — Records the 2026-04-17 pivot away from Apple Developer Program dependencies and the active friend-share DMG contract.
- `.planning/STATE.md` — Confirms Phase 18 is the active next phase after the pivot.

### Prior release-chain truth
- `.planning/phases/16-release-signing-readiness/16-VERIFICATION.md` — Historical release verification baseline that Phase 18 must not regress.
- `.planning/phases/17-signed-dmg-notarization-pipeline/17-VERIFICATION.md` — Historical verification snapshot kept only as superseded context.

### Current repo release surface
- `README.md` — Public short-form release entrypoint that must stay truthful.
- `docs/release/signing-readiness.md` — Canonical maintainer runbook for the current friend-share DMG flow.
- `release.sh` — Canonical release build command.
- `build_dmg.sh` — Final DMG packaging seam.
- `scripts/release/verify-release-readiness.sh` — Static gate for the friend-share release contract.
- `scripts/release/verify-release-docs.sh` — Static gate for release doc truth.
- `scripts/run_menu_bar_verification_slice.sh` — Existing focused controller/UI regression seam that already covers menu-bar WOL and keep-awake behavior.

</canonical_refs>

<code_context>
## Existing Code Insights

### Reusable Assets
- `scripts/release/verify-release-readiness.sh`: already proves the release contract pivot statically and should remain part of any higher-level verification command.
- `scripts/release/verify-release-docs.sh`: already rejects stale release docs and should grow with the Phase 18 verification contract.
- `scripts/run_menu_bar_verification_slice.sh`: already reruns the controller/UI seam for WOL and keep-awake menu behavior and can be reused instead of duplicated.
- `Tools CatTests/WOLSessionModelTests.swift` and `Tools CatTests/KeepAwakeSessionModelTests.swift`: stable model-level seams for the two runtime behaviors Phase 18 must protect.

### Established Patterns
- Release automation is shell-first, explicit, and uses small helpers under `scripts/release/`.
- Verification scripts prefer `set -euo pipefail`, fail-fast checks, and clear stdout notes about what remains manual.
- The project already treats live tray clicks and fresh-machine install proof as explicit manual boundaries instead of overstating automation.

### Integration Points
- The new Phase 18 verification command should compose `verify-release-readiness.sh`, `verify-release-docs.sh`, one DMG-layout helper, and the focused regression slice.
- The dedicated release doc should name both the automated verification command and the remaining manual/fresh-machine boundary.

</code_context>

<specifics>
## Specific Ideas

- One maintainer command after `sh ./release.sh` should prove the repo-side verification contract end-to-end.
- The DMG check should mount the artifact and inspect its contents instead of trusting the packer script blindly.
- Focused regressions should stay centered on WOL and keep-awake truth, not broaden into unrelated device-library coverage.

</specifics>

<deferred>
## Deferred Ideas

None — discussion stayed within phase scope.

</deferred>

---

*Phase: 18-distribution-verification-closure*
*Context gathered: 2026-04-17*
