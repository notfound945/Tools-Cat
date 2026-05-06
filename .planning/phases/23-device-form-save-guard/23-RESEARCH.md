# Phase 23: Device Form Save Guard - Research

**Researched:** 2026-05-06
**Domain:** macOS SwiftUI saved-device form affordance gating
**Confidence:** HIGH

<user_constraints>
## User Constraints (from CONTEXT.md)

### Locked Decisions
### Save-button enablement
- **D-01:** `保存设备` must stay disabled while the device name field is empty or whitespace-only.
- **D-02:** `保存设备` must stay disabled while the MAC address field is empty or whitespace-only.
- **D-03:** Once both required fields contain some input, `保存设备` becomes enabled even if deeper validation may still fail at submit time.

### Validation timing preservation
- **D-04:** Existing delayed validation-message reveal timing from v1.7 remains unchanged: validation text only appears on blur or explicit submit, not during ordinary typing.
- **D-05:** Save-time validation truth remains unchanged: tapping enabled `保存设备` with malformed data must still run the existing validation path and block invalid persistence.

### Scope and regression guardrails
- **D-06:** Do not rewrite MAC validation rules, normalization, or save error messaging.
- **D-07:** Do not reopen first-use device seeding, WOL result timing, or menu structure; this phase only changes the add/edit form affordance.
- **D-08:** Keep parity with the keep-awake duration form pattern where the primary save action is gated by required-field presence, not by broader validation-message visibility timing.

### Claude's Discretion
- Choose whether the button-enable predicate lives as a computed session-model property or another equally local session-owned seam, as long as the view remains presentation-only and save-time truth still belongs to `saveDraft()`.
- Decide the exact trimming rule reuse for "has input" checks as long as whitespace-only values keep the button disabled.

### Deferred Ideas (OUT OF SCOPE)
None — discussion stayed within phase scope.
</user_constraints>

<phase_requirements>
## Phase Requirements

| ID | Description | Research Support |
|----|-------------|------------------|
| DEVS-15 | User can tap `保存设备` only after both the saved-device name and MAC address fields contain input | Redefine `DeviceLibrarySessionModel.canSaveDraft` as a trimmed required-field-presence predicate and bind the form button to `.disabled(!session.canSaveDraft)` in `DeviceLibraryView.swift` |
| DEVS-16 | The saved-device form still uses the current delayed validation-message reveal timing and save-time validation truth after the new save-button gating is added | Leave `visible*ValidationMessage`, `revealValidation(for:)`, `revealValidationForSubmit()`, and `saveDraft()` validation branches intact; extend regressions around blur/submit timing and invalid-save blocking |
</phase_requirements>

## Summary

Phase 23 is a narrow brownfield affordance change inside the existing `DeviceLibrarySessionModel` plus `DeviceLibraryView` split. The repo already has the right architecture for this work: validation truth lives in the session model, blur timing lives in the SwiftUI view, and save-time persistence still funnels through `saveDraft()`. The change planner should target is smaller than a validator rewrite: make the device-form save button reflect required-field presence only, not full draft validity.

The most important code-level finding is that the current device form does not apply `canSaveDraft` to the button at all. `DeviceLibrarySessionModel` still computes `canSaveDraft` from full validity, but `DeviceLibraryView.swift` currently renders `保存设备` without `.disabled(...)`. By contrast, the keep-awake duration form already uses the desired pattern: the view binds the button to `.disabled(!session.canSaveDraft)` and the session owns the gating predicate. Phase 23 should reuse that pattern rather than introducing a new controller or a second validation seam.

The main regression risk is accidentally reopening Phase 19 behavior. Enabling the button once both fields are merely non-empty must not cause validation text to appear during typing, and it must not weaken `saveDraft()` as the persistence truth boundary. The plan should treat this as a two-part change: update the affordance predicate and button wiring, then prove delayed reveal plus invalid-save blocking still behave exactly as they do today.

**Primary recommendation:** keep validation truth in `DeviceLibrarySessionModel`, redefine `canSaveDraft` to mean “active form + trimmed required fields present,” apply `.disabled(!session.canSaveDraft)` to `保存设备`, and add focused unit/UI regressions for the button state without changing the existing blur/submit validation flow.

## Project Constraints (from CLAUDE.md)

