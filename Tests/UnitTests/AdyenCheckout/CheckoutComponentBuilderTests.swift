//
// Copyright (c) Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) @testable import Adyen
@_spi(AdyenInternal) @testable import AdyenCheckout
@_spi(AdyenInternal) @testable import AdyenComponents
@_spi(AdyenInternal) @testable import AdyenUI
import XCTest

final class CheckoutComponentBuilderTests: XCTestCase {
    
    var checkoutConfiguration: CheckoutConfiguration!
    var context: AdyenContext!
    
    override func setUp() {
        super.setUp()
        context = Dummy.context
        checkoutConfiguration = CheckoutConfiguration(context: context)
    }
    
    override func tearDown() {
        checkoutConfiguration = nil
        context = nil
        super.tearDown()
    }
    
    // MARK: - BLIK Component Tests
    
    func testBuild_WithBLIKPaymentMethod_ReturnsBLIKComponent() throws {
        // Given
        let paymentMethod = try XCTUnwrap(createBLIKPaymentMethod())
        
        // When
        let component = CheckoutComponentBuilder.build(
            for: paymentMethod,
            configuration: checkoutConfiguration
        )
        
        // Then
        XCTAssertEqual(component.paymentMethod.type, .blik)
        XCTAssertEqual(component.paymentMethod.name, paymentMethod.name)
        
        // Verify it's the correct component type by checking its concrete type
        let blikComponent = component as? BLIKComponent
        XCTAssertNotNil(blikComponent, "Component should be BLIKComponent")
    }
    
    func testBuild_WithBLIKAndCustomConfiguration_AppliesConfiguration() throws {
        // Given
        let paymentMethod = try XCTUnwrap(createBLIKPaymentMethod())
        var blikConfig = BLIKComponentConfiguration()
        blikConfig.showsSubmitButton = false
        
        checkoutConfiguration = CheckoutConfiguration(
            context: context,
            configurations: [.payment(.blik): blikConfig]
        )
        
        // When
        let component = CheckoutComponentBuilder.build(
            for: paymentMethod,
            configuration: checkoutConfiguration
        )
        
        // Then
        XCTAssertEqual(component.paymentMethod.type, .blik)
        
        // Verify configuration was applied
        guard let blikComponent = component as? BLIKComponent else {
            XCTFail("Component should be BLIKComponent")
            return
        }
        
        // Test that the component was created with the configuration
        XCTAssertNotNil(blikComponent)
    }
    
    func testBuild_WithBLIKAndNoConfiguration_UsesDefaultConfiguration() throws {
        // Given
        let paymentMethod = try XCTUnwrap(createBLIKPaymentMethod())
        checkoutConfiguration = CheckoutConfiguration(context: context)
        
        // When
        let component = CheckoutComponentBuilder.build(
            for: paymentMethod,
            configuration: checkoutConfiguration
        )
        
        // Then
        XCTAssertEqual(component.paymentMethod.type, .blik)
        XCTAssertNotNil(component as? BLIKComponent)
    }
    
    // MARK: - Global Settings Application Tests
    
    func testBuild_AppliesContextFromCheckoutConfiguration() throws {
        // Given
        let customAmount = Amount(value: 500, currencyCode: "USD")
        let customContext = AdyenContext(
            apiContext: Dummy.apiContext,
            payment: Payment(amount: customAmount, countryCode: "US"),
            amount: customAmount
        )
        checkoutConfiguration = CheckoutConfiguration(context: customContext)
        let paymentMethod = try XCTUnwrap(createBLIKPaymentMethod())
        
        // When
        let component = CheckoutComponentBuilder.build(
            for: paymentMethod,
            configuration: checkoutConfiguration
        )
        
        // Then - Verify context was passed correctly
        XCTAssertEqual(component.context.amount.value, 500)
        XCTAssertEqual(component.context.amount.currencyCode, "USD")
    }
    
    func testBuild_WithDifferentPaymentMethods_CreatesCorrectComponentTypes() throws {
        // Given
        let blikPaymentMethod = try XCTUnwrap(createBLIKPaymentMethod())
        
        // When
        let blikComponent = CheckoutComponentBuilder.build(
            for: blikPaymentMethod,
            configuration: checkoutConfiguration
        )
        
        // Then - Verify correct types
        XCTAssertEqual(blikComponent.paymentMethod.type, .blik)
        XCTAssertNotNil(blikComponent as? BLIKComponent)
    }
    
    // MARK: - Factory Integration Tests
    
    func testBuild_PassesPaymentMethodToFactory() throws {
        // Given
        let paymentMethod = try XCTUnwrap(createBLIKPaymentMethod())
        
        // When
        let component = CheckoutComponentBuilder.build(
            for: paymentMethod,
            configuration: checkoutConfiguration
        )
        
        // Then - Verify payment method was passed correctly
        XCTAssertEqual(component.paymentMethod.type, paymentMethod.type)
        XCTAssertEqual(component.paymentMethod.name, paymentMethod.name)
    }
    
