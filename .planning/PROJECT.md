# Tools Cat

## What This Is

Tools Cat is a personal macOS menu bar utility for two everyday jobs: keeping the display awake and waking devices on the local network with Wake-on-LAN. It now has a hardened native baseline with saved-device management, truthful status feedback, explicit verification boundaries, user-managed timed keep-awake durations, and a consistent shipped identity across the app, automation, and planning surface.

## Core Value

From the menu bar, I can reliably wake the devices I care about and trust the app's status without editing code or fighting the UI.

## Current State

- Active milestone: none
- Live product identity: `Tools Cat`
- Latest shipped scope: truthful WOL and keep-awake state, saved-device management, shared saved-device wake flows through `快速 WOL` plus the dedicated `发送 WOL …` row, timed keep-awake, native menu/window polish, planning-truth cleanup, validation rebaseline, explicit verification strategy, full rename closure, the keep-awake menu-truth fix, macOS 14 baseline support, user-managed keep-awake durations with live root-menu synchronization, native duration-management and device-library list surfaces, compact retained add/edit sheets, semantic edit/delete affordances, stabilized direct-launch manager smokes, a non-notarized friend-share DMG flow with repeatable release verification, deferred saved-device validation reveal timing, exact-once first-use device seeding for `UGREEN NAS`, transient shared WOL feedback that auto-clears after three seconds in both the window and menu bar, a required-field save guard that enables `保存设备` only after trimmed name and MAC input exist, and truthful timed keep-awake notifications for both pre-expiry and actual session end, including visible unavailable-reminder state that does not block keep-awake behavior
- Planning state: v1.9 is shipped and archived. The project is ready to define a fresh milestone-scoped `REQUIREMENTS.md`.

## Next Milestone Goals

- Decide whether the next milestone should return to deferred convenience work such as `CONV-04`, `AWAKE-12`, and `AWAKE-13`, or extend the new reminder surface with `NOTF-06` through `NOTF-08`.
- Recreate a fresh milestone-scoped `REQUIREMENTS.md` instead of carrying forward the archived v1.9 reminder contract.

## Current Milestone

No active milestone is defined yet.

Use `$gsd-new-milestone` to define the next scoped requirement set and roadmap.

## Latest Shipped Milestone: v1.9 Timed Keep-Awake Notifications

**Result:** Timed keep-awake no longer ends silently: the app now requests reminder permission at launch, can warn shortly before expiry, notifies again when the timed session actually ends, and keeps reminder-unavailable truth visible without blocking keep-awake itself.

**Delivered:**
- Added Apple-native local notification support around the existing timed keep-awake lifecycle, including one session-scoped pre-expiry reminder for eligible durations.
- Added one truthful end-of-session reminder that only fires after the keep-awake session has actually turned off.
- Reused the existing keep-awake status row so countdown truth and reminder-unavailable truth can appear together without changing the shipped menu structure.
- Closed the milestone with a `tech_debt` audit: no runtime blockers remain, but one live pre-expiry reminder proof and the Phase 24/25 Nyquist validation closure are still deferred.

<details>
<summary>Previous shipped milestone: v1.8 WOL Feedback Guardrails</summary>

**Result:** WOL feedback now feels transient and less noisy, and the saved-device add/edit form no longer exposes an actionable save button before the required fields are filled.

**Delivered:**
- Auto-cleared shared WOL success/failure feedback after about three seconds in both the WOL window and the menu-bar wake section.
- Kept the saved-device `保存设备` button disabled until trimmed name and MAC input exist, while preserving delayed validation reveal and submit-time MAC blocking.
- Closed the milestone with a passing v1.8 audit, completed human dwell confirmation, and Nyquist validation closure for both new phases.

<details>
<summary>Previous shipped milestone: v1.7 WOL Device Entry Polish</summary>

**Result:** Saved-device entry now feels quieter and more helpful: validation appears only after blur or explicit submit, first-use empty libraries start with one practical NAS target, and the v1.7 evidence chain is formally closed.

