---
phase: 20-first-use-device-seed
plan: 01
subsystem: testing
tags: [userdefaults, xctest, xcuitest, onboarding, wol]
requires:
  - phase: 19-deferred-device-form-validation
    provides: direct-launch device-library ui seams that can distinguish fresh and explicit-empty startup paths
provides:
  - repository-owned first-use saved-device seeding for one default NAS entry
  - regression coverage proving explicit empty libraries stay empty and existing libraries stay untouched
  - ui launch fixtures that distinguish missing saved-device payloads from explicit empty payloads
affects: [milestone-v1.7, device-library, onboarding, ui-tests]
tech-stack:
  added: []
  patterns:
    - repository seeds first-use defaults only when the canonical payload key is absent
    - direct-launch ui fixtures use nil vs explicit empty payloads to express startup semantics honestly
key-files:
  created: [.planning/phases/20-first-use-device-seed/20-01-SUMMARY.md]
  modified:
    - Tools Cat/SavedDeviceRepository.swift
    - Tools CatTests/SavedDeviceRepositoryTests.swift
    - Tools CatTests/SavedDeviceLibraryStoreTests.swift
    - Tools CatUITests/Tools_CatUITests.swift
key-decisions:
  - "Keep first-use seeding inside `UserDefaultsSavedDeviceRepository.loadDevices()` so persistence truth stays in one repository-owned boundary."
  - "Treat a missing `saved_devices` payload as first use, but preserve an explicit persisted empty array as an already-initialized empty library."
patterns-established:
  - "First-use seed via key absence: seed immediately, persist through the existing normalization path, and never add a second marker flag."
  - "UI startup fixture split: `nil` launch payload means fresh defaults, while `[]` means an explicit empty device library."
requirements-completed: [DEVS-13, DEVS-14]
duration: 2026-05-06 session
completed: 2026-05-06
---

# Phase 20 Plan 01: First-Use Device Seed Summary

**Fresh saved-device libraries now open with one seeded `UGREEN NAS` entry while explicit-empty and existing personal libraries remain untouched**

## Performance

- **Completed:** 2026-05-06
- **Tasks:** 2
- **Core repo files changed:** 4
- **Phase artifacts added:** 1

## Accomplishments
- Moved first-use default-device seeding into the saved-device repository so a missing `saved_devices` payload now yields exactly one canonical `UGREEN NAS` device and persists it immediately.
- Added repository and store regressions proving the seed happens once, never overwrites existing non-empty libraries, and never reseeds an explicit empty library.
- Split direct-launch UI fixtures so fresh startup and explicit-empty startup are tested separately, keeping empty-state coverage honest after the new seed behavior.

## Task Commits

Each task was committed atomically:

1. **Task 1: Add repository-owned first-use seed truth and lock it with repository/store regressions** - `d494e96` (feat)
2. **Task 2: Separate fresh-seed and explicit-empty startup fixtures in direct-launch UI coverage** - `a62e804` (test)

**Plan metadata:** `81e07ff` (docs)

## Files Created/Modified

- `Tools Cat/SavedDeviceRepository.swift` - seeds and persists the canonical first-use `UGREEN NAS` device when `saved_devices` is absent.
- `Tools CatTests/SavedDeviceRepositoryTests.swift` - covers first-use seeding, no duplicate on reload, explicit-empty preservation, and no-overwrite behavior.
- `Tools CatTests/SavedDeviceLibraryStoreTests.swift` - proves a fresh repository-backed store exposes the seed exactly once.
- `Tools CatUITests/Tools_CatUITests.swift` - distinguishes fresh launch from explicit-empty launch and adds direct-launch seed coverage.
- `.planning/phases/20-first-use-device-seed/20-01-SUMMARY.md` - records execution outcome and verification evidence.

## Verification Highlights

- `xcodebuild test -project "Tools Cat.xcodeproj" -scheme "Tools Cat" -destination 'platform=macOS' -parallel-testing-enabled NO -only-testing:'Tools CatTests/SavedDeviceRepositoryTests' -only-testing:'Tools CatTests/SavedDeviceLibraryStoreTests'`
- `xcodebuild test -project "Tools Cat.xcodeproj" -scheme "Tools Cat" -destination 'platform=macOS' -parallel-testing-enabled NO -only-testing:'Tools CatUITests/Tools_CatUITests/testLaunchWithFreshDeviceLibrarySeedsDefaultDevice' -only-testing:'Tools CatUITests/Tools_CatUITests/testLaunchWithExplicitlyEmptyDeviceLibraryShowsPolishedEmptyState' -only-testing:'Tools CatUITests/Tools_CatUITests/testLaunchWithSeededDeviceLibraryShowsManagementWindow'`

## Issues Encountered

None.

## Next Phase Readiness

Phase 20 completes the v1.7 scoped product work. The milestone is now ready for milestone-level audit/archive flow rather than more onboarding changes.

## Self-Check: PASSED

- Found `.planning/phases/20-first-use-device-seed/20-01-SUMMARY.md`
- Found repository/store verification pass for DEVS-13 and DEVS-14
- Found direct-launch UI verification pass for fresh, explicit-empty, and seeded startup paths
