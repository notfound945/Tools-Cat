# Phase 19: Deferred Device Form Validation - Research

**Researched:** 2026-05-06
**Domain:** macOS SwiftUI form validation timing in the saved-device manager
**Confidence:** HIGH

<user_constraints>
## User Constraints

No Phase 19 `CONTEXT.md` exists. Planning constraints below are derived from [REQUIREMENTS.md](/Users/hailinpan/Documents/GitHub/Tools-Cat/.planning/REQUIREMENTS.md:1), [ROADMAP.md](/Users/hailinpan/Documents/GitHub/Tools-Cat/.planning/ROADMAP.md:1), [PROJECT.md](/Users/hailinpan/Documents/GitHub/Tools-Cat/.planning/PROJECT.md:1), [STATE.md](/Users/hailinpan/Documents/GitHub/Tools-Cat/.planning/STATE.md:1), the user prompt, and prior Phase 15 artifacts.

### Locked Decisions
- Keep scope local to the `设备库` add/edit form. Do not expand into default-device seeding; that belongs to Phase 20.
- Keep the existing name and MAC validation rules. This phase changes when feedback appears, not what counts as valid.
- Save remains the final truth boundary. Invalid drafts must still fail to persist.
- Keep the existing native SwiftUI/AppKit stack. Do not introduce a third-party form or validation library for blur tracking.
- Preserve the dedicated `设备库` manager window, current CRUD truth, delete confirmation, reorder mode, and saved-device persistence behavior shipped earlier.

### Claude's Discretion
- Choose the minimum native macOS mechanism for deferred reveal. `@FocusState` plus explicit submit tracking is the recommended baseline.
- Decide whether reveal state should be modeled as per-field booleans or a small field enum/set, as long as name and MAC can reveal independently.
- Decide the minimum UI-test seam additions needed to make blur and submit timing deterministic enough for regression coverage.

### Deferred Ideas (OUT OF SCOPE)
- Default-device seeding
- Rewriting `ManualMACValidator`
- Weakening save-time blocking
- New device metadata, search, import/export, or broader device-library redesign
</user_constraints>

<phase_requirements>
## Phase Requirements

| ID | Description | Research Support |
|----|-------------|------------------|
| DEVS-10 | User sees the saved-device name required-field hint only after the name field loses focus or is explicitly submitted | Add field-specific reveal state and bind the name `TextField` to focus transitions instead of deriving its message directly from raw draft text |
| DEVS-11 | User sees saved-device MAC validation hints only after the MAC field loses focus or is explicitly submitted | Add independent MAC reveal state driven by focus loss and submit attempts while reusing `ManualMACValidator` unchanged |
| DEVS-12 | User still cannot save a saved-device draft with an invalid name or invalid MAC address even when inline validation reveal is deferred | Keep `saveDraft()` as the truth gate, but make save attempts reveal field errors even when the draft never blurred first |
</phase_requirements>

## Summary

Phase 19 is a small brownfield UI/state change, not a validation rewrite. The current device form already blocks invalid saves in [DeviceLibrarySessionModel.swift](/Users/hailinpan/Documents/GitHub/Tools-Cat/Tools%20Cat/DeviceLibrarySessionModel.swift:95), and the MAC rules are already stable in [ManualMACValidator.swift](/Users/hailinpan/Documents/GitHub/Tools-Cat/Tools%20Cat/ManualMACValidator.swift:35). The problem is timing: [DeviceLibraryView.swift](/Users/hailinpan/Documents/GitHub/Tools-Cat/Tools%20Cat/DeviceLibraryView.swift:156) renders `session.nameValidationMessage` and `session.macAddressValidationMessage` directly from in-progress draft text, so warnings appear while the user is still typing.

There is one non-obvious requirement implication the plan must account for: DEVS-12 means the current disabled save button behavior is no longer sufficient. Today `保存设备` is disabled when `canSaveDraft` is false in [DeviceLibraryView.swift](/Users/hailinpan/Documents/GitHub/Tools-Cat/Tools%20Cat/DeviceLibraryView.swift:194), which prevents an explicit invalid submit from happening at all. To satisfy “blur or explicit submit,” save must remain tappable while `saveDraft()` decides whether to persist and marks the relevant fields as revealed when validation fails.

