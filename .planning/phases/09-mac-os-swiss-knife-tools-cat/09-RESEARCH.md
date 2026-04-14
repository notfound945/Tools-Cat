# Phase 9: mac-os-swiss-knife-tools-cat - Research

**Researched:** 2026-04-13
**Domain:** macOS/Xcode product rename for a sandboxed menu bar app
**Confidence:** HIGH

<user_constraints>
## User Constraints (from CONTEXT.md)

### Locked Decisions
### Rename depth
- **D-01:** Phase 9 should be a full rename, not a docs-only or UI-only pass.
- **D-02:** The rename should cover project-facing and build-facing identifiers as well as runtime branding: Xcode target names, scheme names, generated artifact names, module-derived names, test target names, packaging script defaults, and current planning/docs.

### Identifier migration
- **D-03:** Bundle identifiers should migrate with the product rename instead of preserving the old `Mac-OS-Swiss-Knife` family.
- **D-04:** Test bundle identifiers and any app/test host references should move in the same pass so the repo does not keep a mixed old/new identity.

### Runtime naming
- **D-05:** Chinese UI copy should still use the English brand `Tools Cat` where a product name is shown; do not introduce a separate Chinese brand name.
- **D-06:** Existing repo convention still applies outside branding: user-facing functional copy remains Chinese, while type/API names stay English unless a generated target/module name must change because the Xcode target name changed.

### Migration strategy
- **D-07:** This should be a hard cut to `Tools Cat`; do not keep a dual-brand transition period.
- **D-08:** Downstream work may keep narrowly historical references only where archival planning artifacts must preserve past truth, but current active docs and shipped-product surfaces should no longer present `Mac OS Swiss Knife` as the live name.

### Claude's Discretion
- Exact sequencing for renaming directories, project references, generated test filenames, and script defaults, as long as the final repo builds and tests under the new name.
- Whether legacy historical names need brief archival notes inside milestone/phase history files, as long as current-facing docs and active build paths hard-switch to `Tools Cat`.
- Exact normalization of underscore/hyphen variants created by Xcode after target renames, as long as the new naming remains internally consistent.

### Deferred Ideas (OUT OF SCOPE)
- Introducing a separate Chinese brand name for `Tools Cat`.
- Keeping legacy app IDs or docs as a compatibility alias beyond narrow historical/archive notes.
- Any distribution work such as signing/notarization cleanup that might be convenient to do during the rename but is not required to complete it.
</user_constraints>

## Summary

This phase is an identity migration, not a string replace. Local inspection verified that the old name still drives the Xcode identity stack end to end: `xcodebuild -list` exposes the `Mac OS Swiss Knife` scheme and three old-name targets, `xcodebuild -showBuildSettings` resolves `PRODUCT_MODULE_NAME = Mac_OS_Swiss_Knife`, and `project.pbxproj` still hardcodes the old bundle IDs, `TEST_HOST`, `TEST_TARGET_NAME`, entitlements path, app bundle name, and test bundle names. The repo is also using `PBXFileSystemSynchronizedRootGroup`, which reduces per-file pbxproj churn, but the synchronized root-group paths and target names still need a coordinated rename.

The highest-risk part is the bundle-identifier cutover. This machine already has live persisted state under `cn.notfound945.Mac-OS-Swiss-Knife`: `saved_devices`, `saved_device_wake_metadata`, a module-derived window-frame key, an installed `/Applications/Mac OS Swiss Knife.app`, old app containers, old Application Scripts folders, and old DMG/build outputs. Because D-03 and D-04 require moving the bundle ID family, the plan must explicitly choose between a one-time data migration and an accepted reset. Without that decision, saved devices will silently disappear after the rename.

The safest execution order is: capture a clean pre-rename baseline, decide the persisted-data policy, rename the Xcode identity core in one wave, immediately re-green build/test/script verification under the new name, then update active docs and generated planning artifacts while leaving archival history and the current GSD phase path alone unless a separate workflow rename is explicitly desired.