**Delivered:**
- Delayed saved-device name and MAC validation hints until blur or explicit submit while preserving save-time invalid-draft blocking.
- Seeded exactly one canonical first-use device, `UGREEN NAS` / `6C:1F:F7:75:C7:0E`, only when the saved-device payload is truly absent.
- Closed the milestone evidence gap with formal Phase 19/20 verification artifacts, stabilized audit-grade UI seams, and a passing v1.7 milestone audit.

<details>
<summary>Previous shipped milestone: v1.6 Distribution Hardening</summary>

**Result:** `Tools Cat` now ships with a deterministic friend-share DMG flow, truthful first-launch guidance for non-notarized installs, and a repeatable verification command that rechecks the shipped artifact plus focused WOL/keep-awake regressions.

**Delivered:**
- Kept `release.sh` as one canonical release command that builds a local Release app and packages `dist/Tools-Cat.dmg`.
- Updated maintainer and friend-facing docs around the real manual-open boundary: drag to `/Applications`, `右键打开`, then remove quarantine only if Gatekeeper still blocks launch.
- Added `bash scripts/release/verify-distribution-closure.sh` so the repo can verify the mounted DMG layout and rerun the focused regression slice after each release build.

<details>
<summary>Previous shipped milestone: v1.5 Device Library UI Parity</summary>

**Result:** The `设备库` manager now reads like the shipped `常亮时长` manager: native list-first browsing, compact retained add/edit sheets, semantic edit/delete actions, and preserved saved-device truth.

**Delivered:**
- Replaced the normal populated device-library stack with a native SwiftUI `List` while preserving reorder mode and the dedicated management shell.
- Moved add/edit presentation onto a retained shared sheet so the list context stays visible during management flows.
- Matched the duration manager's semantic affordances by tinting `编辑` with the app accent color and keeping `删除` destructive, then reran the focused regression slice cleanly.

<details>
<summary>Previous shipped milestone: v1.4 Duration UI Polish</summary>

**Result:** The `常亮时长` manager now reads as a native macOS list, the row actions communicate edit versus delete intent immediately, and the shipped CRUD and keep-awake menu truth remain intact.

**Delivered:**
- Replaced the custom populated timed-duration stack with a native SwiftUI `List` while preserving the manager shell and accessibility seams.
- Styled `编辑` with the app accent color and kept `删除` destructive so the row actions are semantically obvious without adding decorative chrome.
- Stabilized the direct-launch duration-manager smoke and reran the full Phase 14 regression slice cleanly.

<details>
<summary>Previous shipped milestone: v1.3 Duration Management</summary>

**Result:** The app now treats timed keep-awake durations as managed user data instead of fixed presets, and the shipped native management flow keeps the root menu truthful without reopening the broader wake surface.

**Delivered:**
- Persist and validate managed durations with exact-once default seeding.
- Ship a dedicated native duration-management window with add, edit, delete, and confirmation flows.
- Keep `无限常亮` fixed first while timed keep-awake rows stay live-synchronized and sorted shortest-to-longest in the root menu.
- Restore macOS 14 deployment-target truth and keep the real 14.8.3 launch check as an explicit manual verification boundary.

<details>
<summary>Previous shipped milestone: v1.2 Menu Truth</summary>

The shipped baseline now keeps the keep-awake action group truthful in idle and active states, and the evidence chain for that behavior is fully closed from implementation through milestone audit.

It delivered:
- Hide `关闭常亮` whenever keep-awake is already off and no stop transition is running
- Preserve one direct `关闭常亮` action for active or stopping keep-awake sessions
- Lock the idle/active keep-awake truth boundary with focused controller regressions, a formal Phase 10 verification report, and closed milestone traceability

The shipped baseline became easier to trust and maintain: current-facing planning docs matched shipped behavior, verification boundaries became explicit, validation debt closed for Phases 01-04, and the live app / automation / documentation surface all aligned on `Tools Cat`.

