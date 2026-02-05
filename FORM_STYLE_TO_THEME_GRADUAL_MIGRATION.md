# Form Style → Theme Gradual Migration Strategy

## Goal: Zero Compilation Breaks, Small PRs, Green CI

---

## Migration Progress

### Phase 1: Infrastructure ✅ **COMPLETE**
- ✅ FormItemViewBuilder has theme parameter (defaults to `.default`)
- ✅ FormViewController passes theme to builder
- ✅ FormViewItemManager receives builder with theme

### Phase 2: View Conversion 🔄 **IN PROGRESS** (14/24 views)
| Status | View | PR |
|--------|------|----|
| ✅ | FormPickerItemView chain (4 views) | #7 |
| ✅ | FormTextItemView (+ TextInput, PhoneNumber, CardNumber, SecurityCode) | #1 |
| ✅ | FormSeparatorItemView | #2 |
| ⚪ | FormSpacerItemView | Excluded (pure layout) |
| ✅ | FormLabelItemView | #3 |
| ✅ | FormToggleItemView | #4 |
| ✅ | FormButtonItemView | #5 |
| ✅ | FormVerticalStackItemView | #6 |
| ⏳ | SelectableFormItemView | |
| ⏳ | FormAddressItemView | |
| ⏳ | FormSplitItemView | |
| ⏳ | ~9 more views... | |

### Phase 3: Item Updates ⏳ **PENDING**
Remove `style` from items after ALL views support theme.

### Phase 4: Cleanup ⏳ **PENDING**
Remove style infrastructure, simplify view inits.

**Last Updated**: 2025-12-11

---

## Established Pattern

**Core Principle**: Views are ALWAYS theme-based. Branching logic stays ONLY in the builder.

### View Pattern
```swift
class FormExampleItemView: FormItemView<FormExampleItem> {
    package let theme: AdyenTheme

    init(item: FormExampleItem, theme: AdyenTheme) {
        self.theme = theme
        super.init(item: item)
        configure()
    }

    required convenience init(item: FormExampleItem) {
        self.init(item: item, theme: .default)
    }

    private func configure() {
        let style = theme.elements./* relevant element */
        // Apply all theme styling here
    }
}
```

### Builder Pattern
```swift
public func build(with item: FormExampleItem) -> FormItemView<FormExampleItem> {
    FormExampleItemView(item: item, theme: theme)
}
```

### Test Pattern
- Add `FormExampleItemViewThemeTests.swift` to `Tests/IntegrationTests/UIKit/Form/Theme/`
- Test custom theme colors/fonts are applied
- Test convenience init uses default theme
- Use helper methods: `makeSUT()`, `findLabel()`, etc.

### Test Helper Infrastructure

Located in `Tests/IntegrationTests/Helpers/`:

**TestTheme.swift** - Distinctive theme with expected style structs:
```swift
// Create theme with verifiable colors
configuration.theme = TestTheme.distinctive()

// Expected styles contain ALL properties to assert
TestTheme.expectedTextFieldStyle  // titleColor, titleFont, textColor, textFont, containerColor, cornerRadius
TestTheme.expectedButtonStyle     // backgroundColor, textColor, cornerRadius
```

**FormViewExtractor.swift** - Comprehensive theme assertions:
```swift
// Assert ALL text field theme properties (6 assertions per field)
sut.viewController.assertTextFieldsUseTheme(
    ["\(prefix).holderNameItem", "\(prefix).accountNumberItem"],
    style: TestTheme.expectedTextFieldStyle
)

// Assert ALL button theme properties (3 assertions)
sut.viewController.assertButtonUsesTheme(
    "\(prefix).payButtonItem",
    style: TestTheme.expectedButtonStyle
)
```

**Properties tested per text field:**
| Property | Theme Source |
|----------|--------------|
| Title color | `theme.elements.textField.title.color` |
| Title font | `theme.elements.textField.title.font` |
| Text color | `theme.elements.textField.text.color` |
| Text font | `theme.elements.textField.text.font` |
| Container color | `theme.elements.textField.containerColor` |
| Corner radius | `theme.elements.textField.cornerRadius` |

