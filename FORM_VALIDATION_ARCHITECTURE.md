# Form Validation Architecture

This document captures findings, use cases, and improvement plans for the form validation system.

---

## Current Architecture Problems

### 1. The `forced` Flag is Misleading

The `updateValidationStatus(forced: Bool)` parameter conflates multiple concerns:

| What `forced` tries to mean | What it actually controls |
|----------------------------|---------------------------|
| "Show validation now" | Whether to display error message |
| "User explicitly requested validation" | Whether to bypass editing state checks |
| "Validate regardless of state" | Different things in different subclasses |

**The real intent**: We want to distinguish between:
- **Explicit validation**: User tapped Pay button → validate and show errors
- **Implicit validation**: User is typing or left field → maybe validate, maybe not

**The problem**: `forced` is a boolean that tries to encode a policy decision inside the validation logic itself. This couples "when to validate" with "how to validate".

### 2. State Scattered Across Layers

| Location | State Variable | Purpose |
|----------|---------------|---------|
| `FormValueItemView` | `isEditing` | Is the field being edited |
| `FormTextItemView` | `isShowingValidationError` | Is error UI shown (border) |
| `FormValidatableValueItemView` | (none - implicit in footer visibility) | Is error message shown |
| `FormCardNumberItem` | `isActive` | Observable for external consumers |

**Problem**: No single source of truth. Views manage their own state, leading to inconsistencies.

### 3. Observer Cascade Creates Race Conditions

```
User types "4" in card number
    ↓
value changes → observer fires → updateValidationStatus()
    ↓
brand detected → observer fires → updateValidationStatus(forced: true) [BUG!]
    ↓
Both compete, order-dependent behavior
```

### 4. Placeholder/Error Footer Sharing

The `footerLabel` serves dual purpose:
- Show hint text (placeholder) when valid
- Show error message when invalid

When `placeholder` is `nil`, `showHint()` hides the footer entirely, including any error that should be shown.

---

## Use Cases (Given-When-Then)

### UC1: Basic Text Field - Error on Explicit Validation

```
GIVEN a text field with no placeholder (e.g., BLIK code input)
  AND the field contains invalid input
  AND no validation error is currently shown
WHEN the user taps the Pay button (explicit validation)
THEN the validation error message should appear below the field
  AND the field border should turn red
  AND the error accessory icon should appear
```

### UC2: Basic Text Field - Error Cleared on Focus

```
GIVEN a text field showing a validation error
WHEN the user taps into the field (gains focus)
THEN the validation error message should disappear immediately
  AND the field border should return to active color
  AND the error accessory icon should be removed
  AND this happens BEFORE the user types anything
```

### UC3: Basic Text Field - Error on Focus Loss

```
GIVEN a text field with invalid input
  AND the user was editing the field
WHEN the user taps on another field (focus loss)
THEN the validation error message should appear
  AND the field border should turn red
  AND the error accessory icon should appear
```

### UC4: Basic Text Field - No Error While Typing

```
GIVEN a text field with allowsValidationWhileEditing = false (default)
  AND the user is actively typing
WHEN the input becomes invalid during typing
THEN NO validation error should be shown yet
  AND the field should remain in normal/active state
```


### UC5: Card Number - Brand Detection Hides Placeholder (No Error)

```
GIVEN an empty card number field
  AND the supported brand logos are shown below as placeholder
WHEN the user types "4" (triggering Visa brand detection)
THEN the Visa brand icon should appear in the accessory
  AND the supported brand logos below should DISAPPEAR (brand is now known)
  AND NO validation error should be shown (no validation trigger occurred)
  AND the footer area should be empty (not showing error, not showing placeholder)
```

**Bug Found**: Currently, when brand is detected, an error message appears. This is wrong because:
- Brand detection is NOT a validation trigger
- We're just updating the UI to reflect "we know the brand now"
- Validation should only occur on: focus loss, explicit request (Pay button)

### UC6: Card Number - Error Hides Brand Logos

```
GIVEN a card number field with supported brand logos below
  AND the field contains an invalid card number (e.g., "1234")
WHEN the user taps on another field (focus loss) - VALIDATION TRIGGER
THEN the validation error message should appear
  AND the supported brand logos should be hidden
  AND the field border should turn red
```

**Bug Found & Fixed**: Brand logos were not being hidden when validation error appeared. The `update(brands:)` method in `FormCardNumberContainerItem` was directly setting logo visibility without considering `shouldShowValidationError` state, competing with the observer-based `updateLogosVisibility()` method.

**Resolution**: Changed `update(brands:)` to call `updateLogosVisibility()` instead of directly manipulating `supportedCardLogosItem.isHidden`, ensuring consistent logic that respects error state.

