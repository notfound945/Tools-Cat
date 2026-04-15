# Phase 12: Duration Preset Persistence - Research

**Researched:** 2026-04-15
**Domain:** persisted timed keep-awake durations for a local-first macOS menu bar utility
**Confidence:** HIGH

<user_constraints>
## User Constraints

No `12-CONTEXT.md` exists yet. Planning boundaries for this phase come from [`ROADMAP.md`](/Users/hailinpan/Documents/GitHub/Tools-Cat/.planning/ROADMAP.md#L23), [`REQUIREMENTS.md`](/Users/hailinpan/Documents/GitHub/Tools-Cat/.planning/REQUIREMENTS.md#L9), [`STATE.md`](/Users/hailinpan/Documents/GitHub/Tools-Cat/.planning/STATE.md#L35), and the locked timed-keep-awake decisions in [`04-CONTEXT.md`](/Users/hailinpan/Documents/GitHub/Tools-Cat/.planning/phases/04-timed-keep-awake/04-CONTEXT.md#L10).

### Locked Constraints For Planning
- Phase 12 scope is data ownership, validation, and persistence for timed durations. The management UI belongs to Phase 13, and dynamic root-menu rendering belongs to Phase 14.
- The app must seed `15 分钟`, `30 分钟`, `1 小时`, and `2 小时` exactly once for users who do not already have duration data.
- Invalid or duplicate managed timed durations must not be saved.
- Managed timed durations must persist across relaunch and reload in deterministic ascending order.
- `无限常亮` remains a fixed keep-awake action outside the managed duration list and must not become user-editable data.
- The product stays native AppKit/SwiftUI, local-first, and backed by `UserDefaults.standard` for runtime persistence.
- Menu state must stay truthful to real state; no optimistic keep-awake UI changes are allowed.

### Planning Discretion
- Whether Phase 12 keeps [`KeepAwakeDurationPreset.swift`](/Users/hailinpan/Documents/GitHub/Tools-Cat/Tools%20Cat/KeepAwakeDurationPreset.swift#L3) as a temporary bridge or migrates keep-awake session state to the new persisted duration type now.
- The exact error enum and validation surface exposed by the new duration store.
- Whether load-time corruption throws, falls back, or self-heals. Save-time validation should still be strict.

### Out Of Scope
- Editing or deleting `无限常亮`
- Manual drag ordering for timed durations
- Cloud sync or shared presets
- One-off unsaved timed durations
- Custom labels/notes for timed durations
</user_constraints>

<phase_requirements>
## Phase Requirements

| ID | Description | Research Support |
|----|-------------|------------------|
| AWAKE-06 | User can open a duration-management surface seeded with `15 分钟`, `30 分钟`, `1 小时`, and `2 小时` | Phase 12 should create a persisted duration repository/store that seeds these four defaults exactly once so Phase 13 only reads existing data |
| AWAKE-10 | User cannot save invalid or duplicate managed keep-awake durations | Centralize validation in one store/repository boundary that rejects invalid minutes and duplicate canonical durations before persistence |
| AWAKE-11 | User sees managed keep-awake durations persist across app relaunch and return in the correct sorted positions | Persist the list as Codable `Data` in `UserDefaults`, reload through a fresh repository/store, and sort ascending on every successful save/load |
</phase_requirements>

## Summary

The repo already has the right persistence pattern for this phase: a thin `UserDefaults` repository, an observable store, and exact-once migration markers in [`SavedDeviceRepository.swift`](/Users/hailinpan/Documents/GitHub/Tools-Cat/Tools%20Cat/SavedDeviceRepository.swift#L15) and [`SavedDeviceLibraryStore.swift`](/Users/hailinpan/Documents/GitHub/Tools-Cat/Tools%20Cat/SavedDeviceLibraryStore.swift#L4). Phase 12 should copy that pattern for timed keep-awake durations instead of inventing a special-case menu-only defaults trick.

The main planning decision is scope control. The current hardcoded preset coupling is real, but Phase 12 does not need to finish Phase 14 early. The safest Phase 12 shape is: add a persisted timed-duration model plus repository/store, seed the four defaults exactly once, make save/load validation strict, wire the shared store in [`AppDelegate.swift`](/Users/hailinpan/Documents/GitHub/Tools-Cat/Tools%20Cat/AppDelegate.swift#L60), and keep `无限常亮` completely outside that store. Full dynamic menu rendering can still wait for Phase 14.

There is no legacy timed-duration data to migrate from another bundle or file format. This is first-write seeding, not cross-suite migration. That matters because the seeding rule must be based on explicit storage absence or a dedicated seed marker, not on list emptiness. Otherwise Phase 13 delete-all behavior would be broken before it ships.

**Primary recommendation:** Use a `UserDefaults`-backed `KeepAwakeDurationStore` that persists `[KeepAwakeManagedDuration]` as JSON `Data`, validates strictly on save, seeds defaults once on first load, and leaves the current hardcoded menu/session bridge intentionally temporary until Phase 14.

## Project Constraints (from CLAUDE.md)

- Keep the app inside the existing native AppKit/SwiftUI shell; do not plan a shell rewrite.
- Optimize for a personal daily-use utility, not a generalized automation or multi-user system.
- Keep the UX small, restrained, and native macOS.
- Menu state must reflect real local state; false success is unacceptable.
- New functionality should reduce coupling and create clearer seams instead of deepening controller ownership.
- Follow repo conventions: one main type per file, small focused functions, Chinese runtime copy with English API/type names, and Xcode-style formatting.
- `workflow.nyquist_validation` is enabled in [`.planning/config.json`](/Users/hailinpan/Documents/GitHub/Tools-Cat/.planning/config.json#L1), so planning must include automated and manual validation coverage.
- Work should stay inside GSD workflow conventions.

## Standard Stack

### Core
| Library | Version | Purpose | Why Standard |
|---------|---------|---------|--------------|
| Foundation `UserDefaults` | macOS SDK 26.2 via Xcode 26.2 | local-first persistence for small preference-owned data | Apple’s documented defaults system is the standard storage for lightweight app preferences and settings; the repo already uses it for saved devices |
| Foundation `JSONEncoder` / `JSONDecoder` | macOS SDK 26.2 via Xcode 26.2 | encode custom Swift structs into `Data` for defaults storage | `UserDefaults` stores property-list types directly; custom app data should be archived into `Data` |
| Foundation `UUID` + integer minutes | macOS SDK 26.2 via Xcode 26.2 | stable identity plus canonical duplicate/sort key | Keeps future edit/delete flows stable while avoiding floating-point duration identity bugs |
| Combine `ObservableObject` / `@Published` | macOS SDK 26.2 via Xcode 26.2 | observable in-memory store for future Phase 13/14 consumers | Matches existing store/session patterns in this repo |
| XCTest | Xcode 26.2 | repository/store/unit regression coverage | The repo already uses isolated `UserDefaults(suiteName:)` fixtures and model/controller unit seams |

### Supporting
| Library | Version | Purpose | When to Use |
|---------|---------|---------|-------------|
| AppKit / AppDelegate startup wiring | macOS SDK 26.2 via Xcode 26.2 | create one shared duration store at launch | Use only to compose the shared runtime object, not to own validation logic |
| Existing `LaunchConfiguration` suite injection | local repo seam in [`AppDelegate.swift`](/Users/hailinpan/Documents/GitHub/Tools-Cat/Tools%20Cat/AppDelegate.swift#L93) | deterministic test defaults suites when app-level wiring needs smoke coverage | Use only if Phase 12 adds launch-level integration tests |
| Existing keep-awake enum bridge | local repo seam in [`KeepAwakeDurationPreset.swift`](/Users/hailinpan/Documents/GitHub/Tools-Cat/Tools%20Cat/KeepAwakeDurationPreset.swift#L3) | temporary compatibility layer while menu rendering remains fixed | Use only as a short-lived adapter until Phase 14 replaces hardcoded timed rows |

### Alternatives Considered
| Instead of | Could Use | Tradeoff |
|------------|-----------|----------|
| `UserDefaults` + JSON `Data` | property-list dictionaries/arrays | Works, but diverges from the repo’s current repository pattern and makes type-safe decoding/validation uglier |
| `minutes: Int` as canonical duration | `TimeInterval` / `Double` seconds | More general, but introduces floating-point equality problems for duplicates and sorting with no current product benefit |
| strict save-time validation | silent save-time dedupe | Easier to code, but hides bugs and makes Phase 13 form feedback weaker |
| temporary enum bridge in Phase 12 | full menu/session migration now | Reduces later bridge code, but increases this phase’s scope and regression surface beyond the listed success criteria |

**Installation:**
```bash
# No third-party packages are needed.
xcodebuild -version
swift --version
```

**Version verification:** `xcodebuild -version` returned `Xcode 26.2 (17C52)` on 2026-04-15, and `swift --version` returned `Apple Swift 6.2.3`. No package registry verification is needed because this phase uses only system frameworks already present in the Xcode toolchain.

## Architecture Patterns

### Recommended Project Structure
```text
Tools Cat/
├── KeepAwakeManagedDuration.swift        # Persisted timed-duration entity
├── KeepAwakeDurationRepository.swift     # Protocol + UserDefaults repository
├── KeepAwakeDurationStore.swift          # Observable validated store
├── KeepAwakeDurationFormatting.swift     # Canonical title formatter / seed catalog
├── AppDelegate.swift                     # Shared store composition
├── KeepAwakeDurationPreset.swift         # Temporary bridge only, if kept in Phase 12
└── KeepAwakeSessionModel.swift           # Only touched if bridge changes are required
```

### Current Hardcoded Preset Coupling

- [`KeepAwakeDurationPreset.swift`](/Users/hailinpan/Documents/GitHub/Tools-Cat/Tools%20Cat/KeepAwakeDurationPreset.swift#L3) hardcodes the four timed options, their labels, and their durations.
- [`KeepAwakeSessionModel.swift`](/Users/hailinpan/Documents/GitHub/Tools-Cat/Tools%20Cat/KeepAwakeSessionModel.swift#L4) stores timed keep-awake state and pending starts in terms of that enum.
- [`KeepAwakePresentation.swift`](/Users/hailinpan/Documents/GitHub/Tools-Cat/Tools%20Cat/KeepAwakePresentation.swift#L23) derives active timed state and pending copy directly from the enum.
- [`StatusBarController.swift`](/Users/hailinpan/Documents/GitHub/Tools-Cat/Tools%20Cat/StatusBarController.swift#L64) hardcodes one `NSMenuItem` and selector per timed preset, then checks enum equality when rendering state.
- [`KeepAwakeSessionModelTests.swift`](/Users/hailinpan/Documents/GitHub/Tools-Cat/Tools%20CatTests/KeepAwakeSessionModelTests.swift#L35) and [`StatusBarControllerKeepAwakeMenuTests.swift`](/Users/hailinpan/Documents/GitHub/Tools-Cat/Tools%20CatTests/StatusBarControllerKeepAwakeMenuTests.swift#L8) assert directly on those fixed preset cases and row titles.

This coupling should be documented in the plan as Phase 14 follow-up work. Phase 12 should avoid deep menu churn unless required to keep the bridge compiling cleanly.

### Pattern 1: Repository + Store, Matching Saved Devices
**What:** Mirror the repo’s existing persistence pattern: repository owns bytes and storage keys; store owns normalized in-memory state and validation.

**When to use:** For all timed-duration load/save operations.

**Example:**
```swift
import Combine
import Foundation

struct KeepAwakeManagedDuration: Codable, Equatable, Identifiable {
    let id: UUID
    let minutes: Int
}

protocol KeepAwakeDurationRepository: AnyObject {
    func loadDurations() throws -> [KeepAwakeManagedDuration]
    func saveDurations(_ durations: [KeepAwakeManagedDuration]) throws
}

@MainActor
final class KeepAwakeDurationStore: ObservableObject {
    @Published private(set) var durations: [KeepAwakeManagedDuration]

    private let repository: KeepAwakeDurationRepository

    init(repository: KeepAwakeDurationRepository) throws {
        self.repository = repository
        self.durations = try repository.loadDurations()
    }

    func reload() throws {
        durations = try repository.loadDurations()
    }

    func replaceAll(_ durations: [KeepAwakeManagedDuration]) throws {
        let normalized = try KeepAwakeManagedDuration.normalizeForPersistence(durations)
        try repository.saveDurations(normalized)
        self.durations = normalized
    }
}
```
Source: repo persistence pattern in [`SavedDeviceRepository.swift`](/Users/hailinpan/Documents/GitHub/Tools-Cat/Tools%20Cat/SavedDeviceRepository.swift#L8) and [`SavedDeviceLibraryStore.swift`](/Users/hailinpan/Documents/GitHub/Tools-Cat/Tools%20Cat/SavedDeviceLibraryStore.swift#L12), plus Apple `UserDefaults` docs at https://developer.apple.com/documentation/foundation/userdefaults

### Pattern 2: Exact-Once Seed On First Read
**What:** Seed default timed durations only when the duration payload does not exist yet. Do not use `register(defaults:)` as the persistence mechanism, and do not re-seed because the list is empty.

**When to use:** In `UserDefaultsKeepAwakeDurationRepository.loadDurations()`.

**Example:**
```swift
final class UserDefaultsKeepAwakeDurationRepository: KeepAwakeDurationRepository {
    private static let durationsKey = "keep_awake_managed_durations"
    private static let didSeedKey = "did_seed_keep_awake_managed_durations"

    private let defaults: UserDefaults
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    func loadDurations() throws -> [KeepAwakeManagedDuration] {
        if let data = defaults.data(forKey: Self.durationsKey) {
            let decoded = try decoder.decode([KeepAwakeManagedDuration].self, from: data)
            return try KeepAwakeManagedDuration.normalizeForPersistence(decoded)
        }

        guard defaults.bool(forKey: Self.didSeedKey) == false else {
            return []
        }

        let seeded = KeepAwakeManagedDuration.defaultSeed
        try saveDurations(seeded)
        defaults.set(true, forKey: Self.didSeedKey)
        return seeded
    }

    func saveDurations(_ durations: [KeepAwakeManagedDuration]) throws {
        let normalized = try KeepAwakeManagedDuration.normalizeForPersistence(durations)
        let data = try encoder.encode(normalized)
        defaults.set(data, forKey: Self.durationsKey)
    }
}
```
Source: Apple preference-domain guidance at https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/UserDefaults/AboutPreferenceDomains/AboutPreferenceDomains.html and repo migration-marker pattern in [`SavedDeviceRepository.swift`](/Users/hailinpan/Documents/GitHub/Tools-Cat/Tools%20Cat/SavedDeviceRepository.swift#L59)

### Pattern 3: Canonical Validation Boundary
**What:** Validate with a single canonical key, not display text. Use `minutes: Int` as the domain truth, derive the localized title from that, and reject invalid or duplicate minutes before persistence.

**When to use:** On every save path, and on load if you want strict corruption detection.

**Example:**
```swift
enum KeepAwakeDurationValidationError: Equatable, Error {
    case invalidMinutes(Int)
    case duplicateMinutes(Int)
}

extension KeepAwakeManagedDuration {
    static let defaultSeed: [KeepAwakeManagedDuration] = [15, 30, 60, 120].map {
        KeepAwakeManagedDuration(id: UUID(), minutes: $0)
    }

    static func normalizeForPersistence(
        _ durations: [KeepAwakeManagedDuration]
    ) throws -> [KeepAwakeManagedDuration] {
        var seenMinutes: Set<Int> = []

        let sorted = try durations.sorted { $0.minutes < $1.minutes }.map { duration in
            guard duration.minutes > 0 else {
                throw KeepAwakeDurationValidationError.invalidMinutes(duration.minutes)
            }
            guard seenMinutes.insert(duration.minutes).inserted else {
                throw KeepAwakeDurationValidationError.duplicateMinutes(duration.minutes)
            }
            return duration
        }

        return sorted
    }
}
```
Source: repo normalization pattern in [`SavedDeviceLibraryStore.swift`](/Users/hailinpan/Documents/GitHub/Tools-Cat/Tools%20Cat/SavedDeviceLibraryStore.swift#L33) and current hardcoded preset set in [`KeepAwakeDurationPreset.swift`](/Users/hailinpan/Documents/GitHub/Tools-Cat/Tools%20Cat/KeepAwakeDurationPreset.swift#L3)

### Pattern 4: Keep `无限常亮` Out Of Persisted Data
**What:** The store owns only timed durations. `无限常亮` remains a fixed controller/session concept.

**When to use:** In data modeling, validation, and future Phase 13 CRUD logic.

**Example:**
```swift
enum KeepAwakeMode: Equatable {
    case off
    case indefinite
    case timed(minutes: Int, endDate: Date)
}
```
Source: requirements boundary in [`REQUIREMENTS.md`](/Users/hailinpan/Documents/GitHub/Tools-Cat/.planning/REQUIREMENTS.md#L26) and current keep-awake mode separation in [`KeepAwakeSessionModel.swift`](/Users/hailinpan/Documents/GitHub/Tools-Cat/Tools%20Cat/KeepAwakeSessionModel.swift#L4)

### Recommended Build Order
1. Add `KeepAwakeManagedDuration`, title formatting, default seed catalog, and validation helpers.
2. Add `KeepAwakeDurationRepository` plus `UserDefaultsKeepAwakeDurationRepository` with exact-once seeding and isolated suite tests.
3. Add `KeepAwakeDurationStore` with `reload()` and `replaceAll(_:)` as the minimal Phase 12 mutation boundary.
4. Wire one shared `KeepAwakeDurationStore` into [`AppDelegate.swift`](/Users/hailinpan/Documents/GitHub/Tools-Cat/Tools%20Cat/AppDelegate.swift#L60) so future phases do not invent their own store instances.
5. Keep menu/session changes minimal: extract shared title/duration seed constants if needed, but defer root-menu replacement to Phase 14.

### Anti-Patterns to Avoid
- **Using `register(defaults:)` as the seed mechanism:** registration-domain defaults are fallback values, not persisted app-owned data.
- **Deleting the storage key to represent an empty list:** that would make future relaunches indistinguishable from first launch and re-seed deleted defaults.
- **Persisting localized menu titles:** it creates copy drift and makes duplicates depend on UI text.
- **Using `TimeInterval` or `Double` as duplicate identity:** it invites equality bugs with no user benefit in this milestone.
- **Pulling `无限常亮` into the managed list:** it violates requirement scope and complicates Phase 13 CRUD rules immediately.

## Don't Hand-Roll

| Problem | Don't Build | Use Instead | Why |
|---------|-------------|-------------|-----|
| Custom objects in defaults | ad hoc dictionaries sprinkled through controllers | Codable structs encoded to `Data` | Matches the repo’s current persistence pattern and keeps decoding/validation centralized |
| First-run seed behavior | `register(defaults:)` or UI-time “if empty then insert defaults” logic | repository-owned exact-once seeding | Prevents deleted defaults from returning and keeps behavior deterministic on relaunch |
| Duplicate detection | compare localized strings like `1 小时` | compare canonical `minutes` only | UI labels are derived output, not identity |
| Sort truth | manual menu-item order constants plus separate data order | store-normalized ascending `minutes` order | One source of truth keeps Phase 14 menu rendering simple |
| Permanent keep-awake action management | CRUD support for `无限常亮` | fixed controller/session action outside the store | Requirement scope explicitly excludes it |

**Key insight:** Phase 12 is not “save four labels somewhere.” It is the first durable domain boundary for timed keep-awake data. The plan should optimize that boundary for exact-once seed semantics, strict validation, and future Phase 13/14 reuse.

## Common Pitfalls

### Pitfall 1: Re-Seeding After User Deletes Everything
**What goes wrong:** A future delete-all flow appears to work, but the four defaults come back on relaunch.

**Why it happens:** The code treats “empty list” or “fewer than four items” as “needs seed”.

**How to avoid:** Seed only when the payload key is absent for the first time. Persist `[]` as real data if the list becomes empty later.

**Warning signs:** Tests only cover first launch and never cover “save empty list then reload”.

### Pitfall 2: Duplicate Validation Based On Display Text
**What goes wrong:** Different labels for the same duration, or future formatting changes, break duplicate detection.

**Why it happens:** Validation compares `menuTitle` instead of canonical duration data.

**How to avoid:** Validate on `minutes` only, and derive titles afterwards.

**Warning signs:** The validator or store imports a formatter just to detect duplicates.

### Pitfall 3: Silent Save-Time Dedupe
**What goes wrong:** Invalid input appears to save successfully, but the stored list quietly drops or rewrites rows.

**Why it happens:** The persistence layer “helps” by normalizing bad data instead of rejecting it.

**How to avoid:** Save-time APIs should throw typed validation errors. If load-time repair is ever chosen, make it explicit and tested as corruption handling, not normal behavior.

**Warning signs:** `saveDurations(_:)` can never fail for duplicates because it just filters them out.

### Pitfall 4: Storing Labels Instead Of Data
**What goes wrong:** Sorting becomes label-dependent, copy changes require migration, and future locale changes can desynchronize stored values from behavior.

**Why it happens:** The data model tries to persist what the user sees instead of the actual timed duration.

**How to avoid:** Persist only stable identity plus canonical minutes.

**Warning signs:** The stored model contains both `title` and `minutes`.

### Pitfall 5: Pulling Menu Refactor Into The Persistence Phase
**What goes wrong:** A data-only phase becomes a large session/menu migration, increasing regression risk without helping the listed success criteria.

**Why it happens:** The planner tries to erase all existing preset hardcoding at once.

**How to avoid:** Land the store first, wire it in AppDelegate, and keep the current menu bridge minimal until Phase 14.

**Warning signs:** Phase 12 tasks include dynamic `NSMenuItem` insertion/removal or controller row-order rewrites.

## Code Examples

Verified patterns from official sources and current repo conventions:

### Persist Timed Durations In `UserDefaults`
```swift
final class UserDefaultsKeepAwakeDurationRepository: KeepAwakeDurationRepository {
    private static let durationsKey = "keep_awake_managed_durations"
    private let defaults: UserDefaults
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    func loadDurations() throws -> [KeepAwakeManagedDuration] {
        guard let data = defaults.data(forKey: Self.durationsKey) else {
            return []
        }

        return try decoder.decode([KeepAwakeManagedDuration].self, from: data)
    }

    func saveDurations(_ durations: [KeepAwakeManagedDuration]) throws {
        let data = try encoder.encode(durations)
        defaults.set(data, forKey: Self.durationsKey)
    }
}
```
Source: Apple `UserDefaults` docs at https://developer.apple.com/documentation/foundation/userdefaults and repo repository pattern in [`SavedDeviceRepository.swift`](/Users/hailinpan/Documents/GitHub/Tools-Cat/Tools%20Cat/SavedDeviceRepository.swift#L31)

### Exact-Once Seeding With A Fresh Defaults Suite
```swift
func testFreshSuiteSeedsDefaultDurationsExactlyOnce() throws {
    let suiteName = "KeepAwakeDurationRepositoryTests.\(UUID().uuidString)"
    let defaults = try XCTUnwrap(UserDefaults(suiteName: suiteName))
    defaults.removePersistentDomain(forName: suiteName)

    let repository = UserDefaultsKeepAwakeDurationRepository(defaults: defaults)

    let firstLoad = try repository.loadDurations()
    let secondRepository = UserDefaultsKeepAwakeDurationRepository(defaults: defaults)
    let secondLoad = try secondRepository.loadDurations()

    XCTAssertEqual(firstLoad.map(\.minutes), [15, 30, 60, 120])
    XCTAssertEqual(secondLoad.map(\.minutes), [15, 30, 60, 120])
}
```
Source: existing isolated-suite test style in [`SavedDeviceRepositoryTests.swift`](/Users/hailinpan/Documents/GitHub/Tools-Cat/Tools%20CatTests/SavedDeviceRepositoryTests.swift#L5) and [`SavedDeviceLibraryStoreTests.swift`](/Users/hailinpan/Documents/GitHub/Tools-Cat/Tools%20CatTests/SavedDeviceLibraryStoreTests.swift#L5)

### Share The Store From App Startup
```swift
private var keepAwakeDurationStore: KeepAwakeDurationStore!

private func configureSharedStores() {
    let defaults = launchConfiguration.userDefaults ?? .standard
    let durationRepository = UserDefaultsKeepAwakeDurationRepository(defaults: defaults)
    keepAwakeDurationStore = try? KeepAwakeDurationStore(repository: durationRepository)
}
```
Source: startup composition pattern in [`AppDelegate.swift`](/Users/hailinpan/Documents/GitHub/Tools-Cat/Tools%20Cat/AppDelegate.swift#L60)

## State Of The Art

| Old Approach | Current Approach | When Changed | Impact |
|--------------|------------------|--------------|--------|
| Hardcoded timed preset enum with title and seconds baked in | persisted timed-duration model plus seeded repository/store | planner target for Phase 12, researched 2026-04-15 | Phase 13/14 can consume real user data instead of controller constants |
| UI-time defaults or registration-domain fallback | repository-owned exact-once persisted seed | current Apple defaults guidance and repo migration-marker pattern | delete/edit flows stay trustworthy after relaunch |
| Localized labels as truth | canonical integer minutes with derived labels | recommended for this phase | duplicate validation and sorting become deterministic |

**Deprecated/outdated:**
- Using `UserDefaults.register(defaults:)` to claim app-owned persisted data. Apple’s preference-domain model treats registration defaults as fallback values, not stored user data.
- Adding new `synchronize()` calls as part of the duration-store design. The repo still has existing calls in [`AppDelegate.swift`](/Users/hailinpan/Documents/GitHub/Tools-Cat/Tools%20Cat/AppDelegate.swift#L70), but Phase 12 should not depend on them for correctness.

## Open Questions

1. **Should Phase 12 keep the current enum bridge or migrate keep-awake session state immediately?**
   - What we know: the current preset enum is coupled into session, presentation, controller, and tests.
   - What's unclear: whether the planner wants minimum Phase 12 churn or earlier convergence toward Phase 14.
   - Recommendation: keep a temporary bridge in Phase 12, but extract shared seed/title logic so Phase 14 can delete the enum cleanly.

2. **How should corrupted stored duration data behave after first seed?**
   - What we know: there is no true legacy duration dataset to rescue; bad data would come from a bug or manual tampering.
   - What's unclear: whether the product should throw/fail closed or silently self-heal on load.
   - Recommendation: fail closed on load in Phase 12 tests and avoid silent repair. If self-healing is desired later, plan it explicitly as corruption handling.

## Environment Availability

| Dependency | Required By | Available | Version | Fallback |
|------------|------------|-----------|---------|----------|
| `xcodebuild` | XCTest execution and Xcode project validation | ✓ | Xcode 26.2 (17C52) | — |
| `swift` | Swift toolchain and local builds | ✓ | Apple Swift 6.2.3 | — |
| macOS AppKit runtime | app startup and menu-bar integration smoke | ✓ | macOS host present | — |

**Missing dependencies with no fallback:**
- None

**Missing dependencies with fallback:**
- None

## Validation Architecture

### Test Framework
| Property | Value |
|----------|-------|
| Framework | XCTest / XCUITest via Xcode 26.2 |
| Config file | none — test targets are defined in `Tools Cat.xcodeproj` |
| Quick run command | `xcodebuild test -project "Tools Cat.xcodeproj" -scheme "Tools Cat" -destination 'platform=macOS' -only-testing:'Tools CatTests/KeepAwakeDurationRepositoryTests' -only-testing:'Tools CatTests/KeepAwakeDurationStoreTests'` |
| Full suite command | `xcodebuild test -project "Tools Cat.xcodeproj" -scheme "Tools Cat" -destination 'platform=macOS'` |

The `xcodebuild` command shape was verified locally on 2026-04-15 with:

```bash
xcodebuild test -project "Tools Cat.xcodeproj" -scheme "Tools Cat" -destination 'platform=macOS' -only-testing:'Tools CatTests/SavedDeviceRepositoryTests/testEmptySuiteLoadsNoDevices'
```

### Phase Requirements → Test Map
| Req ID | Behavior | Test Type | Automated Command | File Exists? |
|--------|----------|-----------|-------------------|-------------|
| AWAKE-06 | Fresh defaults suite seeds `15/30/60/120` once and later reloads do not append/re-seed | unit | `xcodebuild test -project "Tools Cat.xcodeproj" -scheme "Tools Cat" -destination 'platform=macOS' -only-testing:'Tools CatTests/KeepAwakeDurationRepositoryTests'` | ❌ Wave 0 |
| AWAKE-10 | Invalid or duplicate timed durations are rejected before save | unit | `xcodebuild test -project "Tools Cat.xcodeproj" -scheme "Tools Cat" -destination 'platform=macOS' -only-testing:'Tools CatTests/KeepAwakeDurationStoreTests'` | ❌ Wave 0 |
| AWAKE-11 | Persisted durations survive a fresh repository/store instance and remain sorted ascending | unit | `xcodebuild test -project "Tools Cat.xcodeproj" -scheme "Tools Cat" -destination 'platform=macOS' -only-testing:'Tools CatTests/KeepAwakeDurationRepositoryTests' -only-testing:'Tools CatTests/KeepAwakeDurationStoreTests'` | ❌ Wave 0 |

### Sampling Rate
- **Per task commit:** `xcodebuild test -project "Tools Cat.xcodeproj" -scheme "Tools Cat" -destination 'platform=macOS' -only-testing:'Tools CatTests/KeepAwakeDurationRepositoryTests' -only-testing:'Tools CatTests/KeepAwakeDurationStoreTests'`
- **Per wave merge:** `xcodebuild test -project "Tools Cat.xcodeproj" -scheme "Tools Cat" -destination 'platform=macOS' -only-testing:'Tools CatTests/KeepAwakeDurationRepositoryTests' -only-testing:'Tools CatTests/KeepAwakeDurationStoreTests' -only-testing:'Tools CatTests/KeepAwakeSessionModelTests'`
- **Phase gate:** `xcodebuild test -project "Tools Cat.xcodeproj" -scheme "Tools Cat" -destination 'platform=macOS'`

### Manual Boundary
- No new user-facing manual-only behavior is required for the phase requirements themselves if menu rendering stays deferred.
- Optional smoke only: launch, quit, relaunch the app once after the store is wired in AppDelegate to confirm the new duration store does not crash startup or termination.

### Wave 0 Gaps
- [ ] [`Tools CatTests/KeepAwakeDurationRepositoryTests.swift`](/Users/hailinpan/Documents/GitHub/Tools-Cat/Tools%20CatTests/KeepAwakeDurationRepositoryTests.swift) — seed-once, encode/decode, empty-list persistence, fresh-suite reload
- [ ] [`Tools CatTests/KeepAwakeDurationStoreTests.swift`](/Users/hailinpan/Documents/GitHub/Tools-Cat/Tools%20CatTests/KeepAwakeDurationStoreTests.swift) — validation errors, sort normalization, replace/reload behavior
- [ ] Extend [`KeepAwakeSessionModelTests.swift`](/Users/hailinpan/Documents/GitHub/Tools-Cat/Tools%20CatTests/KeepAwakeSessionModelTests.swift#L35) only if the Phase 12 bridge changes timed preset typing
- [ ] Extend [`StatusBarControllerKeepAwakeMenuTests.swift`](/Users/hailinpan/Documents/GitHub/Tools-Cat/Tools%20CatTests/StatusBarControllerKeepAwakeMenuTests.swift#L8) only if AppDelegate or preset-title bridging changes the current fixed-row behavior

## Sources

### Primary (HIGH confidence)
- Apple `UserDefaults` documentation — persistence APIs, `suiteName`, `data(forKey:)`, `didChangeNotification`: https://developer.apple.com/documentation/foundation/userdefaults
- Apple Preferences and Settings Programming Guide, “About the User Defaults System / Preference Domains” — registration domain and persistence behavior: https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/UserDefaults/AboutPreferenceDomains/AboutPreferenceDomains.html
- Repo persistence pattern in [`SavedDeviceRepository.swift`](/Users/hailinpan/Documents/GitHub/Tools-Cat/Tools%20Cat/SavedDeviceRepository.swift#L15)
- Repo observable store pattern in [`SavedDeviceLibraryStore.swift`](/Users/hailinpan/Documents/GitHub/Tools-Cat/Tools%20Cat/SavedDeviceLibraryStore.swift#L4)
- Current hardcoded keep-awake preset seams in [`KeepAwakeDurationPreset.swift`](/Users/hailinpan/Documents/GitHub/Tools-Cat/Tools%20Cat/KeepAwakeDurationPreset.swift#L3), [`KeepAwakeSessionModel.swift`](/Users/hailinpan/Documents/GitHub/Tools-Cat/Tools%20Cat/KeepAwakeSessionModel.swift#L4), [`KeepAwakePresentation.swift`](/Users/hailinpan/Documents/GitHub/Tools-Cat/Tools%20Cat/KeepAwakePresentation.swift#L23), and [`StatusBarController.swift`](/Users/hailinpan/Documents/GitHub/Tools-Cat/Tools%20Cat/StatusBarController.swift#L64)

### Secondary (MEDIUM confidence)
- Prior timed keep-awake phase research and decisions in [`04-CONTEXT.md`](/Users/hailinpan/Documents/GitHub/Tools-Cat/.planning/phases/04-timed-keep-awake/04-CONTEXT.md#L10) and [`04-RESEARCH.md`](/Users/hailinpan/Documents/GitHub/Tools-Cat/.planning/phases/04-timed-keep-awake/04-RESEARCH.md#L1)
- Current test harness patterns in [`SavedDeviceRepositoryTests.swift`](/Users/hailinpan/Documents/GitHub/Tools-Cat/Tools%20CatTests/SavedDeviceRepositoryTests.swift#L5), [`SavedDeviceLibraryStoreTests.swift`](/Users/hailinpan/Documents/GitHub/Tools-Cat/Tools%20CatTests/SavedDeviceLibraryStoreTests.swift#L5), and [`Tools_CatUITests.swift`](/Users/hailinpan/Documents/GitHub/Tools-Cat/Tools%20CatUITests/Tools_CatUITests.swift#L276)

### Tertiary (LOW confidence)
- None

## Metadata

**Confidence breakdown:**
- Standard stack: HIGH - the repo already standardizes on `UserDefaults` + Codable `Data`, and Apple’s defaults APIs are stable and current.
- Architecture: HIGH - existing saved-device patterns map directly, and Phase 12 can stay intentionally data-scoped.
- Pitfalls: HIGH - the key failure modes are well-defined by the exact-once seed requirement and current hardcoded coupling.

**Research date:** 2026-04-15
**Valid until:** 2026-05-15
