# Phase 05: Native Menu Polish - Research

**Researched:** 2026-04-12
**Domain:** Native macOS menu-bar polish using AppKit `NSMenu` + SwiftUI utility windows
**Confidence:** MEDIUM

<user_constraints>
## User Constraints (from CONTEXT.md)

### Locked Decisions
### Menu grouping
- **D-01:** The root menu should use a clear three-section structure: keep-awake controls first, wake actions second, and management/quit actions last.
- **D-02:** Section separation should be expressed with native menu separators rather than extra explanatory text rows.
- **D-03:** The keep-awake section remains a direct root-menu group; the wake section continues to include recent devices plus the `所有设备` path; management actions stay at the bottom.

### Menu status density
- **D-04:** Status rows should be restrained and appear only when they carry meaningful state, such as in-progress work, a current active keep-awake session, or a recent truthful result/failure.
- **D-05:** Idle menu states should collapse unnecessary status rows to keep the root menu short and scanable.
- **D-06:** Existing truthful state semantics remain unchanged: when a status row is shown, it must still reflect real local state rather than optimistic UI copy.

### WOL window polish
- **D-07:** The WOL window should stay a compact native utility window rather than becoming a heavy panel or dashboard.
- **D-08:** The existing single-column structure should remain, but the visual hierarchy should be strengthened with clearer sectioning for mode choice, input area, status area, and action area.
- **D-09:** Polish should come from typography, spacing, grouping, and restrained supporting copy rather than adding new interaction modes or dense chrome.

### Device-management window polish
- **D-10:** The device-management window should stay list-first, with the saved-device list as the primary visual anchor.
- **D-11:** Polish should emphasize the top action area, device-row hierarchy, and empty-state presentation so the window feels like a refined native management surface rather than a development utility panel.
- **D-12:** Add/edit forms remain secondary to the list view; Phase 5 should not turn the surface into a form-first editor.

### Claude's Discretion
- Exact separator placement and spacing in the root menu, as long as the three-section structure stays obvious and compact.
- Exact show/hide rules for wake and keep-awake status rows in idle versus active states, as long as the menu becomes shorter when no meaningful status is present.
- Exact typographic, spacing, and icon treatments inside the WOL and device-management windows, as long as they remain restrained and native to macOS.
- Whether small supporting subtitles or helper copy are needed inside the windows, as long as they improve hierarchy without making the surfaces feel verbose.

### Deferred Ideas (OUT OF SCOPE)
None — discussion stayed within phase scope.
</user_constraints>

<phase_requirements>
## Phase Requirements

| ID | Description | Research Support |
|----|-------------|------------------|
| UX-01 | User sees wake actions, keep-awake state, status feedback, and management actions grouped in a compact native macOS menu structure | Fixed menu anchors, two native separators, contextual status-row visibility, and no extra menu chrome in [`StatusBarController.swift`](/Users/hailinpan/Documents/GitHub/Mac%20OS%20Swiss%20Knife/Mac%20OS%20Swiss%20Knife/StatusBarController.swift) |
| UX-04 | User experiences a visually restrained, polished interface with clear hierarchy and status cues consistent with native macOS expectations | Keep stock AppKit/SwiftUI controls, use primary/secondary button prominence, strengthen spacing/typography in [`WOLView.swift`](/Users/hailinpan/Documents/GitHub/Mac%20OS%20Swiss%20Knife/Mac%20OS%20Swiss%20Knife/WOLView.swift) and [`DeviceLibraryView.swift`](/Users/hailinpan/Documents/GitHub/Mac%20OS%20Swiss%20Knife/Mac%20OS%20Swiss%20Knife/DeviceLibraryView.swift), and preserve truthful status presentation |
</phase_requirements>

## Summary

Phase 05 should stay entirely inside the existing shell: AppKit still owns the status item, menu, and retained windows, while SwiftUI continues to render the WOL and device-library contents. Apple’s current guidance still favors stock menu grouping, separators for logical command groups, restrained button prominence, and standard controls that automatically adopt current macOS appearance. That matches the repo’s locked direction and means planning should avoid any shell rewrite, custom menu item views, custom chrome, or new interaction models.

