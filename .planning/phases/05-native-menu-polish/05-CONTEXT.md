# Phase 5: Native Menu Polish - Context

**Gathered:** 2026-04-12
**Status:** Ready for planning

<domain>
## Phase Boundary

Consolidate the existing menu and native surfaces into a more compact, clearly grouped, and visually restrained macOS utility. This phase covers menu grouping, status-row density, and visual hierarchy polish for the WOL window and device-management window. It does not add new capabilities, reopen timed keep-awake semantics, change saved-device wake behavior, or move device editing into the menu.

</domain>

<decisions>
## Implementation Decisions

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

### the agent's Discretion
- Exact separator placement and spacing in the root menu, as long as the three-section structure stays obvious and compact.
- Exact show/hide rules for wake and keep-awake status rows in idle versus active states, as long as the menu becomes shorter when no meaningful status is present.
- Exact typographic, spacing, and icon treatments inside the WOL and device-management windows, as long as they remain restrained and native to macOS.
- Whether small supporting subtitles or helper copy are needed inside the windows, as long as they improve hierarchy without making the surfaces feel verbose.

</decisions>

<specifics>
## Specific Ideas

- Menu structure should read as three clear groups: keep-awake, wake, then management/exit.
- Status feedback should become more on-demand so the menu stays compact when the app is idle.
- The WOL window should feel like a polished native tool window, not a settings page or a command dashboard.
- The device-management window should feel more deliberate and refined through stronger row hierarchy, clearer empty state, and a more intentional top action area.

</specifics>

<canonical_refs>
## Canonical References

**Downstream agents MUST read these before planning or implementing.**

### Phase scope and requirements
- `.planning/ROADMAP.md` — Defines Phase 5 goal, success criteria, and the compact native menu polish scope.
- `.planning/REQUIREMENTS.md` — Defines `UX-01` and `UX-04`, plus the broader milestone constraints that keep this phase focused on polish rather than new capability.

### Project-level constraints
- `.planning/PROJECT.md` — Captures the core value, native macOS direction, and the explicit goal of a small, restrained, polished utility.
- `.planning/STATE.md` — Confirms Phase 4 is complete and Phase 5 is now the active focus.

### Prior phase decisions that remain locked
- `.planning/phases/02-device-library-management/02-CONTEXT.md` — Keeps device management in a dedicated native window and preserves the compact utility-window direction.
- `.planning/phases/03-saved-device-wake-flows/03-CONTEXT.md` — Keeps the root menu compact with recent devices plus `所有设备`, and preserves the menu-status expectations for wake flows.
- `.planning/phases/04-timed-keep-awake/04-CONTEXT.md` — Keeps keep-awake controls at the root menu, preserves the explicit `关闭常亮` row, and prevents reopening timed keep-awake behavior decisions during polish.

### Existing product behavior
- `README.md` — Describes the current menu-bar utility model and high-level user-facing capabilities this polish phase is refining.

</canonical_refs>

<code_context>
## Existing Code Insights

### Reusable Assets
- `Mac OS Swiss Knife/StatusBarController.swift`: Owns the entire root menu structure, keep-awake action group, wake shortcuts, status rows, and separator placement.
- `Mac OS Swiss Knife/KeepAwakePresentation.swift`: Already centralizes keep-awake icon, tooltip, and status-row copy decisions that Phase 5 should preserve while refining density.
- `Mac OS Swiss Knife/WOLView.swift`: Current WOL window layout already has the correct information architecture and is the direct surface to refine visually.
- `Mac OS Swiss Knife/WOLWindow.swift`: Owns compact native window shell decisions such as title, size, and activation behavior for the WOL surface.
- `Mac OS Swiss Knife/DeviceLibraryView.swift`: Current list/form management surface already has list-first behavior, empty state, row hierarchy primitives, and top action controls to polish.
- `Mac OS Swiss Knife/DeviceLibraryWindow.swift`: Owns the compact native shell for the device-management window.
- `Mac OS Swiss Knife/DeviceLibraryManagementPresentation.swift`: Existing presentation-copy layer for manager labels and empty-state text can anchor any polish that adjusts hierarchy without changing behavior.

### Established Patterns
- AppKit owns the menu shell and retained windows, while SwiftUI provides the window contents.
- Runtime strings stay Chinese, while type and API names stay English.
- Root-menu behavior remains compact and native, using real menu rows and separators instead of explanatory text blocks.
- Truthful state semantics from earlier phases are already established and must not be loosened during polish.

### Integration Points
- Menu regrouping and status-density changes will land primarily in `Mac OS Swiss Knife/StatusBarController.swift`.
- WOL-window visual hierarchy changes will land in `Mac OS Swiss Knife/WOLView.swift`, with only minor shell adjustments in `Mac OS Swiss Knife/WOLWindow.swift` if sizing or title treatment needs tuning.
- Device-manager polish will center on `Mac OS Swiss Knife/DeviceLibraryView.swift` and may touch `Mac OS Swiss Knife/DeviceLibraryWindow.swift` or `Mac OS Swiss Knife/DeviceLibraryManagementPresentation.swift` for refined structure and copy.
- App-level composition in `Mac OS Swiss Knife/AppDelegate.swift` should remain stable; Phase 5 is about presentation and grouping, not lifecycle redesign.

</code_context>

<deferred>
## Deferred Ideas

None — discussion stayed within phase scope.

</deferred>

---

*Phase: 05-native-menu-polish*
*Context gathered: 2026-04-12*