</details>
</details>
</details>
</details>
</details>
</details>
</details>

## Requirements

### Validated

- ✓ Keep the display awake from a menu bar toggle — existing
- ✓ Send a Wake-on-LAN magic packet from a native macOS utility window — existing
- ✓ Run as a lightweight menu bar app without a main document window — existing
- ✓ Manual Wake-on-LAN entry now validates in real time with exact user-facing format errors — validated in Phase 1
- ✓ Wake results now describe local send success or failure without implying the target device woke — validated in Phase 1
- ✓ Keep-awake menu state now follows confirmed assertion outcomes instead of optimistic UI toggles — validated in Phase 1
- ✓ Save and manage multiple Wake-on-LAN devices locally without editing source code — validated in Phase 2
- ✓ Add editable device notes so devices are easy to identify at a glance — validated in Phase 2
- ✓ Remember recently used saved devices to reduce repetitive input and reopen the WOL window with the right context — validated in Phase 3
- ✓ Make Wake-on-LAN flows stable enough for daily use, including accurate status and duplicate-send protection across menu and window surfaces — validated in Phase 3
- ✓ Ship timed keep-awake with explicit duration presets, live countdown feedback, immediate replacement, and automatic expiry — validated in Phase 4
- ✓ Planning and verification docs now reflect the shipped `快速 WOL` / `发送 WOL …` wake surface without stale recents/menu-path claims — validated in Phase 6
- ✓ Menu-bar entry flows now have an explicit, durable layered regression strategy — validated in Phase 7
- ✓ Phase 01-04 validation artifacts now match actual coverage, wave-0 truth, and explicit ownership — validated in Phase 8
- ✓ Rename the shipped app, current planning docs, automation scripts, and packaging outputs to `Tools Cat` without breaking saved-device persistence or regression coverage — validated in Phase 9
- ✓ Keep-awake idle menus no longer show `关闭常亮` when there is no active session to stop — validated in Phase 10 and closed through Phase 11 verification
- ✓ Active or stopping keep-awake sessions still expose one clear `关闭常亮` action from the menu — validated in Phase 10 and closed through Phase 11 verification
- ✓ The keep-awake menu-truth contract is now locked by focused regression coverage and formal traceability — validated in Phase 10 and closed through Phase 11 verification
- ✓ User can manage timed keep-awake durations without affecting the fixed `无限常亮` action — validated in v1.3
- ✓ The keep-awake menu now renders timed rows from the managed duration list in ascending duration order — validated in v1.3
- ✓ Managed durations are validated, persisted, and reflected correctly after add/edit/delete operations — validated in v1.3
- ✓ User can scan managed keep-awake durations inside a clearly native macOS list surface instead of rows blending into the window background — validated in Phase 14
- ✓ User can distinguish edit versus delete actions immediately through semantic styling, with edit in the app theme color and delete in destructive red — validated in Phase 14
- ✓ User can use the polished list UI without regressing existing add, edit, delete, sorting, or live root-menu sync behavior — validated in Phase 14
- ✓ User sees saved WOL devices inside a clearly native macOS list surface instead of the prior custom stacked treatment — validated in Phase 15
- ✓ User can add or edit a saved WOL device through a compact in-place management presentation that keeps the device list visible — validated in Phase 15
- ✓ User sees device-library edit and delete affordances styled consistently with the duration manager's accent/destructive semantics — validated in Phase 15
- ✓ User can use the polished device-library manager without regressing saved-device add, edit, delete, reorder, or direct-launch behavior — validated in Phase 15
- ✓ Maintainer can produce a Developer ID signed `Tools Cat.app` through the archive/export release seam with explicit signing prerequisites — validated in Phase 16
- ✓ Repo docs now explain the signing identity, notary profile bootstrap, and release preflight without storing sensitive credentials — validated in Phase 16
- ✓ Friends can receive `Tools Cat` as a DMG-backed artifact together with accurate first-launch instructions, even if manual Gatekeeper approval is still required — validated in Phase 18
- ✓ The release flow now produces a deterministic local Release app and DMG without requiring Apple Developer Program credentials — validated in Phase 18
- ✓ Distribution hardening did not change the shipped wake or keep-awake product behavior — validated in Phase 18
- ✓ Saved-device name validation now appears only after the field loses focus or is explicitly submitted — validated in Phase 19 and closed through Phase 21 verification
- ✓ Saved-device MAC validation now appears only after the field loses focus or is explicitly submitted — validated in Phase 19 and closed through Phase 21 verification
- ✓ Save still blocks invalid saved-device drafts even when inline validation reveal is deferred — validated in Phase 19 and closed through Phase 21 verification
- ✓ First-use empty saved-device libraries now seed exactly one default `UGREEN NAS` device with MAC `6C:1F:F7:75:C7:0E` — validated in Phase 20 and closed through Phase 21 verification
- ✓ Existing non-empty saved-device libraries are never modified by the default-device seed path — validated in Phase 20 and closed through Phase 21 verification
- ✓ WOL send result in the WOL window now auto-clears after three seconds — validated in Phase 22
- ✓ WOL send result in the menu-bar wake section now auto-clears after three seconds — validated in Phase 22
- ✓ Timed keep-awake can request local-notification authorization from app launch through one shared reminder scheduler seam — validated in Phase 24 with remaining macOS prompt acceptance kept as human verification debt
- ✓ Timed keep-awake sends one local notification about `2 分钟` before expiry when the remaining duration allows it — validated in Phase 24 through focused regression coverage with remaining desktop-delivery proof kept as human verification debt
- ✓ Reminder delivery stays truthful for pre-expiry scheduling: stale notifications are canceled on replacement, stop, or switch-away transitions — validated in Phase 24
- ✓ Timed keep-awake sends one local notification when the session actually ends — validated in Phase 25
- ✓ If local notification permission is unavailable, timed keep-awake still works and the app surfaces a truthful reminder-unavailable state instead of implying reminders will arrive — validated in Phase 25

