---
phase: 08
slug: validation-debt-closure
status: complete
created: 2026-04-13
updated: 2026-04-13
source: local-research
---

# Phase 8: Validation Debt Closure - Research

## Summary

Phase 8 is not new feature work. The current Phase 01-04 validation files are mostly stale validation contracts that still describe pre-execution `Wave 0` gaps, missing test files, scaffold-only UI coverage, and pending sign-off even though the codebase, verification reports, resolved HUMAN-UAT files, and current local test runs now prove otherwise.

The safest scope is therefore a documentation-truth pass over the four validation files:

1. Rebaseline Phase 01-02 validation docs against the current test inventory and resolved human verification.
2. Rebaseline Phase 03-04 validation docs against the shipped compact wake surface and the now-green keep-awake regression slices.
3. Avoid inventing new coverage debt. Only retain manual-only checks that are still genuinely manual on the live AppKit menu surface.

## Inputs Used

- `.planning/ROADMAP.md`
- `.planning/REQUIREMENTS.md`
- `.planning/STATE.md`
- `.planning/phases/01-truthful-foundations/01-VALIDATION.md`
- `.planning/phases/01-truthful-foundations/01-VERIFICATION.md`
- `.planning/phases/01-truthful-foundations/01-HUMAN-UAT.md`
- `.planning/phases/02-device-library-management/02-VALIDATION.md`
- `.planning/phases/02-device-library-management/02-VERIFICATION.md`
- `.planning/phases/03-saved-device-wake-flows/03-VALIDATION.md`
- `.planning/phases/03-saved-device-wake-flows/03-VERIFICATION.md`
- `.planning/phases/03-saved-device-wake-flows/03-HUMAN-UAT.md`
- `.planning/phases/04-timed-keep-awake/04-VALIDATION.md`
- `.planning/phases/04-timed-keep-awake/04-VERIFICATION.md`
- `.planning/phases/04-timed-keep-awake/04-HUMAN-UAT.md`
- `Mac OS Swiss KnifeTests/*.swift`
- `Mac OS Swiss KnifeUITests/Mac_OS_Swiss_KnifeUITests.swift`

## Current Factual State

### What the validation docs still claim

- All four files still set `wave_0_complete: false`.
- All four files still keep `Approval: pending`.
- Phase 01 still marks every referenced unit suite as `❌ Wave 0`.
- Phase 02 still marks the manager UI path as `⚠ scaffold only`.
- Phase 03 still documents the removed root-level recent-device / `所有设备` model instead of the current compact `快速 WOL` submenu plus dedicated `发送 WOL …` row.
- Phase 04 still claims `KeepAwakeMenuStateTests` may stall locally.

### What the codebase and verification artifacts prove now

- Every Phase 01-04 validation-referenced unit test file exists today:
  - `MACAddressValidatorTests.swift`
  - `WOLSendPresentationTests.swift`
  - `WOLSessionModelTests.swift`
  - `KeepAwakeMenuStateTests.swift`
  - `SavedDeviceRepositoryTests.swift`
  - `DeviceLibrarySessionModelTests.swift`
  - `DeviceLibraryManagementPresentationTests.swift`
  - `SavedDeviceLibraryStoreTests.swift`
  - `StatusBarControllerWakeMenuTests.swift`
  - `KeepAwakeSessionModelTests.swift`
  - `StatusBarControllerKeepAwakeMenuTests.swift`
- `01-VERIFICATION.md`, `02-VERIFICATION.md`, `03-VERIFICATION.md`, and `04-VERIFICATION.md` all currently end in `status: passed`.
- `01-HUMAN-UAT.md`, `03-HUMAN-UAT.md`, and `04-HUMAN-UAT.md` are all `status: resolved`.
- The current UI smoke suite already contains:
  - `testLaunchWithSeededDeviceLibraryShowsManagementWindow`
  - `testLaunchWithSeededDeviceLibraryShowsManagementListSurface`
  - `testLaunchWithEmptyDeviceLibraryShowsPolishedEmptyState`
  - `testLaunchWithWOLWindowShowsPolishedSections`