- Keep the implementation in the existing native macOS AppKit/SwiftUI stack.
- Optimize for a personal daily-use utility rather than generalized abstractions.
- Keep UI changes small, restrained, polished, and native to macOS.
- Preserve reliability: UI affordance changes must not create false-success persistence behavior.
- Prefer maintainable seams that reduce coupling rather than pushing validation policy into the view.
- Follow the repo’s GSD workflow expectations for edits and execution.

## Standard Stack

### Core
| Library | Version | Purpose | Why Standard |
|---------|---------|---------|--------------|
| SwiftUI | Xcode 26.2 / macOS SDK 26.2 verified 2026-05-06 | Form controls, focus handling, button disabled state | Already owns the shipped device-library and keep-awake management forms |
| SwiftUI focus APIs (`@FocusState`, `.focused`) | Xcode 26.2 / macOS SDK 26.2 verified 2026-05-06 | Blur tracking without AppKit delegate plumbing | Apple’s current native focus-management path for SwiftUI text input |
| XCTest | Xcode 26.2 verified 2026-05-06 | Session-model truth regressions | Existing unit suite already covers device-form validation and persistence seams |
| XCUITest | Xcode 26.2 verified 2026-05-06 | Device-form affordance and validation timing smoke | Existing direct-launch seam already opens the real device-library window |

### Supporting
| Library | Version | Purpose | When to Use |
|---------|---------|---------|-------------|
| `DeviceLibrarySessionModel` | repo local | Own draft truth, required-field gating, and save-time validation | Always; keep business rules out of the view |
| `DeviceLibraryView` | repo local | Apply presentation-only disabled state and focus-driven reveal timing | Always; it already owns the form sheet and `@FocusState` |
| `KeepAwakeDurationManagementSessionModel` + view | repo local | Canonical parity example for required-field save gating | Use as the implementation reference for this phase |
| `ManualMACValidator` | repo local | Canonical MAC validation + normalization | Reuse unchanged inside `saveDraft()` and validation-message properties |

### Alternatives Considered
| Instead of | Could Use | Tradeoff |
|------------|-----------|----------|
| session-owned `canSaveDraft` predicate | view-local `trimmedName.isEmpty` checks | Duplicates truth in the view and breaks established session/view separation |
| SwiftUI `.disabled(!session.canSaveDraft)` | conditional omission or replacement of the button | Worse accessibility and diverges from the keep-awake form pattern |
| existing `@FocusState` blur handling | custom AppKit text-field delegate bridge | Unnecessary complexity for a phase that should remain presentation-local |

**Installation:** No third-party package installation is required. This phase stays within the Xcode project and Apple frameworks already present in the repo.

**Version verification:** `xcodebuild -version` on 2026-05-06 returned `Xcode 26.2` and `Build version 17C52`. `swift --version` returned `Apple Swift version 6.2.3`.

## Architecture Patterns

### Recommended Project Structure
```text
Tools Cat/
├── DeviceLibrarySessionModel.swift   # required-field predicate + existing save-time truth
├── DeviceLibraryView.swift           # save button disabled binding + unchanged focus reveal wiring
├── KeepAwakeDurationManagementView.swift
└── KeepAwakeDurationManagementSessionModel.swift

Tools CatTests/
└── DeviceLibrarySessionModelTests.swift

Tools CatUITests/
└── Tools_CatUITests.swift
```

### Pattern 1: Session-Owned Required-Field Gating
**What:** Keep `canSaveDraft` in the session model, but change its meaning from “fully valid draft” to “active form and both required fields contain non-whitespace input.”

**When to use:** Whenever the form affordance should unlock before deeper submit-time validation completes.

**Example:**
```swift
private var hasRequiredDraftInput: Bool {
    !draftName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        && !draftMACAddress.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
}

var canSaveDraft: Bool {
    currentFormMode != nil && hasRequiredDraftInput
}
```

Source: local session seam in `Tools Cat/DeviceLibrarySessionModel.swift`; parity target in `Tools Cat/KeepAwakeDurationManagementSessionModel.swift`.

### Pattern 2: View Applies Disabled State, Not Validation Policy
**What:** Keep the button visible, keep its action as `session.saveDraft()`, and attach `.disabled(!session.canSaveDraft)` in the view.

**When to use:** For a native macOS form where the action should remain discoverable but non-interactive until minimum input exists.

**Example:**
```swift
Button(DeviceLibraryManagementPresentation.saveButtonTitle) {
    session.saveDraft()
}
.buttonStyle(.borderedProminent)
.disabled(!session.canSaveDraft)
```

