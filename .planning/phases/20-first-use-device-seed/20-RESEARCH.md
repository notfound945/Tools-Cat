# Phase 20: First-Use Device Seed - Research

**Researched:** 2026-05-06
**Domain:** Saved-device persistence seeding in a native macOS Swift/AppKit/SwiftUI app
**Confidence:** HIGH

<user_constraints>
## User Constraints

No `*-CONTEXT.md` exists for Phase 20. These constraints come from the user request, `.planning/ROADMAP.md`, and `.planning/REQUIREMENTS.md`.

### Locked Constraints
- Seed exactly one default saved device named `UGREEN NAS` with MAC `6C:1F:F7:75:C7:0E`.
- Seed only when the saved-device library is first used and empty.
- Do not mutate existing non-empty libraries.
- Do not duplicate the default device on reload.
- Keep scope strictly to Phase 20.
- Do not reopen Phase 19 validation timing.

### Claude's Discretion
- Choose the best implementation seam for first-use seeding.
- Recommend the minimum test updates needed to preserve intent.

### Deferred Ideas (OUT OF SCOPE)
- Reworking saved-device validation timing or rules.
- Changing the shipped WOL/menu behavior beyond what seeded data naturally causes.
- Adding third-party persistence or migration libraries.
</user_constraints>

<phase_requirements>
## Phase Requirements

| ID | Description | Research Support |
|----|-------------|------------------|
| DEVS-13 | First-use empty saved-device libraries seed exactly one default device named `UGREEN NAS` with MAC address `6C:1F:F7:75:C7:0E` | Recommend seeding in `UserDefaultsSavedDeviceRepository.loadDevices()` only when the `saved_devices` key is absent, then persisting the normalized seed immediately |
| DEVS-14 | Existing non-empty saved-device libraries are never modified by the default-device seed path | Recommend using key absence, not `devices.isEmpty`, as the first-use gate; existing non-empty and explicitly persisted empty libraries bypass seeding |
</phase_requirements>

## Summary

The best seam for Phase 20 is the concrete persistence boundary in [SavedDeviceRepository.swift](/Users/hailinpan/Documents/GitHub/Tools-Cat/Tools%20Cat/SavedDeviceRepository.swift), specifically `UserDefaultsSavedDeviceRepository.loadDevices()`. That class already owns the `saved_devices` key, already distinguishes real persistence state, and is the only current seam that can safely tell the difference between a brand-new library with no key at all and an intentionally persisted empty library after the user deletes everything.

Seeding in `SavedDeviceLibraryStore` or `AppDelegate` is weaker. `AppDelegate` would miss other legitimate construction paths that instantiate `SavedDeviceLibraryStore()` directly, and store-level seeding would either need protocol expansion or type checks to recover persistence-state knowledge the repository already has. Repository-owned seeding keeps the change phase-local, preserves current in-memory test seams, and prevents duplicates by persisting the default device the first time it is materialized.

The critical behavioral distinction is this: "first use" must mean "`saved_devices` has never been written", not "`loadDevices()` returned an empty array". If the implementation seeds any time the loaded array is empty, the app will wrongly reseed after a user intentionally clears the library, and several tests that currently use a fresh suite to mean "empty state" will start asserting the wrong product behavior.

**Primary recommendation:** Seed inside `UserDefaultsSavedDeviceRepository.loadDevices()` only when `defaults.object(forKey: "saved_devices") == nil`, persist the single normalized default immediately with `saveDevices`, and leave `SavedDeviceLibraryStore`, `AppDelegate`, and in-memory test repositories unmodified unless tests explicitly need first-use semantics.

## Project Constraints (from CLAUDE.md)

- Stay native to the existing AppKit/SwiftUI macOS stack.
- Optimize for a personal daily-use utility, not generalized multi-user behavior.
- Keep UX restrained and polished; avoid flashy scope expansion.
- Core menu state must stay truthful; no fake success paths.
- New functionality should reduce coupling or at least avoid deepening it.
- Follow the existing small-file, focused-function style.
- Keep persistence on `UserDefaults.standard`; Phase 18 state already treats that as a durable decision.

## Standard Stack

