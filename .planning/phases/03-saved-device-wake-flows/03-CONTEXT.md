# Phase 3: Saved-Device Wake Flows - Context

**Gathered:** 2026-04-12
**Status:** Ready for planning

<domain>
## Phase Boundary

Turn the saved-device library into the fast daily wake path. This phase covers direct wake actions from the menu bar, recent-device memory, last-used saved-device preselection in the WOL window, and shared in-flight/result behavior so repeat sends stay truthful and non-duplicative. It does not reopen device CRUD, add favorites or shortcuts, or claim remote wake verification the app cannot actually observe.

</domain>

<decisions>
## Implementation Decisions

### Menu Wake Access
- **D-01:** The root menu should stay compact by showing a short recent-devices section inline plus an `所有设备` path for the full saved-device library.
- **D-02:** Every saved device must remain wakeable from the menu bar; recents are an acceleration layer, not the only path.
- **D-03:** Quick wake rows should stay compact and name-first. Do not show full MAC addresses in high-frequency menu actions.

### Recent and Last-Used Memory
- **D-04:** Recent-device ordering and last-used saved-device memory should update only after a locally successful saved-device wake send, never on selection changes or failed sends.
- **D-05:** Keep the recent-devices list short at three devices, ordered most-recent-first.
- **D-06:** Reopening the WOL window should default to preset mode with the most recently used saved device selected when a saved-device wake happened previously.
- **D-07:** Phase 1's manual-draft rule still applies: an unfinished manual MAC draft must not be blown away just to force saved-device preselection.
- **D-08:** If no saved-device history exists yet, the preset path should fall back to the canonical library order rather than inventing a new ranking heuristic.

### Shared Send and Status Semantics
- **D-09:** Menu-triggered wakes and window-triggered wakes must share one send state so duplicate wake actions cannot stack across surfaces.
- **D-10:** While a wake send is in progress, all saved-device wake actions should be disabled instead of queueing or replacing the active send.
- **D-11:** The menu should expose one lightweight status row that shows the current send in progress and then preserves the last local success or failure until a newer attempt replaces it.
- **D-12:** Status copy must keep Phase 1 truth semantics: success means the packet was sent locally from this Mac, not that the target device is confirmed awake.

### the agent's Discretion
- Exact menu labels, separators, and whether the full-library path is a submenu or another compact native presentation, as long as the root menu stays short and every saved device is reachable from the menu bar.
- Exact wording of the recent-device section title and last-result status text, as long as it stays concise, truthful, and user-facing Chinese.
- Exact fallback behavior when the last-used saved device was deleted, as long as the app lands on another valid saved-device choice without showing stale identity.
- Exact persistence shape for recent-device and last-used metadata, as long as it extends the shared repository/store contract instead of scattering new keys through views.

</decisions>

<specifics>
## Specific Ideas

- The fast path should feel like "open menu, wake the machine I usually wake" rather than "open a window and re-select the same device again."
- The menu should stay recognizably native and scannable even after saved-device wake actions are added.
- Manual MAC entry remains the exception path for odd cases; saved-device defaults should not erase an unfinished manual draft.
- The persistent status surface should help the user trust what just happened without pretending the app can verify the remote machine woke up.

</specifics>

<canonical_refs>
## Canonical References

**Downstream agents MUST read these before planning or implementing.**

### Phase scope and requirements
- `.planning/ROADMAP.md` — Defines the Phase 3 goal, success criteria, dependency on Phase 2, and the compact native-menu expectation that still applies here.
- `.planning/REQUIREMENTS.md` — Defines `WOL-01`, `WOL-03`, `WOL-04`, `RELY-04`, and `UX-03`, plus the out-of-scope guardrails around discovery, automation, and deep menu editing.