The recommended architecture is to keep validation truth in `DeviceLibrarySessionModel`, keep `ManualMACValidator` unchanged, and add a small per-field reveal model plus focus tracking in the view. On macOS SwiftUI, the standard native mechanism is `@FocusState` with `.focused(...)` for field blur detection, combined with `.onSubmit` or the save action for explicit submit. Apple’s current text-field guidance also aligns with this timing: validate after users switch fields when the context allows it.

**Primary recommendation:** implement deferred reveal with `@FocusState` in the form view and per-field reveal flags in `DeviceLibrarySessionModel`, then change save from “disabled when invalid” to “always submits, never persists invalid data.”

## Project Constraints

- Keep the implementation inside the existing SwiftUI/AppKit codebase and native macOS interaction model. Source: [AGENTS.md](/Users/hailinpan/Documents/GitHub/Tools-Cat/AGENTS.md:1), [PROJECT.md](/Users/hailinpan/Documents/GitHub/Tools-Cat/.planning/PROJECT.md:1)
- Keep user-facing copy in Chinese and code identifiers in English. Source: [AGENTS.md](/Users/hailinpan/Documents/GitHub/Tools-Cat/AGENTS.md:1)
- Stay narrowly scoped to form timing and persistence truth. Do not reopen wake/menu behavior or Phase 20 seeding scope. Source: [REQUIREMENTS.md](/Users/hailinpan/Documents/GitHub/Tools-Cat/.planning/REQUIREMENTS.md:5), [ROADMAP.md](/Users/hailinpan/Documents/GitHub/Tools-Cat/.planning/ROADMAP.md:29)

## Standard Stack

### Core
| Library | Version | Purpose | Why Standard |
|---------|---------|---------|--------------|
| SwiftUI form state | Xcode 26.2 / macOS SDK 26.2 verified 2026-05-06 | `TextField`, `sheet`, field rendering, focus bindings | already owns the shipped device-library form |
| SwiftUI focus APIs | Xcode 26.2 / macOS SDK 26.2 verified 2026-05-06 | `@FocusState` and `.focused(...)` for blur tracking | native way to observe and control focus on macOS SwiftUI forms |
| XCTest | Xcode 26.2 verified 2026-05-06 | session-model truth regressions | already covers invalid save blocking and CRUD truth |
| XCUITest | Xcode 26.2 verified 2026-05-06 | direct-launch sheet and validation timing smoke | already owns the deterministic manager launch seam |

### Supporting
| Library | Version | Purpose | When to Use |
|---------|---------|---------|-------------|
| `DeviceLibrarySessionModel` | repo local | own draft truth, reveal flags, and save-time validation | always; keep validation policy out of the view |
| `ManualMACValidator` | repo local | canonical MAC validation + normalization | always; do not fork MAC rules into the view |
| `DeviceLibraryManagementPresentation` | repo local | preserve current copy and button titles | whenever new field-level messages or accessibility labels are added |

### Alternatives Considered
| Instead of | Could Use | Tradeoff |
|------------|-----------|----------|
| `@FocusState` blur tracking | AppKit `NSTextField` delegate bridge | unnecessary complexity for this phase unless SwiftUI focus proves flaky in tests |
| per-field reveal state | continue using one global `validationMessage` | cannot model independent name vs MAC reveal timing cleanly |
| submit-enabled save button | keep `保存设备` disabled when invalid | fails the explicit-submit reveal path required by DEVS-12 |

**Version verification:** `xcodebuild -version` on 2026-05-06 returned `Xcode 26.2` and `Build version 17C52`.

## Architecture Patterns

### Recommended Project Structure

This phase should stay within the existing device-library seams:

