# Phase 4: Timed Keep-Awake - Research

**Researched:** 2026-04-12
**Domain:** macOS menu bar keep-awake sessions with timed expiry and countdown feedback
**Confidence:** MEDIUM

<user_constraints>
## User Constraints (from CONTEXT.md)

### Locked Decisions

### 菜单结构
- **D-01:** keep-awake 控制采用主菜单直接展开的结构，而不是收进子菜单。
- **D-02:** 主菜单中的 keep-awake 动作项应作为同一组并列展示：`无限常亮`、`15 分钟`、`30 分钟`、`1 小时`、`2 小时`。
- **D-03:** 不保留旧的单一“保持屏幕常亮”切换项作为并列入口；无限模式与定时模式统一归入同一组动作项。

### 时长与切换语义
- **D-04:** 定时常亮的预设时长固定为 `15 分钟`、`30 分钟`、`1 小时`、`2 小时`。
- **D-05:** 如果当前已有定时常亮会话在运行，再次选择新的定时时长或切换到无限常亮时，应直接替换为新选择，不做二次确认。
- **D-06:** 定时常亮自然结束后，状态应直接回到关闭，而不是切回无限常亮或保留新的活动会话。

### 倒计时与状态反馈
- **D-07:** 实时倒计时只显示在 keep-awake 的状态行中，不写进动作项标题。
- **D-08:** 动作项标题应保持稳定、可扫描，不因倒计时每秒变化而频繁跳动。
- **D-09:** 定时结束后不额外保留“已结束”提示；菜单直接回到关闭状态的常规呈现。

### 与既有真实状态语义的衔接
- **D-10:** 仍然沿用 Phase 1 的真实状态原则：稳定态 UI 只能在底层 assertion 状态真正切换成功后更新。
- **D-11:** keep-awake 菜单仍应保持紧凑、原生，不引入长说明文案或新的设置型交互。

### Claude's Discretion
- 无限常亮与定时项的精确中文文案，只要保持短、直观、便于扫描。
- 状态行倒计时的具体格式，例如“还剩 28 分钟”是否在低于 1 分钟时切到秒级显示。
- 活跃 keep-awake 模式在菜单中的高亮方式，例如 checkmark、disabled 状态、或补充状态行组合。
- 定时会话的内部计时实现方式，以及它与 `PowerAssertionManager` / `KeepAwakePowerControlling` 的衔接模型。

### Deferred Ideas (OUT OF SCOPE)
None — discussion stayed within phase scope.
</user_constraints>

<phase_requirements>
## Phase Requirements

| ID | Description | Research Support |
|----|-------------|------------------|
| AWAKE-01 | User can enable keep-awake in either indefinite mode or timed mode from native menu controls | Use fixed root-menu action rows bound to one shared `KeepAwakeSessionModel`, with truthful pending/confirmed transitions and `NSMenuItem.state` for the active mode |
| AWAKE-02 | User can choose from a small set of preset keep-awake durations for timed mode | Model presets as a small enum/catalog (`15m`, `30m`, `1h`, `2h`) with stable titles and one action handler per preset |
| AWAKE-03 | User sees a live countdown while a timed keep-awake session is active | Store an absolute `endDate`, drive a cancellable repeating timer, and format the remaining interval through `DateComponentsFormatter` in the status row only |
| AWAKE-04 | Keep-awake turns off automatically when the selected timed session expires | On countdown completion, call the existing power-controller disable path and only return the UI to `off` after `.success(false)` or `.unchanged(false)` |
</phase_requirements>

## Summary