### Core
| Library | Version | Purpose | Why Standard |
|---------|---------|---------|--------------|
| Foundation `UserDefaults` | macOS SDK 26.2 via Xcode 26.2 | Persist the saved-device JSON blob and detect whether the library key has ever been written | Already the shipped persistence mechanism; it exposes both `data(forKey:)` and `object(forKey:)`, which is exactly what Phase 20 needs |
| XCTest | Xcode 26.2 | Verify repository/store/session behavior without introducing new harnesses | Existing repo test stack and already covers this subsystem directly |

### Supporting
| Library | Version | Purpose | When to Use |
|---------|---------|---------|-------------|
| Combine / `ObservableObject` | macOS SDK 26.2 via Xcode 26.2 | Publish seeded or loaded store state into menu/session consumers | Use only through the existing `SavedDeviceLibraryStore` and session models |
| AppKit / SwiftUI | macOS SDK 26.2 via Xcode 26.2 | Surface seeded devices in the management window and WOL picker/menu | Use for UI verification only; seeding logic itself should stay below the UI layer |

### Alternatives Considered
| Instead of | Could Use | Tradeoff |
|------------|-----------|----------|
| Repository-first seeding | `SavedDeviceLibraryStore` init seeding | Store lacks direct persisted-key knowledge; would need protocol expansion or concrete type checks |
| Repository-first seeding | `AppDelegate.configureSharedStores()` seeding | Too launch-path-specific; misses other `SavedDeviceLibraryStore()` construction seams and couples app startup to persistence policy |
| Missing-key detection | `register(defaults:)` | Apple documents registration defaults as volatile fallback values per launch, not persisted library creation; it cannot express "seed exactly once" safely |

**Installation:**
```bash
# No new packages. Use the existing Xcode/macOS SDK toolchain.
```

**Version verification:** Verified locally with `xcodebuild -version` on 2026-05-06: `Xcode 26.2 (Build 17C52)`. The current build uses the macOS 26.2 SDK during test compilation.

## Architecture Patterns

### Recommended Project Structure
```text
Tools Cat/
├── SavedDevice.swift               # Saved-device value type
├── SavedDeviceRepository.swift     # UserDefaults persistence truth, including first-use seed gate
├── SavedDeviceLibraryStore.swift   # Published library state, reload/replace/upsert/delete orchestration
├── DeviceLibrarySessionModel.swift # Add/edit/delete session logic
└── WOLSessionModel.swift           # Picker/manual-send behavior that consumes library state
```

### Pattern 1: Seed At The UserDefaults Persistence Boundary
**What:** Put first-use seeding in `UserDefaultsSavedDeviceRepository.loadDevices()`, before the method returns the loaded array.
**When to use:** Any time the backing `saved_devices` key is absent in a real `UserDefaults` domain.
**Example:**
```swift
// Source: Tools Cat/SavedDeviceRepository.swift + Apple UserDefaults docs
func loadDevices() throws -> [SavedDevice] {
    if defaults.object(forKey: Self.devicesKey) == nil {
        let seed = [Self.firstUseDefaultDevice()]
        try saveDevices(seed)
        return seed
    }

    guard let data = defaults.data(forKey: Self.devicesKey) else {
        return []
    }

    let devices = try decoder.decode([SavedDevice].self, from: data)
    return Self.normalized(devices.sorted { $0.sortOrder < $1.sortOrder })
}
```

### Pattern 2: Treat Persisted Empty As User Intent
**What:** Preserve `[]` if the key exists and decodes to an empty array.
**When to use:** After the user has deleted all saved devices, or a test intentionally persists an empty library.
**Example:**
```swift
// Source: Tools CatTests/Tools_CatUITests.swift helpers + repository behavior
let encodedEmptyLibrary = try JSONEncoder().encode([SavedDevice]())
defaults.set(encodedEmptyLibrary, forKey: "saved_devices")

let repository = UserDefaultsSavedDeviceRepository(defaults: defaults)
XCTAssertEqual(try repository.loadDevices(), [])
```