### UC7: Card Number - Re-entering Field Restores Logos

```
GIVEN a card number field showing a validation error
  AND the supported brand logos are hidden
WHEN the user taps back into the card number field
THEN the validation error should clear
  AND the supported brand logos should reappear
```

### UC8: Card Number - Valid Input Hides Logos

```
GIVEN a card number field with a complete, valid card number
  AND the detected brand icon is shown in the accessory
WHEN validation completes (focus loss or explicit)
THEN the supported brand logos should be hidden (valid state)
  AND the valid checkmark accessory should appear
  AND NO error message should be shown
```

### UC9: Card Number - Partial Input While Typing (No Validation)

```
GIVEN a card number field with partial input (e.g., "4111")
  AND the user is actively typing (field has focus)
WHEN the value changes
THEN NO validation should occur
  AND NO error should appear
  AND the brand icon should update based on detection
  AND the brand logos placeholder should be hidden (brand is known)
```

### UC10: Pay Button - Validates All Fields

```
GIVEN a form with multiple fields
  AND some fields have invalid input
  AND no validation errors are currently shown
WHEN the user taps the Pay button
THEN ALL invalid fields should show their validation errors simultaneously
  AND the form should NOT submit
```

### UC11: Field with Placeholder - Error Replaces Placeholder

```
GIVEN a text field with a placeholder hint shown
  AND the field contains invalid input
WHEN validation is triggered (focus loss or explicit)
THEN the placeholder hint should be replaced with the error message
  AND the error message should be styled differently (red color)
```

### UC12: Field with Placeholder - Placeholder Restored on Valid

```
GIVEN a text field showing a validation error
  AND the field has a placeholder defined
WHEN the user corrects the input to be valid
  AND validation is triggered
THEN the error message should be replaced with the placeholder hint
```

### UC13: Animation - Footer Transitions Should Animate

```
GIVEN a text field footer (showing placeholder, error, or empty)
WHEN the footer content changes (placeholder → error, error → placeholder, show → hide)
THEN the transition should be animated smoothly
  AND the animation should match the existing form field animation style
```

**Bug Found**: Animation was removed when refactoring the footer display logic.

### UC14: Empty Field - No Error on Focus Loss

```
GIVEN an empty text field (no user input)
  AND the user taps into the field
WHEN the user taps on another field (focus loss) without entering anything
THEN NO validation error should be shown
  AND the field should remain in default state (no error border, no error accessory)
```

### UC15: Valid Input - Shows Valid State

```
GIVEN a text field with valid input
WHEN validation is triggered (focus loss or explicit)
THEN the valid checkmark accessory should appear
  AND NO error message should be shown in footer
  AND the field border should return to default color
```

---
---

## Short-Term Goal (v6)

**Objective**: Fix the immediate bugs with minimal, testable changes.

### Approach: Single Source of Truth

Introduce `shouldShowValidationError` as an observable property on the **item** (model), not the view:

```swift
// FormValidatableValueItem
@AdyenObservable(false) public var shouldShowValidationError: Bool
```

**Benefits**:
- Views observe and react (reactive pattern)
- External consumers (like card container) can also observe
- No race conditions - state change is atomic
- Easier to test - check `item.shouldShowValidationError`

### Decouple "When to Validate" from "How to Validate"

Replace the `forced` flag with explicit intent:

```swift
// Instead of: updateValidationStatus(forced: true)
// Consider:
enum ValidationTrigger {
    case valueChanged      // User typed something
    case focusLost         // User left the field
    case explicitRequest   // Pay button tapped
}

func triggerValidation(_ trigger: ValidationTrigger)
```

This makes the intent clear and allows each trigger to have its own policy.

---

## ValidationState Enum (v6)

**Objective**: Replace boolean `shouldShowValidationError` with a proper state machine enum.

### ValidationState Definition

```swift
public enum ValidationState: Equatable {
    case pristine           // Never validated, no error shown
    case valid              // Validated and valid, no error shown
    case invalid(String)    // Validated and invalid, shows error message
}
```

**Benefits**:
- Single state enum replaces multiple booleans
- Clear state machine semantics
- Easy to test state transitions
- Encapsulates error message within state
- SwiftUI-ready for future migration

### State Transitions

```
                    ┌─────────────┐
                    │   pristine  │  (initial state)
                    └─────────────┘
                          │
           ┌──────────────┼──────────────┐
           │ validation   │              │ validation
           │ passes       │              │ fails
           ▼              │              ▼
    ┌─────────────┐       │       ┌─────────────────┐
    │    valid    │       │       │ invalid("msg")  │
    └─────────────┘       │       └─────────────────┘
           │              │              │
           │   focus gain │              │ focus gain
           │   (reset)    │              │ (reset)
           └──────────────┼──────────────┘
                          ▼
                    ┌─────────────┐
                    │   pristine  │
                    └─────────────┘
```

