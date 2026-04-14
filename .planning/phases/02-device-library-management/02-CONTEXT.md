# Phase 2: Device Library Management - Context

**Gathered:** 2026-04-11
**Status:** Ready for planning

<domain>
## Phase Boundary

Add a dedicated native surface for managing a small local Wake-on-LAN device library. This phase covers local device create, edit, delete, note capture, validation-before-save, and persisted manual ordering. It does not include fast wake shortcuts, recents, discovery, import/export, or deep inline editing inside the menu bar.

</domain>

<decisions>
## Implementation Decisions

### Management Surface Shape
- **D-01:** Device management must live in a dedicated native window rather than inside the existing WOL send window or the menu hierarchy.
- **D-02:** The management window should feel like a small, compact utility window rather than a heavy settings panel or split-view management app.
- **D-03:** The device management window and the WOL send window should be fully independent and allowed to stay open at the same time.
- **D-04:** The primary entry point for the management window should be a dedicated `管理设备…` item in the menu bar menu.

### Device List Presentation
- **D-05:** The saved-device list should use a balanced row layout rather than minimal name-only rows or dense full-detail rows.
- **D-06:** Each row should show both the device name and MAC address as equally important information.
- **D-07:** If a device has a note, the list may show a lighter, shorter note preview beneath the main row content.

### Add and Edit Flow
- **D-08:** The default management view should focus on the device list; add/edit should transition into a dedicated form view instead of leaving a permanent editor visible beside the list.
- **D-09:** Creating and editing devices should share the same form layout and interaction model.
- **D-10:** The add/edit form must cover name, MAC address, and optional note, with invalid edits blocked before save.

### Reorder and Delete Behavior
- **D-11:** Reordering should not be permanently active; drag reordering should appear only after the user enters an explicit editing or reordering mode.
- **D-12:** Device deletion should require a confirmation step before the item is removed.
- **D-13:** Preserved user order is the canonical display order for the library and must survive app reopen.

### the agent's Discretion
- Exact menu wording and button labels, as long as the menu clearly exposes a dedicated device-management entry.
- Exact compact-window dimensions, spacing, and native AppKit/SwiftUI chrome choices, as long as the result stays restrained and utility-like.
- Exact note preview truncation rules and row spacing, as long as name and MAC remain the primary scannable identifiers.
- Exact wording and presentation of validation copy and delete confirmation, as long as invalid edits are blocked before save and deletion remains deliberate.
- Exact structure of the temporary add/edit form transition, as long as it stays distinct from the passive list view and does not turn into a permanent split management interface.

</decisions>

<specifics>
## Specific Ideas

- The management surface should feel like a native macOS utility window, not like a settings-heavy preferences app.
- The device list should let the user identify entries by both name and MAC without opening each item.
- Notes are supporting context, not the primary identifier.
- Reordering should feel intentional rather than always-on, to reduce accidental movement in a small utility window.

</specifics>

<canonical_refs>
## Canonical References

**Downstream agents MUST read these before planning or implementing.**

### Phase scope and requirements
- `.planning/ROADMAP.md` — Defines Phase 2 goal, success criteria, dependency on Phase 1, and UI hint.
- `.planning/REQUIREMENTS.md` — Defines `DEVS-01` through `DEVS-05`, `RELY-01`, and `UX-02`, plus explicit out-of-scope items such as deep menu editing and import/export.

### Project-level constraints
- `.planning/PROJECT.md` — Defines the local-first personal-use scope, native macOS direction, reliability expectations, and maintainability constraints.
- `.planning/STATE.md` — Confirms milestone sequencing and that Phase 2 is the current focus after Phase 1 completion.

### Existing product behavior
- `.planning/phases/01-truthful-foundations/01-CONTEXT.md` — Carries forward truthful validation expectations, session/lifecycle preferences, and native window behavior decisions established in Phase 1.
- `README.md` — Describes the current menu bar app model and existing WOL window entry flow that Phase 2 extends.

</canonical_refs>

<code_context>
## Existing Code Insights

### Reusable Assets
- `Mac OS Swiss Knife/AppDelegate.swift`: Already owns retained window/controller lifecycle and is the natural coordinator for a second dedicated management window.
- `Mac OS Swiss Knife/StatusBarController.swift`: Already defines the compact menu structure and is the place where a dedicated `管理设备…` entry can be added.
- `Mac OS Swiss Knife/WOLWindow.swift`: Existing pattern for a retained AppKit window hosting a SwiftUI view that can guide the new management surface.
- `Mac OS Swiss Knife/WOLSessionModel.swift`: Existing session-owned state pattern proves the app now supports retained UI state outside a single SwiftUI view.
- `Mac OS Swiss Knife/ManualMACValidator.swift`: Existing MAC validation contract from Phase 1 is directly reusable for save-time device validation.
- `Mac OS Swiss Knife/WOLView.swift`: Current hardcoded device option list shows exactly where Phase 2 needs to replace source-edited presets with real local device data.

### Established Patterns
- The app uses small, flat Swift files with one primary type per file; Phase 2 should fit that structure rather than introducing a large subsystem tree.
- AppKit owns long-lived windows and menu actions, while SwiftUI hosts the actual form/list UI inside those windows.
- Runtime strings are user-facing Chinese, while type and API names stay English.
- Validation and side-effect truthfulness are already handled through explicit typed models rather than optimistic UI assumptions.

### Integration Points
- A new management window/controller should plug into the same lifecycle ownership layer as the current WOL window.
- Saved-device persistence needs to become the source of truth for both the management window and the existing WOL device-selection path.
- The management UI must connect to the existing MAC validation path so save rules stay aligned with the truthful manual-send rules from Phase 1.
- Reordering and deletion flows will need to feed a persisted device order that later phases can reuse directly for menu and wake flows.

</code_context>

<deferred>
## Deferred Ideas

- Recent devices and preselected last-used device behavior — Phase 3
- Direct wake actions from saved devices in the menu bar — Phase 3
- Import/export of device libraries — deferred beyond this milestone
- Auto discovery or scanning of devices on the LAN — out of scope for this milestone
- Deep inline editing inside the menu bar menu — explicitly out of scope

</deferred>

---

*Phase: 02-device-library-management*
*Context gathered: 2026-04-11*
