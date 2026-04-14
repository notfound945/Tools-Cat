---
phase: 09
slug: mac-os-swiss-knife-tools-cat
status: draft
nyquist_compliant: true
wave_0_complete: true
created: 2026-04-13
---

# Phase 09 — Validation Contract

> Canonical validation contract for the Phase 9 hard cut from `Mac OS Swiss Knife` to `Tools Cat`.

---

## Test Infrastructure

| Property | Value |
|----------|-------|
| **Framework** | XCTest / XCUITest via Xcode 26.2 |
| **Config file** | `Tools Cat.xcodeproj/project.pbxproj` |
| **Quick run command** | `xcodebuild test -project "Tools Cat.xcodeproj" -scheme "Tools Cat" -destination 'platform=macOS' -only-testing:'Tools CatTests/SavedDeviceRepositoryTests' -only-testing:'Tools CatTests/StatusBarControllerMenuPolishTests'` |
| **Full suite command** | `bash scripts/run_menu_bar_verification_slice.sh && xcodebuild test -project "Tools Cat.xcodeproj" -scheme "Tools Cat" -destination 'platform=macOS'` |
| **Estimated runtime** | ~180 seconds |

---

## Sampling Rate

- **After every task commit:** Run `xcodebuild test -project "Tools Cat.xcodeproj" -scheme "Tools Cat" -destination 'platform=macOS' -only-testing:'Tools CatTests/SavedDeviceRepositoryTests' -only-testing:'Tools CatTests/StatusBarControllerMenuPolishTests'`
- **After Wave 1:** Run `xcodebuild -list -project "Tools Cat.xcodeproj" && xcodebuild -showBuildSettings -project "Tools Cat.xcodeproj" -scheme "Tools Cat" | rg "PRODUCT_MODULE_NAME = Tools_Cat|PRODUCT_BUNDLE_IDENTIFIER = cn.notfound945.Tools-Cat|CODE_SIGN_ENTITLEMENTS = Tools Cat/Tools_Cat.entitlements|TEST_HOST = \\$\\(BUILT_PRODUCTS_DIR\\)/Tools Cat.app/\\$\\(BUNDLE_EXECUTABLE_FOLDER_PATH\\)/Tools Cat|TEST_TARGET_NAME = Tools Cat"`
- **After Wave 2:** Run `bash scripts/run_menu_bar_verification_slice.sh && SCHEME="Tools Cat" sh ./release.sh`
- **Before `$gsd-verify-work`:** Full suite must be green under the renamed project and scheme
- **Max feedback latency:** 180 seconds

---

## Per-Task Verification Map

| Task ID | Plan | Wave | Requirement | Test Type | Automated Command | File Exists | Status |
|---------|------|------|-------------|-----------|-------------------|-------------|--------|
| 09-01-01 | 01 | 1 | RENAME-01, RENAME-04 | build-settings + unit | `xcodebuild -list -project "Tools Cat.xcodeproj" && xcodebuild test -project "Tools Cat.xcodeproj" -scheme "Tools Cat" -destination 'platform=macOS' -only-testing:'Tools CatTests/SavedDeviceRepositoryTests' -only-testing:'Tools CatTests/StatusBarControllerMenuPolishTests'` | ✅ | ⬜ pending |
| 09-02-01 | 02 | 2 | RENAME-02, RENAME-03 | regression slice + packaging | `bash scripts/run_menu_bar_verification_slice.sh && SCHEME="Tools Cat" sh ./release.sh` | ✅ | ⬜ pending |
| 09-03-01 | 03 | 3 | RENAME-03 | grep audit | `rg -n "Tools Cat|Tools_Cat|Tools-Cat" README.md CLAUDE.md .planning/PROJECT.md .planning/ROADMAP.md .planning/codebase && rg -n "Mac OS Swiss Knife|Mac_OS_Swiss_Knife|Mac-OS-Swiss-Knife|Swiss Knife" README.md CLAUDE.md .planning/PROJECT.md .planning/ROADMAP.md .planning/codebase | rg -v "Phase 9|legacy defaults domain|defaults delete cn.notfound945.Mac-OS-Swiss-Knife|historical|archive"` | ✅ | ⬜ pending |

*Status: ⬜ pending · ✅ green · ❌ red · ⚠️ flaky*

---

## Wave 0 Requirements

- [x] Existing XCTest and XCUITest targets already cover rename-sensitive unit and UI smoke paths.
- [x] `Tools CatTests/SavedDeviceRepositoryTests.swift` will absorb the legacy-defaults migration coverage; no new test harness is required.
- [x] `scripts/run_menu_bar_verification_slice.sh` remains the canonical regression wrapper after its project/scheme and test-target names are updated.

---

## Manual-Only Verifications

| Behavior | Requirement | Why Manual | Test Instructions |
|----------|-------------|------------|-------------------|
| First launch after the bundle-ID cutover preserves saved devices and wake metadata from the legacy defaults domain | RENAME-04 | Unit tests can prove the migration logic, but only a live run proves the real old domain on disk migrates into `cn.notfound945.Tools-Cat` | Seed the old domain with `defaults write cn.notfound945.Mac-OS-Swiss-Knife saved_devices -data '<seeded-hex-or-base64>'` and `defaults write cn.notfound945.Mac-OS-Swiss-Knife saved_device_wake_metadata -data '<seeded-hex-or-base64>'`, launch `Tools Cat.app` once, then confirm `defaults read cn.notfound945.Tools-Cat` contains both keys and the legacy domain still exists for manual cleanup |
| Old local residue cleanup stays manual and does not silently delete a maintainer's local artifacts | RENAME-03 | Cleanup is intentionally non-destructive in this phase | After migration succeeds, optionally delete the old defaults domain with `defaults delete cn.notfound945.Mac-OS-Swiss-Knife` and manually remove stale `Mac OS Swiss Knife.app` / `Mac-OS-Swiss-Knife.dmg` artifacts if they still exist locally |

---

## Validation Sign-Off

- [x] All tasks have `<automated>` verify or explicit manual coverage
- [x] Sampling continuity: no 3 consecutive tasks without automated verify
- [x] Wave 0 covers all missing validation references
- [x] No watch-mode flags
- [x] Feedback latency < 180s for the quick path
- [x] `nyquist_compliant: true` set in frontmatter

**Approval:** pending