### Computed Properties for View

```swift
extension ValidationState {
    /// Whether error UI should be displayed
    var shouldShowError: Bool {
        if case .invalid = self { return true }
        return false
    }

    /// The error message to display, if any
    var errorMessage: String? {
        if case .invalid(let message) = self { return message }
        return nil
    }
}
```

### Migration from Boolean

| Old (boolean) | New (enum) |
|---------------|------------|
| `shouldShowValidationError = false` (initial) | `.pristine` |
| `shouldShowValidationError = false` (after valid) | `.valid` |
| `shouldShowValidationError = true` | `.invalid(errorMessage)` |

### Future SwiftUI Migration (v7+)

1. **v7.0**: Add `@Published` wrapper for SwiftUI observation
2. **v7.x**: SwiftUI views observe `validationState` directly
3. **v8.0**: Remove legacy UIKit validation code

---

## Test Coverage Requirements

Before implementing any fix, we need tests covering:

1. **Unit Tests** for `FormValidatableValueItem`:
   - `shouldShowValidationError` state transitions

2. **Unit Tests** for `FormValidatableValueItemView`:
   - Footer visibility based on `shouldShowValidationError`
   - Placeholder vs error display

3. **Unit Tests** for `FormTextItemView`:
   - Validation trigger conditions
   - Border color state
   - Accessory icon state

4. **Integration Tests** for Card Component:
   - Brand logo visibility coordination
   - Full validation flow

5. **Integration Tests** for BLIK Component:
   - Error display without placeholder

---

## Files Involved

| File | Role |
|------|------|
| `FormValidatableValueItem.swift` | Model - holds validation state |
| `FormValidatableValueItemView.swift` | View - displays footer (hint/error) |
| `FormTextItem.swift` | Model - text field specific |
| `FormTextItemView.swift` | View - text field with border, accessory |
| `FormCardNumberItem.swift` | Model - card number specific |
| `FormCardNumberItemView.swift` | View - card number with brand detection |
| `FormCardNumberContainerItem.swift` | Container - coordinates number + logos |

---

## Implementation Status

### Phases 1-4: Core Architecture ✅ COMPLETE

**Summary:** Reactive validation with single source of truth.

| Component | Implementation |
|-----------|----------------|
| State | `ValidationState` enum (`.initial`, `.valid`, `.invalid(String)`) |
| Trigger | `ValidationTrigger` enum (`.focusLost`, `.explicit`) |
| Observable | `@AdyenUIObservable` always-publish for UI updates |
| Single path | `item.triggerValidation(_:)` → observer → `onValidationStateChanged()` |
| Animation | Parent stack view layout animated, crossfade for content changes |

**Test Coverage:** 30 tests in `FormTextItemViewValidationTests` (20) and `FormCardNumberValidationTests` (10) covering UC1-UC13.

**Key Files:**
- `FormValidatableValueItem.swift` - Model with `validationState`, `triggerValidation(_:)`
- `FormValidatableValueItemView.swift` - Reactive view with `onValidationStateChanged()`
- `FormTextItemView.swift` - Text field with accessory/border updates
- `UIViewHelpers.swift` - Animation with stack view layout

---

## Phase 5: Eliminate State Duplication & Remove Escape Hatches ⏳ PENDING

### Remaining Issues

| Issue | Current State | Target |
|-------|---------------|--------|
| `isEditing` duplication | Exists in both Item and View | Keep only View's property |
| `showHint()` / `showError()` | Package-level escape hatches | Remove, use reactive pattern |

### Consumers of Escape Hatches

- `FormSelectableValueItemView` — calls `showError()` / `showHint()` directly
- `FormCardSecurityCodeItemView` — calls `showHint()` when placeholder changes

### Migration Plan

1. Add `placeholder` observer to `FormValidatableValueItemView`
2. Refactor `FormSelectableValueItemView` to override `onValidationStateChanged()`
3. Refactor `FormCardSecurityCodeItemView` to rely on reactive placeholder updates
4. Remove `showHint()` and `showError()` methods
5. Remove `isEditing` from `FormValidatableValueItem`

### Phase 6: Animation Behavior Tests ✅ COMPLETE

**Tests added:** 5 animation behavior tests in `FormTextItemViewValidationTests`.

**Animation fix:** Parent `UIStackView` layout now animates alongside footer visibility changes in `UIViewHelpers.swift`, eliminating the "jump" glitch.