**Primary recommendation:** Treat Phase 9 as one atomic Xcode identity cutover plus one explicit runtime-state decision, then use the existing verification slice and build-setting checks as hard checkpoints before touching broader docs/archive cleanup.

## Project Constraints (from CLAUDE.md)

- Stay inside the native macOS AppKit/SwiftUI stack.
- Keep the product focused on a personal daily-use utility; do not add unrelated scope.
- Preserve the existing language split: user-facing functional copy remains Chinese, while identifiers and API/type names remain English unless generated target/module names must change.
- Keep the flat target-directory layout and one-top-level-type-per-file pattern.
- Keep Xcode-style formatting; no formatter/linter config exists in-repo.
- Keep generated Info.plist values build-setting-driven; the repo does not use a committed app Info.plist file.
- Use the existing XCTest/XCUITest infrastructure in the Xcode project; there is no `.xctestplan`.
- Respect GSD-managed docs and markers in `CLAUDE.md`; do not remove `<!-- GSD:* -->` sections or the managed profile block.
- Generated planning/codebase docs should stay coherent with their sources; avoid hand-editing them into drift if regeneration is the safer path.

## Standard Stack

### Core
| Library / Tool | Version | Purpose | Why Standard |
|---------|---------|---------|--------------|
| Xcode toolchain | 26.2 (`xcodebuild` build 17C52, verified locally 2026-04-13) | Owns target names, schemes, bundle IDs, module names, test wiring, and generated Info.plist values | The rename is primarily an Xcode identity migration |
| Swift 5.0 target settings | `SWIFT_VERSION = 5.0` in `project.pbxproj` | App, unit tests, and UI tests compile from the same module naming rules | Generated module names and `@testable import` fallout come directly from the target rename |
| XCTest / XCUITest | bundled with Xcode 26.2 | Regression coverage for app-facing copy, imports, and direct-launch utility windows | Existing automation already proves the critical seams that the rename can break |

### Supporting
| Library / Tool | Version | Purpose | When to Use |
|---------|---------|---------|-------------|
| `xcodebuild` | 26.2 CLI | List schemes, inspect build settings, build, and run tests | Use before and after the rename to prove identity cutover |
| `defaults` / `plutil` | macOS system tools | Inspect persisted defaults domains and plist-backed values | Use when deciding and verifying bundle-ID migration behavior |
| `hdiutil` | macOS system tool | Produce DMGs in `build_dmg.sh` | Use to verify renamed artifact names and mounted volume names |
| `/usr/bin/ditto` | macOS system tool | Stage the app bundle for DMG packaging | Keep using the existing packaging flow |
| `rg` | 15.1.0 | Audit rename blast radius and verify old-name cleanup | Use for active-doc and source grep checkpoints |

### Alternatives Considered
| Instead of | Could Use | Tradeoff |
|------------|-----------|----------|
| Full identity rename | Rename only visible strings | Violates D-01 through D-04 and leaves mixed old/new build identity |
| Xcode build-setting rename | Add a committed `Info.plist` just for the rename | Unnecessary drift; current metadata is build-setting-driven |
| Existing verification slice | Ad hoc one-off `xcodebuild` commands | Harder to compare pre/post rename and easier to miss script fallout |
| Generated-doc regeneration/update | Blind global replace across all planning files | Risks corrupting archival truth and GSD-managed content |

**Installation:** Not applicable beyond the existing Apple toolchain already present on this machine.

**Version verification:**
```bash
xcodebuild -version
node --version
rg --version
```

## Architecture Patterns

### Recommended Project Structure
```text
Tools Cat/
├── Tools_CatApp.swift          # Generated app entry renamed with the target/module
├── Tools_Cat.entitlements      # App Sandbox entitlements file after path rename
└── ...                         # Existing flat app target files
Tools CatTests/
├── Tools_CatTests.swift        # Generated unit-test scaffold renamed with the target/module
└── ...                         # Existing unit tests
Tools CatUITests/
├── Tools_CatUITests.swift      # Generated UI-test scaffold renamed with the target/module
└── Tools_CatUITestsLaunchTests.swift
Tools Cat.xcodeproj/
scripts/
.planning/
```