### Pattern 3: Keep Store Initialization Purely About Published State
**What:** Let `SavedDeviceLibraryStore` continue to load, prune wake metadata, and publish the repository result.
**When to use:** Always.
**Example:**
```swift
// Source: Tools Cat/SavedDeviceLibraryStore.swift
devices = (try? resolvedRepository.loadDevices()) ?? []
let wakeMetadata = (try? resolvedRepository.loadWakeMetadata())
    ?? SavedDeviceWakeMetadata(recentDeviceIDs: [], lastUsedDeviceID: nil)
```

### Anti-Patterns to Avoid
- **Seed on `devices.isEmpty`:** Wrongly reseeds after the user intentionally clears the library.
- **Seed in `AppDelegate`:** Makes first-use behavior dependent on one launch path instead of the persistence contract.
- **Append-if-missing by name/MAC on every init:** Hides the real first-use boundary and can mutate old libraries unexpectedly.
- **Use `register(defaults:)` for one-time seed:** Apple documents it as a volatile fallback domain applied each launch, not a persisted one-time creation path.

## Don't Hand-Roll

| Problem | Don't Build | Use Instead | Why |
|---------|-------------|-------------|-----|
| First-use detection | A second "didSeedDefaultDevice" boolean flag | The existing `saved_devices` key absence check | One persistence key already encodes the distinction Phase 20 needs |
| Duplicate prevention | Name/MAC dedupe scans on every launch | One-time write on missing key, then normal loads thereafter | Eliminates duplicate logic and preserves explicit empty/non-empty user state |
| UI onboarding truth | View/session-local fake seed rows | Repository-backed persisted seed | Menu, WOL window, and management window all stay in sync automatically |

**Key insight:** This phase is not about finding a device if one is missing later; it is about materializing the initial persisted library exactly once. Presence of the persistence key is the simplest durable truth.

## Common Pitfalls

### Pitfall 1: Confusing "Missing Key" With "Empty Library"
**What goes wrong:** The app reseeds after the user deletes the last device.
**Why it happens:** The code checks `loadDevices().isEmpty` instead of whether `saved_devices` has ever been written.
**How to avoid:** Gate seeding on `defaults.object(forKey: devicesKey) == nil` before decoding.
**Warning signs:** A test that saves `[]`, reloads, and unexpectedly sees `UGREEN NAS`.

### Pitfall 2: Putting Seeding Above The Repository
**What goes wrong:** Some app paths seed while others still behave as truly empty, causing inconsistent menu/window behavior.
**Why it happens:** `AppDelegate` is only one construction path; tests and some production types instantiate the store directly.
**How to avoid:** Keep the policy in `UserDefaultsSavedDeviceRepository`.
**Warning signs:** UI tests pass but unit tests with `SavedDeviceLibraryStore()` or `StatusBarController(deviceLibrary: nil)` diverge.

### Pitfall 3: Breaking Existing Empty-State Tests By Accident
**What goes wrong:** Fresh-suite UI tests fail because "empty suite" no longer means "empty library".
**Why it happens:** Today several tests rely on a brand-new `UserDefaults` suite with no `saved_devices` key.
**How to avoid:** Add explicit test helpers for a persisted empty library where that scenario still matters.
**Warning signs:** `testLaunchWithEmptyDeviceLibraryShowsPolishedEmptyState` fails immediately after seeding lands.

## Code Examples

Verified patterns from project sources and official docs:

### One-Time Repository Seed
```swift
// Source: Tools Cat/SavedDeviceRepository.swift
private static func firstUseDefaultDevice() -> SavedDevice {
    SavedDevice(
        id: UUID(),
        name: "UGREEN NAS",
        macAddress: "6C:1F:F7:75:C7:0E",
        note: "",
        sortOrder: 0
    )
}
```

### Focused Regression Command
```bash
# Source: local verified command on 2026-05-06
xcodebuild test \
  -project 'Tools Cat.xcodeproj' \
  -scheme 'Tools Cat' \
  -only-testing:'Tools CatTests/SavedDeviceRepositoryTests' \
  -only-testing:'Tools CatTests/SavedDeviceLibraryStoreTests' \
  -only-testing:'Tools CatTests/WOLSessionModelTests' \
  -only-testing:'Tools CatTests/DeviceLibrarySessionModelTests' \
  CODE_SIGNING_ALLOWED=NO
```