**Properties tested per button:**
| Property | Theme Source |
|----------|--------------|
| Background | `theme.elements.buttons.primary.backgroundColor` |
| Text color | `theme.elements.buttons.primary.textColor` |
| Corner radius | `theme.elements.buttons.primary.cornerRadius` |

**Benefits:**
- Explicit field list in assertion
- Comprehensive: 6 props/field + 3 props/button = 21 assertions for 3 fields
- Clear failure messages: `holderNameItem title color: expected <systemPink>`
- ~100 lines total helper code
- Consistent test patterns across components
- Descriptive failure messages
- Single source of truth for test colors

---


### Component Configuration Pattern

Theme propagation flows from `CheckoutConfiguration` → Component Configurations:

```
CheckoutConfiguration (public API)
    └── theme: AdyenTheme (set via public .theme() modifier)
            │
            ▼
CheckoutComponentBuilder (internal propagation)
    └── componentConfiguration.theme = configuration.theme
            │
            ▼
ACHDirectDebitComponent.Configuration (package access)
    └── package var theme: AdyenTheme
```

**What component configurations need:**

1. **Conform to `CheckoutComponentConfiguration` protocol:**
```swift
public struct Configuration: AnyXXXConfiguration,
                            AnyPersonalInformationConfiguration,
                            CheckoutComponentConfiguration {  // Add this
```

2. **Add required protocol properties:**
```swift
package let componentType: CheckoutComponentType = .payment(.achDirectDebit)
package var theme: AdyenTheme = .init()
package var showsSubmitButton: Bool  // Change from internal let to package var
```

**⚠️ NO public `theme()` modifier on component configurations!**
The public API exists only on `CheckoutConfiguration`. Components receive theme internally.

**Tests use `@_spi(AdyenInternal)` to access package properties directly:**
```swift
@_spi(AdyenInternal) import AdyenUI

// Direct property access for testing (bypasses CheckoutConfiguration)
configuration.theme = TestTheme.distinctive()
```

**Checklist for each component:**
- [ ] Configuration conforms to `CheckoutComponentConfiguration`
- [ ] Has `componentType` property
- [ ] Has `theme` property (package var)
- [ ] Has `showsSubmitButton` as package var
- [ ] Theme passed to FormViewController in component init
- [ ] Tests verify theme is applied correctly
## PR Checklist

1. ✅ View init requires `theme: AdyenTheme` (non-optional)
2. ✅ Theme is `package let` (accessible to subclasses)
3. ✅ Convenience `init(item:)` delegates to `init(item:, theme: .default)`
4. ✅ `configure()` method applies all theme styling
5. ✅ Builder's `build()` passes theme
6. ✅ Integration test added and passing
7. ✅ Run SwiftFormat after edits

---

## Key Lessons Learned

1. **Theme-only approach** eliminates technical debt - views already in final form
2. **Convenience init pattern** avoids code duplication
3. **Builder-level defaulting** keeps views clean (no nil checks)
4. **Integration tests > Unit tests** for UI theme verification
5. **Helper methods** (makeSUT, expect, etc.) make tests 70% more concise
6. **Always run SwiftFormat** after edits to prevent whitespace noise
7. **Don't add unused params** - FormSpacerItemView excluded (no styling needed)
8. **Global renames must preserve public API** - SubmitButton → FormButton kept public method names
9. **Old style tests need REWRITING** - views ignore `item.style`, only read `theme`. Rewrite tests to use `AdyenTheme` directly, don't try to uncomment old `FormComponentStyle` tests
10. **Container views must propagate theme** - `FormVerticalStackItemView` and similar containers must pass theme to their subitem builders, not use static methods
11. **CRITICAL: Use sed/manual edits for tests** - The edit tool reformats entire files. For test files, use `sed` commands or manual edits to avoid massive whitespace diffs. For implementation files, always run SwiftFormat after edits.
12. **Semantic testing strategy** - New tests verify theme properties are applied consistently across all relevant UI elements, not granular per-field customization. Focus on: (1) semantic colors applied to all fields, (2) button theming, (3) component structure, (4) presence of expected elements.
13. **MANDATORY: Run tests after every rewrite** - Never rewrite tests without immediately running them to verify they compile and pass. Use `xcodebuild test` with appropriate scheme and test selector. This is non-negotiable for test refactoring work.
14. **Avoid edit tool for test files entirely** - Even for single test rewrites, the edit tool causes massive formatting changes. Use manual file editing or targeted replacements only.
15. **Shared test infrastructure** - `TestTheme.swift` provides `TestTheme.distinctive()` for consistent test themes; `FormViewExtractor.swift` provides `assertTextFieldsUseTheme(_:style:)` and `assertButtonUsesTheme(_:style:)` with comprehensive property testing for cleaner assertions
16. **Expected style structs over raw values** - Use `TestTheme.expectedTextFieldStyle` and `TestTheme.expectedButtonStyle` structs instead of individual color/font values. This ensures all theme properties are tested comprehensively (6 per text field, 3 per button) and keeps test code DRY.