```text
Tools Cat/
├── DeviceLibraryView.swift           # field focus wiring and conditional error display
├── DeviceLibrarySessionModel.swift   # reveal-state truth and save-time submit logic
├── ManualMACValidator.swift          # unchanged canonical MAC validator
└── DeviceLibraryManagementPresentation.swift  # optional new field/accessibility copy

Tools CatTests/
└── DeviceLibrarySessionModelTests.swift

Tools CatUITests/
└── Tools_CatUITests.swift
```

### Pattern 1: Validation Truth In Session, Reveal Timing In Dedicated State
**What:** Keep `nameValidationMessage` and MAC validity as reusable truth computations, but gate their visibility behind dedicated reveal flags instead of showing them unconditionally.

**When to use:** For any brownfield form where save-time validation must stay strict while inline feedback becomes quieter.

**Example:**

```swift
enum DeviceFormField {
    case name
    case macAddress
}

@Published var revealedFields: Set<DeviceFormField> = []

var visibleNameValidationMessage: String? {
    guard revealedFields.contains(.name) else { return nil }
    return nameValidationMessage
}

var visibleMACValidationMessage: String? {
    guard revealedFields.contains(.macAddress) else { return nil }
    return macAddressValidation.userMessage
}
```

Source: existing validation seams in [DeviceLibrarySessionModel.swift](/Users/hailinpan/Documents/GitHub/Tools-Cat/Tools%20Cat/DeviceLibrarySessionModel.swift:27)

### Pattern 2: Blur Detection In View, Not In Validator
**What:** Use `@FocusState` and compare the previous focused field to the next focused field. When a field loses focus, tell the session to reveal validation for that field.

**When to use:** Native SwiftUI forms where validation should appear after blur.

**Example:**

```swift
@FocusState private var focusedField: DeviceFormField?

TextField("请输入设备名称", text: $session.draftName)
    .focused($focusedField, equals: .name)

TextField("AA:BB:CC:DD:EE:FF", text: $session.draftMACAddress)
    .focused($focusedField, equals: .macAddress)

.onChange(of: focusedField) { previous, current in
    if previous == .name && current != .name {
        session.revealValidation(for: .name)
    }
    if previous == .macAddress && current != .macAddress {
        session.revealValidation(for: .macAddress)
    }
}
```

Source: Apple SwiftUI focus APIs and current form seam in [DeviceLibraryView.swift](/Users/hailinpan/Documents/GitHub/Tools-Cat/Tools%20Cat/DeviceLibraryView.swift:151)

### Pattern 3: Save Action As Explicit Submit
**What:** Let the save button always invoke `saveDraft()`. Inside `saveDraft()`, reveal all required field errors before returning if validation fails.

**When to use:** When explicit submit must reveal errors even if fields never blurred.

**Example:**

```swift
func saveDraft() {
    revealValidation(for: .name)
    revealValidation(for: .macAddress)

    guard nameValidationMessage == nil else { return }
    guard case let .valid(normalizedMACAddress) = macAddressValidation else { return }

    // Persist as before.
}
```

Source: save-time truth seam in [DeviceLibrarySessionModel.swift](/Users/hailinpan/Documents/GitHub/Tools-Cat/Tools%20Cat/DeviceLibrarySessionModel.swift:95)

### Anti-Patterns to Avoid
- **Immediate computed-message rendering:** The current pattern in [DeviceLibraryView.swift](/Users/hailinpan/Documents/GitHub/Tools-Cat/Tools%20Cat/DeviceLibraryView.swift:156) shows errors straight from draft text and causes the premature-noise bug.
- **Single global error string as the only reveal state:** `validationMessage` is currently save-oriented and not field-specific enough for blur timing.
- **View-local validation duplication:** Recomputing MAC parsing in the view would fork truth away from `ManualMACValidator`.
- **Disabled save as the only invalid-state guard:** It prevents the explicit-submit reveal path required by DEVS-12.

## Don't Hand-Roll

