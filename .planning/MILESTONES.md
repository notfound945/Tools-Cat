# Milestones

## v1.3 Duration Management (Shipped: 2026-04-16)

**Phases completed:** 3 phases, 7 plans, 11 tasks
**Audit:** passed

**Key accomplishments:**

- Managed keep-awake durations now persist as normalized UserDefaults data with exact-once default seeding, derived menu titles, and a validated observable store
- The keep-awake session and fixed root menu now run on managed duration values and a shared duration store, while preserving the current shipped menu structure
- The app now builds against a macOS 14.0 deployment baseline, and the repo guidance plus validation boundary all agree on what is automated proof versus what still needs a real macOS 14.8.3 launch smoke
- The keep-awake duration manager now has a real store-backed state machine for timed CRUD, validation, and delete confirmation
- The app now exposes a real native duration-management window from both direct launch and the status menu, with the live managed-duration root-menu sync folded into Phase 13
- Keep-awake menu rows now follow managed durations live, and add/edit happen in one compact in-place modal instead of replacing the management surface
- The keep-awake duration manager now presents timed durations inside a clearly grouped native list surface instead of letting them disappear into the window background

**Archive files:**

- `.planning/milestones/v1.3-ROADMAP.md`
- `.planning/milestones/v1.3-REQUIREMENTS.md`
- `.planning/milestones/v1.3-MILESTONE-AUDIT.md`

---

## v1.2 Menu Truth (Shipped: 2026-04-15)

**Phases completed:** 2 phases, 3 plans, 5 tasks
**Audit:** passed

**Key accomplishments:**

- The keep-awake root menu now hides the idle `关闭常亮` row while keeping a direct stop action visible for real active or stopping sessions.
- Phase 10 now has startup, replacement, stopping, and compact-idle regression coverage plus a validation contract that maps `MENU-01` through `MENU-03` to exact checks.
- The missing `10-VERIFICATION.md` artifact now ties the shipped evidence chain to all three MENU requirements without reopening runtime scope.
- The v1.2 audit now passes with closed traceability, formal verification, and no remaining milestone blockers.

**Archive files:**

- `.planning/milestones/v1.2-ROADMAP.md`
- `.planning/milestones/v1.2-REQUIREMENTS.md`
- `.planning/milestones/v1.2-MILESTONE-AUDIT.md`

---

## v1.1 Hardening (Shipped: 2026-04-13)

**Phases completed:** 4 phases, 11 plans, 12 tasks

**Key accomplishments:**

- Project and audit docs now describe the shipped `快速 WOL` wake surface with the dedicated `发送 WOL …` row, while deferring shortcut recovery to `CONV-04` as non-blocking debt
- Phase 2 verification now records the shipped device-library copy wiring as passed and keeps the old gap only as historical context
- Phase 3 verification now documents the shipped `快速 WOL` wake section, dedicated `发送 WOL …` entry, durable wake status, and reopen memory instead of the removed shortcut-first menu model
- StatusBarController now has a dedicated XCTest slice proving the root `发送 WOL …` and `管理 WOL 设备…` rows dispatch through their callback seams and that the wake row disables during shared in-flight sends.
- Named Phase 7 regression runner plus a validation contract that maps controller seams, direct-launch UI smoke, and manual tray-entry checks
- Current-facing docs now align the Phase 7 verification boundary across controller tests, launch-argument UI smoke, and manual tray-entry coverage
- Phase 01 and Phase 02 validation contracts now describe the real shipped coverage, approved sign-off, and current manager smoke evidence instead of stale wave-0 placeholders.
- Phase 03 and Phase 04 validation contracts now match the shipped compact wake and timed keep-awake behavior, with real wave-0 coverage and approved evidence instead of stale placeholders.
- The repo now builds and runs as `Tools Cat`, and the legacy `saved_devices` / `saved_device_wake_metadata` keys migrate safely into the new bundle-ID family exactly once.
- The stable regression script and the default packaging path now both target `Tools Cat`, including the renamed UI smoke selectors and the new DMG output name.
- The active maintainer surface now consistently says `Tools Cat`, while old-brand residue is framed as optional manual cleanup instead of destructive automation.

**Archive files:**

- `.planning/milestones/v1.1-ROADMAP.md`
- `.planning/milestones/v1.1-REQUIREMENTS.md`

---

## v1.0 MVP (Shipped: 2026-04-13)

**Phases completed:** 5 phases, 17 plans, 31 tasks
**Audit:** tech_debt, no in-scope blockers

**Key accomplishments:**

- Locked truthful Wake-on-LAN validation, local-send feedback, and keep-awake state ownership so the app no longer implies success before the underlying system work completes.
- Added a local saved-device library with CRUD, notes, ordering, and a dedicated native management window instead of source-edited presets.
- Turned saved devices into the daily wake path with shared session state, duplicate-send protection, persistent wake status, and last-used reopen defaults.
- Shipped timed keep-awake with fixed presets, countdown feedback, replacement behavior, and automatic expiry on the live menu flow.
- Finished a compact three-group native menu plus polished WOL and device-library utility windows with targeted smoke coverage and human approval.

**Archive files:**

- `.planning/milestones/v1.0-ROADMAP.md`
- `.planning/milestones/v1.0-REQUIREMENTS.md`
- `.planning/milestones/v1.0-MILESTONE-AUDIT.md`

---