### Active

- [ ] User can access a short recent-devices list for faster repeat wake actions
- [ ] User can create a one-off timed keep-awake duration without saving it into the managed list
- [ ] User can assign custom labels or notes to managed keep-awake durations
- [ ] User can configure whether pre-expiry reminders are enabled
- [ ] User can configure the reminder lead time instead of using the fixed `2 分钟` rule
- [ ] User can review reminder history or notification-delivery troubleshooting inside the app

### Out of Scope

- Cross-platform support — this tool is intentionally optimized for personal macOS use
- Cloud sync, accounts, or shared device management — unnecessary complexity for a self-use utility
- Broad marketplace-style device discovery or fleet management — the goal is quick access to a small personal set of devices
- Restoring root-level recent-device wake shortcuts outside the shipped `快速 WOL` / `发送 WOL …` structure during the completed hardening cycle — intentionally left out of the shipped hardening work
- Reopening shipped duration data-model or wake-menu truth without a dedicated future milestone — those contracts already shipped and should stay closed by default
- Pulling in a third-party component library before exhausting the native macOS list/table components — native consistency and lower maintenance take priority
- Public-distribution polish as the primary milestone — signing/notarization matters later, but current scope is daily-use quality first
- Injecting the default `UGREEN NAS` seed into existing non-empty device libraries — the shipped v1.7 scope only improved first-use empty-library onboarding
- Rewriting MAC/name validation rules or weakening save-time blocking — the shipped v1.7 scope changed validation reveal timing, not device-truth rules
- Expanding reminder delivery into WOL or non-keep-awake notifications — v1.9 only covers timed keep-awake reminders
- Adding notification preferences UI or configurable reminder lead times during v1.9 — fixed `2 分钟` plus expiry reminders are enough for this pass
- Blocking timed keep-awake when notification permission is denied — keep-awake utility must remain usable even when reminders are unavailable
- Reopening user-managed duration CRUD or one-off unsaved duration entry during v1.9 — this milestone only adds reminder behavior to existing timed sessions