| Problem | Don't Build | Use Instead | Why |
|---------|-------------|-------------|-----|
| Blur tracking | custom AppKit responder plumbing from scratch | SwiftUI `@FocusState` + `.focused(...)` | native, smaller, and already supported on macOS |
| MAC validation rules | second validator inside the form view | `ManualMACValidator` | existing tests already lock the canonical behavior |
| Persistence guard | ad hoc UI-only disable logic | `saveDraft()` as the truth boundary | persistence rules belong in the session/store path |
| UI launch harness | new custom automation entrypoint | existing `--ui-test-open-device-library` launch path | direct-launch smoke already exists and is deterministic |

**Key insight:** the tricky part here is not validation logic; it is decoupling validation truth from validation visibility.

## Common Pitfalls

### Pitfall 1: “Hide the label” Without Changing Submit Semantics
**What goes wrong:** Inline messages disappear during typing, but save stays disabled, so the user still never gets the required explicit-submit reveal path.

**Why it happens:** The current code conflates “valid enough to persist” with “allowed to press the button” through `canSaveDraft`.

**How to avoid:** Keep `saveDraft()` authoritative and allow button presses while invalid.

**Warning signs:** UI tests cannot tap `保存设备` on an invalid draft, or DEVS-12 can only be satisfied by blur.

### Pitfall 2: One Reveal Flag For The Whole Form
**What goes wrong:** Blurring name reveals MAC errors too, or vice versa.

**Why it happens:** Global “hasSubmitted” or single `validationMessage` state is too coarse.

**How to avoid:** Track reveal per field.

**Warning signs:** Editing the name field alone causes a MAC warning to appear before the user visits MAC.

### Pitfall 3: Reveal State Survives Across Add/Edit Sessions
**What goes wrong:** Opening a fresh add sheet immediately shows stale validation from the last attempt.

**Why it happens:** Reveal flags are not cleared in `beginAdd()`, `beginEdit()`, and `cancelForm()`.

**How to avoid:** Reset reveal state anywhere the draft resets.

**Warning signs:** New add flow opens with warnings visible before any interaction.

### Pitfall 4: UI Tests Assert Too Early On macOS Sheets
**What goes wrong:** Tests flake because sheet focus and controls are not yet attached when assertions run.

**Why it happens:** macOS SwiftUI sheets can take an extra loop turn before the text fields become queryable.

**How to avoid:** Reuse the current “retry click + wait for either sheet or action row” pattern already used in the direct-launch tests.

**Warning signs:** Local runs pass inconsistently on the same machine with no code changes.

## Code Examples

Verified brownfield patterns from repo seams and Apple’s current SwiftUI guidance:

### Existing Save-Time Truth Boundary
```swift
func saveDraft() {
    guard let activeFormMode = currentFormMode else { return }

    let trimmedName = draftName.trimmingCharacters(in: .whitespacesAndNewlines)
    if let nameValidationMessage {
        validationMessage = nameValidationMessage
        saveErrorMessage = nil
        return
    }

    let macValidation = macAddressValidation
    guard case let .valid(normalizedMACAddress) = macValidation else {
        validationMessage = macValidation.userMessage
        saveErrorMessage = nil
        return
    }

    // persist
}
```

Source: [DeviceLibrarySessionModel.swift](/Users/hailinpan/Documents/GitHub/Tools-Cat/Tools%20Cat/DeviceLibrarySessionModel.swift:95)

### Current Premature-Reveal Pattern To Replace
```swift
fieldGroup(title: "名称") {
    TextField("请输入设备名称", text: $session.draftName)
        .textFieldStyle(.roundedBorder)
} message: {
    session.nameValidationMessage
}
```

Source: [DeviceLibraryView.swift](/Users/hailinpan/Documents/GitHub/Tools-Cat/Tools%20Cat/DeviceLibraryView.swift:156)

### Canonical MAC Validation Reuse
```swift
var macAddressValidation: ManualMACValidation {
    ManualMACValidator.validate(draftMACAddress)
}
```

Source: [DeviceLibrarySessionModel.swift](/Users/hailinpan/Documents/GitHub/Tools-Cat/Tools%20Cat/DeviceLibrarySessionModel.swift:31)