### Pattern 1: Rename The Xcode Identity Stack Atomically
**What:** Rename the app target, test targets, synchronized root-group paths, product refs, bundle IDs, entitlements path, `TEST_HOST`, `TEST_TARGET_NAME`, generated filenames, generated type names, and module imports in the same implementation wave.
**When to use:** First implementation wave, immediately after baseline verification and the persisted-data decision.
**Why:** `PRODUCT_NAME = $(TARGET_NAME)` and generated module naming mean partial renames create broken builds fast.
**Example:**
```bash
xcodebuild -showBuildSettings \
  -project "Tools Cat.xcodeproj" \
  -scheme "Tools Cat" \
  | rg 'PRODUCT_MODULE_NAME|PRODUCT_BUNDLE_IDENTIFIER|CODE_SIGN_ENTITLEMENTS|TEST_HOST|TEST_TARGET_NAME'
```

### Pattern 2: Decide Bundle-ID Migration Before Renaming Tests And Docs
**What:** Choose whether `saved_devices` and `saved_device_wake_metadata` move from the old defaults domain into the new app identity, or whether reset is explicitly accepted.
**When to use:** Before changing `PRODUCT_BUNDLE_IDENTIFIER`.
**Why:** A bundle-ID cutover changes the sandbox identity and defaults domain; the old state does not appear automatically in the new app.
**Example:**
```swift
// Source: local repo pattern in SavedDeviceRepository.swift
let oldDefaults = UserDefaults(suiteName: "cn.notfound945.Mac-OS-Swiss-Knife")
let newDefaults = UserDefaults.standard

if let devices = oldDefaults?.data(forKey: "saved_devices") {
    newDefaults.set(devices, forKey: "saved_devices")
}

if let metadata = oldDefaults?.data(forKey: "saved_device_wake_metadata") {
    newDefaults.set(metadata, forKey: "saved_device_wake_metadata")
}
```

### Pattern 3: Separate Active-Doc Renames From Historical And Workflow Paths
**What:** Hard-switch current doc content and generated codebase docs to `Tools Cat`, but preserve archival history and keep the active phase path stable unless there is an explicit workflow-path migration plan.
**When to use:** After build/test/package verification is green under the new name.
**Why:** `.planning/phases/09-mac-os-swiss-knife-tools-cat/` is the current GSD address used by tooling, and `CLAUDE.md` contains managed sections derived from other docs.
**Example:**
```bash
rg -n --hidden -S "Mac OS Swiss Knife|Swiss Knife|Mac_OS_Swiss_Knife|Mac-OS-Swiss-Knife" \
  README.md CLAUDE.md .planning/PROJECT.md .planning/ROADMAP.md .planning/STATE.md \
  .planning/REQUIREMENTS.md .planning/codebase release.sh build_dmg.sh scripts \
  "Tools Cat.xcodeproj" "Tools Cat" "Tools CatTests" "Tools CatUITests"
```

### Safest Execution Order
1. Record a pre-rename baseline:
   - `xcodebuild -list -project "Mac OS Swiss Knife.xcodeproj"`
   - `bash scripts/run_menu_bar_verification_slice.sh`
   - `defaults read cn.notfound945.Mac-OS-Swiss-Knife`
2. Decide and document the persisted-data policy:
   - Migrate `saved_devices` and `saved_device_wake_metadata`, or explicitly accept reset.
   - Do not spend time migrating transient AppKit keys unless the user cares about window placement.
3. Rename the Xcode identity core in one wave:
   - Target names, test target names, project display name, synchronized root-group paths, generated filenames, imports, entitlements path, product refs, bundle IDs, `TEST_HOST`, `TEST_TARGET_NAME`.
4. Immediately re-green the toolchain under the new name:
   - `xcodebuild -list`
   - `xcodebuild -showBuildSettings`
   - `bash scripts/run_menu_bar_verification_slice.sh`
5. Update packaging defaults and active docs:
   - `release.sh`, `build_dmg.sh`, `README.md`, `CLAUDE.md`, `.planning/PROJECT.md`, `.planning/ROADMAP.md`, `.planning/STATE.md`, `.planning/REQUIREMENTS.md`, `.planning/codebase/*`, active Phase 9 docs.