### Project and prior-phase constraints
- `.planning/PROJECT.md` — Defines the core value, local-first scope, native macOS UX direction, and the requirement that menu state reflect real local outcomes.
- `.planning/STATE.md` — Confirms Phase 2 is complete and Phase 3 is the next milestone step.
- `.planning/phases/01-truthful-foundations/01-CONTEXT.md` — Carries forward truthful local-send semantics, no false wake claims, preserved manual drafts, and clear in-flight/result behavior.
- `.planning/phases/02-device-library-management/02-CONTEXT.md` — Carries forward the dedicated manager window, compact utility UX, canonical saved-device order, and the decision not to move editing into the menu.
- `.planning/phases/02-device-library-management/02-03-SUMMARY.md` — Confirms Phase 2 already replaced hardcoded presets with the shared saved-device library as the WOL source of truth.
- `.planning/phases/02-device-library-management/02-05-SUMMARY.md` — Confirms the live manager and shared presentation contract are settled; Phase 3 should build on that wiring instead of reopening it.

### Research guidance
- `.planning/research/FEATURES.md` — Recommends one-click menu waking, lightweight last-attempt feedback, and a short recent-devices path while warning against long flat root menus.
- `.planning/research/ARCHITECTURE.md` — Recommends keeping recents, last-selected metadata, and status in shared store/view-model seams rather than view-local state.
- `.planning/research/PITFALLS.md` — Calls out false-success recents, menu bloat, and one-network assumptions as the main risks for this phase.

</canonical_refs>

<code_context>
## Existing Code Insights

### Reusable Assets
- `Mac OS Swiss Knife/AppDelegate.swift`: Already owns one shared `SavedDeviceLibraryStore`, one retained `WOLSessionModel`, and the native window lifecycle for both wake and management surfaces.
- `Mac OS Swiss Knife/StatusBarController.swift`: Already owns the compact root menu, keep-awake state row, and the callback pattern where new wake actions can be injected without moving device editing into the menu.
- `Mac OS Swiss Knife/WOLSessionModel.swift`: Already owns preset/manual selection, truthful send states, in-flight gating, and reopen semantics for the wake flow.
- `Mac OS Swiss Knife/WOLView.swift`: Already binds the wake window to `selectedSavedDeviceID`, the shared saved-device library, and the current send/result presentation.
- `Mac OS Swiss Knife/SavedDeviceLibraryStore.swift`: Already provides the canonical ordered saved-device list used by both the WOL window and the manager surface.
- `Mac OS Swiss Knife/SavedDeviceRepository.swift`: Already provides the persistence seam that should absorb last-used and recent-device metadata instead of spreading new keys through UI code.
- `Mac OS Swiss Knife/WakeSendPresentation.swift`: Already centralizes truthful wake copy and should remain the source of send/result wording.
- `Mac OS Swiss KnifeTests/WOLSessionModelTests.swift`: Already covers preset sends, hidden-window completion behavior, and lifecycle expectations that Phase 3 will extend.

### Established Patterns
- AppKit owns the menu shell and retained windows; SwiftUI views stay thin and bind to session models or presentation helpers.
- The shared saved-device library store is the canonical identity and ordering source for every surface; views do not own device persistence directly.
- Wake send truth is modeled explicitly through `idle`, `sending`, `success`, and `failure` states, with completion published back onto the main thread.
- User-facing runtime copy stays in Chinese while type and API names remain English.

### Integration Points
- Menu wake actions, recent-device rows, and the last-result row will extend `Mac OS Swiss Knife/StatusBarController.swift`.
- Shared wake state and last-used selection will build on `Mac OS Swiss Knife/WOLSessionModel.swift`, not a second isolated send model.
- Recent-device and last-used persistence will extend the repository/store layer behind `Mac OS Swiss Knife/SavedDeviceRepository.swift` and `Mac OS Swiss Knife/SavedDeviceLibraryStore.swift`.
- `Mac OS Swiss Knife/AppDelegate.swift` is the natural composition point for any shared status or session object that both the menu and WOL window must observe.

</code_context>

<deferred>
## Deferred Ideas

- Favorite or pinned devices separate from recents — deferred beyond this phase; Phase 3 should stick to a short recents model.
- Dedicated `Wake Last Device` keyboard shortcut — useful follow-on convenience, but out of scope until the menu/state model settles.
- Advanced per-device networking or route diagnostics — still out of scope unless real hardware proves the simple local model is insufficient.

</deferred>

---

*Phase: 03-saved-device-wake-flows*
*Context gathered: 2026-04-12*