The planning-critical code fact is that the current implementation is close, but not yet shaped for the Phase 05 contract. [`StatusBarController.swift`](/Users/hailinpan/Documents/GitHub/Mac%20OS%20Swiss%20Knife/Mac%20OS%20Swiss%20Knife/StatusBarController.swift) has only one separator today, and its wake status row is only created when the saved-device library is non-empty. That matters because the phase now requires a consistently grouped wake section with contextual status feedback. The windows already have the right ownership and high-level information architecture; the work is mostly spacing, typography, prominence, and visibility rules, not structural rewrites.

**Primary recommendation:** Plan three implementation tracks only: fixed root-menu section anchors, compact status visibility rules, and stock-control hierarchy polish for the two retained utility windows.

## Standard Stack

### Core
| Library | Version | Purpose | Why Standard |
|---------|---------|---------|--------------|
| AppKit / Cocoa | macOS 26.2 SDK via Xcode 26.2 | `NSStatusItem`, `NSMenu`, `NSMenuItem`, `NSWindow` shell ownership | Native menu-bar utilities still rely on AppKit for the most precise menu and retained-window behavior |
| SwiftUI | macOS 26.2 SDK via Xcode 26.2 | WOL and device-library content views | Stock controls, semantic colors, and system button styles fit the “small, restrained, polished” goal |
| XCTest | Xcode 26.2 | Unit coverage for menu grouping and presentation logic | Existing repo already uses unit tests to lock menu order and truthful status state |

### Supporting
| Library | Version | Purpose | When to Use |
|---------|---------|---------|-------------|
| XCUITest | Xcode 26.2 | Window/surface smoke coverage | Use for presence/order/accessibility hooks, not pixel-perfect visual assertions |
| Combine / `ObservableObject` | macOS 26.2 SDK | Propagate session changes into AppKit menu refreshes and SwiftUI views | Keep using existing session-driven refresh patterns; don’t add another UI state bus |
| SF Symbols | System-provided | Status-bar icon and empty-state symbol | Keep to existing symbol usage only; don’t add decorative iconography to menu rows |

### Alternatives Considered
| Instead of | Could Use | Tradeoff |
|------------|-----------|----------|
| AppKit `NSStatusItem` + `NSMenu` | SwiftUI `MenuBarExtra` | Valid on modern macOS, but `SHELL-01` explicitly defers shell modernization and the current repo already has AppKit window ownership/test seams |
| Stock `NSMenuItem` rows + separators | Custom menu item views / attributed rows | More chrome, more accessibility risk, and easier to drift away from native status-menu behavior |
| Existing `ScrollView` normal mode + `List` reorder mode | Always-on `List` | Simpler visually, but risks reopening the XCUITest row-queryability problem Phase 2 already solved |

**Installation:**
```bash
# No third-party packages are required for this phase.
open "Mac OS Swiss Knife.xcodeproj"
```

**Version verification:** No package registry check is needed; the stack is Apple SDK-only. Verified locally on 2026-04-12:
```bash
xcodebuild -version
swift --version
```

Verified versions:
- Xcode 26.2 (`Build version 17C52`)
- Apple Swift 6.2.3 (`swift-driver 1.127.14.1`)
- Project settings: `SWIFT_VERSION = 5.0`, `MACOSX_DEPLOYMENT_TARGET = 15.6`, `LSUIElement = 1`

## Architecture Patterns

### Recommended Project Structure
```text
Mac OS Swiss Knife/
├── StatusBarController.swift                 # Fixed root-menu anchors + dynamic wake section rebuild
├── KeepAwakePresentation.swift              # Truthful keep-awake icon, tooltip, and status-row copy
├── WOLWindow.swift                          # Retained compact AppKit shell for the WOL utility window
├── WOLView.swift                            # Single-column SwiftUI hierarchy polish only
├── DeviceLibraryWindow.swift                # Retained compact AppKit shell for device management
├── DeviceLibraryView.swift                  # List-first SwiftUI management surface
└── DeviceLibraryManagementPresentation.swift # Shared Chinese copy for headings, empty state, alerts

Mac OS Swiss KnifeTests/
├── StatusBarControllerWakeMenuTests.swift
├── StatusBarControllerKeepAwakeMenuTests.swift
└── ...Phase 05 additions for menu grouping/status collapse

Mac OS Swiss KnifeUITests/
└── Mac_OS_Swiss_KnifeUITests.swift          # Extend with window hierarchy smoke tests
```

