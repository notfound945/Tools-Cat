# Codebase Structure

**Analysis Date:** 2026-04-11

## Directory Layout

```text
Tools Cat/
├── .planning/codebase/          # Generated analysis documents for planning workflows
├── Tools Cat/          # Main macOS app target source, assets, and entitlements
│   └── Assets.xcassets/         # App icon and accent color asset catalog
├── Tools Cat.xcodeproj/ # Xcode project metadata and workspace definition
├── Tools CatTests/     # Unit test target source
├── Tools CatUITests/   # UI test target source
├── build/                       # Gitignored DerivedData/build output from release builds
├── build-test/                  # Local ad-hoc build/test output currently present in the worktree
├── dist/                        # Gitignored DMG output directory
├── .gitignore                   # Ignore rules for Xcode and packaging artifacts
├── build_dmg.sh                 # DMG packaging helper
├── README.md                    # Project usage and release notes
└── release.sh                   # Release build wrapper around xcodebuild + DMG packaging
```

## Directory Purposes

**.planning/codebase/**
- Purpose: Holds generated repository-analysis documents consumed by other GSD planning commands.
- Contains: `*.md` architecture/structure/stack/conventions documents.
- Key files: `.planning/codebase/ARCHITECTURE.md`, `.planning/codebase/STRUCTURE.md`
- Subdirectories: None in the current repo.

**Tools Cat/**
- Purpose: Main application target directory.
- Contains: Flat Swift source files, `Tools_Cat.entitlements`, and `Assets.xcassets`.
- Key files: `Tools Cat/Tools_CatApp.swift`, `Tools Cat/AppDelegate.swift`, `Tools Cat/StatusBarController.swift`, `Tools Cat/PowerAssertionManager.swift`, `Tools Cat/WOLWindow.swift`, `Tools Cat/WOLView.swift`, `Tools Cat/WOLSender.swift`
- Subdirectories: `Tools Cat/Assets.xcassets/` only; there are no feature folders such as `Views/`, `Services/`, or `Models/`.

**Tools Cat/Assets.xcassets/**
- Purpose: Asset catalog for app icon and accent color resources.
- Contains: `Contents.json`, `AccentColor.colorset/`, `AppIcon.appiconset/`, and icon PNGs tracked in git.
- Key files: `Tools Cat/Assets.xcassets/Contents.json`, `Tools Cat/Assets.xcassets/AppIcon.appiconset/Contents.json`
- Subdirectories: Apple asset sub-bundles (`*.colorset`, `*.appiconset`).

**Tools Cat.xcodeproj/**
- Purpose: Defines the Xcode project, targets, build settings, and workspace metadata.
- Contains: `project.pbxproj` and the generated workspace file `project.xcworkspace/contents.xcworkspacedata`.
- Key files: `Tools Cat.xcodeproj/project.pbxproj`
- Subdirectories: `project.xcworkspace/` is committed; `xcuserdata/` exists locally and is ignored by `.gitignore`.

**Tools CatTests/**
- Purpose: Unit test target attached to the app target.
- Contains: A single XCTest source file.
- Key files: `Tools CatTests/Tools_CatTests.swift`
- Subdirectories: None.

**Tools CatUITests/**
- Purpose: UI test target for app launch and UI interaction coverage.
- Contains: XCTest UI automation files.
- Key files: `Tools CatUITests/Tools_CatUITests.swift`, `Tools CatUITests/Tools_CatUITestsLaunchTests.swift`
- Subdirectories: None.

**build/**
- Purpose: DerivedData-style local build output used by `release.sh` and direct `xcodebuild` invocations.
- Contains: Build products, logs, module caches, intermediates, and `.app` artifacts.
- Key files: Not source-controlled; contents are generated under `build/Build/`, `build/Logs/`, and related cache directories.
- Subdirectories: Deep Xcode-generated output tree.

**build-test/**
- Purpose: Additional local build/test output directory currently present in the worktree.
- Contains: Module caches, SDK stat caches, and generated plist/build support files.
- Key files: Not source-controlled; contents such as `build-test/info.plist` are generated artifacts.
- Subdirectories: Xcode-generated cache directories like `ModuleCache.noindex/`.

**dist/**
- Purpose: Output directory for packaged DMG files produced by `build_dmg.sh` or `release.sh`.
- Contains: Built `.dmg` artifacts when packaging has been run.
- Key files: Not source-controlled; output names are driven by `build_dmg.sh` arguments or `DMG_NAME`.
- Subdirectories: None in the current worktree snapshot.

## Key File Locations

**Entry Points:**
- `Tools Cat/Tools_CatApp.swift`: SwiftUI `@main` entry for the app target.
- `Tools Cat/AppDelegate.swift`: Runtime lifecycle coordinator that creates the menu bar controller and WOL window.
- `release.sh`: Shell entry point for release builds and DMG packaging.
- `build_dmg.sh`: Shell entry point for packaging an existing `.app` bundle into a DMG.

**Configuration:**
- `Tools Cat.xcodeproj/project.pbxproj`: Target definitions, build settings, menu bar `LSUIElement` flag, entitlements path, deployment target, and bundle identifiers.
- `Tools Cat/Tools_Cat.entitlements`: App Sandbox and outbound network entitlement configuration.
- `.gitignore`: Ignore rules for `build/`, `dist/`, `xcuserdata/`, and other local Xcode artifacts.

**Core Logic:**
- `Tools Cat/StatusBarController.swift`: Menu bar item creation, menu wiring, and keep-awake/WOL action routing.
- `Tools Cat/PowerAssertionManager.swift`: IOKit display-sleep assertion management.
- `Tools Cat/WOLWindow.swift`: AppKit window controller hosting the WOL form and publishing lifecycle notifications.
- `Tools Cat/WOLView.swift`: SwiftUI WOL form, local state, validation, and async send trigger.
- `Tools Cat/WOLSender.swift`: Socket creation, interface enumeration, broadcast address selection, and magic-packet transmission.
- `Tools Cat/ContentView.swift`: Placeholder SwiftUI view file currently not wired into the runtime flow.

**Testing:**
- `Tools CatTests/Tools_CatTests.swift`: Unit test target scaffold.
- `Tools CatUITests/Tools_CatUITests.swift`: UI test scaffold for launching the app.
- `Tools CatUITests/Tools_CatUITestsLaunchTests.swift`: Launch screenshot/performance test scaffold.

**Documentation:**
- `README.md`: User-facing feature overview, run/build steps, packaging notes, and sandbox explanation.
- `.planning/codebase/ARCHITECTURE.md`: Repository architecture map for planning workflows.
- `.planning/codebase/STRUCTURE.md`: Repository structure map for planning workflows.

## Naming Conventions

**Files:**
- `PascalCase.swift` for most runtime source files named after their primary type, for example `Tools Cat/StatusBarController.swift` and `Tools Cat/WOLWindow.swift`.
- Underscore-separated filenames derived from the product/target name for app entry and entitlement/test scaffolds, for example `Tools Cat/Tools_CatApp.swift` and `Tools Cat/Tools_Cat.entitlements`.
- Root helper scripts use lowercase shell filenames with underscores, for example `release.sh` and `build_dmg.sh`.

**Directories:**
- Xcode target directories mirror target names exactly, including spaces: `Tools Cat/`, `Tools CatTests/`, `Tools CatUITests/`.
- Asset catalog subdirectories follow Apple bundle suffix conventions such as `AppIcon.appiconset/` and `AccentColor.colorset/`.

**Special Patterns:**
- Test files follow Xcode default XCTest naming with `Tests`/`UITests` suffixes, for example `Tools CatUITests/Tools_CatUITests.swift`.
- Asset catalogs always include `Contents.json` metadata files, for example `Tools Cat/Assets.xcassets/Contents.json`.
- The app target uses a flat file layout; new source files are added directly under `Tools Cat/` rather than under nested feature folders.

## Where to Add New Code

**New Feature:**
- Primary code: Add new runtime types under `Tools Cat/`; keep them flat beside related controllers/views/services because the target does not currently use feature subdirectories.
- Tests: Add unit coverage in `Tools CatTests/` and UI coverage in `Tools CatUITests/` when the feature changes menu or window behavior.
- Config if needed: Update `Tools Cat.xcodeproj/project.pbxproj` for new build settings/capabilities and `Tools Cat/Tools_Cat.entitlements` if the feature needs new sandbox permissions.

**New Component/Module:**
- Implementation: Place Swift types in `Tools Cat/` and name the file after the primary type or responsibility.
- Types: Keep small supporting enums/structs next to the owning feature file, as `InputMode` and `DeviceOption` currently live inside `Tools Cat/WOLView.swift`.
- Tests: Mirror the target split by putting pure logic tests in `Tools CatTests/` and app-driven interaction tests in `Tools CatUITests/`.

**New Menu Action:**
- Definition: Extend the menu setup and selector wiring in `Tools Cat/StatusBarController.swift`.
- Handler: Put AppKit window orchestration in `Tools Cat/AppDelegate.swift` or a dedicated controller file in `Tools Cat/`, and place view code in a sibling SwiftUI file if the action opens UI.
- Tests: Add UI assertions in `Tools CatUITests/` if the action changes visible menu or window behavior.

**Utilities:**
- Shared helpers: Add reusable non-UI helpers under `Tools Cat/`; there is no separate `Utilities/` directory today.
- Type definitions: Keep lightweight enums/structs adjacent to the feature they support unless a broader cross-feature type emerges.

## Special Directories

**Tools Cat.xcodeproj/project.xcworkspace/**
- Purpose: Workspace metadata created by Xcode for the project.
- Source: Xcode project generation and maintenance.
- Committed: Yes for `Tools Cat.xcodeproj/project.xcworkspace/contents.xcworkspacedata`; no for user-specific `xcuserdata/`.

**build/**
- Purpose: Release/default build output and logs.
- Source: `xcodebuild` via `release.sh` or manual command-line builds.
- Committed: No.

**build-test/**
- Purpose: Alternate local build/test output currently present in the worktree.
- Source: Local Xcode or `xcodebuild` test/build execution with a custom derived data path.
- Committed: No.

**dist/**
- Purpose: Packaged DMG output.
- Source: `build_dmg.sh` and `release.sh`.
- Committed: No.

**.planning/codebase/**
- Purpose: Planning artifacts generated from repository analysis.
- Source: GSD mapper workflows such as this one.
- Committed: No in the current git index snapshot.

---

*Structure analysis: 2026-04-11*
*Update when directory structure changes*