## State of the Art

| Old Approach | Current Approach | When Changed | Impact |
|--------------|------------------|--------------|--------|
| Always derive error text directly from current input | Separate validation truth from reveal timing using focus/submit state | Current Apple SwiftUI guidance and modern form UX | quieter typing experience without weakening persistence checks |
| `TextField` editing callbacks as the main seam | `@FocusState`, `.focused(...)`, and `.onSubmit` | modern SwiftUI API direction | better fit for blur-driven validation on native SwiftUI forms |
| Disable save button to enforce validity | Let save submit and fail fast in model layer | required by DEVS-12 for explicit submit | user gets correct feedback even without leaving a field |

**Deprecated/outdated:**
- Directly binding inline validation labels to raw draft state for every keystroke is outdated for this form. It is the exact behavior this phase is correcting.

## Open Questions

1. **Should both fields reveal on save, even if only one is invalid?**
   - What we know: DEVS-12 requires invalid submit to reveal the correct feedback and refuse persistence.
   - What's unclear: whether the desired UX is “reveal all unresolved fields” or “reveal only the first failing field.”
   - Recommendation: reveal both invalid fields on submit. It is simpler, deterministic, and avoids repeated submit loops.

2. **Do we need a UI-test-only accessibility marker for visible validation text?**
   - What we know: current UI tests can open the form but do not assert validation timing.
   - What's unclear: whether querying the orange caption text by literal string is stable enough across sheet timing.
   - Recommendation: prefer existing literal-text assertions first; add one small accessibility identifier only if the UI test proves flaky.

## Environment Availability

| Dependency | Required By | Available | Version | Fallback |
|------------|------------|-----------|---------|----------|
| `xcodebuild` | unit/UI regression commands | ✓ | Xcode 26.2 / Build 17C52 | — |
| `swift` | local Swift compilation through Xcode toolchain | ✓ | installed | — |
| `xcrun` | test/build command execution | ✓ | installed | — |

**Missing dependencies with no fallback:**
- None

**Missing dependencies with fallback:**
- None

## Validation Architecture

### Test Framework
| Property | Value |
|----------|-------|
| Framework | XCTest + XCUITest via Xcode 26.2 |
| Config file | none — Xcode project targets drive test config |
| Quick run command | `xcodebuild test -project "Tools Cat.xcodeproj" -scheme "Tools Cat" -destination 'platform=macOS' -parallel-testing-enabled NO -only-testing:'Tools CatTests/DeviceLibrarySessionModelTests' -only-testing:'Tools CatUITests/Tools_CatUITests/testLaunchWithSeededDeviceLibraryShowsManagementWindow'` |
| Full suite command | `xcodebuild test -project "Tools Cat.xcodeproj" -scheme "Tools Cat" -destination 'platform=macOS' -parallel-testing-enabled NO -only-testing:'Tools CatTests/DeviceLibrarySessionModelTests' -only-testing:'Tools CatTests/MACAddressValidatorTests' -only-testing:'Tools CatUITests/Tools_CatUITests/testLaunchWithSeededDeviceLibraryShowsManagementWindow' -only-testing:'Tools CatUITests/Tools_CatUITests/testLaunchWithSeededDeviceLibraryShowsManagementListSurface' -only-testing:'Tools CatUITests/Tools_CatUITests/testLaunchWithEmptyDeviceLibraryShowsPolishedEmptyState'` |

### Phase Requirements → Test Map
| Req ID | Behavior | Test Type | Automated Command | File Exists? |
|--------|----------|-----------|-------------------|-------------|
| DEVS-10 | Name error stays hidden until blur or submit | unit + UI | `xcodebuild test ... -only-testing:'Tools CatTests/DeviceLibrarySessionModelTests' -only-testing:'Tools CatUITests/Tools_CatUITests/testDeviceLibraryNameValidationRevealsAfterBlurOrSubmit'` | ❌ Wave 0 |
| DEVS-11 | MAC error stays hidden until blur or submit | unit + UI | `xcodebuild test ... -only-testing:'Tools CatTests/DeviceLibrarySessionModelTests' -only-testing:'Tools CatUITests/Tools_CatUITests/testDeviceLibraryMACValidationRevealsAfterBlurOrSubmit'` | ❌ Wave 0 |
| DEVS-12 | Invalid save still blocked and feedback revealed | unit | `xcodebuild test ... -only-testing:'Tools CatTests/DeviceLibrarySessionModelTests/testInvalidDraftBlocksSave'` | ✅ |