6. Finish with rename-audit and residue guidance:
   - Active-doc grep clean
   - `dist/Tools-Cat.dmg` exists
   - old local app/container/artifact cleanup documented

### Anti-Patterns to Avoid
- **Blind repo-wide replace:** It will rewrite archival milestone truth and workflow addresses that should remain historical or stable.
- **Bundle-ID cutover without a state decision:** Saved devices disappear and the phase looks "done" only because verification missed persisted data.
- **Partial target rename:** Leaving old `TEST_HOST`, `TEST_TARGET_NAME`, or `@testable import` references breaks tests even if the app builds.
- **Manual shared-scheme editing as a first move:** No committed shared `.xcscheme` exists; the current scheme is project-derived, so target/project identity is the real source of truth.
- **Hand-editing generated GSD blocks recklessly:** `CLAUDE.md` and `.planning/codebase/*` have generation semantics that should stay intact.

## Don't Hand-Roll

| Problem | Don't Build | Use Instead | Why |
|---------|-------------|-------------|-----|
| App metadata rename | A manual `Info.plist` just to control names | Existing Xcode build settings (`PRODUCT_NAME`, bundle ID, generated Info.plist keys) | Current project already derives metadata from build settings |
| Source registration after file renames | Manual per-file PBX source refs | Existing `PBXFileSystemSynchronizedRootGroup` roots plus renamed root paths | This project auto-syncs files inside the target roots; fewer pbxproj edits are needed |
| Saved-device migration | A new export/import format | The existing `UserDefaultsSavedDeviceRepository` keys and Codable payloads | The current repository already owns the persisted schema |
| Verification | One-off local clicks and scattered test commands | The existing verification slice script plus `xcodebuild -showBuildSettings` checks | Reusable, comparable, and already passing pre-rename |
| Planning-doc cleanup | Ad hoc edits that diverge from generators | Update source docs or regenerate codebase docs after the rename | Safer than maintaining stale generated references |

**Key insight:** The safest plan leans on the existing Xcode metadata model, existing persistence seam, and existing verification wrapper. Custom side channels add more rename surface, not less.

## Runtime State Inventory

| Category | Items Found | Action Required |
|----------|-------------|------------------|
| Stored data | `defaults read cn.notfound945.Mac-OS-Swiss-Knife` currently contains `saved_devices`, `saved_device_wake_metadata`, `NSWindow Frame Mac_OS_Swiss_Knife.ContentView-1-AppWindow-1`, and `NSStatusItem Preferred Position Item-0` | Code edit plus decision: migrate `saved_devices` and `saved_device_wake_metadata` if state must survive; window-frame/status-item keys can usually reset |
| Live service config | None detected in-repo. No external dashboards, cloud configs, exported workflows, or service names were found for this app | None |
| OS-registered state | `/Applications/Mac OS Swiss Knife.app`; `~/Library/Application Scripts/cn.notfound945.Mac-OS-Swiss-Knife`; `~/Library/Application Scripts/cn.notfound945.Mac-OS-Swiss-KnifeUITests.xctrunner`; LaunchServices registration is refreshed during builds | Manual cleanup guidance after cutover; no code edit required unless uninstall automation is explicitly added |
| Secrets/env vars | No old-brand env var names or secret keys detected in-repo. Script overrides are generic: `SCHEME`, `CONFIG`, `DERIVED`, `DMG_NAME`, `VOL_NAME`, `OUT_DIR` | None |
| Build artifacts | `dist/Mac-OS-Swiss-Knife.dmg`; old-name app/test build products under Xcode build output; new verification run recreated old-name DerivedData at `~/Library/Developer/Xcode/DerivedData/Mac_OS_Swiss_Knife-*` | Manual cleanup or scripted cleanup note; regenerate fresh artifacts under the new name |

**Migration split to plan explicitly:**
- **Data migration:** If preservation is required, move only `saved_devices` and `saved_device_wake_metadata`.
- **Code edit:** Rename the defaults domain by changing the app/test bundle IDs.
- **Non-goal by default:** Migrating the old AppKit window-frame key. It is module-derived and not product-critical.