Source: Apple `disabled(_:)` guidance and existing parity in `Tools Cat/KeepAwakeDurationManagementView.swift`.

### Pattern 3: Preserve Blur/Submit Reveal Separation
**What:** Leave `visibleNameValidationMessage`, `visibleMACAddressValidationMessage`, `revealValidation(for:)`, and `revealValidationForSubmit()` unchanged so message timing remains driven by blur or explicit submit, not by typing.

**When to use:** Any time the affordance gate is looser than the real validator.

**Example:**
```swift
.onChange(of: focusedField) { newFocusedField in
    revealValidationIfNeeded(afterBlurFrom: lastFocusedField, to: newFocusedField)
    lastFocusedField = newFocusedField
}
```

Source: existing implementation in `Tools Cat/DeviceLibraryView.swift`.

### Anti-Patterns to Avoid
- **Using full validation for `canSaveDraft`:** This would violate D-03 by keeping malformed-but-non-empty drafts disabled.
- **Moving trimming/required logic into the view:** It forks state truth and makes edit/add behavior harder to test.
- **Revealing messages when `canSaveDraft` flips:** Button enablement and validation visibility are intentionally separate contracts.
- **Weakening `saveDraft()` after adding button gating:** The button is only an affordance guard, not the persistence truth boundary.

## Don't Hand-Roll

| Problem | Don't Build | Use Instead | Why |
|---------|-------------|-------------|-----|
| Required-field affordance gating | custom form controller or extra state machine | `DeviceLibrarySessionModel.canSaveDraft` | The repo already uses session-owned form predicates |
| Focus-loss detection | AppKit delegate bridge | `@FocusState` plus existing `revealValidationIfNeeded` | Already shipped for Phase 19 and matches current SwiftUI guidance |
| MAC parsing | second validator for button state | simple trimmed non-empty check for gating, `ManualMACValidator` for save truth | This phase must not rewrite validation rules |
| UI access to button state | new harness | existing `deviceLibrarySaveButton(in:formActions:)` helper in `Tools_CatUITests.swift` | The UI test seam already knows how to locate the button inside the sheet |

**Key insight:** the planner should treat “button enabled” and “draft valid enough to persist” as two different truths owned by the same session model.

## Common Pitfalls

### Pitfall 1: Whitespace Enables Save
**What goes wrong:** Entering only spaces in name or MAC enables `保存设备`.
**Why it happens:** The gate uses raw string emptiness instead of trimmed emptiness.
**How to avoid:** Reuse `trimmingCharacters(in: .whitespacesAndNewlines)` for both required fields.
**Warning signs:** Unit tests pass for `""` but fail for `"   "`.

### Pitfall 2: Edit Form Starts Disabled Unexpectedly
**What goes wrong:** Opening an existing device in edit mode shows a disabled save button even though valid saved values are prefilled.
**Why it happens:** The gate depends on transient reveal state or a stale cached predicate instead of current draft contents.
**How to avoid:** Keep `canSaveDraft` purely derived from `currentFormMode`, `draftName`, and `draftMACAddress`.
**Warning signs:** `beginEdit(deviceID:)` opens with filled fields but the button remains disabled.

### Pitfall 3: Validation Messages Appear While Typing
**What goes wrong:** As soon as both fields are non-empty, inline messages begin flashing during in-progress edits.
**Why it happens:** The implementation ties message visibility to `canSaveDraft` or raw validator output instead of reveal state.
**How to avoid:** Leave `visible*ValidationMessage` and focus-driven reveal untouched.
**Warning signs:** Existing Phase 19 UI tests start failing before save-button tests are added.

### Pitfall 4: Save-Time Truth Gets Softened
**What goes wrong:** Because the button is disabled less often, malformed MAC input is accidentally allowed to persist.
**Why it happens:** Someone changes `saveDraft()` to trust `canSaveDraft` and skips `ManualMACValidator`.
**How to avoid:** Keep `saveDraft()` validation branches exactly as the final persistence gate.
**Warning signs:** A malformed-but-non-empty MAC saves successfully in unit tests.

## Code Examples

Verified repo-aligned patterns:

