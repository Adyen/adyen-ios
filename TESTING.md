# Testing Guide

This file provides guidance for writing tests in the Adyen iOS SDK.

## Testing Philosophy

- Unit tests go in `Tests/UnitTests/`
- Integration tests go in `Tests/IntegrationTests/`
- Integration tests may use `XCTestCase+Wait` helpers for async operations
- Integration tests often create and present view controllers using `XCTestCase+RootViewController`
- Mock types follow the naming convention `*Mock` (e.g., `APIClientMock`, `PaymentComponentDelegateMock`)

### When to Avoid Unit Tests

**During rapid API changes or structural migrations:**
- ❌ **Avoid testing API surface details** (e.g., theme/style initializer variations)
- ❌ **Avoid testing construction patterns** that are in flux
- ✅ **Focus on integration tests** that verify actual behavior and UI outcomes

**Why?** Unit tests that verify "how" things are built (rather than "what" they do) become a maintenance burden during migrations. They:
- Break with every structural change
- Create PR review overhead
- Test implementation details, not functionality
- Provide little value when the API is changing

**Example:**
```swift
// ❌ Avoid during migrations - tests API surface
func test_themeInitialization_withCustomColors() {
    let theme = AdyenTheme(colors: AdyenColors(primary: .red))
    XCTAssertEqual(theme.colors.primary, .red)
}

// ✅ Prefer - tests actual behavior
func test_formTextField_appliesCustomThemeColors() {
    var customElements = AdyenElements(colors: .default)
    customElements.textField.borderColor = .systemPink
    let theme = AdyenTheme(elements: customElements)

    let sut = FormTextItemView(item: FormTextInputItem(), theme: theme)

    XCTAssertEqual(getContainerView(from: sut)?.layer.borderColor, UIColor.systemPink.cgColor)
}
```

Once the structure stabilizes, focused unit tests can be added back for specific edge cases.

## Running Tests

**List available simulators:**
```bash
xcrun simctl list devices available
```

Choose an available simulator name from the output (e.g., "iPhone 15 Pro", "iPhone 16", etc.) and use it in the commands below by replacing `<SIMULATOR_NAME>`.

**Run unit tests:**
```bash
# Option 1: Use a standard iPhone simulator (recommended)
xcodebuild test -project Adyen.xcodeproj -scheme UnitTests -destination 'platform=iOS Simulator,name=<SIMULATOR_NAME>'

# Option 2: Use specific device by ID (most reliable)
xcodebuild test -project Adyen.xcodeproj -scheme UnitTests -destination 'platform=iOS Simulator,id=<DEVICE_ID>'
```

**Run integration tests:**
```bash
xcodebuild test -project Adyen.xcodeproj -scheme IntegrationUIKitTests -destination 'platform=iOS Simulator,name=<SIMULATOR_NAME>'
```

**Run single test:**
```bash
xcodebuild test -project Adyen.xcodeproj -scheme UnitTests -destination 'platform=iOS Simulator,name=<SIMULATOR_NAME>' -only-testing:UnitTests/TestClassName/testMethodName
```

**Note:** Do not use `swift test` - it doesn't work well with the Xcode project structure. The `SnapshotTests` target is primarily for CI and not typically run during local development.

## Testing Form Views

**Preferred approach:** Integration tests in `Tests/IntegrationTests/UIKit/` for UI component theme/style verification.

### Test Pattern - Use Helper Methods

Form view tests should follow these established patterns to maximize readability and reduce verbosity:

#### 1. SUT Factory Methods

Create `makeSUT()` functions with overloads for different configurations:

```swift
private func makeSUT(with theme: AdyenTheme = .default) -> FormTextItemView<FormTextInputItem> {
    FormTextItemView(item: FormTextInputItem(), theme: theme)
}

private func makeSUT(
    borderColor: UIColor,
    borderActiveColor: UIColor
) -> FormTextItemView<FormTextInputItem> {
    var style = AdyenTextFieldStyle()
    style.borderColor = borderColor
    style.borderActiveColor = borderActiveColor
    let theme = AdyenTheme(elements: AdyenElements(textField: style))
    return FormTextItemView(item: FormTextInputItem(), theme: theme)
}
```

#### 2. Assertion Helpers

Custom `expect()` methods with `file: StaticString = #file, line: UInt = #line` parameters:

```swift
private func expect(
    _ sut: FormTextItemView<FormTextInputItem>,
    toMatchStyle style: AdyenTextFieldStyle,
    file: StaticString = #file,
    line: UInt = #line
) {
    XCTAssertEqual(sut.textField.font, style.text.font, file: file, line: line)
    XCTAssertEqual(sut.textField.textColor, style.text.color, file: file, line: line)
    XCTAssertEqual(sut.titleLabel.font, style.title.font, file: file, line: line)
    // ...
}

private func expectBorderColor(
    _ containerView: UIStackView?,
    toBe color: UIColor,
    file: StaticString = #file,
    line: UInt = #line
) {
    XCTAssertEqual(containerView?.layer.borderColor, color.cgColor, file: file, line: line)
}
```

#### 3. Action Helpers

Methods for common operations like `triggerEditing()`, `setEnabled()`, etc.:

```swift
private func triggerEditing(on sut: FormTextItemView<FormTextInputItem>, isEditing: Bool) {
    if isEditing {
        sut.textField.delegate?.textFieldDidBeginEditing?(sut.textField)
    } else {
        sut.textField.delegate?.textFieldDidEndEditing?(sut.textField)
    }
}

private func setEnabled(_ enabled: Bool, on item: FormTextInputItem, sut: FormTextInputItemView) {
    item.isEnabled = enabled
    wait(until: { sut.textField.isEnabled == enabled }, timeout: 2.0)
}
```

#### 4. Async Utilities

Helper methods for waiting on reactive property changes. Use polling-based waits instead of fixed delays to avoid flaky tests:

```swift
// Preferred: Polling-based wait (robust)
private func setEnabled(_ enabled: Bool, on item: FormTextInputItem, sut: FormTextInputItemView) {
    item.isEnabled = enabled
    wait(until: { sut.textField.isEnabled == enabled }, timeout: 2.0)
}

// Or more generic:
private func waitUntil(
    _ condition: @escaping () -> Bool,
    timeout: TimeInterval = 2.0,
    file: StaticString = #file,
    line: UInt = #line
) {
    wait(until: condition, timeout: timeout, file: file, line: line)
}
```

**Note:** Avoid fixed delays like `DispatchQueue.main.asyncAfter(deadline: .now() + 0.1)` as they can be flaky. Use condition-based polling with `wait(until:timeout:)` instead.

### Accessing Private Views for Testing

When you need to test private UI elements:

1. Add accessibility identifier using `ViewIdentifierBuilder.build(scopeInstance: self, postfix: "viewName")`
2. Use `@testable import` and the `findView(by:)` helper method
3. This pattern is consistent across the codebase

Example:

```swift
// In the view:
stackView.accessibilityIdentifier = ViewIdentifierBuilder.build(scopeInstance: self, postfix: "entryTextStackView")

// In the test:
private func getContainerView(from sut: FormTextItemView<FormTextInputItem>) -> UIStackView? {
    sut.findView(by: "entryTextStackView")
}
```

### Benefits

This helper method pattern makes tests **~70% more concise** while maintaining clarity and proper error reporting. Tests read like specifications rather than imperative code.