## State of the Art

| Old Approach | Current Approach | When Changed | Impact |
|--------------|------------------|--------------|--------|
| Missing `saved_devices` key loads as `[]` | Missing `saved_devices` key should persist and return one default saved device | Phase 20 | First-use users see a practical default; explicit empty libraries remain empty |
| UI tests use fresh suites to mean "empty library" | UI tests that need a true empty library should persist `[]` explicitly | Phase 20 | Tests become aligned with real product semantics |
| Launch-time seeding is absent | Repository-owned one-time seed | Phase 20 | All real `UserDefaults` consumers share the same persistence truth |

**Deprecated/outdated:**
- Fresh-suite-equals-empty assumptions in UserDefaults-backed tests: outdated once Phase 20 ships, because fresh suite now means first-use seeding should occur.

## Open Questions

1. **Should the seeded device use a fixed UUID or a newly generated UUID?**
   - What we know: Requirements only lock the name and MAC, not the identifier.
   - What's unclear: Whether the planner wants exact-ID assertions in UI/unit tests.
   - Recommendation: Use `UUID()` unless a test needs stable exact-object identity across fresh suites; the one-time persisted write already prevents duplicates without a fixed ID.

## Environment Availability

| Dependency | Required By | Available | Version | Fallback |
|------------|------------|-----------|---------|----------|
| `xcodebuild` | Unit and UI validation | ✓ | Xcode 26.2 / Build 17C52 | — |

**Missing dependencies with no fallback:**
- None

**Missing dependencies with fallback:**
- None

## Validation Architecture

### Test Framework
| Property | Value |
|----------|-------|
| Framework | XCTest via Xcode 26.2 |
| Config file | none — Xcode project target configuration |
| Quick run command | `xcodebuild test -project 'Tools Cat.xcodeproj' -scheme 'Tools Cat' -only-testing:'Tools CatTests/SavedDeviceRepositoryTests' -only-testing:'Tools CatTests/SavedDeviceLibraryStoreTests' CODE_SIGNING_ALLOWED=NO` |
| Full suite command | `xcodebuild test -project 'Tools Cat.xcodeproj' -scheme 'Tools Cat' CODE_SIGNING_ALLOWED=NO` |

### Phase Requirements → Test Map
| Req ID | Behavior | Test Type | Automated Command | File Exists? |
|--------|----------|-----------|-------------------|-------------|
| DEVS-13 | Missing `saved_devices` key seeds exactly one `UGREEN NAS` with normalized MAC and persists it | unit | `xcodebuild test -project 'Tools Cat.xcodeproj' -scheme 'Tools Cat' -only-testing:'Tools CatTests/SavedDeviceRepositoryTests' -only-testing:'Tools CatTests/SavedDeviceLibraryStoreTests' CODE_SIGNING_ALLOWED=NO` | ❌ Wave 0 |
| DEVS-13 | Fresh app/device-library launch shows the seeded device instead of blank onboarding when using a new UserDefaults suite | UI smoke | `xcodebuild test -project 'Tools Cat.xcodeproj' -scheme 'Tools Cat' -only-testing:'Tools CatUITests/Tools_CatUITests' CODE_SIGNING_ALLOWED=NO` | ⚠️ Existing file, new case needed |
| DEVS-14 | Existing non-empty library remains unchanged | unit | `xcodebuild test -project 'Tools Cat.xcodeproj' -scheme 'Tools Cat' -only-testing:'Tools CatTests/SavedDeviceRepositoryTests' CODE_SIGNING_ALLOWED=NO` | ⚠️ Existing file, new case needed |
| DEVS-14 | Persisted empty library remains empty and does not reseed after reload | unit/UI | `xcodebuild test -project 'Tools Cat.xcodeproj' -scheme 'Tools Cat' -only-testing:'Tools CatTests/SavedDeviceRepositoryTests' -only-testing:'Tools CatUITests/Tools_CatUITests' CODE_SIGNING_ALLOWED=NO` | ❌ Wave 0 |

