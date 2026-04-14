---
phase: 05
slug: native-menu-polish
status: draft
nyquist_compliant: true
wave_0_complete: true
created: 2026-04-12
---

# Phase 05 — Validation Strategy

> Per-phase validation contract for feedback sampling during execution.

---

## Test Infrastructure

| Property | Value |
|----------|-------|
| **Framework** | XCTest + XCUITest via Xcode 26.2 |
| **Config file** | none — Xcode project and shared scheme only |
| **Quick run command** | `xcodebuild test -project 'Mac OS Swiss Knife.xcodeproj' -scheme 'Mac OS Swiss Knife' -destination 'platform=macOS' -only-testing:'Mac OS Swiss KnifeTests/StatusBarControllerMenuPolishTests' -only-testing:'Mac OS Swiss KnifeTests/StatusBarControllerWakeMenuTests' -only-testing:'Mac OS Swiss KnifeTests/StatusBarControllerKeepAwakeMenuTests'` |
| **Full suite command** | `xcodebuild test -project 'Mac OS Swiss Knife.xcodeproj' -scheme 'Mac OS Swiss Knife' -destination 'platform=macOS'` |
| **Estimated runtime** | quick slice ~15-25s, UI smoke slice ~20-40s, full suite ~60-90s |

---

## Sampling Rate

- **After every task commit:** Run the narrowest matching quick slice rather than the full suite.
- **Plan 05-01 controller/menu edits (wave 1):** `xcodebuild test -project 'Mac OS Swiss Knife.xcodeproj' -scheme 'Mac OS Swiss Knife' -destination 'platform=macOS' -only-testing:'Mac OS Swiss KnifeTests/StatusBarControllerMenuPolishTests' -only-testing:'Mac OS Swiss KnifeTests/StatusBarControllerWakeMenuTests' -only-testing:'Mac OS Swiss KnifeTests/StatusBarControllerKeepAwakeMenuTests'`
- **Plan 05-02 WOL hierarchy edits (wave 1):** `xcodebuild build-for-testing -project 'Mac OS Swiss Knife.xcodeproj' -scheme 'Mac OS Swiss Knife' -destination 'platform=macOS'`
- **Plan 05-02 device-library hierarchy edits (wave 1):** `xcodebuild test -project 'Mac OS Swiss Knife.xcodeproj' -scheme 'Mac OS Swiss Knife' -destination 'platform=macOS' -only-testing:'Mac OS Swiss KnifeUITests/Mac_OS_Swiss_KnifeUITests/testLaunchWithSeededDeviceLibraryShowsManagementWindow'`
- **Plan 05-03 final UI smoke (wave 2):** `xcodebuild test -project 'Mac OS Swiss Knife.xcodeproj' -scheme 'Mac OS Swiss Knife' -destination 'platform=macOS' -only-testing:'Mac OS Swiss KnifeUITests/Mac_OS_Swiss_KnifeUITests/testLaunchWithWOLWindowShowsPolishedSections' -only-testing:'Mac OS Swiss KnifeUITests/Mac_OS_Swiss_KnifeUITests/testLaunchWithSeededDeviceLibraryShowsManagementWindow' -only-testing:'Mac OS Swiss KnifeUITests/Mac_OS_Swiss_KnifeUITests/testLaunchWithEmptyDeviceLibraryShowsPolishedEmptyState'`
- **After every plan wave:** Run `xcodebuild test -project 'Mac OS Swiss Knife.xcodeproj' -scheme 'Mac OS Swiss Knife' -destination 'platform=macOS'`
- **Before `$gsd-verify-work`:** Full suite must be green
- **Max feedback latency:** 30 seconds for task slices, 90 seconds at wave/full-suite gates

---

## Per-Task Verification Map