## Context

This is a brownfield macOS app with an existing codebase map under `.planning/codebase/`. The current app already ships two core capabilities: display-sleep prevention through `PowerAssertionManager` and WOL packet sending through `WOLSender`, exposed via an AppKit status bar menu and a SwiftUI-hosted WOL window.

The implementation remains optimized for one person's usage and shows that in several ways: WOL preset data started as hardcoded UI data, window lifecycle is coordinated with notifications, and core system interactions are only lightly abstracted. The recent milestones moved the project from functional-but-fragile to a more trustworthy daily baseline without changing its intentionally local, native, personal-use scope.

Phase 1 completed the trust layer for manual WOL entry and keep-awake status: validation and send feedback now come from explicit contracts, the WOL window keeps an app-session state owner, and keep-awake visuals wait for confirmed power-assertion outcomes.

Phase 2 added a local saved-device library with native CRUD, notes, ordering, and a dedicated management window. Phase 3 turned that library into the fast daily wake path: the shipped menu keeps saved-device wake actions under `快速 WOL`, keeps the dedicated `发送 WOL …` row for manual or window-driven sends, shares one retained session across the menu and WOL window, keeps the last truthful local result visible, and restores the last-used saved-device context when reopening the WOL window without stealing unfinished manual drafts.

Phase 4 completed timed keep-awake as a first-class menu feature: the root menu now offers explicit Chinese preset rows, one shared keep-awake session drives icon/status truth, countdown feedback stays confined to the disabled status row, and timed sessions can be replaced or expire back to off without extra banners.

The v1.0 roadmap work is archived. A follow-on idea to restore root-level recent-device wake shortcuts was intentionally removed from the hardening cycle, so the shipped wake surface remains `快速 WOL` plus the dedicated `发送 WOL …` row.

The v1.1 hardening work made the verification boundary explicit instead of implying stronger automation than the repo has. Controller tests cover menu grouping and root entry dispatch, direct-launch UI smoke covers the retained `WOL 发送器` and `设备库` windows through launch arguments, and manual tray-entry checks still own the real live `NSStatusItem` click path.

The v1.2 milestone kept scope intentionally narrow: it fixed a keep-awake truth leak inside the already-shipped menu contract, where the idle menu still showed `关闭常亮` even though there was nothing to stop.

The v1.3 milestone then converted timed keep-awake from fixed presets into managed persisted data. Phase 12 established the canonical duration store and fixed-row bridge, Phase 12.1 restored the real macOS 14 compatibility baseline, and Phase 13 shipped the native duration-management flow plus live root-menu synchronization and final visual polish.

The v1.4 milestone is intentionally narrower again: it does not reopen duration persistence or keep-awake behavior. It only revisits the `常亮时长` manager presentation so the timed list can lean harder on native list semantics and clearer edit/delete affordances.

The v1.5 milestone then brought the `设备库` manager up to that same native-management bar: device browsing now uses a real list surface, add/edit stays in a retained shared sheet, row actions communicate edit versus delete semantics immediately, and the existing saved-device CRUD, reorder, and direct-launch flows stayed truthful.

The v1.6 milestone is now shipped and archived. It stayed intentionally operational rather than product-facing: the app already worked for daily use, but the release chain still needed a deterministic friend-share artifact and truthful install guidance. On 2026-04-17, the milestone pivoted away from Developer ID/notarization because the maintainer chose not to join Apple Developer Program. The shipped outcome is now a non-notarized DMG plus explicit first-launch instructions and repeatable release verification, not a fully Gatekeeper-approved release chain.

The v1.7 milestone is now shipped and archived. It kept the current validation rules and wake/menu contract intact, but changed when saved-device validation feedback appears and how a truly first-use empty library is seeded. The shipped outcome is quieter add/edit feedback, preserved invalid-save truth, one exact-once `UGREEN NAS` seed for fresh libraries, and a fully closed verification chain for those behaviors.