### Shell Commands for Test Modifications

**Why:** The `edit`/`multi_edit` tools have an internal formatter causing ~200 line diffs for 1-line changes.

**Simple text replacement:**
```bash
sed -i '' 's/oldText/newText/g' file.swift
```

**Multi-line replacement (perl):**
```bash
perl -i -0777 -pe 's/old pattern/new pattern/' file.swift
```

**Replace entire test method (head/tail approach):**
```bash
# 1. Write new test to temp file
cat > /tmp/new_test.swift << 'TESTEOF'
    func testUIConfiguration() {
        // new test content
    }
TESTEOF

# 2. Find line numbers: grep -n "func testUIConfiguration\|func nextTest" file.swift
# 3. Assemble: keep lines before, add new test, keep lines after
head -87 file.swift > /tmp/assembled.swift
cat /tmp/new_test.swift >> /tmp/assembled.swift
tail -n +169 file.swift >> /tmp/assembled.swift
mv /tmp/assembled.swift file.swift
```

**Always verify:**
```bash
git diff file.swift  # Should show only logical changes
```

---

## Implementation Log

### PR #1: FormTextItemView (2025-11-14) ✅
- **Views**: FormTextItemView, FormTextInputItemView, FormPhoneNumberItemView, FormCardNumberItemView, FormCardSecurityCodeItemView
- **Theme path**: `theme.elements.textField`
- **Test**: `FormTextItemViewThemeTests.swift`
- **Unique insight**: Established core pattern (designated init + convenience init)

### PR #2: FormSeparatorItemView (2025-11-18) ✅
- **Views**: FormSeparatorItemView (FormSpacerItemView excluded - no styling)
- **Theme path**: `theme.colors.separator`
- **Test**: `FormSeparatorItemViewThemeTests.swift`
- **Unique insight**: Don't add unused params to views with no visual styling

### PR #3: FormLabelItemView (2025-11-20) ✅
- **Views**: FormLabelItemView (renamed from ADYLabel)
- **Theme path**: `theme.elements.labels.body`
- **Test**: `FormLabelItemTests.swift`
- **Unique insight**: Safe to rename internal classes if only used in one file

### PR #4: FormToggleItemView (2025-11-24) ✅
- **Views**: FormToggleItemView
- **Theme path**: `theme.elements.switch`
- **Test**: `FormToggleItemViewThemeTests.swift`
- **Re-enabled**: `CardComponentTests.testTintColorCustomization`
- **Unique insight**: UISwitch uses `onTintColor` for theme tint

### PR #5: FormButtonItemView (2025-11-25) ✅
- **Views**: FormButtonItemView
- **Theme path**: `theme.elements.buttons.primary`
- **Test**: `FormButtonItemViewThemeTests.swift`
- **Re-enabled**: `PreselectedPaymentComponentTests.testUICustomization`
- **Refactoring**: SubmitButton → FormButton (25 files, public API preserved)
- **Unique insight**: Global renames must preserve public API names

