---
phase: 07
slug: menu-bar-verification-strategy
status: draft
nyquist_compliant: true
wave_0_complete: true
created: 2026-04-13
---

# Phase 07 — Validation Contract

> Canonical validation contract for the Phase 7 menu-bar verification strategy.

---

## Stable Regression Slice

| Property | Value |
|----------|-------|
| Canonical command | `bash scripts/run_menu_bar_verification_slice.sh` |
| Project | `Mac OS Swiss Knife.xcodeproj` |
| Scheme | `Mac OS Swiss Knife` |
| Destination | `platform=macOS` |
| Scope | Controller seams for menu grouping and entry dispatch, plus launch-argument UI smoke for retained utility windows |
| Boundary | This automated slice does not prove live tray clicks |

The canonical script runs these concrete automated checks:

- `Mac OS Swiss KnifeTests/StatusBarControllerEntryFlowTests`
- `Mac OS Swiss KnifeTests/StatusBarControllerMenuPolishTests`
- `Mac OS Swiss KnifeTests/StatusBarControllerWakeMenuTests`
- `Mac OS Swiss KnifeTests/StatusBarControllerKeepAwakeMenuTests`
- `Mac OS Swiss KnifeUITests/Mac_OS_Swiss_KnifeUITests/testLaunchWithWOLWindowShowsPolishedSections`
- `Mac OS Swiss KnifeUITests/Mac_OS_Swiss_KnifeUITests/testLaunchWithSeededDeviceLibraryShowsManagementListSurface`
- `Mac OS Swiss KnifeUITests/Mac_OS_Swiss_KnifeUITests/testLaunchWithEmptyDeviceLibraryShowsPolishedEmptyState`

## Requirement Coverage Map

| Requirement | Coverage | Evidence |
|-------------|----------|----------|
| `AUTO-01` | Automated coverage inventory is explicit and names the wake and management entry seams | `StatusBarControllerEntryFlowTests` proves `发送 WOL …` dispatch through `onOpenWOL`, `管理 WOL 设备…` dispatch through `onOpenDeviceLibrary`, and the in-flight disabled-state rule for the root wake row |
| `AUTO-02` | One explicit layered strategy covers controller seams and direct-launch UI smoke, then uses manual tray-entry for the live status-item path | `scripts/run_menu_bar_verification_slice.sh`, the controller suites above, the WOL launch smoke, the seeded device-library list-surface smoke, the empty-state smoke, and the manual tray-entry checklist below |
| `AUTO-03` | Maintainers have one stable regression slice command instead of rediscovering scattered `xcodebuild` invocations | `bash scripts/run_menu_bar_verification_slice.sh` |

## What The Automated Slice Proves

- Controller tests prove the menu structure, wake submenu behavior, keep-awake menu behavior, and root entry callbacks at the `StatusBarController` seam.
- `StatusBarControllerEntryFlowTests` proves the root `发送 WOL …` and `管理 WOL 设备…` rows dispatch through the controller callbacks, and that the root wake row disables while the shared wake session is sending.
- The XCUITests prove the retained WOL and device-library windows render correctly when launched through the existing utility-window seams; this is launch-argument UI smoke, not live tray automation.
- The automated slice does not prove live tray clicks, because the UI smoke opens retained windows through launch arguments instead of clicking the real `NSStatusItem`.

## Current-Facing Docs

- `.planning/phases/05-native-menu-polish/05-VERIFICATION.md` should be read as the current-facing verification report for this same layered strategy.
- `.planning/PROJECT.md` should describe the active hardening work in the same terms: controller tests, direct-launch UI smoke, and manual tray-entry.
- If any current doc implies automated live tray clicks, this validation contract takes precedence and the doc should be corrected.

## Manual Tray-Entry Checklist

This manual tray-entry checklist covers the live menu-bar path that automation does not currently own.

1. Launch the built app normally so it appears as an `LSUIElement` menu-bar utility.
2. Click the live tray icon and confirm the root menu reads in this order: keep-awake group, wake group, then management group.
3. Confirm the wake group exposes `快速 WOL`, `发送 WOL …`, and `管理 WOL 设备…` with native separators only.
4. Click `发送 WOL …` from the live tray menu and confirm the retained `WOL 发送器` window opens and remains usable.
5. Click `管理 WOL 设备…` from the live tray menu and confirm the retained `设备库` window opens and remains usable.
6. If a wake send is already in flight, reopen the live tray menu and confirm the root `发送 WOL …` row is disabled while `管理 WOL 设备…` remains available.

## Boundary Note

Phase 7 owns the menu-bar verification strategy for the current wake and management surfaces only. It does not reopen Phase 8's broader validation-debt cleanup beyond this narrow statement of coverage ownership.