## Rename Blast Radius

### Xcode Identity
- Project display name in `project.pbxproj`
- App target name, unit-test target name, UI-test target name
- Product refs: `.app`, `.xctest`, UI-test runner paths
- `PRODUCT_BUNDLE_IDENTIFIER` for app/tests
- `CODE_SIGN_ENTITLEMENTS`
- `TEST_HOST`
- `TEST_TARGET_NAME`
- `PRODUCT_MODULE_NAME` and generated Swift header/module naming
- DerivedData/product path prefixes and executable names

### Source And Tests
- App entry filename/type: `Mac_OS_Swiss_KnifeApp.swift`, `Mac_OS_Swiss_KnifeApp`
- Entitlements filename path: `Mac_OS_Swiss_Knife.entitlements`
- Unit/UI-test scaffold filenames and class names
- All `@testable import Mac_OS_Swiss_Knife` usages
- UI-test suite naming constant: `Mac-OS-Swiss-Knife-UITests-*`
- Runtime brand string: `退出 Swiss Knife`

### Scripts And Packaging
- `release.sh` default scheme, DMG name, and volume name
- `build_dmg.sh` usage examples and default DMG/volume names
- `scripts/run_menu_bar_verification_slice.sh` project/scheme/test selectors
- `README.md` build, run, and DMG examples

### Planning And Docs
- `CLAUDE.md`
- `.planning/PROJECT.md`
- `.planning/ROADMAP.md`
- `.planning/STATE.md`
- `.planning/REQUIREMENTS.md`
- `.planning/codebase/*`
- Active Phase 9 docs

### Local Residue
- Installed old app bundle
- Old sandbox containers and Application Scripts folders
- Old DerivedData and DMG outputs

## Common Pitfalls

### Pitfall 1: Bundle-ID Cutover Looks Fine But User Data Vanishes
**What goes wrong:** The renamed app launches and tests pass, but saved devices/history are missing.
**Why it happens:** The new bundle ID creates a new defaults domain and sandbox identity.
**How to avoid:** Decide the migration/reset policy before editing bundle IDs; verify it after the first renamed launch.
**Warning signs:** `defaults read cn.notfound945.Tools-Cat` is empty while the old domain still contains `saved_devices`.

### Pitfall 2: App Builds But Tests Still Point At The Old App
**What goes wrong:** Unit or UI tests fail to launch or attach after the target rename.
**Why it happens:** `TEST_HOST` and `TEST_TARGET_NAME` are explicit strings in `project.pbxproj`.
**How to avoid:** Treat them as first-wave rename items and verify with `xcodebuild -showBuildSettings`.
**Warning signs:** Build settings still print `Mac OS Swiss Knife.app` or `Mac OS Swiss Knife` after the rename.

### Pitfall 3: Module Rename Breaks Every `@testable import`
**What goes wrong:** Tests stop compiling even though most source files are unchanged.
**Why it happens:** The module name is derived from the target name and currently resolves to `Mac_OS_Swiss_Knife`.
**How to avoid:** Rename scaffold filenames/types/imports in the same wave as the target rename.
**Warning signs:** Compiler errors such as `No such module 'Mac_OS_Swiss_Knife'`.

### Pitfall 4: Entitlements Path Lags Behind The Filesystem Rename
**What goes wrong:** The app stops signing/building because Xcode still points to the old entitlements path.
**Why it happens:** `CODE_SIGN_ENTITLEMENTS` is a literal path string in `project.pbxproj`.
**How to avoid:** Rename the entitlements file and update the build setting together.
**Warning signs:** Build errors referencing `Mac OS Swiss Knife/Mac_OS_Swiss_Knife.entitlements`.

### Pitfall 5: Archive Noise Hides Real Cleanup Work
**What goes wrong:** Grep still finds hundreds of old-name hits, making it unclear what is actually still live.
**Why it happens:** Archived milestone and completed phase artifacts preserve historical truth and should not all be rewritten.
**How to avoid:** Run active-doc grep and archive grep separately.
**Warning signs:** Engineers keep reopening archive files as if they were current product blockers.

