# Phase 16: Release Signing Readiness - Discussion Log

> **Audit trail only.** Do not use as input to planning, research, or execution agents.
> Decisions are captured in CONTEXT.md — this log preserves the alternatives considered.

**Date:** 2026-04-16
**Phase:** 16-release-signing-readiness
**Areas discussed:** Release entrypoint shape, Signing configuration source, Distribution build boundary, Documentation and preflight strictness

---

## Release entrypoint shape

| Option | Description | Selected |
|--------|-------------|----------|
| A | Keep `release.sh` as the single canonical maintainer-facing release entrypoint; helpers may exist internally. | ✓ |
| B | Split immediately into multiple first-class scripts such as `release_app.sh`, `sign_dmg.sh`, and `notarize.sh`. | |
| C | Keep `release.sh`, but expose multiple parallel public entrypoints for maintainers to choose from. | |

**User's choice:** `1A`
**Notes:** User accepted the recommended single-entrypoint model so the release surface stays simple while later phases extend the same command.

---

## Signing configuration source

| Option | Description | Selected |
|--------|-------------|----------|
| A | Keep Xcode automatic signing for development, but require explicit release-time identity inputs and validate them in the release script. | ✓ |
| B | Rely fully on Xcode automatic signing and only verify the produced app after build. | |
| C | Push as much release identity configuration as possible into project settings instead of the release flow. | |

**User's choice:** `2A`
**Notes:** User wants the release path to stop depending on local Xcode guesswork while keeping day-to-day development lightweight.

---

## Distribution build boundary

| Option | Description | Selected |
|--------|-------------|----------|
| A | Keep the current `xcodebuild clean build` + DerivedData app pickup flow for now, and defer archive/export. | |
| B | Move to an archive/export-style distribution build boundary now in Phase 16. | ✓ |
| C | Keep both paths, with `clean build` still the default and archive/export available as an alternate path. | |

**User's choice:** `3B`
**Notes:** User explicitly chose to make archive/export the canonical app-output boundary in Phase 16 so later notarization work can build on the same path.

---

## Documentation and preflight strictness

| Option | Description | Selected |
|--------|-------------|----------|
| A | Update both `README.md` and a dedicated release document/checklist; fail fast before build when tools, identities, or the future notary profile are missing. | ✓ |
| B | Update only `README.md`, but still fail fast in the script. | |
| C | Keep docs light and let missing prerequisites fail later during the build/release run. | |

**User's choice:** `4A`
**Notes:** User chose the strictest operational model: short README entrypoint, detailed release doc, and preflight checks before build time is spent.

---

## the agent's Discretion

- Helper-script factoring behind `release.sh`
- Exact names of release-time variables and flags
- Exact archive/export command wiring and output staging
- Exact split of summary versus detail between `README.md` and the dedicated release doc

## Deferred Ideas

None.