### Pattern 1: Fixed Menu Anchors with Dynamic Wake Content
**What:** Keep the root menu’s structural rows fixed, then insert/remove only the wake-section dynamic rows between two permanent separators.
**When to use:** Any time recent devices, the `所有设备` path, or wake status visibility changes.
**Example:**
```swift
let keepAwakeBoundary = NSMenuItem.separator()
let managementBoundary = NSMenuItem.separator()

menu.addItem(keepAwakeOffItem)
menu.addItem(keepAwakeStatusItem)
menu.addItem(keepAwakeBoundary)
menu.addItem(wolItem)
menu.addItem(managementBoundary)
menu.addItem(manageDevicesItem)
menu.addItem(quitItem)
```
Source: Apple `NSMenuItem.separator()` docs plus repo pattern in [`StatusBarController.swift`](/Users/hailinpan/Documents/GitHub/Mac%20OS%20Swiss%20Knife/Mac%20OS%20Swiss%20Knife/StatusBarController.swift)

### Pattern 2: Presentation-Driven Status Visibility
**What:** Derive menu/window status visibility from existing truthful session models instead of adding view-local “display state.”
**When to use:** Keep-awake status rows, wake send feedback, and 1-2 line status blocks in the WOL window.
**Example:**
```swift
keepAwakeStatusItem.title = presentation.statusText ?? ""
keepAwakeStatusItem.isHidden = presentation.statusText == nil

switch wolSession.sendState {
case .sending:
    wakeStatusItem.title = WakeSendMessage.sending.text ?? ""
    wakeStatusItem.isHidden = false
case .idle, .success, .failure:
    wakeStatusItem.title = wolSession.lastCompletedWake?.message ?? ""
    wakeStatusItem.isHidden = wolSession.lastCompletedWake == nil
}
```
Source: repo presentation seams in [`KeepAwakePresentation.swift`](/Users/hailinpan/Documents/GitHub/Mac%20OS%20Swiss%20Knife/Mac%20OS%20Swiss%20Knife/KeepAwakePresentation.swift) and [`StatusBarController.swift`](/Users/hailinpan/Documents/GitHub/Mac%20OS%20Swiss%20Knife/Mac%20OS%20Swiss%20Knife/StatusBarController.swift)

### Pattern 3: Stock-Control Hierarchy, Not Custom Chrome
**What:** Use native heading/body text, bordered versus prominent buttons, semantic colors, and spacing to create hierarchy.
**When to use:** WOL title block, mode selector, action row, device-library top action row, empty state, and row metadata hierarchy.
**Example:**
```swift
HStack(spacing: 16) {
    Spacer()
    Button("取消") { close() }
        .buttonStyle(.bordered)

    Button("发送唤醒包") { session.sendCurrentSelection() }
        .buttonStyle(.borderedProminent)
        .disabled(session.isSending || !session.canSend)
}
```
Source: Apple Buttons HIG plus repo usage in [`WOLView.swift`](/Users/hailinpan/Documents/GitHub/Mac%20OS%20Swiss%20Knife/Mac%20OS%20Swiss%20Knife/WOLView.swift)

### Anti-Patterns to Avoid
- **Menu text headers:** Apple guidance favors grouping commands with separators; text headers add rows and hurt compactness.
- **Custom menu item views for polish:** This phase wants native, not decorative; custom views complicate accessibility and visual consistency.
- **Shell rewrite during polish:** `MenuBarExtra` migration is deferred; Phase 05 should not spend time on scene/lifecycle churn.
- **Form-first device management:** The list is the primary anchor; don’t let add/edit controls dominate the management window.

## Don't Hand-Roll

| Problem | Don't Build | Use Instead | Why |
|---------|-------------|-------------|-----|
| Menu grouping | Custom section headers, attributed titles, badge rows | `NSMenuItem.separator()` + fixed action rows | Native separators already express logical groups and preserve compact scanning |
| Button prominence | Custom filled backgrounds, accent-heavy panels | `.buttonStyle(.bordered)` and `.buttonStyle(.borderedProminent)` | System styles already encode secondary versus primary emphasis and adapt with macOS |
| Window chrome | Custom cards, tinted hero panels, heavy containers | Plain `VStack`, semantic colors, stock controls | Utility windows should feel like small native tools, not dashboards |
| Reorder interactions | Custom drag/reorder surface for all list states | Keep `List` only for reorder mode and current scroll-stack list for normal mode | Existing repo/test strategy already solved normal-mode queryability |
| Status truth | View-local “friendly” status cache | Existing `KeepAwakePresentation`, `WOLSessionModel`, and `lastCompletedWake` | Phase requirements still depend on truthful local state, not optimistic copy |

