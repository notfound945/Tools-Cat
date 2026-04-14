# Project Research Summary

**Project:** Mac OS Swiss Knife
**Domain:** Personal native macOS menu bar utility
**Researched:** 2026-04-11
**Confidence:** HIGH

## Executive Summary

Mac OS Swiss Knife should remain a small, native, personal macOS utility, not expand into a generalized network manager or automation product. The research is consistent on the product shape: a restrained menu bar app for two daily jobs, keeping the display awake and waking a small set of known devices reliably, with local-only persistence and native macOS interaction patterns.

The recommended approach is incremental, not a rewrite. Keep the existing Apple-native stack, add thin seams around system side effects, introduce a canonical persisted device model backed by `UserDefaults`, move WOL state out of views into a small feature model, and use the existing `Settings` surface for device management. Daily-use value comes from persistent saved devices, one-click wake actions, honest send/status feedback, and a menu that stays short and scannable.

The main risks are architectural overreach and false reliability. A shell rewrite, menu bloat, or view-owned persistence would make the app harder to trust and harder to evolve. The mitigation is explicit build order: fix service contracts and persistence seams first, then lifecycle/state ownership, then device management UI, then recents/favorites and polish, with tests and privacy-aware logging closing the loop.

## Key Findings

### Recommended Stack

This milestone does not need a new platform stack. It should stay fully Apple-native, dependency-light, and local-first. The strongest stack recommendation is to use native persistence and state tools proportionate to a small utility, while preserving the existing low-level WOL and power-management primitives behind cleaner interfaces.

The one nuance across the research is shell strategy: Apple-native scene APIs like `MenuBarExtra` and `Settings` are the long-term direction, but the safer milestone path is to clean seams inside the current hybrid AppKit/SwiftUI app before attempting a shell migration. That keeps behavior stable while still moving toward a more native, lower-friction codebase.

**Core technologies:**
- SwiftUI for feature UI and settings: native views and preferences surface — already fits the repo and keeps new UI work small.
- AppKit shell, for now: menu bar item and window lifecycle — safest brownfield path while state ownership is being cleaned up.
- Observation or a small shared state model plus injected view models: app and feature state — reduces notification-driven coupling.
- `UserDefaults` + `Codable`: persisted device library and lightweight preferences — right-sized for a local personal device list.
- Protocol-wrapped `WOLSender` and `PowerAssertionManager`: system side effects — preserves proven low-level behavior while making outcomes testable.
- `OSLog` / `Logger`: diagnostics — replaces raw `print` logging and avoids leaking personal network data.

### Expected Features

The research draws a clean line between daily-use requirements and nice-to-have polish. The next milestone should solve the current prototype gap: no more hardcoded devices, no more code edits for configuration, and no more vague or optimistic status. It should not chase discovery, sync, or automation.

**Must have (daily-use table stakes):**
- Persistent local device library — saved devices must stop living in source or transient view state.
- Dedicated `Manage Devices...` flow — add, edit, delete, and reorder in a focused native UI.
- One-click wake from the menu bar — the main value proposition is fast access.
- Reliable validation and explicit last-attempt feedback — users must know whether the packet send succeeded locally or failed.
- Short per-device notes — lightweight disambiguation for similar machines.

**Should have (follow-on convenience):**
- Recent devices and pinned favorites — improves repeated daily use once the store is stable.
- Remember last selected device — removes repetitive clicks in the wake flow.
- Menu-state polish and disabled-in-flight actions — improves trust without adding product sprawl.

**Defer / avoid:**
- Automatic LAN discovery — too much complexity for uncertain value.
- Cloud sync or shared libraries — misaligned with self-use, local-first scope.
- Automation rules, scripts, or batch wake orchestration — turns a utility into an automation system.
- Deep or editable menus — hurts native menu-bar usability.
- Advanced per-device routing fields unless real hardware proves they are required.

### Architecture Approach

The strongest architecture guidance is to keep one small app target and introduce only the seams needed to support persistence, truthful status, and stable lifecycle behavior. The right pattern is a composition root that owns long-lived controllers, a repository for saved devices, thin service adapters for power and WOL, and view models that own transient feature state. That is enough to support the milestone without turning the app into a framework exercise.