## Local Verification Run On 2026-04-13

### Unit slice

Command run locally:

`xcodebuild test -project "Mac OS Swiss Knife.xcodeproj" -scheme "Mac OS Swiss Knife" -destination 'platform=macOS' -parallel-testing-enabled NO -only-testing:'Mac OS Swiss KnifeTests/MACAddressValidatorTests' -only-testing:'Mac OS Swiss KnifeTests/WOLSendPresentationTests' -only-testing:'Mac OS Swiss KnifeTests/WOLSessionModelTests' -only-testing:'Mac OS Swiss KnifeTests/KeepAwakeMenuStateTests' -only-testing:'Mac OS Swiss KnifeTests/SavedDeviceRepositoryTests' -only-testing:'Mac OS Swiss KnifeTests/DeviceLibrarySessionModelTests' -only-testing:'Mac OS Swiss KnifeTests/DeviceLibraryManagementPresentationTests' -only-testing:'Mac OS Swiss KnifeTests/SavedDeviceLibraryStoreTests' -only-testing:'Mac OS Swiss KnifeTests/StatusBarControllerWakeMenuTests' -only-testing:'Mac OS Swiss KnifeTests/KeepAwakeSessionModelTests' -only-testing:'Mac OS Swiss KnifeTests/StatusBarControllerKeepAwakeMenuTests'`

Result:

- `73` tests executed
- `0` failures
- `** TEST SUCCEEDED **`

Implication:

- Phase 01, 03, and 04 no longer have evidence for unresolved `Wave 0` gaps in the referenced unit suites.
- The specific Phase 04 note about local `KeepAwakeMenuStateTests` instability is stale.

### UI smoke slice

Command run locally:

`xcodebuild test -project "Mac OS Swiss Knife.xcodeproj" -scheme "Mac OS Swiss Knife" -destination 'platform=macOS' -parallel-testing-enabled NO -only-testing:'Mac OS Swiss KnifeUITests/Mac_OS_Swiss_KnifeUITests/testLaunchWithSeededDeviceLibraryShowsManagementListSurface' -only-testing:'Mac OS Swiss KnifeUITests/Mac_OS_Swiss_KnifeUITests/testLaunchWithEmptyDeviceLibraryShowsPolishedEmptyState' -only-testing:'Mac OS Swiss KnifeUITests/Mac_OS_Swiss_KnifeUITests/testLaunchWithWOLWindowShowsPolishedSections'`

Result:

- `3` tests executed
- `0` failures
- `** TEST SUCCEEDED **`

Implication:

- Phase 02 no longer has evidence for calling the manager-window smoke path scaffold-only.
- Phase 03 and Phase 07 current direct-launch UI smoke paths are real, passing artifacts.

## Recommended Scope For Phase 8

### Keep

- Update only the Phase 01-04 validation contracts.
- Reconcile each contract against:
  - current test file existence
  - current verification reports
  - resolved HUMAN-UAT files
  - current local command outcomes

### Do not add

- No new product behavior
- No new architecture or refactors
- No rename work from Phase 9
- No broad new UI test expansion outside what is required to describe the current truth

## Phase-by-Phase Implications

### Phase 01

- Mark `wave_0_complete` true.
- Convert file-existence cells from `❌ Wave 0` to existing coverage where appropriate.
- Keep one live menu-bar manual smoke note, but tie it to the already resolved `01-HUMAN-UAT.md`.
- Update sign-off and approval from pending to approved.

### Phase 02

- Replace the stale `⚠ scaffold only` wording with the current real launch-argument UI smoke surface.
- Keep the still-manual behaviors that are genuinely manual:
  - reorder drag UX
  - delete confirmation feel
  - dual-window native behavior
- Update sign-off and approval to reflect the current passed verification and UI smoke.

### Phase 03

- Rewrite the validation contract away from the removed root-level recent-device / `所有设备` baseline.
- Describe the current shipped truth:
  - compact wake group
  - `快速 WOL` submenu
  - dedicated `发送 WOL …` row
  - persistent wake-status row