**Key insight:** In this phase, “polish” should mostly mean deleting custom ideas. The fastest path to a better native result is to lean harder on standard AppKit/SwiftUI behavior and make visibility rules more selective.

## Common Pitfalls

### Pitfall 1: Separator Drift Breaks the Three-Section Contract
**What goes wrong:** Dynamic wake rebuilds insert rows relative to `wolItem`, but the menu still only has one fixed separator today.
**Why it happens:** Current code was built for capability delivery, not the new three-group invariant.
**How to avoid:** Add permanent separator anchors in `configure()`, then rebuild only the wake rows between those anchors.
**Warning signs:** `wolMenuIndexForTesting` shifts unpredictably, or management actions move up when recents/status rows change.

### Pitfall 2: Wake Status Disappears for Manual-Only Users
**What goes wrong:** `wakeStatusItem` is created only when `deviceLibrary.devices` is non-empty.
**Why it happens:** `rebuildWakeMenu()` returns early before creating the wake status row for an empty library.
**How to avoid:** Treat wake status as part of the wake section contract, not as a side effect of having saved devices.
**Warning signs:** Manual WOL sends succeed/fail in the WOL window, but the root menu shows no wake status afterward.

### Pitfall 3: “Polish” Turns Into Custom Chrome
**What goes wrong:** Extra panels, custom fills, or decorative helper text make the utility feel less native.
**Why it happens:** Visual improvement is mistaken for adding more UI rather than improving hierarchy.
**How to avoid:** Limit prominence to one primary action per surface, use semantic colors, and let whitespace and text weight do the work.
**Warning signs:** Multiple blue elements compete for attention, or the window starts reading like a settings/dashboard surface.

### Pitfall 4: Replacing the Normal Device List with a `List` Reopens Test Issues
**What goes wrong:** XCUITest can lose stable access to row identifiers in dense macOS `List` rendering.
**Why it happens:** The repo already split reorder mode and normal mode for this reason, but polish work can accidentally undo it.
**How to avoid:** Keep the Phase 2 scroll-stack/list split unless a new test-backed alternative proves better.
**Warning signs:** Existing UI tests stop finding `device-row-*` markers after a visual refactor.

### Pitfall 5: Visual Assertions Are Harder Than Structural Assertions
**What goes wrong:** Plans promise “clear hierarchy” without adding testable hooks.
**Why it happens:** Typography/spacing changes are real UX work, but XCUITest can only verify them indirectly.
**How to avoid:** Add accessibility identifiers for new WOL sections/status blocks and pair smoke tests with a short manual visual checklist.
**Warning signs:** A plan claims UX-04 coverage but only adds unit tests around model state.

## Code Examples

Verified patterns from official sources:

### Group Commands with Native Separators
```swift
menu.addItem(keepAwakeOffItem)
menu.addItem(keepAwakeStatusItem)
menu.addItem(NSMenuItem.separator())
menu.addItem(wolItem)
menu.addItem(allDevicesItem)
menu.addItem(wakeStatusItem)
menu.addItem(NSMenuItem.separator())
menu.addItem(manageDevicesItem)
menu.addItem(quitItem)
```
Source: https://developer.apple.com/documentation/appkit/nsmenuitem/separator()

### Use Prominent Style Only for the Primary Action
```swift
Button("取消") {
    session.cancelForm()
}
.buttonStyle(.bordered)

Button("保存设备") {
    session.saveDraft()
}
.buttonStyle(.borderedProminent)
.disabled(!session.canSaveDraft)
```
Source: https://developer.apple.com/design/human-interface-guidelines/buttons

### Keep Reorder Mode on Native `List`
```swift
List {
    ForEach(session.devices) { device in
        DeviceRow(device: device, isReordering: true, onEdit: {}, onDelete: {})
    }
    .onMove(perform: session.moveDevices)
}
.listStyle(.inset)
```
Source: https://developer.apple.com/documentation/swiftui/list

## State of the Art

| Old Approach | Current Approach | When Changed | Impact |
|--------------|------------------|--------------|--------|
| Custom-drawn polish layers | Stock AppKit/SwiftUI controls automatically adopt current system appearance and materials | Current Apple guidance; reinforced in recent SDK/HIG updates | Prefer system button styles, semantic colors, and standard controls over decorative chrome |
| Rewriting every modern menu-bar app to `MenuBarExtra` | `MenuBarExtra` is available, but AppKit `NSStatusItem` remains valid and often better for existing retained-window shells | SwiftUI addition in recent macOS releases | For this repo, keep AppKit and treat shell modernization as deferred work |
| Deep or multiple submenu nesting | Single-purpose, shallow command structure with one submenu only when needed | Stable macOS menu guidance | Keep only the `所有设备` submenu and avoid second-level nesting |

