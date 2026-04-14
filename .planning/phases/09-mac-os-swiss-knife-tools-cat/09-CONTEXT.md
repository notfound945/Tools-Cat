# Phase 9: mac-os-swiss-knife-tools-cat - Context

**Gathered:** 2026-04-13
**Status:** Ready for planning

<domain>
## Phase Boundary

Unify the shipped app, project metadata, packaging scripts, test targets, and current planning/docs under the new product name `Tools Cat`. This phase covers a true product rename rather than a surface-only copy pass, so downstream work may rename Xcode targets, scheme/module-derived names, bundle identifiers, app/test artifact names, scripts, and user-facing brand strings that still say `Mac OS Swiss Knife` or `Swiss Knife`.

It does not add new user features, change the shipped menu/WOL/keep-awake behavior, introduce a Chinese-localized alternate brand, or create a dual-brand transition period.

</domain>

<decisions>
## Implementation Decisions

### Rename depth
- **D-01:** Phase 9 should be a full rename, not a docs-only or UI-only pass.
- **D-02:** The rename should cover project-facing and build-facing identifiers as well as runtime branding: Xcode target names, scheme names, generated artifact names, module-derived names, test target names, packaging script defaults, and current planning/docs.

### Identifier migration
- **D-03:** Bundle identifiers should migrate with the product rename instead of preserving the old `Mac-OS-Swiss-Knife` family.
- **D-04:** Test bundle identifiers and any app/test host references should move in the same pass so the repo does not keep a mixed old/new identity.

### Runtime naming
- **D-05:** Chinese UI copy should still use the English brand `Tools Cat` where a product name is shown; do not introduce a separate Chinese brand name.
- **D-06:** Existing repo convention still applies outside branding: user-facing functional copy remains Chinese, while type/API names stay English unless a generated target/module name must change because the Xcode target name changed.

### Migration strategy
- **D-07:** This should be a hard cut to `Tools Cat`; do not keep a dual-brand transition period in repo docs or app-facing copy.
- **D-08:** Downstream work may keep narrowly historical references only where archival planning artifacts must preserve past truth, but current active docs and shipped-product surfaces should no longer present `Mac OS Swiss Knife` as the live name.

### the agent's Discretion
- Exact sequencing for renaming directories, project references, generated test filenames, and script defaults, as long as the final repo builds and tests under the new name.
- Whether legacy historical names need brief archival notes inside milestone/phase history files, as long as current-facing docs and active build paths hard-switch to `Tools Cat`.
- Exact normalization of underscore/hyphen variants created by Xcode after target renames, as long as the new naming remains internally consistent.

</decisions>

<canonical_refs>
## Canonical References

**Downstream agents MUST read these before planning or implementing.**

### Phase scope and current milestone state
- `.planning/ROADMAP.md` — Defines Phase 9 as the rename phase appended after Phase 8 and records its current high-level goal.
- `.planning/PROJECT.md` — Current project narrative and milestone framing that still use the old product name and therefore must be reconciled.
- `.planning/STATE.md` — Current session state and roadmap evolution; confirms Phase 9 is pending planning after Phase 7 closure.

### Product requirements and repo guidance
- `.planning/REQUIREMENTS.md` — Confirms this milestone is still a hardening-oriented follow-up and should not absorb unrelated new capabilities during the rename.
- `README.md` — Current user/developer-facing setup, build, and packaging instructions that still use the old app/scheme/artifact names.
- `CLAUDE.md` — Repo-specific engineering guidance and codebase map that currently use the old product name throughout.

### Build, packaging, and project identity
- `Mac OS Swiss Knife.xcodeproj/project.pbxproj` — Source of truth for target names, scheme-visible names, product names, bundle identifiers, test host wiring, entitlements path, and generated app/test artifact names.
- `build_dmg.sh` — Current DMG helper with old app path, DMG name, and volume name defaults.
- `release.sh` — Current release wrapper with old scheme and packaging defaults.
- `scripts/run_menu_bar_verification_slice.sh` — Current verification script with old project, scheme, and test-target references.