### Required-Field Gate Without Rewriting Save Truth
```swift
var canSaveDraft: Bool {
    currentFormMode != nil
        && !draftName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        && !draftMACAddress.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
}

func saveDraft() {
    guard let activeFormMode = currentFormMode else { return }
    revealValidationForSubmit()

    if let nameValidationMessage {
        validationMessage = nameValidationMessage
        saveErrorMessage = nil
        return
    }

    guard case let .valid(normalizedMACAddress) = macAddressValidation else {
        validationMessage = macAddressValidation.userMessage
        saveErrorMessage = nil
        return
    }

    // Persist as before.
}
```

Source: `Tools Cat/DeviceLibrarySessionModel.swift`

### Existing Parity Pattern For Disabled Save Actions
```swift
Button(KeepAwakeDurationManagementPresentation.saveButtonTitle) {
    session.saveDraft()
}
.buttonStyle(.borderedProminent)
.disabled(!session.canSaveDraft)
```

Source: `Tools Cat/KeepAwakeDurationManagementView.swift`

## State of the Art

| Old Approach | Current Approach | When Changed | Impact |
|--------------|------------------|--------------|--------|
| `TextField` editing callbacks via deprecated `onEditingChanged` / `onCommit` initializer | `@FocusState` with `.focused(_:equals:)` and `.onSubmit` | Verified current Apple docs on 2026-05-06 | Matches current SwiftUI focus/submission model and avoids deprecated text-field APIs |
| Save-button validity tied to complete validator truth | Save-button affordance tied to minimum required input, with save action still validating fully | Existing repo parity in keep-awake form; required now for Phase 23 | Better form affordance without weakening persistence rules |

**Deprecated/outdated:**
- `TextField` `init(_:text:onEditingChanged:onCommit:)`: Apple now directs SwiftUI forms toward `FocusState` for editing-state behavior and `onSubmit` for commit behavior.

## Open Questions

1. **Should Phase 23 add a focused UI assertion for button enabled/disabled state in addition to unit coverage?**
   - What we know: existing UI tests already open the real device form and already have a `deviceLibrarySaveButton(in:formActions:)` helper.
   - What's unclear: whether the team wants button-state evidence only at the session layer or also at the real sheet layer.
   - Recommendation: add one narrow UI test for disabled-to-enabled transition, because DEVS-15 is an observable affordance requirement, not just a model invariant.

## Environment Availability

| Dependency | Required By | Available | Version | Fallback |
|------------|------------|-----------|---------|----------|
| Xcode / `xcodebuild` | Building and running unit/UI regressions | ✓ | Xcode 26.2 / Build 17C52 | — |
| Swift toolchain | Swift compilation and local test execution | ✓ | Apple Swift 6.2.3 | — |
| macOS GUI test host | XCUITest device-library sheet assertions | ✓ | local desktop session | Fallback to unit-only evidence if GUI automation is temporarily blocked, but phase sign-off should still include at least one UI smoke rerun |

**Missing dependencies with no fallback:**
- None found.

**Missing dependencies with fallback:**
- None found.

## Validation Architecture

### Test Framework
| Property | Value |
|----------|-------|
| Framework | XCTest + XCUITest via Xcode 26.2 |
| Config file | none — Xcode project target configuration in `Tools Cat.xcodeproj/project.pbxproj` |
| Quick run command | `xcodebuild test -project "Tools Cat.xcodeproj" -scheme "Tools Cat" -destination 'platform=macOS' -parallel-testing-enabled NO -only-testing:'Tools CatTests/DeviceLibrarySessionModelTests' -only-testing:'Tools CatUITests/Tools_CatUITests/testDeviceLibraryNameValidationRevealsAfterSubmit' -only-testing:'Tools CatUITests/Tools_CatUITests/testDeviceLibraryMACValidationRevealsAfterBlurOrSubmit'` |
| Full suite command | `xcodebuild test -project "Tools Cat.xcodeproj" -scheme "Tools Cat" -destination 'platform=macOS' -parallel-testing-enabled NO` |

