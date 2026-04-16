# Roadmap: Tools Cat

## Milestones

- ✅ **v1.0 MVP** — Phases 1-5 shipped 2026-04-13. Archive: `.planning/milestones/v1.0-ROADMAP.md`
- ✅ **v1.1 Hardening** — Phases 6-9 shipped 2026-04-13. Archive: `.planning/milestones/v1.1-ROADMAP.md`
- ✅ **v1.2 Menu Truth** — Phases 10-11 shipped 2026-04-15. Archive: `.planning/milestones/v1.2-ROADMAP.md`
- ✅ **v1.3 Duration Management** — Phases 12-13 shipped 2026-04-16. Archive: `.planning/milestones/v1.3-ROADMAP.md`
- ✅ **v1.4 Duration UI Polish** — Phase 14 shipped 2026-04-16. Archive: `.planning/milestones/v1.4-ROADMAP.md`
- ✅ **v1.5 Device Library UI Parity** — Phase 15 shipped 2026-04-16. Archive: `.planning/milestones/v1.5-ROADMAP.md`
- 🚧 **v1.6 Distribution Hardening** — Phases 16-18 planned 2026-04-16

## Overview

This milestone is intentionally operational rather than product-facing. `Tools Cat` already ships the wake and keep-awake behavior it needs; the gap is that the current DMG is explicitly not notarized and still requires manual Gatekeeper approval. The milestone goal is to keep the existing DMG distribution shape, but harden it into a friend-installable release chain with Developer ID signing, notarization, stapling, and explicit verification.

## Phases

**Phase Numbering:**
- Integer phases continue from the last shipped milestone
- v1.6 therefore starts at Phase 16

- [x] **Phase 16: Release Signing Readiness** - Make the project and release flow produce a distribution-signed app with clear signing/notary prerequisites. (completed 2026-04-16)
- [ ] **Phase 17: Signed DMG Notarization Pipeline** - Upgrade packaging so the shipped DMG is signed, notarized, stapled, and release-scripted. (human verification pending)
- [ ] **Phase 18: Distribution Verification Closure** - Close the milestone with repeatable verification and regression proof that release hardening did not change shipped app behavior.

## Phase Details

### Phase 16: Release Signing Readiness
**Goal**: The maintainer can build a Developer ID signed `Tools Cat.app` through a release flow that clearly surfaces the required signing identity and notarization prerequisites.
**Depends on**: Phase 15
**Requirements**: DIST-01, DIST-05
**Plans**: 2/2 plans complete
Plans:
- [x] `16-01-PLAN.md` — Replace the local DerivedData release path with fail-fast preflight plus Developer ID archive/export signing readiness.
- [x] `16-02-PLAN.md` — Rewrite maintainer release docs around the explicit signing bootstrap and signed-app export contract.
**Success Criteria** (what must be TRUE):
  1. The release path can produce a distribution-signed `Tools Cat.app` that is suitable for direct distribution outside the Mac App Store.
  2. The project/release configuration makes hardened-runtime and signing readiness explicit enough to support later notarization work.
  3. The repo documents the required signing identity, notarization credential bootstrap, and release preflight without storing sensitive credentials in source control.

### Phase 17: Signed DMG Notarization Pipeline
**Goal**: The release flow produces the final signed `Tools-Cat.dmg`, notarizes it with `notarytool`, staples the result, and fails clearly on any notarization rejection.
**Depends on**: Phase 16
**Requirements**: DIST-02, DIST-03, DIST-04
**Plans**: 0/0 plans complete
**Success Criteria** (what must be TRUE):
  1. The release process outputs a Developer ID signed `Tools-Cat.dmg` that contains the distributable app bundle.
  2. The release process can submit the final DMG to Apple with `notarytool`, wait for completion, and surface actionable failure information when notarization is rejected.
  3. A successful release staples the notarization ticket to the DMG and the final artifact passes local Gatekeeper assessment.

### Phase 18: Distribution Verification Closure
**Goal**: The repo closes the milestone with a repeatable verification path that proves friend installability without regressing shipped WOL or keep-awake behavior.
**Depends on**: Phase 17
**Requirements**: DIST-06, DIST-07
**Plans**: 0/0 plans complete
**Success Criteria** (what must be TRUE):
  1. The repo provides a repeatable local verification checklist that proves the shipped artifact is ready for friend installation without manual `隐私与安全性` overrides.
  2. The verification boundary includes a focused regression check showing that WOL and keep-awake behavior remain unchanged by the release hardening work.
  3. Release-facing docs and validation artifacts agree on how to verify installability and what still requires a fresh-machine/manual smoke.

## Progress

**Execution Order:**
Phases execute in numeric order: 16, 17, 18

| Phase | Plans Complete | Status | Completed |
|-------|----------------|--------|-----------|
| 16. Release Signing Readiness | 2/2 | Complete    | 2026-04-16 |
| 17. Signed DMG Notarization Pipeline | 2/2 | Verification Pending | - |
| 18. Distribution Verification Closure | 0/0 | Not started | - |