### Existing code and tests that expose shipped branding
- `Mac OS Swiss Knife/StatusBarController.swift` — Contains live app-facing branding in the quit menu item (`退出 Swiss Knife`).
- `Mac OS Swiss Knife/Mac_OS_Swiss_KnifeApp.swift` — Current app entry filename/type derived from the old target name.
- `Mac OS Swiss KnifeTests/StatusBarControllerMenuPolishTests.swift` — Locks the current quit-row string and will need to move with the rename.
- `Mac OS Swiss KnifeTests/Mac_OS_Swiss_KnifeTests.swift` — Current unit-test scaffold and module import pattern derived from the old target name.
- `Mac OS Swiss KnifeUITests/Mac_OS_Swiss_KnifeUITests.swift` — Current UI-test scaffold and launch target bundle identifier derived from the old target name.

### Codebase conventions that constrain the rename
- `.planning/codebase/CONVENTIONS.md` — Documents the current filename and generated underscore-name conventions tied to the old target name.
- `.planning/codebase/STRUCTURE.md` — Documents the current directory layout and target-directory naming, which the rename phase will likely change.
- `.planning/codebase/STACK.md` — Documents current build/runtime assumptions, scheme names, and packaging outputs tied to the old product identity.

</canonical_refs>

<code_context>
## Existing Code Insights

### Reusable Assets
- `Mac OS Swiss Knife.xcodeproj/project.pbxproj`: Central place to update target names, product names, bundle IDs, test host references, entitlements path, and generated artifact names in one coordinated pass.
- `build_dmg.sh` and `release.sh`: Already centralize DMG/build naming defaults, so product rename fallout in packaging should be handled there instead of scattered shell snippets.
- `scripts/run_menu_bar_verification_slice.sh`: Centralizes the canonical verification command and therefore is the right place to update project/scheme/test target references after renaming.

### Established Patterns
- The repo currently mirrors the Xcode product name directly into target directories, test target names, generated underscore filenames, shell defaults, and planning/docs.
- Runtime strings are mostly Chinese, but product/type/API identifiers are English; brand replacement should preserve that general pattern.
- Planning artifacts under `.planning/` are treated as current operational truth, so active docs should hard-switch with the codebase instead of lagging behind.

### Integration Points
- Project rename work will center on `Mac OS Swiss Knife.xcodeproj/project.pbxproj`, then ripple into source/test paths, generated entry/test filenames, and shell automation that references those names.
- App-facing brand updates will need coordinated changes between `StatusBarController.swift`, tests that assert current branding, and docs/scripts that describe the shipped app.
- Planning/docs reconciliation will touch `README.md`, `CLAUDE.md`, `.planning/PROJECT.md`, `.planning/ROADMAP.md`, `.planning/REQUIREMENTS.md`, and any active phase artifacts that still present the old name as current truth.

</code_context>

<specifics>
## Specific Ideas

- Treat this as a repo-wide rename from `Mac OS Swiss Knife` / `Swiss Knife` to `Tools Cat`, not just a visible menu-label cleanup.
- Rename the Xcode identity stack together: app target, test targets, scheme-visible names, module-derived names, `.app` output, DMG defaults, and bundle identifier family.
- Keep Chinese functional copy where it already exists, but whenever the product name itself appears, show `Tools Cat`.

</specifics>

<deferred>
## Deferred Ideas

- Introducing a separate Chinese brand name for `Tools Cat`.
- Keeping legacy app IDs or docs as a compatibility alias beyond narrow historical/archive notes.
- Any distribution work such as signing/notarization cleanup that might be convenient to do during the rename but is not required to complete it.

</deferred>

---

*Phase: 09-mac-os-swiss-knife-tools-cat*
*Context gathered: 2026-04-13*