| Task ID | Plan | Wave | Requirement | Test Type | Automated Command | File Exists | Status |
|---------|------|------|-------------|-----------|-------------------|-------------|--------|
| 05-01-01 | 05-01 | 1 | UX-01 | unit | `xcodebuild test -project 'Mac OS Swiss Knife.xcodeproj' -scheme 'Mac OS Swiss Knife' -destination 'platform=macOS' -only-testing:'Mac OS Swiss KnifeTests/StatusBarControllerMenuPolishTests'` | ✅ task creates before verify | ⬜ pending |
| 05-01-02 | 05-01 | 1 | UX-01 | unit | `xcodebuild test -project 'Mac OS Swiss Knife.xcodeproj' -scheme 'Mac OS Swiss Knife' -destination 'platform=macOS' -only-testing:'Mac OS Swiss KnifeTests/StatusBarControllerMenuPolishTests' -only-testing:'Mac OS Swiss KnifeTests/StatusBarControllerWakeMenuTests' -only-testing:'Mac OS Swiss KnifeTests/StatusBarControllerKeepAwakeMenuTests'` | ✅ | ⬜ pending |
| 05-02-01 | 05-02 | 1 | UX-04 | build | `xcodebuild build-for-testing -project 'Mac OS Swiss Knife.xcodeproj' -scheme 'Mac OS Swiss Knife' -destination 'platform=macOS'` | ✅ | ⬜ pending |
| 05-02-02 | 05-02 | 1 | UX-04 | ui smoke | `xcodebuild test -project 'Mac OS Swiss Knife.xcodeproj' -scheme 'Mac OS Swiss Knife' -destination 'platform=macOS' -only-testing:'Mac OS Swiss KnifeUITests/Mac_OS_Swiss_KnifeUITests/testLaunchWithSeededDeviceLibraryShowsManagementWindow'` | ✅ extend | ⬜ pending |
| 05-03-01 | 05-03 | 2 | UX-01, UX-04 | ui smoke | `xcodebuild test -project 'Mac OS Swiss Knife.xcodeproj' -scheme 'Mac OS Swiss Knife' -destination 'platform=macOS' -only-testing:'Mac OS Swiss KnifeUITests/Mac_OS_Swiss_KnifeUITests/testLaunchWithWOLWindowShowsPolishedSections' -only-testing:'Mac OS Swiss KnifeUITests/Mac_OS_Swiss_KnifeUITests/testLaunchWithSeededDeviceLibraryShowsManagementWindow' -only-testing:'Mac OS Swiss KnifeUITests/Mac_OS_Swiss_KnifeUITests/testLaunchWithEmptyDeviceLibraryShowsPolishedEmptyState'` | ✅ extend | ⬜ pending |
| 05-03-02 | 05-03 | 2 | UX-01, UX-04 | manual visual | `echo "Manual checkpoint follows successful Task 1 UI smoke execution"` | ✅ manual | ⬜ pending |

*Status: ⬜ pending · ✅ green · ❌ red · ⚠️ flaky*

---

## Wave References

- **Wave 1:** Plan `05-01` locks the menu controller contract for `UX-01` while Plan `05-02` polishes the WOL and device-library windows for `UX-04`.
- **Wave 2:** Plan `05-03` runs the final Phase 5 UI smoke and the blocking human approval gate after both wave-1 plans complete.
- **Wave 0:** none required; this phase creates controller coverage in Plan `05-01` Task 1 and extends existing UI smoke in Plans `05-02` and `05-03`.

---

## Manual-Only Verifications

| Behavior | Requirement | Why Manual | Test Instructions |
|----------|-------------|------------|-------------------|
| Root menu reads as three compact native groups without decorative chrome | UX-01 | XCTest can verify separator/order invariants, but not real menu scanability and visual restraint | Launch the app, open the menu in idle and active states, and confirm the menu reads as keep-awake → wake → management with only native separators and no extra explanatory rows |
| WOL window hierarchy feels like a refined native tool window | UX-04 | Spacing, typographic hierarchy, and prominence are only partially automatable | Launch the WOL window, verify the single-column structure, restrained section spacing, one clear primary action, and that the status block only appears when meaningful |
| Device-library window remains list-first and visually restrained after polish, including form mode | UX-04 | Visual hierarchy, empty-state feel, list-first emphasis, and form-secondary layout still need human judgment beyond structural smoke | Launch the device manager with and without devices, verify the top action row, empty state, device-row hierarchy, and enter add/edit form mode to confirm labels stay above controls, validation stays directly under the affected fields, and `device-library-form-actions` remains the clear action row |

---

## Validation Sign-Off

- [ ] All tasks have `<automated>` verify or equivalent blocking automation
- [ ] Sampling continuity: no 3 consecutive tasks without automated verify
- [x] Wave references match the actual 05-01 / 05-02 / 05-03 layout
- [ ] No watch-mode flags
- [x] Feedback latency < 90s
- [x] `nyquist_compliant: true` set in frontmatter

**Approval:** pending
