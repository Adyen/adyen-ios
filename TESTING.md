# Testing Guide

This file provides guidance for writing tests in the Adyen iOS SDK.

## Testing Philosophy

- Unit tests go in `Tests/UnitTests/`
- Integration tests go in `Tests/IntegrationTests/`
- Integration tests may use `XCTestCase+Wait` helpers for async operations
- Integration tests often create and present view controllers using `XCTestCase+RootViewController`
- Mock types follow the naming convention `*Mock` (e.g., `APIClientMock`, `PaymentComponentDelegateMock`)

## Running Tests

**List available simulators:**
```bash
xcrun simctl list devices available
```

**Run unit tests:**
```bash
# Option 1: Use a standard iPhone simulator (recommended)
xcodebuild test -project Adyen.xcodeproj -scheme UnitTests -destination 'platform=iOS Simulator,name=iPhone 17'

# Option 2: Use specific device by ID (most reliable)
xcodebuild test -project Adyen.xcodeproj -scheme UnitTests -destination 'platform=iOS Simulator,id=<DEVICE_ID>'
```

**Run integration tests:**
```bash
xcodebuild test -project Adyen.xcodeproj -scheme IntegrationUIKitTests -destination 'platform=iOS Simulator,name=iPhone 17'
```

**Run single test:**
```bash
xcodebuild test -project Adyen.xcodeproj -scheme UnitTests -destination 'platform=iOS Simulator,name=iPhone 17' -only-testing:UnitTests/TestClassName/testMethodName
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

private func setEnabled(_ enabled: Bool, on item: FormTextInputItem) {
    item.isEnabled = enabled
    waitForObservableUpdate()
}
```

#### 4. Async Utilities

Helper methods like `waitForObservableUpdate()` for reactive property changes:

```swift
private func waitForObservableUpdate() {
    let expectation = XCTestExpectation(description: "Wait for observable update")
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
        expectation.fulfill()
    }
    wait(for: [expectation], timeout: 1.0)
}
```

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

### Example Test Structure

```swift
final class FormTextItemViewThemeTests: XCTestCase {

    func test_formTextItemView_shouldApplyThemeAttributesCorrectly() {
        let textFieldStyle = makeTextFieldStyle()
        let sut = makeSUT(with: textFieldStyle)
        expect(sut, toMatchStyle: textFieldStyle)
    }

    func test_formTextItemView_borderColor_shouldUpdateOnEditingStateChange() {
        let sut = makeSUT(borderColor: .green, borderActiveColor: .orange)
        let containerView = getContainerView(from: sut)

        expectBorderColor(containerView, toBe: .green)
        triggerEditing(on: sut, isEditing: true)
        expectBorderColor(containerView, toBe: .orange)
        triggerEditing(on: sut, isEditing: false)
        expectBorderColor(containerView, toBe: .green)
    }

    // MARK: - SUT Factory

    private func makeSUT(with theme: AdyenTheme) -> FormTextItemView<FormTextInputItem> {
        FormTextItemView(item: FormTextInputItem(), theme: theme)
    }

    // MARK: - Assertions

    private func expect(
        _ sut: FormTextItemView<FormTextInputItem>,
        toMatchStyle style: AdyenTextFieldStyle,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        // assertions...
    }

    // MARK: - Helpers

    private func getContainerView(from sut: FormTextItemView<FormTextInputItem>) -> UIStackView? {
        sut.findView(by: "entryTextStackView")
    }
}
```
