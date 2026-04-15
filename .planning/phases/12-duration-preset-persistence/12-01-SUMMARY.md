---
phase: 12-duration-preset-persistence
plan: 01
subsystem: infra
tags: [swift, userdefaults, persistence, keep-awake, macos]
requires:
  - phase: 11-menu-truth-verification-closure
    provides: "The keep-awake menu truth contract that the managed-duration foundation must preserve."
provides:
  - "Managed keep-awake duration entity with derived Chinese menu titles"
  - "UserDefaults-backed exact-once seeding and normalized reload for timed durations"
  - "Observable duration store with centralized validation and mutation persistence"
affects: [phase-12-02, phase-13-duration-management-surface, phase-14-managed-duration-menu-integration]
tech-stack:
  added: []
  patterns:
    - "Managed-duration persistence lives behind a repository plus store seam modeled after the saved-device library flow."
key-files:
  created:
    - Tools Cat/ManagedKeepAwakeDuration.swift
    - Tools Cat/KeepAwakeDurationRepository.swift
    - Tools Cat/KeepAwakeDurationStore.swift
    - Tools CatTests/KeepAwakeDurationRepositoryTests.swift
    - Tools CatTests/KeepAwakeDurationStoreTests.swift
  modified:
    - Tools Cat.xcodeproj/project.pbxproj
key-decisions:
  - "Seed the four shipped timed durations only when the dedicated defaults key is absent, so deleted defaults never silently reappear on later launches."
  - "Keep titles derived from canonical duration seconds instead of persisting localized strings, so ordering and duplicate detection stay tied to one numeric source of truth."
patterns-established:
  - "Managed keep-awake durations are normalized by canonical seconds and deduplicated before persistence."
  - "Validation for duration creation and editing belongs in KeepAwakeDurationStore, not in raw UserDefaults access."
requirements-completed: [AWAKE-10, AWAKE-11]
duration: 3 min
completed: 2026-04-15
---

# Phase 12 Plan 01: Duration Persistence Foundation Summary

**Managed keep-awake durations now persist as normalized UserDefaults data with exact-once default seeding, derived menu titles, and a validated observable store**

## Performance

- **Duration:** 3 min
- **Started:** 2026-04-15T16:00:00+08:00
- **Completed:** 2026-04-15T16:03:00+08:00
- **Tasks:** 2
- **Files modified:** 6

## Accomplishments

- Added `ManagedKeepAwakeDuration` as the canonical timed keep-awake value type with derived Chinese menu titles from `durationSeconds`.
- Added `UserDefaultsKeepAwakeDurationRepository` with exact-once seeding for `15 分钟` / `30 分钟` / `1 小时` / `2 小时`, plus normalized ascending reload and duplicate removal.
- Added `KeepAwakeDurationStore` with centralized invalid/duplicate validation and persistence-backed add, update, delete, reload, and lookup APIs.
- Locked the new persistence seam with focused repository and store XCTest coverage.

## Task Commits

Each task was committed atomically:

1. **Task 1: Add the managed timed-duration entity and exact-once UserDefaults repository** - `fd254ba` (feat)
2. **Task 2: Add the observable duration store with centralized validation and mutation persistence** - `51980dd` (feat)

**Plan metadata:** committed with this summary file

## Files Created/Modified

- `Tools Cat/ManagedKeepAwakeDuration.swift` - Defines the stable-ID timed duration entity and derived menu-title formatting.
- `Tools Cat/KeepAwakeDurationRepository.swift` - Implements the repository seam, exact-once default seeding, normalization, and deduplication.
- `Tools Cat/KeepAwakeDurationStore.swift` - Owns validated mutation APIs and observable reload behavior for managed durations.
- `Tools CatTests/KeepAwakeDurationRepositoryTests.swift` - Covers first-load seeding, no re-seed behavior, normalization, and non-persistence of titles.
- `Tools CatTests/KeepAwakeDurationStoreTests.swift` - Covers invalid/duplicate rejection, sorted edits, deletion, and persistence across reload.
- `Tools Cat.xcodeproj/project.pbxproj` - Registers the new production and test Swift files in the synced project roots.

## Decisions Made

- Used one dedicated `managed_keep_awake_durations` defaults key so "missing key" and "existing but empty array" remain meaningfully different states.
- Kept menu titles derived from seconds instead of stored JSON fields so future edits and sorting stay based on canonical numeric duration values.

## Deviations from Plan

None - plan executed exactly as written.

## Issues Encountered

- One repository test initially tried to read the stored JSON as a `String` directly from `UserDefaults`; it was corrected to decode the persisted `Data` payload before final verification.

## User Setup Required

None - no external service configuration required.

## Next Phase Readiness

- The keep-awake duration domain now has a real persisted source of truth that later UI and menu phases can consume directly.
- Phase `12-02` can now migrate the keep-awake session and fixed menu rows off the preset enum without inventing a second storage path.

## Self-Check: PASSED

---
*Phase: 12-duration-preset-persistence*
*Completed: 2026-04-15*