### Pitfall 6: GSD Workflow Paths Get Renamed Mid-Phase
**What goes wrong:** Planning commands lose track of the phase directory or current workflow state.
**Why it happens:** The active phase slug still contains the old name, and the current toolchain keys Phase 9 to that path today.
**How to avoid:** Rename doc content, not the active phase path, unless the workflow rename is planned explicitly.
**Warning signs:** `gsd-tools init phase-op "09-mac-os-swiss-knife-tools-cat"` stops resolving the phase.

## Code Examples

Verified patterns from local source and official Apple documentation:

### Build-Setting Verification After The Rename
```bash
xcodebuild -showBuildSettings \
  -project "Tools Cat.xcodeproj" \
  -scheme "Tools Cat" \
  | rg 'PRODUCT_MODULE_NAME|PRODUCT_BUNDLE_IDENTIFIER|CODE_SIGN_ENTITLEMENTS|TEST_HOST|TEST_TARGET_NAME'
```

### Active Rename-Audit Command
```bash
rg -n --hidden -S "Mac OS Swiss Knife|Swiss Knife|Mac_OS_Swiss_Knife|Mac-OS-Swiss-Knife" \
  README.md CLAUDE.md .planning/PROJECT.md .planning/ROADMAP.md .planning/STATE.md \
  .planning/REQUIREMENTS.md .planning/codebase release.sh build_dmg.sh scripts \
  "Tools Cat.xcodeproj" "Tools Cat" "Tools CatTests" "Tools CatUITests"
```

### Minimal Defaults Migration If Preservation Is Required
```swift
let oldDefaults = UserDefaults(suiteName: "cn.notfound945.Mac-OS-Swiss-Knife")
let newDefaults = UserDefaults.standard

["saved_devices", "saved_device_wake_metadata"].forEach { key in
    if let value = oldDefaults?.data(forKey: key) {
        newDefaults.set(value, forKey: key)
    }
}
```

## State of the Art

| Old Approach | Current Approach | When Changed | Impact |
|--------------|------------------|--------------|--------|
| Explicit per-file PBX source/file references | `PBXFileSystemSynchronizedRootGroup` target roots in this repo | Current repo state verified 2026-04-13 | Directory/root-path renames matter more than per-file PBX rewiring |
| Committed app `Info.plist` edits | Generated Info.plist values via Xcode build settings | Current repo state verified 2026-04-13 | Rename metadata should be driven from build settings, not a new plist file |
| Scattered manual test commands | Repo-owned verification slice script plus target selectors | Phase 7 introduced this, verified passing 2026-04-13 | The rename has a stable pre/post regression gate already |

**Deprecated/outdated:**
- Docs-only rename: rejected by D-01 through D-04.
- Keeping the old bundle-ID family as the live identity: rejected by D-03 and D-04.

## Open Questions

1. **Should saved devices/history survive the bundle-ID cutover?**
   - What we know: Old persisted data exists today in the old defaults domain.
   - What's unclear: Whether the phase should preserve it or explicitly reset it.
   - Recommendation: Resolve this before planning. It changes whether a migration task and tests are required.

2. **Should the active Phase 9 directory/slug itself be renamed?**
   - What we know: Current tooling resolves Phase 9 by `.planning/phases/09-mac-os-swiss-knife-tools-cat/`.
   - What's unclear: Whether the user wants workflow-path renames or only doc-content renames.
   - Recommendation: Keep the active phase path stable for this phase unless a separate GSD workflow migration is explicitly requested.

3. **Should generated planning/codebase docs be regenerated or manually edited?**
   - What we know: `.planning/codebase/*` and large portions of `CLAUDE.md` are generator-shaped and currently hardcode old paths/names.
   - What's unclear: Whether the planner should use a regeneration step after code rename or perform targeted manual edits.
   - Recommendation: Prefer regeneration or source-of-truth edits where available; avoid hand-editing generated blocks into drift.