The current implementation is still a Phase 1 boolean toggle owned directly by [`Mac OS Swiss Knife/StatusBarController.swift`](/Users/hailinpan/Documents/GitHub/Mac%20OS%20Swiss%20Knife/Mac%20OS%20Swiss%20Knife/StatusBarController.swift#L4), backed by the truthful IOKit seam in [`Mac OS Swiss Knife/PowerAssertionManager.swift`](/Users/hailinpan/Documents/GitHub/Mac%20OS%20Swiss%20Knife/Mac%20OS%20Swiss%20Knife/PowerAssertionManager.swift#L4). That seam is worth keeping. Apple’s power-management docs still support the same assertion/release model, and the repo already enforces the right rule: steady-state UI changes only after the underlying assertion call completes.

The best Phase 4 shape is a shared `KeepAwakeSessionModel` retained by [`Mac OS Swiss Knife/AppDelegate.swift`](/Users/hailinpan/Documents/GitHub/Mac%20OS%20Swiss%20Knife/Mac%20OS%20Swiss%20Knife/AppDelegate.swift#L4), mirroring the existing `WOLSessionModel` pattern in [`Mac OS Swiss Knife/WOLSessionModel.swift`](/Users/hailinpan/Documents/GitHub/Mac%20OS%20Swiss%20Knife/Mac%20OS%20Swiss%20Knife/WOLSessionModel.swift#L21). The session model should own confirmed mode, pending action, error/status copy, selected timed preset, and a cancellable countdown scheduler. `StatusBarController` should become a thin AppKit binding layer that renders fixed menu rows and a separate status row from one presentation object.

For the countdown itself, do not treat “seconds remaining” as the source of truth. Store an absolute `endDate`, derive remaining time from `Date()` on each tick, and cancel/recreate exactly one repeating timer whenever the session changes. That matches Apple’s timer guidance, avoids drift when replacing presets, and makes AWAKE-04 truthful because expiry still goes through the existing disable callback before the UI claims the app is off.

**Primary recommendation:** Keep `PowerAssertionManager` unchanged, add one shared timed-session model above it, and drive countdown UI from `endDate + DateComponentsFormatter + one cancellable repeating timer`.

## Project Constraints (from CLAUDE.md)

- Keep the app inside the existing native AppKit/SwiftUI shell; do not plan a shell rewrite for this phase.
- Optimize for a personal daily-use utility, not a generalized automation or multi-user system.
- Keep the UX small, restrained, and native macOS; avoid flashy or over-explanatory menu interactions.
- Menu state must reflect real local state; false success is unacceptable for keep-awake behavior.
- New functionality should reduce coupling and create clearer seams instead of deepening controller ownership.
- Follow repo conventions: one main type per file, small focused functions, Chinese runtime copy with English API/type names, and Xcode-style formatting.
- Nyquist validation is enabled in `.planning/config.json`, so planning must include automated and manual validation coverage.
- Work should stay inside the GSD workflow; downstream implementation should route through `/gsd:execute-phase`, not direct ad hoc edits.

## Standard Stack

### Core
| Library | Version | Purpose | Why Standard |
|---------|---------|---------|--------------|
| AppKit (`NSStatusItem`, `NSMenu`, `NSMenuItem`) | macOS SDK 26.2 via Xcode 26.2 | Root menu structure, fixed action rows, status row, checkmarks | The app already uses AppKit for menu ownership, and Apple documents `NSMenuItem.state`, `isEnabled`, and `isHidden` as the native way to express active/disabled menu state |
| Foundation (`Date`, `Calendar`, `Timer`) | macOS SDK 26.2 via Xcode 26.2 | Session end date, remaining-time calculations, repeating countdown tick | Apple’s timer APIs are the standard mechanism for repeating UI-facing updates when you actually need a timer |
| Foundation (`DateComponentsFormatter`) | macOS SDK 26.2 via Xcode 26.2 | Localized “remaining time” strings for the status row | Apple positions it as the formatter for quantities of time and exposes `allowedUnits`, `maximumUnitCount`, and time-remaining phrasing support |
| IOKit Power Management | macOS SDK 26.2 via Xcode 26.2 | Truthful display-sleep assertion ownership | The repo already wraps this seam cleanly; Apple’s docs and QA still describe the same assertion/release lifecycle |
| XCTest | Xcode 26.2 | Timed-session state and presentation regression tests | Existing keep-awake tests already use injected fakes and are the right Phase 4 extension point |

### Supporting
| Library | Version | Purpose | When to Use |
|---------|---------|---------|-------------|
| Combine | macOS SDK 26.2 via Xcode 26.2 | Publish session changes from a shared model into `StatusBarController` | Follow the same observation pattern already used for `WOLSessionModel` |
| DispatchQueue | macOS SDK 26.2 via Xcode 26.2 | Keep the IOKit enable/disable call off the main thread | Reuse the existing `SystemKeepAwakePowerController` contract |
| `timerfires` CLI | `/usr/bin/timerfires` on this machine | Diagnose unexpected timer wakeups during manual verification | Use only if countdown behavior or idle wakeups look suspicious in a live build |

### Alternatives Considered
| Instead of | Could Use | Tradeoff |
|------------|-----------|----------|
| `Timer` on the main run loop | `DispatchSourceTimer` | Viable if you want queue-owned scheduling, but it adds more cancellation and queue-hopping complexity for a simple menu countdown |
| `DateComponentsFormatter` | `RelativeDateTimeFormatter` | Apple says relative-date strings are intended as standalone strings; they are awkward if you want custom embedded copy like `还剩 …` |
| Shared `KeepAwakeSessionModel` | Keep all timed logic inside `StatusBarController` | Faster to start, but it repeats the coupling Phase 1 and Phase 3 already moved away from and makes expiry/test logic harder to prove |

**Installation:**
```bash
# No third-party packages are needed for this phase.
xcodebuild -version
swift --version
```

**Version verification:** `xcodebuild -version` reported `Xcode 26.2 (17C52)` and `swift --version` reported `Apple Swift 6.2.3`. The repo still targets `SWIFT_VERSION = 5.0` and `MACOSX_DEPLOYMENT_TARGET = 15.6` in the Xcode project metadata surfaced through `CLAUDE.md`. `npm view` is not applicable because this phase uses only system frameworks.

## Architecture Patterns

### Recommended Project Structure
```text
Mac OS Swiss Knife/
├── KeepAwakeSessionModel.swift        # Shared confirmed/pending keep-awake session state
├── KeepAwakeDurationPreset.swift      # Preset catalog and stable menu labels
├── KeepAwakeCountdownScheduler.swift  # Small protocol + Timer-backed implementation
├── KeepAwakePresentation.swift        # Menu-row titles, checkmarks, status-row copy
├── StatusBarController.swift          # Fixed AppKit menu wiring only
└── AppDelegate.swift                  # Retains one shared keep-awake session

Mac OS Swiss KnifeTests/
├── KeepAwakeSessionModelTests.swift   # Timed start/replace/expire/failure coverage
└── KeepAwakeMenuStateTests.swift      # Presentation and menu binding regressions
```

### Pattern 1: Lifecycle-Owned Keep-Awake Session
**What:** Move timed keep-awake state out of `StatusBarController` and into one shared observable model retained for the app lifecycle.

**When to use:** Immediately. Phase 4 introduces replaceable sessions, timed expiry, and countdown state; those are session concerns, not menu-item concerns.

**Example:**
```swift
@MainActor
final class KeepAwakeSessionModel: ObservableObject {
    @Published private(set) var confirmedMode: KeepAwakeMode = .off
    @Published private(set) var pendingAction: KeepAwakePendingAction?
    @Published private(set) var message: String?

    private let powerController: KeepAwakePowerControlling
    private let scheduler: KeepAwakeCountdownScheduling
    private var countdownToken: KeepAwakeCountdownToken?
}
```
// Source: existing session-model pattern in `/Users/hailinpan/Documents/GitHub/Mac OS Swiss Knife/Mac OS Swiss Knife/WOLSessionModel.swift` plus Apple Timer docs at https://developer.apple.com/documentation/foundation/timer/2091887-init

### Pattern 2: End-Date-Driven Countdown
**What:** Store `endDate` and derive `remaining` from the current time on each tick instead of decrementing a mutable counter.

**When to use:** For every timed preset and replacement flow.

**Example:**
```swift
let endDate = Date().addingTimeInterval(preset.duration)

countdownToken = scheduler.startRepeating(
    interval: 1,
    tolerance: 0.1
) { [weak self] in
    self?.refreshCountdown(now: Date())
}
```
// Source: Apple timer guidance at https://developer.apple.com/library/archive/documentation/Performance/Conceptual/power_efficiency_guidelines_osx/Timers.html and `Calendar` date/time APIs at https://developer.apple.com/documentation/foundation/calendar/date%28byadding%3Ato%3Awrappingcomponents%3A%29

### Pattern 3: Truthful Replacement Without Assertion Churn
**What:** Replacing timed ↔ timed or timed ↔ indefinite should still call `setKeepAwakeEnabled(true)`, but accept `.unchanged(true)` as a valid outcome and then only swap session metadata/timer.

**When to use:** Whenever keep-awake is already on and the user selects another active-mode row.

**Example:**
```swift
powerController.setKeepAwakeEnabled(true) { [weak self] outcome in
    guard let self else { return }

    switch outcome {
    case .success(true), .unchanged(true):
        self.confirmedMode = requestedMode
        self.startCountdownIfNeeded(for: requestedMode)
    case .failure(let current, let message):
        self.restoreConfirmedState(currentEnabled: current, message: message)
    default:
        break
    }
}
```
// Source: existing outcome contract in `/Users/hailinpan/Documents/GitHub/Mac OS Swiss Knife/Mac OS Swiss Knife/PowerAssertionManager.swift`

### Pattern 4: Presentation-Only Menu Controller
**What:** Keep the root keep-awake action titles fixed and let the status row carry countdown, pending, or failure text.

**When to use:** For every Phase 4 menu update.

**Example:**
```swift
indefiniteItem.title = "无限常亮"
fifteenMinuteItem.title = "15 分钟"
statusItem.title = presentation.statusText ?? ""
statusItem.isHidden = presentation.statusText == nil
```
// Source: existing keep-awake status-row pattern in `/Users/hailinpan/Documents/GitHub/Mac OS Swiss Knife/Mac OS Swiss Knife/StatusBarController.swift`

### Anti-Patterns to Avoid
- **Countdown in action titles:** It violates locked decisions D-07 and D-08 and causes the menu to jump visually every second.
- **Timer state owned only by `StatusBarController`:** It makes replacement, quit cleanup, and testability worse.
- **Mutable remaining-seconds counter as truth:** Replacing sessions or delayed timer fires will drift or go negative.
- **Optimistic “off” on expiry:** It breaks the truthful-state guarantee from Phase 1 if the disable call fails.

## Don't Hand-Roll

| Problem | Don't Build | Use Instead | Why |
|---------|-------------|-------------|-----|
| Remaining-time copy | Custom hour/minute/second string concatenation | `DateComponentsFormatter` | Apple already handles localized unit formatting, maximum unit count, and time-remaining phrasing |
| Active menu highlight | Custom glyphs or attributed-title hacks | `NSMenuItem.state` and the menu state column | Native AppKit already gives you the standard checkmark semantics |
| Timed power control | A second low-level IOKit path just for timed mode | Existing `KeepAwakePowerControlling` / `PowerAssertionManager` seam | One side-effect boundary preserves Phase 1 truth semantics and existing tests |
| Countdown truth | A decrementing integer that pretends to be elapsed time | `endDate` plus `Date()` / `Calendar` calculations | Timers are approximate; deriving from real time avoids drift and replace-session bugs |

**Key insight:** Phase 4 is not a new power-management feature. It is a new session layer on top of the existing assertion seam.

## Common Pitfalls

### Pitfall 1: Claiming Expiry Before Disable Finishes
**What goes wrong:** The countdown reaches zero, the UI flips to off immediately, but the assertion release fails or is still in flight.

**Why it happens:** It is tempting to treat the timer callback as the truth boundary instead of the power-controller completion.

**How to avoid:** Model expiry as a pending action, call `setKeepAwakeEnabled(false)`, and only set confirmed mode to `.off` after `.success(false)` or `.unchanged(false)`.

**Warning signs:** A test can make the fake power controller fail disable after timeout and the menu still shows off.

### Pitfall 2: Counter Drift During Replacement
**What goes wrong:** Selecting `30 分钟` after `15 分钟` yields the wrong remaining time, negative countdown values, or two active timers.

**Why it happens:** The code mutates “seconds left” instead of recalculating from a new absolute end date and cancelling the old scheduler.

**How to avoid:** Treat every new preset selection as “cancel old token, compute new end date, start one new timer.”

**Warning signs:** Replacement tests need `Task.sleep` to “settle” timing instead of asserting a deterministic state transition.

### Pitfall 3: Orphaned Repeating Timers
**What goes wrong:** Countdown callbacks continue after the session changed, after the app quit path started, or after the assertion is already off.

**Why it happens:** The timer is created ad hoc and never invalidated on replacement, manual stop, or deinit.

**How to avoid:** Wrap scheduling behind a tiny token protocol and cancel it in every transition that ends or replaces a timed session.

**Warning signs:** Status-row copy continues to change after switching to indefinite or off.

### Pitfall 4: Regressing Discoverable Stop Control
**What goes wrong:** The phase removes the old toggle row but forgets to leave an obvious manual way to stop keep-awake early.

**Why it happens:** The locked action group specifies the preset rows, but it does not explicitly resolve the manual-off affordance.

**How to avoid:** Resolve the stop interaction in planning before implementation starts; do not ship Phase 4 with only auto-expiry as the path back to off.

**Warning signs:** A planner or reviewer cannot answer “How does the user stop a two-hour session after ten minutes?” in one sentence.

## Code Examples

Verified patterns from official sources:

### Start Or Replace a Timed Session
```swift
@MainActor
func startTimedSession(_ preset: KeepAwakeDurationPreset) {
    pendingAction = .starting(preset)
    message = nil

    powerController.setKeepAwakeEnabled(true) { [weak self] outcome in
        guard let self else { return }

        switch outcome {
        case .success(true), .unchanged(true):
            let endDate = Date().addingTimeInterval(preset.duration)
            self.confirmedMode = .timed(preset: preset, endDate: endDate)
            self.pendingAction = nil
            self.installCountdown(until: endDate)
        case .failure(let current, let message):
            self.restoreConfirmedMode(currentEnabled: current, message: message)
        default:
            break
        }
    }
}
```
// Source: Apple timer API and existing power outcome contract
// https://developer.apple.com/documentation/foundation/timer/2091887-init
// https://developer.apple.com/library/archive/qa/qa1340/_index.html

### Format the Status-Row Countdown
```swift
func countdownText(until endDate: Date, now: Date = Date()) -> String? {
    let remaining = max(0, endDate.timeIntervalSince(now))
    guard remaining > 0 else { return nil }

    let formatter = DateComponentsFormatter()
    formatter.allowedUnits = remaining < 60 ? [.second] : [.hour, .minute]
    formatter.maximumUnitCount = 2
    formatter.unitsStyle = .full
    formatter.zeroFormattingBehavior = .dropAll

    guard let value = formatter.string(from: remaining) else { return nil }
    return "还剩 \(value)"
}
```
// Source: `DateComponentsFormatter` docs and Apple warning that `RelativeDateTimeFormatter` output is for standalone strings
// https://developer.apple.com/documentation/foundation/datecomponentsformatter
// https://developer.apple.com/documentation/foundation/nsrelativedatetimeformatter

## State of the Art

| Old Approach | Current Approach | When Changed | Impact |
|--------------|------------------|--------------|--------|
| Single boolean keep-awake toggle state stored directly in `StatusBarController` | Shared session model with explicit `.off / .indefinite / .timed(endDate)` state | Planner target for Phase 4, validated 2026-04-12 | Countdown, replacement, and expiry logic become testable without bloating the menu controller |
| Mutable “seconds remaining” counter | Absolute `endDate` plus current-time calculation on each tick | Current Apple timer guidance validated 2026-04-12 | Timer drift stops being a correctness bug |
| Embedded relative-date formatter strings | `DateComponentsFormatter` for embeddable quantity-of-time copy | Current Foundation docs validated 2026-04-12 | Localized status-row copy stays grammatically safe for custom prefixes like `还剩` |

**Deprecated/outdated:**
- Polling or stray repeating timers that keep firing after the session ends: Apple’s energy guidance explicitly recommends invalidating or canceling repeating timers when they are no longer needed.
- Rebuilding the timed state directly in the menu controller: this repo’s newer session-model pattern already moved away from controller-owned workflow state.

## Open Questions

1. **What is the explicit manual stop affordance after the old toggle row is removed?**
   - What we know: The locked action rows are `无限常亮`, `15 分钟`, `30 分钟`, `1 小时`, `2 小时`, and the old peer toggle row must not remain.
   - What's unclear: How the user stops an active session early without relying on expiry or quit.
   - Recommendation: Resolve this in Wave 0 before task breakdown. Preserve an explicit, discoverable stop path even if it is a new compact row rather than the old toggle copy.

2. **What should the countdown format do below one minute?**
   - What we know: The exact status-line format is left to discretion, and the countdown must stay out of action titles.
   - What's unclear: Whether sub-minute feedback should say `还剩 45 秒`, `还剩 0 分 45 秒`, or stay minute-only.
   - Recommendation: Use hour+minute when `remaining >= 60`, then switch to seconds-only below one minute. It is the shortest readable menu copy.

3. **How should expiry-disable failure present while preserving truthful state?**
   - What we know: Stable UI can only reflect confirmed assertion outcomes, and natural expiry should normally return to off.
   - What's unclear: Which row remains checked if the countdown hit zero but `disable()` failed.
   - Recommendation: Keep the last confirmed active row checked, stop the countdown, and surface a failure status message until the user retries or the assertion is actually released.

## Environment Availability

| Dependency | Required By | Available | Version | Fallback |
|------------|------------|-----------|---------|----------|
| Xcode / `xcodebuild` | Build and XCTest validation | ✓ | Xcode 26.2 (17C52) | — |
| Swift toolchain | Compile Swift app/test sources | ✓ | Apple Swift 6.2.3 | — |
| `timerfires` | Optional timer wakeup diagnosis during manual verification | ✓ | `/usr/bin/timerfires` present | Activity Monitor “Idle Wake Ups” column |

**Missing dependencies with no fallback:**
- None found.

**Missing dependencies with fallback:**
- None found.

## Validation Architecture

### Test Framework
| Property | Value |
|----------|-------|
| Framework | XCTest via Xcode 26.2 |
| Config file | none — Xcode project and shared scheme only |
| Quick run command | `xcodebuild test -project 'Mac OS Swiss Knife.xcodeproj' -scheme 'Mac OS Swiss Knife' -destination 'platform=macOS' -only-testing:'Mac OS Swiss KnifeTests/KeepAwakeMenuStateTests'` |
| Full suite command | `xcodebuild test -project 'Mac OS Swiss Knife.xcodeproj' -scheme 'Mac OS Swiss Knife' -destination 'platform=macOS'` |

### Phase Requirements → Test Map
| Req ID | Behavior | Test Type | Automated Command | File Exists? |
|--------|----------|-----------|-------------------|-------------|
| AWAKE-01 | User can start indefinite or timed keep-awake from root menu controls | unit + manual smoke | `xcodebuild test -project 'Mac OS Swiss Knife.xcodeproj' -scheme 'Mac OS Swiss Knife' -destination 'platform=macOS' -only-testing:'Mac OS Swiss KnifeTests/KeepAwakeMenuStateTests' -only-testing:'Mac OS Swiss KnifeTests/KeepAwakeSessionModelTests'` | ❌ Wave 0 |
| AWAKE-02 | Preset durations render as stable native menu rows | unit | `xcodebuild test -project 'Mac OS Swiss Knife.xcodeproj' -scheme 'Mac OS Swiss Knife' -destination 'platform=macOS' -only-testing:'Mac OS Swiss KnifeTests/KeepAwakeMenuStateTests'` | ✅ |
| AWAKE-03 | Timed session shows a live status-row countdown | unit + manual smoke | `xcodebuild test -project 'Mac OS Swiss Knife.xcodeproj' -scheme 'Mac OS Swiss Knife' -destination 'platform=macOS' -only-testing:'Mac OS Swiss KnifeTests/KeepAwakeSessionModelTests' -only-testing:'Mac OS Swiss KnifeTests/KeepAwakeMenuStateTests'` | ❌ Wave 0 |
| AWAKE-04 | Timed session automatically disables keep-awake on expiry | unit + manual smoke | `xcodebuild test -project 'Mac OS Swiss Knife.xcodeproj' -scheme 'Mac OS Swiss Knife' -destination 'platform=macOS' -only-testing:'Mac OS Swiss KnifeTests/KeepAwakeSessionModelTests'` | ❌ Wave 0 |

### Sampling Rate
- **Per task commit:** Run the task-scoped `-only-testing:` command for the touched keep-awake tests.
- **Per wave merge:** Run `xcodebuild test -project 'Mac OS Swiss Knife.xcodeproj' -scheme 'Mac OS Swiss Knife' -destination 'platform=macOS'`.
- **Phase gate:** Full suite green plus one manual menu-bar smoke covering live countdown, replacement, and actual expiry.

### Wave 0 Gaps
- [ ] `Mac OS Swiss KnifeTests/KeepAwakeSessionModelTests.swift` — timed start, timed replacement, expiry disable, disable-failure retention, and timer-cancel coverage for AWAKE-01/03/04
- [ ] Expand `Mac OS Swiss KnifeTests/KeepAwakeMenuStateTests.swift` — preset row titles, active checkmarks, pending-expiry copy, and status-row countdown visibility for AWAKE-01/02/03
- [ ] Manual verification note for native menu behavior — countdown scanability and real expiry behavior still need a live AppKit smoke even after unit tests land
- [ ] Investigate local `xcodebuild` runner stability — a targeted `KeepAwakeMenuStateTests` run on 2026-04-12 built successfully but then appeared to stall before reporting test completion

## Sources

### Primary (HIGH confidence)
- https://developer.apple.com/documentation/appkit/nsmenuitem - native menu item state, enabled, hidden, and submenu behavior
- https://developer.apple.com/documentation/foundation/timer/2091887-init - repeating timer creation semantics
- https://developer.apple.com/documentation/dispatch/dispatchsourcetimer - alternative timer source with deadline/repeating/leeway scheduling
- https://developer.apple.com/documentation/foundation/datecomponentsformatter - quantity-of-time formatting for countdown copy
- https://developer.apple.com/documentation/foundation/nsrelativedatetimeformatter - standalone relative-time string guidance
- https://developer.apple.com/documentation/foundation/calendar/date%28byadding%3Ato%3Awrappingcomponents%3A%29 - deriving absolute end dates
- https://developer.apple.com/documentation/foundation/calendar/2292887-datecomponents - deriving remaining time from dates
- https://developer.apple.com/documentation/iokit/iopmlib_h/iopmassertiontypes - display-sleep assertion meaning and OS caveats
- https://developer.apple.com/library/archive/qa/qa1340/_index.html - assertion lifecycle and release behavior
- https://developer.apple.com/library/archive/documentation/Performance/Conceptual/power_efficiency_guidelines_osx/Timers.html - timer invalidation, tolerance, and `timerfires` guidance

### Secondary (MEDIUM confidence)
- Repository code and project artifacts inspected locally on 2026-04-12, especially [`Mac OS Swiss Knife/StatusBarController.swift`](/Users/hailinpan/Documents/GitHub/Mac%20OS%20Swiss%20Knife/Mac%20OS%20Swiss%20Knife/StatusBarController.swift), [`Mac OS Swiss Knife/PowerAssertionManager.swift`](/Users/hailinpan/Documents/GitHub/Mac%20OS%20Swiss%20Knife/Mac%20OS%20Swiss%20Knife/PowerAssertionManager.swift), [`Mac OS Swiss Knife/WOLSessionModel.swift`](/Users/hailinpan/Documents/GitHub/Mac%20OS%20Swiss%20Knife/Mac%20OS%20Swiss%20Knife/WOLSessionModel.swift), [`Mac OS Swiss KnifeTests/KeepAwakeMenuStateTests.swift`](/Users/hailinpan/Documents/GitHub/Mac%20OS%20Swiss%20Knife/Mac%20OS%20Swiss%20KnifeTests/KeepAwakeMenuStateTests.swift), [`CLAUDE.md`](/Users/hailinpan/Documents/GitHub/Mac%20OS%20Swiss%20Knife/CLAUDE.md), and [`README.md`](/Users/hailinpan/Documents/GitHub/Mac%20OS%20Swiss%20Knife/README.md)

### Tertiary (LOW confidence)
- None.

## Metadata

**Confidence breakdown:**
- Standard stack: HIGH - Apple system APIs and local tool availability are directly verified.
- Architecture: MEDIUM - the session-model recommendation is strongly supported by repo patterns and Apple APIs, but the exact file split is still a planning choice.
- Pitfalls: MEDIUM - timer/presentation pitfalls are well supported, but the manual-off affordance remains an unresolved product detail.

**Research date:** 2026-04-12
**Valid until:** 2026-05-12