**Major components:**
1. `AppDelegate` / app environment — composition root for long-lived dependencies and controllers.
2. `StatusBarController` and `WOLWindow` — AppKit shell for menu and window ownership during the refactor.
3. `DeviceRepository` — canonical store for saved devices, notes, recents, and selection metadata.
4. `WOLService` and `PowerAssertionService` — typed side-effect boundaries over existing system code.
5. `WOLViewModel` and device-management view model — transient send state, validation, CRUD flows, and user-visible status.
6. `StatusStore` — small shared state for last operation result and menu feedback.

### Critical Pitfalls

1. **View-owned persistence** — avoid storing devices, recents, and notes directly in SwiftUI state or scattered defaults keys; define one canonical saved-device model and repository first.
2. **False-success status** — avoid optimistic menu or wake feedback; only update status and recents after local operations actually succeed, and label outcomes precisely.
3. **NotificationCenter as architecture** — avoid growing window/reset/save flows through broadcast notifications; move to explicit ownership and injected dependencies.
4. **Menu bloat** — avoid turning the status menu into a tiny settings app; keep quick actions in the menu and move editing into settings.
5. **Rewrite creep** — avoid swapping shell, persistence, and feature logic all at once; refactor in shippable increments with behavior parity checks and tests.

## Implications for Roadmap

Based on the combined research, the roadmap should treat this as a reliability-first native utility milestone. The safest and most useful order is to establish truthful service contracts and a canonical device store before changing more UI.

### Phase 1: Service and Data Foundations
**Rationale:** Everything else depends on honest side-effect results and one canonical saved-device model.
**Delivers:** `SavedDevice` model, repository contract, `UserDefaults` persistence, protocol-wrapped WOL and power services, normalized validation rules, privacy-aware logging baseline.
**Addresses:** Persistent local device library, reliable validation, removal of hardcoded device data.
**Avoids:** View-owned persistence, sensitive data leakage, false-success state baked into later UI.

### Phase 2: Feature State and Lifecycle Cleanup
**Rationale:** The current lifecycle glue is fragile; persistent devices and richer feedback will amplify that fragility if state ownership stays implicit.
**Delivers:** `WOLViewModel`, explicit window ownership, reduced `NotificationCenter` usage, typed status/result flow, behavior parity for existing keep-awake and wake actions.
**Implements:** Composition root, AppKit shell plus injected feature models, `StatusStore`.
**Avoids:** Notification-driven reset bugs, duplicate observers, rewrite creep.

### Phase 3: Daily-Use Device Management
**Rationale:** Once persistence and lifecycle seams exist, the app can expose device CRUD safely without smearing schema logic across the menu.
**Delivers:** Native `Settings`-based `Manage Devices...` UI for add/edit/delete/reorder, notes editing, stable local storage as source of truth.
**Addresses:** Dedicated management UI, notes, no-source-edit setup.
**Uses:** SwiftUI settings UI, `UserDefaults` repository, feature-scoped view models.
**Avoids:** Menu bloat, partial invalid saves, schema drift tied to view code.

### Phase 4: Menu Reliability and Daily-Use Speed
**Rationale:** After CRUD works, optimize the main interaction surface around the saved-device workflow.
**Delivers:** Grouped one-click wake menu, last-attempt status surface, accurate keep-awake toggle semantics, recent devices and optionally favorites if the menu remains compact.
**Addresses:** One-click wake, explicit last-attempt feedback, reduced repetitive input, native menu grouping.
**Avoids:** Overpromising wake success, deep menus, recents polluted by failed sends.

### Phase 5: Hardening and Optional Shell Modernization
**Rationale:** Tests and repeated-use verification should land after the new seams exist; shell migration should only happen if the stabilized app still benefits from it.
**Delivers:** XCTest coverage for persistence, migration, validation, failure paths, at least one reopen-cycle UI test, optional evaluation of `MenuBarExtra` if the existing shell remains a maintenance burden.
**Addresses:** Daily-use trust, regression prevention, future-proofing without automatic rewrite.
**Avoids:** Reappearing lifecycle bugs, untested schema changes, premature shell churn.