- Keep live AppKit scanability / in-flight disable timing as manual-only where appropriate.

### Phase 04

- Remove the stale note about local test runner instability.
- Mark the keep-awake suites and human smoke as completed evidence, not pending debt.
- Update frontmatter and sign-off accordingly.

## Suggested Planning Shape

Two execute plans are sufficient:

1. Phase 01-02 validation truth cleanup
2. Phase 03-04 validation truth cleanup

This keeps write scopes disjoint and lets execution verify each pair independently.

## Validation Architecture

### Test Framework

| Property | Value |
|----------|-------|
| Framework | XCTest and targeted XCUITest via Xcode 26.2 |
| Config file | `Mac OS Swiss Knife.xcodeproj/project.pbxproj` |
| Quick run command | `xcodebuild test -project "Mac OS Swiss Knife.xcodeproj" -scheme "Mac OS Swiss Knife" -destination 'platform=macOS' -parallel-testing-enabled NO -only-testing:'Mac OS Swiss KnifeTests/MACAddressValidatorTests' -only-testing:'Mac OS Swiss KnifeTests/WOLSendPresentationTests' -only-testing:'Mac OS Swiss KnifeTests/WOLSessionModelTests' -only-testing:'Mac OS Swiss KnifeTests/KeepAwakeMenuStateTests' -only-testing:'Mac OS Swiss KnifeTests/SavedDeviceRepositoryTests' -only-testing:'Mac OS Swiss KnifeTests/DeviceLibrarySessionModelTests' -only-testing:'Mac OS Swiss KnifeTests/DeviceLibraryManagementPresentationTests' -only-testing:'Mac OS Swiss KnifeTests/SavedDeviceLibraryStoreTests' -only-testing:'Mac OS Swiss KnifeTests/StatusBarControllerWakeMenuTests' -only-testing:'Mac OS Swiss KnifeTests/KeepAwakeSessionModelTests' -only-testing:'Mac OS Swiss KnifeTests/StatusBarControllerKeepAwakeMenuTests'` |
| Full suite command | `bash scripts/run_menu_bar_verification_slice.sh && xcodebuild test -project "Mac OS Swiss Knife.xcodeproj" -scheme "Mac OS Swiss Knife" -destination 'platform=macOS'` |

### Phase Requirements → Test Map

| Req ID | Behavior | Test Type | Automated Command | File Exists? |
|--------|----------|-----------|-------------------|-------------|
| `VAL-01` | Phase 01-04 validation files report wave-0 completion state that matches reality | doc audit + unit/UI proof | unit slice above plus grep of `wave_0_complete: true` in `01-04-VALIDATION.md` | ✅ |
| `VAL-02` | Each validation file maps to concrete automated or manual verification instead of placeholder work | doc audit + XCUITest spot-check | unit slice above plus targeted UI smoke slice | ✅ |
| `VAL-03` | Remaining validation debt is explicit and attributable instead of rediscovery-driven | doc audit | grep for approved sign-off, explicit manual-only rows, and no stale `Wave 0` placeholder cells | ✅ |

### Concrete Verification Checkpoints

1. All four validation files set `wave_0_complete: true`.
2. All four validation files replace stale `pending` placeholder rows with current coverage statements.
3. Phase 02 validation no longer calls the management UI path scaffold-only.
4. Phase 03 validation no longer describes the removed root-level recent-device / `所有设备` model as current shipped truth.
5. Phase 04 validation no longer claims `KeepAwakeMenuStateTests` stall locally.
6. All four validation files show an approved sign-off date instead of `Approval: pending`.

### Wave 0 Gaps

- None for implementation.
- The only remaining work is documentation truth alignment of the validation artifacts themselves.

## Open Questions

- None blocking. Current repo evidence is already enough to plan Phase 8 without discuss-phase context.

## Conclusion

Phase 8 should be executed as a validation-document correction phase. The current repo evidence already closes the old `Wave 0` implementation debt for Phase 01-04; what remains is to rewrite the four validation contracts so they describe that current truth accurately.