4. **Should local cleanup of old app/container/artifact residue be automated?**
   - What we know: Old app, containers, Application Scripts directories, DMGs, and DerivedData residue exist locally.
   - What's unclear: Whether the phase should delete them or only document manual cleanup.
   - Recommendation: Keep cleanup manual unless the user explicitly wants destructive local automation.

## Environment Availability

| Dependency | Required By | Available | Version | Fallback |
|------------|------------|-----------|---------|----------|
| Xcode / `xcodebuild` | Build-setting inspection, build/test verification | ✓ | Xcode 26.2 / build 17C52 | None |
| `hdiutil` | DMG rename verification | ✓ | system tool | Skip packaging verification only if packaging is intentionally deferred |
| `/usr/bin/ditto` | Existing DMG staging flow | ✓ | system tool | None |
| `node` | GSD tooling | ✓ | v22.20.0 | Manual git/doc workflow if necessary |
| `rg` | Rename audit | ✓ | 15.1.0 | `grep` / `find` |

**Missing dependencies with no fallback:**
- None.

**Missing dependencies with fallback:**
- None.

## Validation Architecture

### Test Framework
| Property | Value |
|----------|-------|
| Framework | XCTest / XCUITest via Xcode 26.2 |
| Config file | `Tools Cat.xcodeproj/project.pbxproj` after rename |
| Quick run command | `bash scripts/run_menu_bar_verification_slice.sh` |
| Full suite command | `xcodebuild test -project "Tools Cat.xcodeproj" -scheme "Tools Cat" -destination 'platform=macOS'` |

### Pre-Rename Baseline Status
- `bash scripts/run_menu_bar_verification_slice.sh` passed locally on 2026-04-13 under the old name.
- Use that exact command as the pre-rename checkpoint before changing the Xcode identity stack.

### Phase Requirements → Test Map
| Req ID | Behavior | Test Type | Automated Command | File Exists? |
|--------|----------|-----------|-------------------|-------------|
| RENAME-01 | App/test targets, scheme, module name, and scripts hard-switch to `Tools Cat` and still build/test | smoke | `bash scripts/run_menu_bar_verification_slice.sh` | ✅ existing script after rename updates |
| RENAME-02 | User-facing product-name surfaces switch from `Swiss Knife` to `Tools Cat` while functional copy remains Chinese | unit | `xcodebuild test -project "Tools Cat.xcodeproj" -scheme "Tools Cat" -destination 'platform=macOS' -only-testing:'Tools CatTests/StatusBarControllerMenuPolishTests'` | ✅ existing test to rename |
| RENAME-03 | Packaging outputs and docs switch to `Tools Cat` names | build + grep | `SCHEME="Tools Cat" sh ./release.sh` and active rename-audit `rg` command | ✅ existing scripts/docs |
| RENAME-04 | Bundle-ID cutover either preserves saved-device data or explicitly proves reset policy | manual-only or unit | `defaults read cn.notfound945.Tools-Cat` after first renamed launch, plus optional migration test | ❌ Wave 0 if migration is required |

### Concrete Verification Checkpoints
1. `xcodebuild -list -project "Tools Cat.xcodeproj"` lists only `Tools Cat`, `Tools CatTests`, and `Tools CatUITests`.
2. `xcodebuild -showBuildSettings` prints:
   - `PRODUCT_MODULE_NAME = Tools_Cat`
   - `PRODUCT_BUNDLE_IDENTIFIER = cn.notfound945.Tools-Cat`
   - `CODE_SIGN_ENTITLEMENTS = Tools Cat/Tools_Cat.entitlements`
   - `TEST_HOST = $(BUILT_PRODUCTS_DIR)/Tools Cat.app/.../Tools Cat`
   - `TEST_TARGET_NAME = Tools Cat`
3. `bash scripts/run_menu_bar_verification_slice.sh` passes under the renamed project/scheme.
4. `SCHEME="Tools Cat" sh ./release.sh` emits `dist/Tools-Cat.dmg` and packages `Tools Cat.app`.
5. Active-doc grep finds no remaining old-brand references except approved historical notes.
6. Runtime-state verification proves the chosen bundle-ID policy:
   - Migration path: saved devices/history appear in the renamed app.
   - Reset path: old state is not silently read, and docs explicitly say the rename resets local data.