### PR #6: FormVerticalStackItemView + Card Item Builders (2025-11-26) ✅
- **Views**: FormVerticalStackItemView (container infrastructure)
- **Builders**: FormCardNumberItem, FormCardSecurityCodeItem, FormCardExpiryDateItem, FormCardNumberContainerItem
- **Theme path**: Container propagates theme to subitems via `FormItemViewBuilder(theme: theme)`
- **Test**: `CardComponentTests.testUIConfiguration` (rewritten with semantic approach)
- **Changes**: 6 files (+123, -151 lines net cleanup)
- **Unique insights**:
  - Container views need instance `build()` method (not static) to access theme
  - Edit tool reformats entire test files - use `sed` for surgical test changes
  - Semantic testing focuses on theme consistency, not per-field granularity
  - Tests verify: (1) primary color on all fields, (2) button theme, (3) component structure
- **Strategy**: Delete old commented test (134 lines), replace with semantic version (90 lines)

### PR #7: FormPickerItemView Chain (2025-12-05) ✅
- **Views**: FormPickerItemView, FormSelectableValueItemView, FormValidatableValueItemView, FormValueItemView, BaseFormPickerItemView, FormAddressPickerItemView
- **Theme path**: `theme.elements.labels.body`, `theme.colors.textSecondary`, `theme.colors.destructive`
- **Tests**: `FormPickerItemViewStyleTests` (16), `FormAddressPickerItemViewStyleTests` (12 new)
- **Changes**: 14 files, 37 tests passing
- **Unique insights**:
  - Complex inheritance chain requires theme propagation through 4 parent classes
  - `package let theme` in base class allows subclasses to access theme
  - Removed duplicate `private let theme` from intermediate classes
  - Changed `override` to `required` for init in subclasses
  - Fixed `PayToFormPickerItemView` in AdyenComponents to use theme init
  - Used `sed`/`perl` for clean surgical edits (no formatting noise)
- **Key mapping**: `item.style.text.color` → `theme.elements.labels.body.color`, `item.style.errorColor` → `theme.colors.destructive`

---

## Commented Tests Strategy

### Decision: REWRITE Tests to Use AdyenTheme ✅

Old style tests use `FormComponentStyle` which views now **ignore**. We will **rewrite** them to use `AdyenTheme`.

**Why views ignore item.style**:
- Views have `init(item:, theme:)` and apply `theme.elements.*`
- Builder provides theme, items still receive style (legacy)
- Style is NOT converted to theme - views only read theme

### Tests to Rewrite (Priority Order)