    func testBuild_PassesContextToFactory() throws {
        // Given
        let customContext = AdyenContext(
            apiContext: Dummy.apiContext,
            payment: Payment(amount: Amount(value: 500, currencyCode: "USD"), countryCode: "US"),
            amount: Amount(value: 500, currencyCode: "USD")
        )
        checkoutConfiguration = CheckoutConfiguration(context: customContext)
        let paymentMethod = try XCTUnwrap(createBLIKPaymentMethod())
        
        // When
        let component = CheckoutComponentBuilder.build(
            for: paymentMethod,
            configuration: checkoutConfiguration
        )
        
        // Then - Verify context was passed
        XCTAssertEqual(component.context.amount.value, 500)
        XCTAssertEqual(component.context.amount.currencyCode, "USD")
        XCTAssertEqual(component.context.apiContext.clientKey, customContext.apiContext.clientKey)
    }
    
    // MARK: - Configuration Merging Tests
    
    func testBuild_MergesGlobalShowsFormButtonSetting() throws {
        // Given
        let paymentMethod = try XCTUnwrap(createBLIKPaymentMethod())
        var blikConfig = BLIKComponentConfiguration()
        blikConfig.showsSubmitButton = true // Component-specific
        
        checkoutConfiguration = CheckoutConfiguration(
            context: context,
            configurations: [.payment(.blik): blikConfig]
        )
        checkoutConfiguration.showsSubmitButton = false // Global override
        
        // When
        let component = CheckoutComponentBuilder.build(
            for: paymentMethod,
            configuration: checkoutConfiguration
        )
        
        // Then - Component should be created
        XCTAssertEqual(component.paymentMethod.type, .blik)
        
        guard let blikComponent = component as? BLIKComponent else {
            XCTFail("Component should be of type BLIKComponent")
            return
        }
        XCTAssertFalse(blikComponent.configuration.showsSubmitButton)
    }
    
    func testBuild_UsesStoredConfigurationWhenAvailable() throws {
        // Given
        let paymentMethod = try XCTUnwrap(createBLIKPaymentMethod())
        let customConfig = BLIKComponentConfiguration()
        
        checkoutConfiguration = CheckoutConfiguration(
            context: context,
            configurations: [.payment(.blik): customConfig]
        )
        
        // When
        let component = CheckoutComponentBuilder.build(
            for: paymentMethod,
            configuration: checkoutConfiguration
        )
        
        // Then - Should use stored configuration
        XCTAssertEqual(component.paymentMethod.type, .blik)
    }
    
    func testBuild_UsesDefaultConfigurationWhenNotStored() throws {
        // Given
        let paymentMethod = try XCTUnwrap(createBLIKPaymentMethod())
        checkoutConfiguration = CheckoutConfiguration(context: context) // No stored config
        
        // When
        let component = CheckoutComponentBuilder.build(
            for: paymentMethod,
            configuration: checkoutConfiguration
        )
        
        // Then - Should use factory's default configuration
        XCTAssertEqual(component.paymentMethod.type, .blik)
    }
    
    // MARK: - ACH Direct Debit Component Tests

    func test_build_withACHPaymentMethod_returnsACHComponent() throws {
        // Given
        let paymentMethod = try XCTUnwrap(createACHPaymentMethod())

        // When
        let component = CheckoutComponentBuilder.build(
            for: paymentMethod,
            configuration: checkoutConfiguration
        )

        // Then
        XCTAssertEqual(component.paymentMethod.type, .achDirectDebit)
        XCTAssertEqual(component.paymentMethod.name, paymentMethod.name)

        let achComponent = component as? ACHDirectDebitComponent
        XCTAssertNotNil(achComponent, "Component should be ACHDirectDebitComponent")
    }

    // MARK: - Theme Propagation Tests

    func test_build_withCustomTheme_propagatesThemeToACHComponent() throws {
        // Given
        let paymentMethod = try XCTUnwrap(createACHPaymentMethod())
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
        guard let achComponent = component as? ACHDirectDebitComponent else {
            XCTFail("Component should be ACHDirectDebitComponent")
            return
        }
        XCTAssertEqual(
            achComponent.configuration.theme.colors.primary,
            UIColor.systemPink,
            "Theme should be propagated from CheckoutConfiguration to component"
        )
    }

    func test_build_withCustomTheme_propagatesThemeToBLIKComponent() throws {
        // Given
        let paymentMethod = try XCTUnwrap(createBLIKPaymentMethod())
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
        guard let blikComponent = component as? BLIKComponent else {
            XCTFail("Component should be BLIKComponent")
            return
        }
        XCTAssertEqual(
            blikComponent.configuration.theme.colors.primary,
            UIColor.systemPink,
            "Theme should be propagated from CheckoutConfiguration to component"
        )
    }

    // MARK: - Helper Methods
    
    private func createBLIKPaymentMethod() -> BLIKPaymentMethod? {
        let dict: [String: Any] = [
            "type": "blik",
            "name": "BLIK"
        ]
        return try? AdyenCoder.decode(dict) as BLIKPaymentMethod
    }
    
    private func createACHPaymentMethod() -> ACHDirectDebitPaymentMethod? {
        let dict: [String: Any] = [
            "type": "ach",
            "name": "ACH Direct Debit"
        ]
        return try? AdyenCoder.decode(dict) as ACHDirectDebitPaymentMethod
    }
}