### Sampling Rate
- **Per task commit:** `xcodebuild test -project "Tools Cat.xcodeproj" -scheme "Tools Cat" -destination 'platform=macOS' -only-testing:'Tools CatTests/StatusBarControllerMenuPolishTests'`
- **Per wave merge:** `bash scripts/run_menu_bar_verification_slice.sh`
- **Phase gate:** Full suite green under the renamed scheme, packaging rename verified, and runtime-state policy verified

### Wave 0 Gaps
- [ ] Decide the persisted-data policy before planning
- [ ] Add a migration test only if saved-device preservation is required
- [ ] Decide whether generated planning/codebase docs are regenerated or manually updated
- [ ] Decide whether local cleanup of old app/container/artifact residue is manual-only

## Sources

### Primary (HIGH confidence)
- Local repo inspection:
  - `Mac OS Swiss Knife.xcodeproj/project.pbxproj`
  - `Mac OS Swiss Knife/StatusBarController.swift`
  - `Mac OS Swiss Knife/Mac_OS_Swiss_KnifeApp.swift`
  - `Mac OS Swiss Knife/AppDelegate.swift`
  - `Mac OS Swiss Knife/SavedDeviceRepository.swift`
  - `Mac OS Swiss Knife/Mac_OS_Swiss_Knife.entitlements`
  - `Mac OS Swiss KnifeTests/StatusBarControllerMenuPolishTests.swift`
  - `Mac OS Swiss KnifeTests/Mac_OS_Swiss_KnifeTests.swift`
  - `Mac OS Swiss KnifeUITests/Mac_OS_Swiss_KnifeUITests.swift`
  - `Mac OS Swiss KnifeUITests/Mac_OS_Swiss_KnifeUITestsLaunchTests.swift`
  - `README.md`
  - `build_dmg.sh`
  - `release.sh`
  - `scripts/run_menu_bar_verification_slice.sh`
  - `CLAUDE.md`
  - `.planning/PROJECT.md`
  - `.planning/ROADMAP.md`
  - `.planning/STATE.md`
  - `.planning/REQUIREMENTS.md`
  - `.planning/codebase/*`
- Local toolchain/runtime inspection:
  - `xcodebuild -version`
  - `xcodebuild -list -project "Mac OS Swiss Knife.xcodeproj"`
  - `xcodebuild -showBuildSettings -project "Mac OS Swiss Knife.xcodeproj" -scheme "Mac OS Swiss Knife"`
  - `bash scripts/run_menu_bar_verification_slice.sh`
  - `defaults read cn.notfound945.Mac-OS-Swiss-Knife`
  - `find ~/Library/Containers ...`
  - `find ~/Library/Application\ Scripts ...`
  - `find /Applications ...`
  - `find ./dist ...`
  - `git status --short`
- Official Apple docs:
  - https://developer.apple.com/documentation/xcode/changing-the-bundle-identifier
  - https://developer.apple.com/documentation/xcode/managing-your-app-s-information-property-list-values
  - https://developer.apple.com/documentation/xcode/build-settings-reference

### Secondary (MEDIUM confidence)
- Apple archived sandbox guidance, used only to support the bundle-ID/container interpretation already verified locally:
  - https://developer.apple.com/library/archive/documentation/Security/Conceptual/AppSandboxDesignGuide/AppSandboxInDepth/AppSandboxInDepth.html

### Tertiary (LOW confidence)
- None.

## Metadata

**Confidence breakdown:**
- Standard stack: HIGH - verified directly from the installed Apple toolchain and repo build settings
- Architecture: HIGH - rename surface mapped from the local Xcode project, synchronized target roots, source/test code, scripts, and planning docs
- Pitfalls: MEDIUM - runtime-state and Xcode pitfalls are locally verified, but workflow-path and generated-doc handling still include planner judgment

**Research date:** 2026-04-13
**Valid until:** 2026-05-13
