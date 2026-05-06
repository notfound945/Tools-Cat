# Phase 20: First-Use Device Seed - Research

**Researched:** 2026-05-06
**Domain:** first-use default-device seeding for the saved-device library
**Confidence:** HIGH

<user_constraints>
## User Constraints

No Phase 20 `CONTEXT.md` exists. Planning constraints below are derived from [REQUIREMENTS.md](/Users/hailinpan/Documents/GitHub/Tools-Cat/.planning/REQUIREMENTS.md:1), [ROADMAP.md](/Users/hailinpan/Documents/GitHub/Tools-Cat/.planning/ROADMAP.md:1), [PROJECT.md](/Users/hailinpan/Documents/GitHub/Tools-Cat/.planning/PROJECT.md:1), [STATE.md](/Users/hailinpan/Documents/GitHub/Tools-Cat/.planning/STATE.md:1), the user prompt, and the shipped saved-device persistence seams.

### Locked Decisions
- Seed exactly one default saved device named `UGREEN NAS` with MAC `6C:1F:F7:75:C7:0E`.
- The default device should appear only for first-use empty libraries.
- Existing non-empty libraries must never be mutated by the seed path.
- Do not reopen Phase 19 validation timing, wake/menu behavior, or broader device-library UI polish.
- Preserve the current native SwiftUI/AppKit stack and current `SavedDevice` persistence model.

### Claude's Discretion
- Choose the narrowest persistence seam for first-use seeding.
- Decide whether a dedicated “seeded once” flag is necessary or whether the existing `saved_devices` key truth is sufficient.
- Decide the minimum UI-test fixture change needed so automation can still represent an intentionally empty library after first-use seeding exists.

### Deferred Ideas (OUT OF SCOPE)
- Seeding more than one device
- Device discovery/import
- Editing the default device copy after seed
- Reworking wake metadata behavior
- New onboarding UI beyond the existing manager/window surfaces
</user_constraints>

<phase_requirements>
## Phase Requirements

| ID | Description | Research Support |
|----|-------------|------------------|
| DEVS-13 | First-use empty saved-device libraries seed exactly one default device named `UGREEN NAS` with MAC address `6C:1F:F7:75:C7:0E` | Seed inside the saved-device repository when the canonical `saved_devices` payload is absent, then persist immediately through the existing normalization path |
| DEVS-14 | Existing non-empty saved-device libraries are never modified by the default-device seed path | Treat the presence of `saved_devices` data as “library already initialized,” regardless of whether it is non-empty or explicitly empty |
</phase_requirements>

## Summary

The narrowest safe seam is [SavedDeviceRepository.swift](/Users/hailinpan/Documents/GitHub/Tools-Cat/Tools%20Cat/SavedDeviceRepository.swift:15), not [SavedDeviceLibraryStore.swift](/Users/hailinpan/Documents/GitHub/Tools-Cat/Tools%20Cat/SavedDeviceLibraryStore.swift:4) or [AppDelegate.swift](/Users/hailinpan/Documents/GitHub/Tools-Cat/Tools%20Cat/AppDelegate.swift:74). The repository already owns the canonical `saved_devices` payload, normalization, and legacy migration behavior. That makes it the right layer to say “no persisted library exists yet, so materialize the first-use default device once and save it.”

The key design choice is to seed only when the `saved_devices` key is absent, not whenever the decoded device list is empty. That distinction matters because it lets the app treat an explicit persisted empty array as an already-initialized personal library, which satisfies DEVS-14 and also preserves a clean way for tests to represent an intentionally empty device library. A separate “seeded once” marker is unnecessary if the repository persists the default device immediately on first load, because subsequent loads will see existing `saved_devices` data and skip reseeding.

This phase also has one important automation consequence: several UI tests currently model an empty library by launching with no saved-device payload at all. After Phase 20, that startup path will correctly seed `UGREEN NAS`, so tests that still need the true empty-state surface must explicitly inject an encoded empty device array instead of omitting the payload entirely. That is a test-fixture adjustment, not a product behavior exception.

**Primary recommendation:** implement first-use seeding in `UserDefaultsSavedDeviceRepository.loadDevices()` when `saved_devices` is absent, persist the default device immediately through `saveDevices`, and update UI-test launch helpers so “fresh defaults” and “explicitly empty library” are separate test cases.

## Project Constraints

- Keep persistence truth in the existing `UserDefaultsSavedDeviceRepository` + `SavedDeviceLibraryStore` stack.
- Keep user-facing copy Chinese where existing UI already expects it, but preserve the exact seeded device name `UGREEN NAS` from the requirement.
- Avoid new onboarding flags or alternate app boot flows unless tests genuinely require them.
- Keep the phase tightly scoped to device-library seed initialization and verification.

## Standard Stack

### Core
| Library | Version | Purpose | Why Standard |
|---------|---------|---------|--------------|
| `UserDefaultsSavedDeviceRepository` | repo local | canonical storage/load seam for saved devices | already owns first-load truth, normalization, and migration |
| `SavedDeviceLibraryStore` | repo local | observable runtime bridge for saved devices | already reflects repository state into WOL/device-library UI |
| XCTest | Xcode 26.2 verified 2026-05-06 | repository/store regressions for seed behavior | already covers saved-device persistence and migration |
| XCUITest | Xcode 26.2 verified 2026-05-06 | direct-launch verification for fresh-seed and explicit-empty-library surfaces | existing launch seam already exercises device-library startup |