### Sampling Rate
- **Per task commit:** quick run command above
- **Per wave merge:** full suite command above plus any new Phase 19 UI validation tests
- **Phase gate:** focused session + UI regression slice green before `/gsd:verify-work`

### Wave 0 Gaps
- [ ] Extend [DeviceLibrarySessionModelTests.swift](/Users/hailinpan/Documents/GitHub/Tools-Cat/Tools%20CatTests/DeviceLibrarySessionModelTests.swift:1) to cover hidden-before-reveal state, blur-driven reveal, submit-driven reveal, and reveal reset on reopen.
- [ ] Add at least one direct-launch UI test in [Tools_CatUITests.swift](/Users/hailinpan/Documents/GitHub/Tools-Cat/Tools%20CatUITests/Tools_CatUITests.swift:43) that opens the sheet, types invalid input, blurs a field, and asserts the warning appears only after blur.
- [ ] Add one direct-launch UI test that taps `保存设备` on an invalid draft and confirms the form stays open with visible validation feedback.

## Sources

### Primary (HIGH confidence)
- Repo code: [DeviceLibraryView.swift](/Users/hailinpan/Documents/GitHub/Tools-Cat/Tools%20Cat/DeviceLibraryView.swift:1) - current form rendering, error display, and disabled save behavior
- Repo code: [DeviceLibrarySessionModel.swift](/Users/hailinpan/Documents/GitHub/Tools-Cat/Tools%20Cat/DeviceLibrarySessionModel.swift:1) - canonical draft/save/delete/reorder truth
- Repo code: [ManualMACValidator.swift](/Users/hailinpan/Documents/GitHub/Tools-Cat/Tools%20Cat/ManualMACValidator.swift:1) - current MAC validation rules and normalization
- Repo tests: [DeviceLibrarySessionModelTests.swift](/Users/hailinpan/Documents/GitHub/Tools-Cat/Tools%20CatTests/DeviceLibrarySessionModelTests.swift:1) - existing invalid-save and CRUD coverage
- Repo tests: [Tools_CatUITests.swift](/Users/hailinpan/Documents/GitHub/Tools-Cat/Tools%20CatUITests/Tools_CatUITests.swift:43) - current direct-launch manager test seam

### Secondary (MEDIUM confidence)
- Apple Human Interface Guidelines text fields: https://developer.apple.com/design/human-interface-guidelines/text-fields/ - search snippet confirms context-dependent validation after switching fields is appropriate for some inputs
- Apple SwiftUI `TextField` docs: https://developer.apple.com/documentation/swiftui/textfield - search snippet confirms native use of `onSubmit(of:_:)` and `@FocusState`
- Apple SwiftUI `focused(_:)` docs: https://developer.apple.com/documentation/swiftui/view/focused%28_%3A%29 - search snippet confirms focus can be dismissed and controlled through bound state
- Apple WWDC21 “Direct and reflect focus in SwiftUI”: https://developer.apple.com/videos/play/wwdc2021/10023/ - current Apple guidance for focus-state usage across Apple platforms including macOS

### Tertiary (LOW confidence)
- None

## Metadata

**Confidence breakdown:**
- Standard stack: HIGH - the phase stays inside the current repo seams and verified local Xcode toolchain
- Architecture: HIGH - current code makes the timing bug and the required refactor seam explicit
- Pitfalls: HIGH - the main failure modes come directly from current code shape and requirement wording

**Research date:** 2026-05-06
**Valid until:** 2026-06-05
