# Integrating Payment Components with AdyenCheckout

This guide explains how to integrate a payment component with the new `AdyenCheckout` module, enabling it to work with `CheckoutConfiguration` and receive proper theme propagation.

## Overview

The `AdyenCheckout` module provides a unified way to configure and create payment components through `CheckoutConfiguration`. This architecture enables:

- Centralized theme management via `CheckoutConfiguration.theme()`
- Consistent component creation through `CheckoutComponentBuilder`
- Type-safe configuration storage and retrieval

```
CheckoutConfiguration (public API)
    │
    ├── theme: AdyenTheme
    ├── configurations: [ComponentType: Configuration]
    │
    └── CheckoutComponentBuilder.build(for: paymentMethod)
            │
            ├── Retrieves or creates default configuration
            ├── Propagates theme: config.theme = checkoutConfig.theme
            │
            └── ComponentFactory.create() → PaymentComponent
```

---

## Access Level Strategy

**Components are `package`, Configurations are `public`.**

- **Component classes** → `package` access (created through `CheckoutComponentBuilder`)
- **Configuration structs** → `public` access (used in `CheckoutConfiguration` by integrators)

---

## Part 1: Main Codebase Changes

### Step 1: Create Configuration in Separate File

Create a standalone configuration struct in its own file (e.g., `YourComponentConfiguration.swift`), not nested inside the component class.

### Step 2: Conform Configuration to `CheckoutComponentConfiguration`

Update your component's `Configuration` struct to conform to the protocol:

```swift
// Before (nested in component)
extension YourComponent {
    public struct Configuration: AnyXXXConfiguration {
        public var style: FormComponentStyle
        internal let showsSubmitButton: Bool
        // ...
    }
}

// After (standalone in YourComponentConfiguration.swift)
public struct YourComponentConfiguration: CheckoutComponentConfiguration {

    package let componentType: CheckoutComponentType = .payment(.yourPaymentType)
    package var theme: AdyenTheme = .init()
    package var showsSubmitButton: Bool  // Change: internal let → package var

    public var style: FormComponentStyle
    // ...
}
```

**Key changes:**
- Add `CheckoutComponentConfiguration` conformance
- Add `componentType` property with correct `PaymentMethodType`
- Add `theme` property (package access)
- Change `showsSubmitButton` from `internal let` to `package var`

### Step 3: Create Component Factory

Create a factory file following this pattern:

```swift
// YourComponentFactory.swift

@_spi(AdyenInternal) import Adyen

/// Factory for creating YourComponent instances.
package struct YourComponentFactory: PaymentComponentFactory {
    package typealias Configuration = YourComponentConfiguration
    package typealias Method = YourPaymentMethod
    package typealias Component = YourComponent

    package init() {}

    package func create(
        with paymentMethod: YourPaymentMethod,
        context: AdyenContext,
        configuration: YourComponentConfiguration
    ) -> YourComponent {
        YourComponent(
            paymentMethod: paymentMethod,
            context: context,
            configuration: configuration
        )
    }

    package func defaultConfiguration() -> YourComponentConfiguration {
        YourComponentConfiguration()
    }
}
```

**Reference:** `AdyenComponents/BLIK/BLIKComponentConfiguration.swift`, `AdyenComponents/BLIK/BLIKComponentFactory.swift`

### Step 4: Register in CheckoutComponentBuilder

Add your component to `CheckoutComponentBuilder.swift`:

```swift
// AdyenCheckout/CheckoutComponentBuilder.swift

switch paymentMethod {

#if canImport(AdyenComponents)
    case let blikPaymentMethod as BLIKPaymentMethod:
        return createComponent(
            using: BLIKComponentFactory(),
            paymentMethod: blikPaymentMethod,
            configuration: configuration
        )

    // Add your component here
    case let yourPaymentMethod as YourPaymentMethod:
        return createComponent(
            using: YourComponentFactory(),
            paymentMethod: yourPaymentMethod,
            configuration: configuration
        )
#endif

// ...
}
```

### Step 5: Ensure Theme is Passed to FormViewController

Verify your component passes the theme to `FormViewController`:

```swift
// In your component's initialization
let formViewController = FormViewController(
    scrollEnabled: configuration.showsSubmitButton,
    localizationParameters: configuration.localizationParameters,
    theme: configuration.theme  // Ensure this is passed
)
```

---

## Part 2: Testing

### Unit Tests for Component Factory

Create factory tests following this pattern:

```swift
// YourComponentFactoryTests.swift

@_spi(AdyenInternal) @testable import Adyen
@_spi(AdyenInternal) @testable import AdyenComponents
@_spi(AdyenInternal) @testable import AdyenUI
import XCTest

final class YourComponentFactoryTests: XCTestCase {

    var sut: YourComponentFactory!
    var context: AdyenContext!

    override func setUp() {
        super.setUp()
        sut = YourComponentFactory()
        context = Dummy.context
    }

    override func tearDown() {
        sut = nil
        context = nil
        super.tearDown()
    }

    // MARK: - Default Configuration

    func test_defaultConfiguration_returnsValidConfiguration() {
        // When
        let configuration = sut.defaultConfiguration()

        // Then
        XCTAssertEqual(configuration.componentType, .payment(.yourPaymentType))
        XCTAssertTrue(configuration.showsSubmitButton)
    }

    // MARK: - Component Creation

    func test_create_withValidPaymentMethod_returnsComponent() throws {
        // Given
        let paymentMethod = try XCTUnwrap(createPaymentMethod())
        let configuration = YourComponentConfiguration()

        // When
        let component = sut.create(
            with: paymentMethod,
            context: context,
            configuration: configuration
        )

        // Then
        XCTAssertEqual(component.paymentMethod.type, .yourPaymentType)
    }

    func test_create_withCustomConfiguration_usesProvidedConfiguration() throws {
        // Given
        let paymentMethod = try XCTUnwrap(createPaymentMethod())
        var configuration = YourComponentConfiguration()
        configuration.showsSubmitButton = false

        // When
        let component = sut.create(
            with: paymentMethod,
            context: context,
            configuration: configuration
        )

        // Then
        XCTAssertFalse(component.configuration.showsSubmitButton)
    }

    // MARK: - Helper

    private func createPaymentMethod() -> YourPaymentMethod? {
        let dict: [String: Any] = [
            "type": "your_type",
            "name": "Your Payment Method"
        ]
        return try? AdyenCoder.decode(dict) as YourPaymentMethod
    }
}
```

**Reference:** `Tests/UnitTests/AdyenCheckout/Component Factory Tests/BLIKComponentFactoryTests.swift`

### Unit Tests for CheckoutComponentBuilder

Add integration tests to `CheckoutComponentBuilderTests.swift`:

```swift
// MARK: - Your Component Tests

func test_build_withYourPaymentMethod_returnsYourComponent() throws {
    // Given
    let paymentMethod = try XCTUnwrap(createYourPaymentMethod())

    // When
    let component = CheckoutComponentBuilder.build(
        for: paymentMethod,
        configuration: checkoutConfiguration
    )

    // Then
    XCTAssertEqual(component.paymentMethod.type, .yourPaymentType)
    XCTAssertNotNil(component as? YourComponent)
}

func test_build_withYourComponentAndCustomConfiguration_appliesConfiguration() throws {
    // Given
    let paymentMethod = try XCTUnwrap(createYourPaymentMethod())
    var config = YourComponentConfiguration()
    config.showsSubmitButton = false

    checkoutConfiguration = CheckoutConfiguration(
        context: context,
        configurations: [.payment(.yourPaymentType): config]
    )

    // When
    let component = CheckoutComponentBuilder.build(
        for: paymentMethod,
        configuration: checkoutConfiguration
    )

    // Then
    guard let yourComponent = component as? YourComponent else {
        XCTFail("Component should be YourComponent")
        return
    }
    XCTAssertFalse(yourComponent.configuration.showsSubmitButton)
}
```

---

## Part 3: AdyenTheme Testing

### Theme Propagation Tests

Test that theme flows from `CheckoutConfiguration` to your component:

```swift
func test_build_withCustomTheme_propagatesThemeToYourComponent() throws {
    // Given
    let paymentMethod = try XCTUnwrap(createYourPaymentMethod())
    let customTheme = AdyenTheme()
        .colors(AdyenColors(primary: .systemPink))

    checkoutConfiguration = CheckoutConfiguration(context: context)
    checkoutConfiguration.theme = customTheme

    // When
    let component = CheckoutComponentBuilder.build(
        for: paymentMethod,
        configuration: checkoutConfiguration
    )

    // Then
    guard let yourComponent = component as? YourComponent else {
        XCTFail("Component should be YourComponent")
        return
    }
    XCTAssertEqual(
        yourComponent.configuration.theme.colors.primary,
        UIColor.systemPink,
        "Theme should be propagated from CheckoutConfiguration to component"
    )
}
```

### UI Integration Tests with Theme Helpers

For testing that theme is correctly applied to UI elements, use the shared test helpers:

#### Setup TestTheme

```swift
// Tests/IntegrationTests/Helpers/TestTheme.swift

import AdyenUI

enum TestTheme {

    enum Colors {
        static let primary = UIColor.systemPink
        static let container = UIColor.systemYellow
        static let buttonBackground = UIColor.systemRed
        static let buttonText = UIColor.white
    }

    static let cornerRadius: CGFloat = 12

    static func distinctive() -> AdyenTheme {
        AdyenTheme()
            .colors(AdyenColors(primary: Colors.primary, container: Colors.container))
            .cornerRadius(cornerRadius)
            .primaryButton(backgroundColor: Colors.buttonBackground, textColor: Colors.buttonText)
    }

    // Expected styles for assertions
    static var expectedTextFieldStyle: TextFieldStyle {
        TextFieldStyle(
            titleColor: Colors.primary,
            titleFont: // theme default font,
            textColor: // theme default text color,
            textFont: // theme default font,
            containerColor: Colors.container,
            cornerRadius: 14  // default text field corner radius
        )
    }

    static var expectedButtonStyle: ButtonStyle {
        ButtonStyle(
            backgroundColor: Colors.buttonBackground,
            textColor: Colors.buttonText,
            cornerRadius: cornerRadius
        )
    }
}
```