**Deprecated/outdated:**
- Text headers inside the root status menu: replace with separators.
- Multiple “status” or helper rows visible in idle states: Phase 05 should collapse them.

## Open Questions

1. **Should the WOL window title stay `WOL 发送器` or align with the content heading?**
   - What we know: The shell title is currently `WOL 发送器`, while the approved UI contract only standardizes the in-window heading.
   - What's unclear: Whether copy alignment is part of this polish phase or unnecessary churn.
   - Recommendation: Keep this as a low-cost planner decision and avoid spending a whole task on it unless design review flags it.

2. **How much WOL hierarchy should be UI-testable versus manually verified?**
   - What we know: The device-library view already exposes accessibility markers; `WOLView.swift` currently does not.
   - What's unclear: Whether the planner wants added identifiers for mode selector, status block, and action row.
   - Recommendation: Add identifiers if Phase 05 includes new WOL smoke tests; otherwise document a manual visual gate for UX-04.

## Environment Availability

| Dependency | Required By | Available | Version | Fallback |
|------------|------------|-----------|---------|----------|
| Xcode / `xcodebuild` | Build and test commands, XCTest/XCUITest execution | ✓ | Xcode 26.2 (`17C52`) | — |
| Apple Swift toolchain | Compiling the target and tests | ✓ | Swift 6.2.3 toolchain, project set to `SWIFT_VERSION = 5.0` | — |
| macOS SDK | AppKit/SwiftUI/App Sandbox build target | ✓ | MacOSX 26.2 SDK, deployment target 15.6 | — |

**Missing dependencies with no fallback:**
- None

**Missing dependencies with fallback:**
- None

## Validation Architecture

### Test Framework
| Property | Value |
|----------|-------|
| Framework | XCTest + XCUITest (bundled with Xcode 26.2) |
| Config file | none — target-driven Xcode project |
| Quick run command | `xcodebuild test -scheme 'Mac OS Swiss Knife' -destination 'platform=macOS' -only-testing:'Mac OS Swiss KnifeTests/StatusBarControllerWakeMenuTests' -only-testing:'Mac OS Swiss KnifeTests/StatusBarControllerKeepAwakeMenuTests'` |
| Full suite command | `xcodebuild test -scheme 'Mac OS Swiss Knife' -destination 'platform=macOS'` |

Verified quick-run baseline on 2026-04-12:
- `StatusBarControllerWakeMenuTests` passed
- `StatusBarControllerKeepAwakeMenuTests` passed

### Phase Requirements → Test Map
| Req ID | Behavior | Test Type | Automated Command | File Exists? |
|--------|----------|-----------|-------------------|-------------|
| UX-01 | Root menu always renders keep-awake, wake, and management groups with exactly two separators and contextual status collapse | unit | `xcodebuild test -scheme 'Mac OS Swiss Knife' -destination 'platform=macOS' -only-testing:'Mac OS Swiss KnifeTests/StatusBarControllerMenuPolishTests'` | ❌ Wave 0 |
| UX-04 | WOL and device-library windows keep native hierarchy, restrained prominence, and truthful status visibility | smoke + manual visual | `xcodebuild test -scheme 'Mac OS Swiss Knife' -destination 'platform=macOS' -only-testing:'Mac OS Swiss KnifeUITests/Mac_OS_Swiss_KnifeUITests'` | ✅ extend existing suite |

### Sampling Rate
- **Per task commit:** `xcodebuild test -scheme 'Mac OS Swiss Knife' -destination 'platform=macOS' -only-testing:'Mac OS Swiss KnifeTests/StatusBarControllerWakeMenuTests' -only-testing:'Mac OS Swiss KnifeTests/StatusBarControllerKeepAwakeMenuTests'`
- **Per wave merge:** `xcodebuild test -scheme 'Mac OS Swiss Knife' -destination 'platform=macOS' -only-testing:'Mac OS Swiss KnifeTests/StatusBarControllerMenuPolishTests' -only-testing:'Mac OS Swiss KnifeUITests/Mac_OS_Swiss_KnifeUITests'`
- **Phase gate:** Full suite green before `/gsd:verify-work`