### Sampling Rate
- **Per task commit:** `xcodebuild test -project 'Tools Cat.xcodeproj' -scheme 'Tools Cat' -only-testing:'Tools CatTests/SavedDeviceRepositoryTests' -only-testing:'Tools CatTests/SavedDeviceLibraryStoreTests' CODE_SIGNING_ALLOWED=NO`
- **Per wave merge:** `xcodebuild test -project 'Tools Cat.xcodeproj' -scheme 'Tools Cat' -only-testing:'Tools CatTests/SavedDeviceRepositoryTests' -only-testing:'Tools CatTests/SavedDeviceLibraryStoreTests' -only-testing:'Tools CatTests/WOLSessionModelTests' -only-testing:'Tools CatTests/DeviceLibrarySessionModelTests' CODE_SIGNING_ALLOWED=NO`
- **Phase gate:** Full suite green before `/gsd:verify-work`

### Wave 0 Gaps
- [ ] Replace `SavedDeviceRepositoryTests.testEmptySuiteLoadsNoDevices()` with a first-use seed test and a persisted-empty-no-reseed test.
- [ ] Add a `SavedDeviceLibraryStoreTests` case that verifies initial UserDefaults-backed load seeds once and `reload()` does not duplicate.
- [ ] Add a UI-test helper that persists an explicit empty library for tests that still need the blank-state contract.
- [ ] Update or replace `Tools_CatUITests.testLaunchWithEmptyDeviceLibraryShowsPolishedEmptyState()` so it no longer treats a fresh suite as a persisted empty library.

## Sources

### Primary (HIGH confidence)
- Local code: [Tools Cat/SavedDeviceRepository.swift](/Users/hailinpan/Documents/GitHub/Tools-Cat/Tools%20Cat/SavedDeviceRepository.swift) - current `UserDefaults` persistence seam, migration helper, normalized save/load behavior
- Local code: [Tools Cat/SavedDeviceLibraryStore.swift](/Users/hailinpan/Documents/GitHub/Tools-Cat/Tools%20Cat/SavedDeviceLibraryStore.swift) - store hydration, reload, metadata pruning, and published-state boundary
- Local code: [Tools Cat/AppDelegate.swift](/Users/hailinpan/Documents/GitHub/Tools-Cat/Tools%20Cat/AppDelegate.swift) - current app startup path and why it is a weaker seeding seam
- Local tests: [Tools CatTests/SavedDeviceRepositoryTests.swift](/Users/hailinpan/Documents/GitHub/Tools-Cat/Tools%20CatTests/SavedDeviceRepositoryTests.swift), [Tools CatTests/SavedDeviceLibraryStoreTests.swift](/Users/hailinpan/Documents/GitHub/Tools-Cat/Tools%20CatTests/SavedDeviceLibraryStoreTests.swift), [Tools CatUITests/Tools_CatUITests.swift](/Users/hailinpan/Documents/GitHub/Tools-Cat/Tools%20CatUITests/Tools_CatUITests.swift) - current assumptions that Phase 20 will change
- Apple Developer Documentation: https://developer.apple.com/documentation/foundation/userdefaults - verified that `UserDefaults` provides `object(forKey:)`, `data(forKey:)`, and persistent app-domain storage behavior
- Apple Developer Documentation: https://developer.apple.com/documentation/Foundation/UserDefaults/register%28defaults%3A%29 - verified that `register(defaults:)` writes volatile fallback defaults per launch, not one-time persisted seed state

### Secondary (MEDIUM confidence)
- Apple Developer Documentation: https://developer.apple.com/documentation/xcode/adding-tests-to-your-xcode-project - current Apple guidance that XCTest remains a standard supported testing path in Xcode

### Tertiary (LOW confidence)
- None

## Metadata

**Confidence breakdown:**
- Standard stack: HIGH - no new libraries are needed; this phase sits directly on the repo's existing UserDefaults/XCTest stack
- Architecture: HIGH - repository key-absence detection is directly supported by current code structure and avoids unnecessary seam widening
- Pitfalls: HIGH - the missing-key versus persisted-empty distinction is visible in current code and tests, and was verified against Apple UserDefaults docs

**Research date:** 2026-05-06
**Valid until:** 2026-06-05