### Phase Requirements → Test Map
| Req ID | Behavior | Test Type | Automated Command | File Exists? |
|--------|----------|-----------|-------------------|-------------|
| DEVS-15 | `保存设备` stays disabled until both required fields contain non-whitespace input, then enables | unit + UI smoke | `xcodebuild test -project "Tools Cat.xcodeproj" -scheme "Tools Cat" -destination 'platform=macOS' -parallel-testing-enabled NO -only-testing:'Tools CatTests/DeviceLibrarySessionModelTests' -only-testing:'Tools CatUITests/Tools_CatUITests/testDeviceLibrarySaveButtonEnablesAfterRequiredInput'` | ✅ existing files; new test methods needed |
| DEVS-16 | blur/submit validation timing and invalid-save blocking remain unchanged after gating changes | unit + UI regression | `xcodebuild test -project "Tools Cat.xcodeproj" -scheme "Tools Cat" -destination 'platform=macOS' -parallel-testing-enabled NO -only-testing:'Tools CatTests/DeviceLibrarySessionModelTests' -only-testing:'Tools CatUITests/Tools_CatUITests/testDeviceLibraryNameValidationRevealsAfterSubmit' -only-testing:'Tools CatUITests/Tools_CatUITests/testDeviceLibraryMACValidationRevealsAfterBlurOrSubmit'` | ✅ |

### Sampling Rate
- **Per task commit:** `xcodebuild test -project "Tools Cat.xcodeproj" -scheme "Tools Cat" -destination 'platform=macOS' -parallel-testing-enabled NO -only-testing:'Tools CatTests/DeviceLibrarySessionModelTests'`
- **Per wave merge:** `xcodebuild test -project "Tools Cat.xcodeproj" -scheme "Tools Cat" -destination 'platform=macOS' -parallel-testing-enabled NO -only-testing:'Tools CatTests/DeviceLibrarySessionModelTests' -only-testing:'Tools CatUITests/Tools_CatUITests/testDeviceLibrarySaveButtonEnablesAfterRequiredInput' -only-testing:'Tools CatUITests/Tools_CatUITests/testDeviceLibraryNameValidationRevealsAfterSubmit' -only-testing:'Tools CatUITests/Tools_CatUITests/testDeviceLibraryMACValidationRevealsAfterBlurOrSubmit'`
- **Phase gate:** Full suite green before `/gsd:verify-work`

### Wave 0 Gaps
- [ ] `Tools CatTests/DeviceLibrarySessionModelTests.swift` — add `canSaveDraft` coverage for blank, whitespace-only, partially filled, fully filled, and prefilled edit-form states
- [ ] `Tools CatUITests/Tools_CatUITests.swift` — add one save-button enabled/disabled transition test using the existing `deviceLibrarySaveButton(in:formActions:)` helper
- [ ] `Tools CatUITests/Tools_CatUITests.swift` — extend the new button-state UI test to prove malformed-but-non-empty MAC enables the button without bypassing existing submit-time validation

## Sources

### Primary (HIGH confidence)
- Local code: `Tools Cat/DeviceLibrarySessionModel.swift` — current `canSaveDraft`, validation-message, and `saveDraft()` behavior
- Local code: `Tools Cat/DeviceLibraryView.swift` — current form sheet, `保存设备` button wiring, and `@FocusState` blur handling
- Local code: `Tools Cat/KeepAwakeDurationManagementSessionModel.swift` and `Tools Cat/KeepAwakeDurationManagementView.swift` — parity reference for session-owned save gating plus `.disabled(!session.canSaveDraft)`
- Local tests: `Tools CatTests/DeviceLibrarySessionModelTests.swift` and `Tools CatUITests/Tools_CatUITests.swift` — current regression surface and reusable UI helpers
- Apple Developer Documentation: `focused(_:equals:)` https://developer.apple.com/documentation/swiftui/view/focused%28_%3Aequals%3A%29
- Apple Developer Documentation: `disabled(_:)` https://developer.apple.com/documentation/swiftui/view/disabled%28_%3A%29
- Apple Developer Documentation: deprecated `TextField` editing initializer guidance https://developer.apple.com/documentation/swiftui/textfield/init%28_%3Atext%3Aoneditingchanged%3Aoncommit%3A%29-6lnin

### Secondary (MEDIUM confidence)
- Apple Developer Documentation: `onSubmit(of:_:)` search result and API page path https://developer.apple.com/documentation/swiftui/view/onsubmit%28of%3A_%3A%29
- Phase 19 research and verification artifacts — prior shipped contract for delayed validation reveal

### Tertiary (LOW confidence)
- None. No unverified community sources were needed.

## Metadata

**Confidence breakdown:**
- Standard stack: HIGH - local code and current Apple docs agree on the existing SwiftUI/XCTest path
- Architecture: HIGH - the current repo already contains both the target seam and the parity reference implementation
- Pitfalls: HIGH - each risk is directly derived from shipped Phase 19 behavior or the current device-form code

**Research date:** 2026-05-06
**Valid until:** 2026-06-05