### Supporting
| Library | Version | Purpose | When to Use |
|---------|---------|---------|-------------|
| `SavedDevice` | repo local | exact seeded model shape and sort normalization | always; do not invent a parallel seed DTO in product code |
| `AppDelegate` launch configuration | repo local | current UI-test defaults injection seam | when adjusting test-only startup fixtures for explicit empty libraries |
| `WOLSessionModel` | repo local | indirect consumer of first saved device / last used device selection | only as a regression awareness surface, not the seed implementation seam |

### Alternatives Considered
| Instead of | Could Use | Tradeoff |
|------------|-----------|----------|
| repository-level seeding on missing key | seeding inside `SavedDeviceLibraryStore.init` | would pollute store truth, complicate in-memory repos, and make tests less precise |
| key-absence as first-use signal | dedicated “did seed default device” defaults key | extra state without solving a real problem if seeding persists immediately |
| explicit-empty test payloads | add a test-only “disable seed” launch flag | broader app-surface change than necessary for this phase |

## Architecture Patterns

### Pattern 1: First-Use Seed Belongs To The Persistence Boundary
**What:** If no saved-device payload exists yet, create the default device and persist it before returning from repository load.

**When to use:** Brownfield apps where “first-use defaults” must be globally true anywhere the store is read.

**Example:**

```swift
guard let data = defaults.data(forKey: Self.devicesKey) else {
    let seededDevices = [Self.firstUseDefaultDevice()]
    try saveDevices(seededDevices)
    return seededDevices
}
```

**Why here:** the repository already owns normalized save/load truth.

### Pattern 2: Distinguish Missing Library From Explicitly Empty Library
**What:** `saved_devices` key missing means “never initialized”; encoded `[]` means “initialized and intentionally empty.”

**When to use:** When product requirements say first-use seeding must not come back after the user already had a library.

**Why it matters:** This distinction satisfies DEVS-14 and keeps empty-state UI tests representable.

### Pattern 3: Test Fixtures Must Separate Fresh Defaults From Explicit Empty State
**What:** UI-test launch helpers should support both:
- no saved-device payload injected → seed path
- encoded empty array injected → explicit empty-library path

**When to use:** As soon as first-use product behavior depends on key absence.

## Don't Hand-Roll

| Problem | Don't Build | Use Instead | Why |
|---------|-------------|-------------|-----|
| First-use detection | app-wide extra onboarding controller | repository key-absence check | smallest truth boundary |
| Seed normalization | custom uppercase/sort logic in multiple places | existing `saveDevices` normalization path | keeps ordering/persistence behavior consistent |
| Empty-state test escape hatch | product-only bypass flag | explicit empty encoded payload in tests | smaller, clearer, and contained to harness code |
| Seed duplication prevention | post-load de-dup passes on every startup | immediate persisted seed plus existing key-presence truth | simpler and deterministic |

## Common Pitfalls

### Pitfall 1: Seeding On Every Empty Decode
**What goes wrong:** A user who deletes all devices gets `UGREEN NAS` reinserted later.

**Why it happens:** The implementation checks `devices.isEmpty` after decode instead of checking whether persistence has ever been initialized.

**How to avoid:** Seed only when the `saved_devices` payload is absent.

### Pitfall 2: Putting The Seed In `SavedDeviceLibraryStore`
**What goes wrong:** In-memory repositories and existing unit tests stop meaning “repository truth,” and first-use logic becomes harder to isolate.

**How to avoid:** Keep the seed behavior in `UserDefaultsSavedDeviceRepository`.

### Pitfall 3: Forgetting UI-Test Empty-State Fixtures
**What goes wrong:** Existing “empty library” UI tests suddenly fail because fresh launch now correctly seeds one device.

**How to avoid:** Change the launch helper to support an explicit empty payload distinct from nil/no payload.

### Pitfall 4: Using Non-Canonical Seed Copy Or Formatting
**What goes wrong:** The seeded device appears as `Ugreen NAS` or with a differently cased MAC, violating DEVS-13.

**How to avoid:** Define one canonical default `SavedDevice` source with exact requirement values and rely on existing save/load normalization only for sort order.

## Validation Architecture

Recommended verification layers:
- repository truth: first-load seed, no duplicate on repeated loads, no overwrite of current/non-empty libraries
- store truth: fresh `SavedDeviceLibraryStore` reflects the seeded default from the repository
- UI truth: fresh direct-launch device-library surface shows the seeded device; explicit-empty injected library still shows the empty state

Recommended quick regression command:
`xcodebuild test -project "Tools Cat.xcodeproj" -scheme "Tools Cat" -destination 'platform=macOS' -parallel-testing-enabled NO -only-testing:'Tools CatTests/SavedDeviceRepositoryTests' -only-testing:'Tools CatTests/SavedDeviceLibraryStoreTests'`

Recommended full regression command:
`xcodebuild test -project "Tools Cat.xcodeproj" -scheme "Tools Cat" -destination 'platform=macOS' -parallel-testing-enabled NO -only-testing:'Tools CatTests/SavedDeviceRepositoryTests' -only-testing:'Tools CatTests/SavedDeviceLibraryStoreTests' -only-testing:'Tools CatUITests/Tools_CatUITests/testLaunchWithFreshDeviceLibrarySeedsDefaultDevice' -only-testing:'Tools CatUITests/Tools_CatUITests/testLaunchWithExplicitlyEmptyDeviceLibraryShowsPolishedEmptyState' -only-testing:'Tools CatUITests/Tools_CatUITests/testLaunchWithSeededDeviceLibraryShowsManagementWindow'`

## Recommended Phase Split

1. `20-01`: Add repository-owned first-use seeding with unit/store regressions, then adjust direct-launch UI fixtures so fresh-seed and explicit-empty-library behavior are both covered.

---

*Phase: 20-first-use-device-seed*
*Research completed: 2026-05-06*