### Wave 0 Gaps
- [ ] `Mac OS Swiss KnifeTests/StatusBarControllerMenuPolishTests.swift` — separator placement, static anchor order, idle status collapse, and empty-library wake status coverage for `UX-01`
- [ ] Extend `Mac OS Swiss KnifeUITests/Mac_OS_Swiss_KnifeUITests.swift` — WOL/device-library smoke assertions for visible sections and primary action presence
- [ ] Add accessibility identifiers in `WOLView.swift` for the mode selector group, status block, and action row if UI smoke coverage is planned

## Sources

### Primary (HIGH confidence)
- Repo source: [`StatusBarController.swift`](/Users/hailinpan/Documents/GitHub/Mac%20OS%20Swiss%20Knife/Mac%20OS%20Swiss%20Knife/StatusBarController.swift), [`KeepAwakePresentation.swift`](/Users/hailinpan/Documents/GitHub/Mac%20OS%20Swiss%20Knife/Mac%20OS%20Swiss%20Knife/KeepAwakePresentation.swift), [`WOLView.swift`](/Users/hailinpan/Documents/GitHub/Mac%20OS%20Swiss%20Knife/Mac%20OS%20Swiss%20Knife/WOLView.swift), [`DeviceLibraryView.swift`](/Users/hailinpan/Documents/GitHub/Mac%20OS%20Swiss%20Knife/Mac%20OS%20Swiss%20Knife/DeviceLibraryView.swift), [`DeviceLibraryWindow.swift`](/Users/hailinpan/Documents/GitHub/Mac%20OS%20Swiss%20Knife/Mac%20OS%20Swiss%20Knife/DeviceLibraryWindow.swift), [`WOLWindow.swift`](/Users/hailinpan/Documents/GitHub/Mac%20OS%20Swiss%20Knife/Mac%20OS%20Swiss%20Knife/WOLWindow.swift)
- Repo tests: [`StatusBarControllerWakeMenuTests.swift`](/Users/hailinpan/Documents/GitHub/Mac%20OS%20Swiss%20Knife/Mac%20OS%20Swiss%20KnifeTests/StatusBarControllerWakeMenuTests.swift), [`StatusBarControllerKeepAwakeMenuTests.swift`](/Users/hailinpan/Documents/GitHub/Mac%20OS%20Swiss%20Knife/Mac%20OS%20Swiss%20KnifeTests/StatusBarControllerKeepAwakeMenuTests.swift), [`Mac_OS_Swiss_KnifeUITests.swift`](/Users/hailinpan/Documents/GitHub/Mac%20OS%20Swiss%20Knife/Mac%20OS%20Swiss%20KnifeUITests/Mac_OS_Swiss_KnifeUITests.swift)
- Apple AppKit docs: https://developer.apple.com/documentation/appkit/nsmenuitem/separator() - separator items express logical command grouping
- Apple SwiftUI docs: https://developer.apple.com/documentation/swiftui/list - standard vertical list container for reorder mode and row collections
- Apple Human Interface Guidelines: https://developer.apple.com/design/human-interface-guidelines/buttons - button prominence and restraint
- Apple Human Interface Guidelines: https://developer.apple.com/design/human-interface-guidelines/layout - visual hierarchy, grouping, and scanability
- Apple SwiftUI docs: https://developer.apple.com/documentation/swiftui/menubarextra - current official menu-bar-extra API, used here only as a deferred alternative

### Secondary (MEDIUM confidence)
- Apple HIG search result for Menus: https://developer.apple.com/design/human-interface-guidelines/menus - used to reinforce separators and shallow menu structure; direct page content is JavaScript-rendered in this environment
- Apple HIG search result for Windows/AppKit controls: developer.apple.com HIG pages surfaced in search and cross-checked against existing AppKit/SwiftUI usage

### Tertiary (LOW confidence)
- None

## Metadata

**Confidence breakdown:**
- Standard stack: HIGH - confirmed from repo, local toolchain, and Apple framework docs
- Architecture: HIGH - current file ownership and session/test seams are explicit in the codebase
- Pitfalls: MEDIUM - strongest risks come from current code behavior and prior phase history, but some Apple HIG menu guidance was verified via search snippets rather than a fully rendered page

**Research date:** 2026-04-12
**Valid until:** 2026-05-12