| # | Test File | Test/Asserts | Rewrite Status |
|---|-----------|--------------|----------------|
| 1 | `CardComponentTests` | `testUIConfiguration` (semantic approach) | ✅ Rewritten (PR #6) |
| 2 | `CardComponentTests` | `testSuccessTintColorCustomization` | ⏸️ Commented out - blocked by style dependencies |
| 3 | `SEPADirectDebitComponentTests` | `testUIConfiguration` asserts | ✅ Rewritten with comprehensive theme testing (21 assertions) |
| 4 | `ACHDirectDebitComponentTests` | `testUIConfiguration` asserts | ✅ Rewritten with comprehensive theme testing (21 assertions) |
| 5 | `BasicPersonalInfoFormComponentTests` | UI asserts | ✅ Verified (2025-11-27) |
| 6 | `QiwiWalletComponentTests` | UI asserts | ✅ Verified (2025-11-27) |

**✅ RESOLVED:** Tests 3-6 have been verified (2025-11-27). Test 2 is commented out pending style dependency fixes.

### Rewrite Pattern

**OLD** (FormComponentStyle - broken):
```swift
var style = FormComponentStyle()
style.textField.text.color = .red
style.textField.background.color = .blue
style.textField.title.font = .systemFont(ofSize: 18)
configuration.style = style
// ❌ Views ignore this, checks 20+ granular properties
```

**NEW** (Semantic AdyenTheme - working):
```swift
let customColors = AdyenColors(
    container: .systemYellow,
    primary: .systemPink,
    highlight: .systemBlue
)
var configuration = CardComponentConfiguration()
configuration.theme = AdyenTheme(colors: customColors)
    .primaryButton(backgroundColor: .systemRed, textColor: .white)

// ✅ Verify semantic properties applied consistently
XCTAssertEqual(allTitleLabels.textColor, .systemPink) // Primary color
XCTAssertEqual(allTextFields.textColor, .systemPink) // Consistency
XCTAssertEqual(payButton.backgroundColor, .systemRed) // Button theme
```

**Key differences**:
- Old: Checks granular properties (backgrounds, fonts, alignments) per field
- New: Verifies semantic theme properties applied consistently across all fields
- Old: 20-30 assertions checking implementation details
- New: 15-20 assertions checking theme consistency and component structure

### Coverage Analysis: Style → Theme Migration

When migrating from `FormComponentStyle` to `AdyenTheme`, coverage changes:

| Property | Old Style Tests | New Theme Tests | Impact |
|----------|-----------------|-----------------|--------|
| Text color (primary) | ❌ Often commented | ✅ Active | **IMPROVED** |
| Title color | ❌ Often commented | ✅ Active | **IMPROVED** |
| Button background | ❌ Often commented | ✅ Active | **IMPROVED** |
| Button text color | ❌ Often commented | ✅ Active | **IMPROVED** |
| Button corner radius | ❌ Not tested | ✅ Active | **NEW** |
| Container existence | ❌ Not tested | ✅ Active | **NEW** |
| Text font | ❌ Commented | ❌ N/A | Lost (was broken) |
| Text alignment | ❌ Commented | ❌ N/A | Lost (was broken) |
| Background colors | ❌ Commented | ❌ N/A | Lost (was broken) |

**Key insight:** Most old style tests had assertions **commented out** with `// TODO: Fix`. The new theme tests have **more actual coverage** because all assertions are active.

**Properties NOT in AdyenTheme** (by design):
- Text alignment (uses system defaults)
- Per-field background colors (uses semantic container color)
- Custom fonts (uses system fonts for accessibility)
- Title background colors (not a common customization)

**Acceptance criteria for rewritten tests:**
1. ✅ Primary color applied to all text fields
2. ✅ Button uses theme colors and corner radius
3. ✅ All form containers exist
4. ✅ Component-specific elements exist (billing address, etc.)

### Theme Propagation Gaps (Discovered 2025-11-27)

Testing revealed these limitations in the current theme system:

| Gap | Description | Impact |
|-----|-------------|--------|
| **Text field corner radius** | `theme.cornerRadius()` only affects buttons, not text field containers | Text fields always use default 14pt |
| **Text field border color** | Border color is state-dependent (focused fields use `borderActiveColor`) | Can't reliably assert single border color |
| **CGColor comparison** | System colors (`.systemPurple`) can't be directly compared with CGColor | Use static RGB colors in tests |

**Reliably testable properties:**
- ✅ Text colors (title label, text field) via `assertAllTextFieldsUseColor()`
- ✅ Button background, text, corner radius via `assertThemeStyle()`
- ✅ Container existence via `assertAllContainersExist()`
- ✅ Container background color (with `assertAllTextFieldsUseFullStyle()`)

**Not reliably testable yet:**
- ❌ Text field container border color (state-dependent)
- ❌ Text field container corner radius (not customizable)

### Blocked by Remaining Form Views

| Test File | Test | Blocked By |
|-----------|------|------------|
| ~~`FormPickerItemTests`~~ | ~~`testPresentation`~~ | ~~**FormPickerItemView**~~ ✅ Unblocked |

### Blocked by Non-Form Components

| Test File | Tests | Blocked By |
|-----------|-------|------------|
| `DropInTests` | 18 tests | DropIn infrastructure, ListViewController styling |
| `DropInActionTests` | 2 tests | DropIn infrastructure |
| `StoredPaymentMethodComponentTests` | 9 tests (entire class) | StoredPaymentMethodComponent UI |
| `VoucherViewTests` | `testCustomUI` | VoucherView (not a form item) |
| `PreselectedPaymentComponentTests` | 3 asserts in `testUICustomization` | Separator styling |

---

## Next Views to Convert (Priority Order)

### High Priority (unblocks tests)
1. ✅ ~~**FormPickerItemView**~~ → Completed (PR #7)

### Medium Priority (completes form coverage)
2. **FormSplitItemView** - Used in card expiry/CVC split
3. **FormAddressItemView** - Complex, uses multiple sub-items
4. **SelectableFormItemView** - Used in list selections
5. **FormErrorItemView** - Error message display
6. **FormFootnoteItemView** - Footer text

### Lower Priority (less common)
7. **FormContainerItemView**
8. ✅ **FormVerticalStackItemView** - Migrated (needed for container theme propagation)
9. **FormAttributedLabelItemView**
10. Remaining form item views...

---

## Immediate Actions

1. ✅ ~~**Rewrite `CardComponentTests.testUIConfiguration`** using semantic AdyenTheme approach~~ → Done (PR #6)
2. ✅ ~~**Verify tests 3-6**~~ → All tests verified (2025-11-27)
3. ✅ ~~**Migrate FormPickerItemView**~~ → Done (PR #7)
4. **Continue Phase 2** view migrations (FormSplitItemView, SelectableFormItemView, etc.)

---

## PR #7: FormPickerItemView Migration ✅ COMPLETED

### Overview

`FormPickerItemView` has a **complex inheritance chain** requiring theme propagation through parent classes:

```
FormPickerItemView<Value>
  └─► FormSelectableValueItemView<Value, Item>
        └─► FormValidatableValueItemView<Value, Item>
              └─► FormValueItemView<Value, Style, Item>
                    └─► FormItemView<Item>
```

**Key finding**: Parent classes already have `private let theme: AdyenTheme = .default` with TODO comments `// TODO: Pass as dependency`. This migration resolves these TODOs.

### Files to Modify

| File | Changes |
|------|---------|
| `FormValueItemView.swift` | Change `private let theme` → `package let theme`, add `init(item:theme:)` |
| `FormValidatableValueItemView.swift` | Remove private theme, inherit from parent, add `init(item:theme:)` |
| `FormSelectableValueItemView.swift` | Add theme parameter, apply theme to `valueLabel` |
| `FormPickerItemView.swift` | Add `init(item:theme:)`, convenience init |
| `FormItemViewBuilder.swift` | Update `build(with: FormPickerItem)` to pass theme |
| `FormPickerItemTests.swift` | Add theme integration test, fix blocked `testPresentation` |

### Theme Properties Mapping

| UI Element | Current Source | New Source |
|------------|----------------|------------|
| `titleLabel` | `theme.elements.labels.bodyEmphasized` (already) | No change |
| `valueLabel` text color | `item.style.text.color` | `theme.elements.labels.body.color` |
| `valueLabel` placeholder | `item.style.placeholderText?.color` | `theme.colors.componentPlaceholderText` |
| `alertLabel` | `item.style.errorColor` | `theme.colors.error` |
| `tintColor` | `item.style.tintColor` | Keep or remove (consider) |
| `backgroundColor` | `item.style.backgroundColor` | `theme.colors.background` |

### Detailed Changes

#### 1. FormValueItemView.swift (great-grandparent)

**Current** (lines 16-17):
```swift
// TODO: Pass as a dependency
private let theme: AdyenTheme = .default
```

**After**:
```swift
package let theme: AdyenTheme

public required init(item: ItemType, theme: AdyenTheme) {
    self.theme = theme
    super.init(item: item)
    // ... existing setup
}

public required convenience init(item: ItemType) {
    self.init(item: item, theme: .default)
}
```

#### 2. FormValidatableValueItemView.swift (grandparent)

**Current** (lines 18-19):
```swift
// TODO: Pass as dependency
private let theme: AdyenTheme = .default
```

**After**: Remove private theme, use parent's theme property:
```swift
public required init(item: ItemType, theme: AdyenTheme) {
    super.init(item: item, theme: theme)
    // ... existing setup
}

public required convenience init(item: ItemType) {
    self.init(item: item, theme: .default)
}
```

#### 3. FormSelectableValueItemView.swift (parent)

**Current** styling uses `item.style`:
- Line 93: `ValueLabel(style: item.style.text)`
- Line 121: `valueLabel.textColor = item.style.placeholderText?.color`
- Line 127: `valueLabel.textColor = item.style.text.color`

**After**: Apply theme to valueLabel styling.

#### 4. FormPickerItemView.swift (target view)

**Current** (line 13-14):
```swift
internal required init(item: FormPickerItem<Value>) {
    super.init(item: item)
```

**After**:
```swift
init(item: FormPickerItem<Value>, theme: AdyenTheme) {
    super.init(item: item, theme: theme)
    // ... existing setup
}

required convenience init(item: FormPickerItem<Value>) {
    self.init(item: item, theme: .default)
}
```

#### 5. FormItemViewBuilder.swift

**Current** (lines 121-127):
```swift
public func build<Value>(with item: FormPickerItem<Value>) -> FormItemView<FormPickerItem<Value>> {
    FormPickerItemView(item: item)
}
```

**After**:
```swift
public func build<Value>(with item: FormPickerItem<Value>) -> FormItemView<FormPickerItem<Value>> {
    FormPickerItemView(item: item, theme: theme)
}
```

### Test Plan

#### New Test: `FormPickerItemViewThemeTests.swift`

Location: `Tests/IntegrationTests/UIKit/Form/Theme/`

- `testCustomThemeApplied()` - Verify theme colors on titleLabel, valueLabel
- `testConvenienceInitUsesDefaultTheme()` - Verify `.default` theme

#### Unblock `testPresentation`

Currently commented out in `FormPickerItemTests.swift`. Update to use new init:
```swift
_ = FormPickerItemView(item: formPickerItem, theme: .default)
```

### Execution Order

1. **FormValueItemView** - Make theme `package let`, add designated init
2. **FormValidatableValueItemView** - Remove private theme, propagate from parent
3. **FormSelectableValueItemView** - Add theme parameter, apply to valueLabel
4. **FormPickerItemView** - Add theme init, convenience init
5. **FormItemViewBuilder** - Pass theme in builder method
6. **Tests** - Add theme tests, fix blocked testPresentation
7. **SwiftFormat** - Run on all modified files

### Risk Assessment

| Risk | Mitigation |
|------|------------|
| Breaking subclasses of FormValueItemView | Convenience init provides backward compatibility |
| Other views inheriting from parent classes | All views using parent chain already work with `.default` |
| Existing tests relying on `item.style` | Views now ignore style, use theme - tests must verify theme |

### Implementation Summary ✅

**Completed**: 2025-12-05

**Files changed**: 14
- `FormValueItemView.swift` - `package let theme`, designated init
- `FormValidatableValueItemView.swift` - Removed private theme, inherits from parent
- `FormSelectableValueItemView.swift` - Theme propagation, valueLabel styling
- `FormPickerItemView.swift` - Designated init with theme
- `BaseFormPickerItemView.swift` - Designated init with theme
- `FormAddressPickerItemView.swift` - Designated init with theme
- `FormTextItemView.swift` - Removed duplicate theme, uses parent's
- `FormTextInputItemView.swift` - `override` → `required`
- `FormPhoneNumberItemView.swift` - `override` → `required`
- `FormCardSecurityCodeItemView.swift` - `override` → `required`
- `FormCardNumberItemView.swift` - `override` → `required`
- `FormItemViewBuilder.swift` - Passes theme to FormPickerItemView
- `PayToFormPickerItemView.swift` - Uses theme init
- `FormAddressPickerItemViewStyleTests.swift` - **NEW** 12 style tests

**Test coverage**:
- `FormPickerItemViewStyleTests` - 16 tests (in FormSelectableItemViewTests.swift)
- `FormAddressPickerItemViewStyleTests` - 12 tests (new file)
- `FormSelectableItemViewTests` - 2 functional tests
- `FormAddressPickerItemTests` - 7 functional tests
- **Total: 37 picker-related tests passing**

**Theme properties migrated**:
| UI Element | Old Source | New Source |
|------------|------------|------------|
| `valueLabel` text | `item.style.text.color` | `theme.elements.labels.body.color` |
| `valueLabel` placeholder | `item.style.placeholderText?.color` | `theme.colors.textSecondary` |
| `alertLabel` color | `item.style.errorColor` | `theme.colors.destructive` |
| `titleLabel` | Already theme-based | No change |