#### Use FormViewExtractor Helpers

```swift
// Tests/IntegrationTests/Helpers/FormViewExtractor.swift

extension UIViewController {

    func assertTextFieldsUseTheme(
        _ identifiers: [String],
        style: TestTheme.TextFieldStyle,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        for identifier in identifiers {
            // Find and assert text field properties match expected style
            // Title color, title font, text color, text font, container color, corner radius
        }
    }

    func assertButtonUsesTheme(
        _ identifier: String,
        style: TestTheme.ButtonStyle,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        // Find and assert button properties match expected style
        // Background color, text color, corner radius
    }
}
```

#### Write UI Integration Test

```swift
func testUIConfiguration() {
    // Given - use TestTheme helper for distinctive, verifiable styling
    var configuration = YourComponent.Configuration()
    configuration.theme = TestTheme.distinctive()

    let paymentMethod = YourPaymentMethod(type: .yourPaymentType, name: "Test")
    let sut = YourComponent(
        paymentMethod: paymentMethod,
        context: context,
        configuration: configuration
    )

    setupRootViewController(sut.viewController)
    wait(for: .milliseconds(300))

    // Then - Assert text fields use theme styling
    let prefix = "Adyen.YourComponent"
    sut.viewController.assertTextFieldsUseTheme(
        ["\(prefix).field1Item", "\(prefix).field2Item", "\(prefix).field3Item"],
        style: TestTheme.expectedTextFieldStyle
    )

    // Assert button uses theme styling
    sut.viewController.assertButtonUsesTheme(
        "\(prefix).payButtonItem",
        style: TestTheme.expectedButtonStyle
    )
}
```

**Properties tested per text field (6):**
| Property | Theme Source |
|----------|--------------|
| Title color | `theme.elements.textField.title.color` |
| Title font | `theme.elements.textField.title.font` |
| Text color | `theme.elements.textField.text.color` |
| Text font | `theme.elements.textField.text.font` |
| Container color | `theme.elements.textField.containerColor` |
| Corner radius | `theme.elements.textField.cornerRadius` |

**Properties tested per button (3):**
| Property | Theme Source |
|----------|--------------|
| Background | `theme.elements.buttons.primary.backgroundColor` |
| Text color | `theme.elements.buttons.primary.textColor` |
| Corner radius | `theme.elements.buttons.primary.cornerRadius` |

---

## Checklist

### Main Codebase
- [ ] Configuration in separate file (standalone struct, not nested)
- [ ] Configuration conforms to `CheckoutComponentConfiguration`
- [ ] Has `componentType` property with correct `PaymentMethodType`
- [ ] Has `theme` property (`package var`)
- [ ] Has `showsSubmitButton` as `package var`
- [ ] Theme is passed to `FormViewController`
- [ ] Factory created implementing `PaymentComponentFactory`
- [ ] Factory registered in `CheckoutComponentBuilder`

### Testing
- [ ] Factory unit tests created
- [ ] `test_defaultConfiguration_returnsValidConfiguration`
- [ ] `test_create_withValidPaymentMethod_returnsComponent`
- [ ] `test_create_withCustomConfiguration_usesProvidedConfiguration`
- [ ] Builder integration tests added
- [ ] `test_build_withYourPaymentMethod_returnsYourComponent`
- [ ] `test_build_withCustomTheme_propagatesThemeToYourComponent`

### UI Theme Testing
- [ ] UI integration test uses `TestTheme.distinctive()`
- [ ] Text fields asserted with `assertTextFieldsUseTheme`
- [ ] Button asserted with `assertButtonUsesTheme`
- [ ] All tests pass

---

## Test Naming Convention

```swift
// Pattern: test_methodName_condition_expectedResult
func test_create_withValidPaymentMethod_returnsComponent()
func test_build_withCustomTheme_propagatesThemeToACHComponent()

// Subject under test
var sut: YourComponentFactory!
```

---

## References

- **BLIK Factory:** `AdyenComponents/BLIK/BLIKComponentFactory.swift`
- **BLIK Factory Tests:** `Tests/UnitTests/AdyenCheckout/Component Factory Tests/BLIKComponentFactoryTests.swift`
- **Builder Tests:** `Tests/UnitTests/AdyenCheckout/CheckoutComponentBuilderTests.swift`
- **Test Helpers:** `Tests/IntegrationTests/Helpers/TestTheme.swift`, `FormViewExtractor.swift`