The v1.8 milestone is intentionally narrower still. It does not introduce new WOL capabilities or reopen the validation contract from v1.7. It only makes wake-result feedback transient again and aligns the saved-device form's save-button affordance with the existing keep-awake duration form pattern.

The v1.9 milestone is now shipped and archived. Timed keep-awake no longer ends silently: Apple-native local notifications now cover pre-expiry and actual expiry, the existing status row can surface unavailable reminder truth, and the milestone accepted only process debt rather than runtime blockers.

Phase 9 completed the live rename to `Tools Cat`: the Xcode project, targets, module, bundle IDs, regression scripts, release packaging defaults, and active docs now agree on one product identity. Historical workflow-stability exception: the planning artifact directory remains `.planning/phases/09-mac-os-swiss-knife-tools-cat/`.

## Constraints

- **Platform**: macOS menu bar app — the product should stay native to the existing AppKit/SwiftUI environment
- **Use case**: Personal daily-use utility — scope should optimize for one user's repeated workflows, not multi-tenant generalization
- **UX direction**: Small, restrained, polished — UI changes should feel native macOS rather than flashy or cross-platform
- **Reliability**: Core menu state must reflect real system/network state — false success is unacceptable for keep-awake and WOL actions
- **Maintainability**: New functionality should reduce coupling, not deepen it — architecture work must create clearer seams around UI state and side effects

## Key Decisions