### Phase Ordering Rationale

- Service truth and data shape come first because every feature depends on them and they prevent false confidence from propagating into recents, status, and menu state.
- Lifecycle cleanup comes before settings and menu polish because richer UI on top of notification-driven ownership will magnify fragility.
- Device management belongs in settings after the repository exists, not before.
- Menu speed features like recents/favorites should be derived from confirmed actions after the reliable send pipeline is in place.
- Testing comes after seams exist, but the roadmap should design those seams from Phase 1 onward.

### Research Flags

Phases likely needing deeper research during planning:
- **Phase 4:** Only if real usage demands advanced per-device routing, interface diagnostics, or favorite/recent ranking beyond the simple local model.
- **Phase 5:** Only if the team chooses to replace the AppKit shell with `MenuBarExtra` rather than keeping the stabilized hybrid approach.

Phases with standard patterns (skip `research-phase`):
- **Phase 1:** `UserDefaults` + `Codable`, service protocols, and `Logger` are standard native patterns for a utility of this size.
- **Phase 2:** View-model extraction and explicit ownership are well-understood brownfield refactors.
- **Phase 3:** Settings-based CRUD UI is straightforward once the repository contract exists.

## Confidence Assessment

| Area | Confidence | Notes |
|------|------------|-------|
| Stack | HIGH | Strong alignment on staying Apple-native, dependency-light, and local-first; only the exact shell end-state remains optional. |
| Features | MEDIUM | Must-have daily-use features are clear, but some convenience items like notes vs favorites ordering should still be validated in real usage. |
| Architecture | HIGH | Local repo evidence and the research agree on incremental seam cleanup over rewrite. |
| Pitfalls | HIGH | The failure modes are concrete and directly grounded in the current code shape. |

**Overall confidence:** HIGH

### Gaps to Address

- Advanced network fields: keep `name + MAC` as the default model and only add broadcast/interface configuration if real hardware proves it necessary during implementation.
- Shell end-state: do not commit the roadmap to a `MenuBarExtra` migration unless post-hardening evidence shows the AppKit shell is still the main maintenance problem.
- Notes vs favorites in the milestone boundary: notes are low-cost and useful, but favorites/recents should win if scope pressure appears because they improve repeated daily use more directly.
- Status wording: implementation should validate the exact user-facing copy so it clearly distinguishes `packet sent` from `device confirmed awake`.

## Sources

### Primary (HIGH confidence)
- [.planning/PROJECT.md](/Users/hailinpan/Documents/GitHub/Mac OS Swiss Knife/.planning/PROJECT.md) — project scope and milestone intent
- [.planning/research/STACK.md](/Users/hailinpan/Documents/GitHub/Mac OS Swiss Knife/.planning/research/STACK.md) — native stack recommendations
- [.planning/research/ARCHITECTURE.md](/Users/hailinpan/Documents/GitHub/Mac OS Swiss Knife/.planning/research/ARCHITECTURE.md) — build order and component boundaries
- [.planning/research/PITFALLS.md](/Users/hailinpan/Documents/GitHub/Mac OS Swiss Knife/.planning/research/PITFALLS.md) — phase risks and prevention guidance
- Apple Developer Documentation: `MenuBarExtra`, `Settings`, `AppStorage`, `UserDefaults`, `Logger` — native platform patterns

### Secondary (MEDIUM confidence)
- [.planning/research/FEATURES.md](/Users/hailinpan/Documents/GitHub/Mac OS Swiss Knife/.planning/research/FEATURES.md) — table-stakes vs differentiators for personal WOL tools
- Apple Human Interface Guidelines: menus — menu grouping and scanability guidance
- Mac App Store listings for Wake-on-LAN menu bar utilities — feature baseline and anti-feature comparison

### Tertiary (LOW confidence)
- Competitor-specific convenience signals from commercial WOL tools — useful for prioritization, but lower confidence than repo evidence and Apple-native guidance

---
*Research completed: 2026-04-11*
*Ready for roadmap: yes*