| Decision | Rationale | Outcome |
|----------|-----------|---------|
| Keep the project focused on personal self-use | The user wants a dependable personal utility, not a generalized product surface | Active |
| Prioritize WOL device management and reliability before distribution polish | Daily usability was the immediate bottleneck and hardening needed to follow shipped functionality | Validated in Phases 1-9 |
| Preserve a native macOS visual language | The desired UX is small, restrained, and polished rather than highly branded or flashy | Active |
| Use architecture cleanup as an enabler, not a separate rewrite | Device management and stable UI flows ship faster when system/network logic is separated from views and controllers | Validated in Phases 1-3 |
| Keep saved-device management in a dedicated native surface instead of deep menu editing | CRUD and reorder flows need more space and clearer state ownership than a compact menu can provide | Validated in Phase 2 |
| Keep shipped saved-device waking behind `快速 WOL` and preserve the dedicated `发送 WOL …` row | The current menu stays compact without presenting removed root-level recents / `所有设备` behavior as shipped truth | Validated in Phases 3-9 |
| Share one retained `WOLSessionModel` across the menu and WOL window | Wake status and duplicate-send blocking must come from one source of truth across surfaces | Validated in Phase 3 |
| Share one retained `KeepAwakeSessionModel` across app launch and render keep-awake UI from `KeepAwakePresentation` | Timed keep-awake must stay truthful across menu actions, countdown updates, replacement, and quit handling | Validated in Phase 4 |
| Keep menu-bar verification layered instead of implying live tray automation | Controller seams and direct-launch UI smoke are automated; live tray-entry coverage remains manual | Validated in Phase 7 |
| Treat validation debt closure as documentation-truth work, not new harness work | Phase 8 only needed validation contracts rewritten to match current evidence | Validated in Phase 8 |
| Keep runtime storage on `UserDefaults.standard` and treat the legacy bundle-ID suite only as a one-time migration source | Using the app bundle identifier as a custom defaults suite causes macOS warnings and breaks the intended storage model | Validated in Phase 9 |
| Pass `-project "Tools Cat.xcodeproj"` through release automation | Rename residue can temporarily leave multiple project directories in the worktree, so the release path must be explicit | Validated in Phase 9 |
| Keep MENU traceability anchored to the phase that shipped the behavior, even when a later closure phase only fixes verification debt | Phase 11 closes documentation truth without pretending it shipped the runtime keep-awake change | Validated in Phase 11 |
| Keep timed keep-awake durations as persisted user data instead of fixed menu presets | Users need duration customization and persistence without turning the root menu into a CRUD surface | Validated in Phases 12-13 |
| Keep duration CRUD in a dedicated native management window while `无限常亮` stays outside the managed list | Timed-duration editing needs validation, list clarity, and confirmation flows that do not fit a compact root menu | Validated in Phase 13 |
| Pull live managed-duration root-menu sync into Phase 13 and remove standalone Phase 14 | The milestone needed shipped CRUD truth in the root menu, and verification proved the separate follow-on phase was redundant | Validated in v1.3 |
| Prefer native macOS list components and semantic button colors for duration-manager polish | This milestone is visual refinement of an existing native surface, so platform-consistent affordances beat extra UI-library complexity | Validated in Phase 14 |
| Keep device-library polish presentation-only by deriving add/edit presentation from `currentFormMode` and reusing the duration-manager's list and action semantics | The milestone only needed cross-surface parity, not a new saved-device data or routing model | Validated in Phase 15 |
| Keep v1.6 limited to release-chain hardening so installability improves without reopening shipped runtime behavior | The immediate user problem is distribution friction, not missing app capability | Validated in v1.6 |
| Pivot v1.6 away from Developer ID/notarization and toward explicit non-notarized friend sharing | The maintainer chose not to join Apple Developer Program, so the release flow must stay usable without paid Apple distribution features | Validated in v1.6 |
| Keep the existing saved-device validation rules but delay error reveal until blur or explicit submit | The current issue was premature error noise, not incorrect validation truth | Validated in v1.7 |
| Seed exactly one default `UGREEN NAS` device only when the saved-device library is first used in an empty state | This gives first-use utility without silently mutating existing personal libraries | Validated in v1.7 |
| Keep v1.8 limited to interaction guardrails instead of reopening copy or validation semantics | The user asked for smaller UI-behavior corrections, not new wake capabilities or a validator rewrite | Validated in v1.8 |
| Keep WOL result lifetime owned by one shared `WOLSessionModel` seam so both the window and menu-bar row clear together after three seconds | The user wanted transient feedback in both surfaces without divergent behavior or duplicate timers | Validated in Phase 22 |
| Rebuild `快速 WOL` from the updated device library on the next main-thread turn after device mutations | `@Published` device-change notifications can fire before synchronous menu rebuilds observe the new array, leaving the quick WOL menu stale after add/edit flows | Validated in Phase 22 follow-up |
| Keep the saved-device save affordance owned by `DeviceLibrarySessionModel.canSaveDraft` and gate only on trimmed required-field presence | The button should stop no-op submits without weakening delayed validation reveal or submit-time MAC truth | Validated in Phase 23 |
| Keep v1.9 limited to local reminders for timed keep-awake instead of adding broader notification settings or WOL notifications | The user asked for narrow pre-expiry and expiry reminders, and the milestone should stay behavior-focused | Validated in Phase 24 |
| Keep reminder scheduling, expiry delivery, and unavailable-state presentation aligned with the active `KeepAwakeSessionModel` lifecycle | Reminder truth should follow the same single-source-of-truth rules as keep-awake state itself from pre-expiry scheduling through actual session end | Validated in Phases 24-25 |

## Evolution

This document evolves at phase transitions and milestone boundaries.

**After each phase transition** (via `$gsd-transition`):
1. Requirements invalidated? → Move to Out of Scope with reason
2. Requirements validated? → Move to Validated with phase reference
3. New requirements emerged? → Add to Active
4. Decisions to log? → Add to Key Decisions
5. "What This Is" still accurate? → Update if drifted

**After each milestone** (via `$gsd-complete-milestone`):
1. Full review of all sections
2. Core Value check — still the right priority?
3. Audit Out of Scope — reasons still valid?
4. Update Context with current state

---
*Last updated: 2026-05-10 after archiving milestone v1.9*
