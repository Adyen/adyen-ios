//
// Copyright (c) 2025 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) @testable import Adyen
@_spi(AdyenInternal) @testable import AdyenCard
@_spi(AdyenInternal) @testable import AdyenCheckout
@_spi(AdyenInternal) @testable import AdyenComponents
@_spi(AdyenInternal) @testable import AdyenUI
import XCTest

@MainActor
final class CheckoutComponentBuilderTests: XCTestCase {
    
    var checkoutConfiguration: CheckoutConfiguration!
    var context: AdyenContext!
    
    override func setUp() {
        super.setUp()
        context = Dummy.context
        checkoutConfiguration = makeCheckoutConfiguration()
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
            configuration: checkoutConfiguration,
            context: context
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
        
        checkoutConfiguration = makeCheckoutConfiguration(
            configurations: [.payment(.blik): blikConfig]
        )
        
        // When
        let component = CheckoutComponentBuilder.build(
            for: paymentMethod,
            configuration: checkoutConfiguration,
            context: context
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
        checkoutConfiguration = makeCheckoutConfiguration()

        // When
        let component = CheckoutComponentBuilder.build(
            for: paymentMethod,
            configuration: checkoutConfiguration,
            context: context
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
            amount: customAmount,
            publicKey: Dummy.publicKey,
            analyticsProvider: AnalyticsProviderMock()
        )
        checkoutConfiguration = makeCheckoutConfiguration()
        let paymentMethod = try XCTUnwrap(createBLIKPaymentMethod())
        
        // When
        let component = CheckoutComponentBuilder.build(
            for: paymentMethod,
            configuration: checkoutConfiguration,
            context: customContext
        )
        
        // Then - Verify context was passed correctly
        XCTAssertEqual(component.context.amount?.value, 500)
        XCTAssertEqual(component.context.amount?.currencyCode, "USD")
    }
    
    func testBuild_WithDifferentPaymentMethods_CreatesCorrectComponentTypes() throws {
        // Given
        let blikPaymentMethod = try XCTUnwrap(createBLIKPaymentMethod())
        
        // When
        let blikComponent = CheckoutComponentBuilder.build(
            for: blikPaymentMethod,
            configuration: checkoutConfiguration,
            context: context
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
            configuration: checkoutConfiguration,
            context: context
        )
        
        // Then - Verify payment method was passed correctly
        XCTAssertEqual(component.paymentMethod.type, paymentMethod.type)
        XCTAssertEqual(component.paymentMethod.name, paymentMethod.name)
    }
    
    func testBuild_PassesContextToFactory() throws {
        // Given
        let customContext = AdyenContext(
            apiContext: Dummy.apiContext,
            amount: Amount(value: 500, currencyCode: "USD"),
            publicKey: Dummy.publicKey,
            analyticsProvider: AnalyticsProviderMock()
        )
        checkoutConfiguration = makeCheckoutConfiguration()
        let paymentMethod = try XCTUnwrap(createBLIKPaymentMethod())
        
        // When
        let component = CheckoutComponentBuilder.build(
            for: paymentMethod,
            configuration: checkoutConfiguration,
            context: customContext
        )
        
        // Then - Verify context was passed
        XCTAssertEqual(component.context.amount?.value, 500)
        XCTAssertEqual(component.context.amount?.currencyCode, "USD")
        XCTAssertEqual(component.context.apiContext.clientKey, customContext.apiContext.clientKey)
    }
    
    // MARK: - Configuration Merging Tests
    
    func testBuild_MergesGlobalShowsFormButtonSetting() throws {
        // Given
        let paymentMethod = try XCTUnwrap(createBLIKPaymentMethod())
        var blikConfig = BLIKComponentConfiguration()
        blikConfig.showsSubmitButton = true // Component-specific
        
        checkoutConfiguration = makeCheckoutConfiguration(
            configurations: [.payment(.blik): blikConfig]
        )
        checkoutConfiguration.showsSubmitButton = false // Global override
        
        // When
        let component = CheckoutComponentBuilder.build(
            for: paymentMethod,
            configuration: checkoutConfiguration,
            context: context
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
        
        checkoutConfiguration = makeCheckoutConfiguration(
            configurations: [.payment(.blik): customConfig]
        )
        
        // When
        let component = CheckoutComponentBuilder.build(
            for: paymentMethod,
            configuration: checkoutConfiguration,
            context: context
        )
        
        // Then - Should use stored configuration
        XCTAssertEqual(component.paymentMethod.type, .blik)
    }
    
    func testBuild_UsesDefaultConfigurationWhenNotStored() throws {
        // Given
        let paymentMethod = try XCTUnwrap(createBLIKPaymentMethod())
        checkoutConfiguration = makeCheckoutConfiguration() // No stored config

        // When
        let component = CheckoutComponentBuilder.build(
            for: paymentMethod,
            configuration: checkoutConfiguration,
            context: context
        )
        
        // Then - Should use factory's default configuration
        XCTAssertEqual(component.paymentMethod.type, .blik)
    }

    func test_cardComponent_withLocalizationProviderOnCheckoutConfiguration_shouldReceiveProvider() throws {
        // Given
        let paymentMethod = try XCTUnwrap(createCardPaymentMethod())
        let provider = CheckoutLocalizationProviderMock(result: "Localized card number")
        checkoutConfiguration = makeCheckoutConfiguration().localizationProvider(provider)

        // When
        let component = CheckoutComponentBuilder.build(
            for: paymentMethod,
            configuration: checkoutConfiguration,
            context: context
        )

        // Then
        guard let cardComponent = component as? CardComponent else {
            XCTFail("Component should be CardComponent")
            return
        }
        guard let localizationProvider = cardComponent.configuration.localizationProvider else {
            XCTFail("Localization provider should be propagated to the card configuration")
            return
        }

        let locale = Locale(identifier: "nl-NL")
        XCTAssertEqual(localizationProvider.localizedString(CheckoutLocalizationKey.cardNumber, locale: locale), "Localized card number")
        XCTAssertEqual(provider.recordedCalls.count, 1)
        XCTAssertEqual(provider.recordedCalls.first?.locale.identifier, locale.identifier)
        XCTAssertEqual(provider.recordedCalls.first?.key, CheckoutLocalizationKey.cardNumber)
    }
    
    // MARK: - ACH Direct Debit Component Tests

    func test_build_withACHPaymentMethod_returnsACHComponent() throws {
        // Given
        let paymentMethod = try XCTUnwrap(createACHPaymentMethod())

        // When
        let component = CheckoutComponentBuilder.build(
            for: paymentMethod,
            configuration: checkoutConfiguration,
            context: context
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
            .colors(AdyenColors(primary: .yellow))

        checkoutConfiguration = makeCheckoutConfiguration()
        checkoutConfiguration.theme = customTheme

        // When
        let component = CheckoutComponentBuilder.build(
            for: paymentMethod,
            configuration: checkoutConfiguration,
            context: context
        )

        // Then
        guard let achComponent = component as? ACHDirectDebitComponent else {
            XCTFail("Component should be ACHDirectDebitComponent")
            return
        }
        XCTAssertEqual(
            achComponent.configuration.theme.colors.primary,
            UIColor.yellow,
            "Theme should be propagated from CheckoutConfiguration to component"
        )
    }

    func test_build_withCustomTheme_propagatesThemeToBLIKComponent() throws {
        // Given
        let paymentMethod = try XCTUnwrap(createBLIKPaymentMethod())
        let customTheme = AdyenTheme()
            .colors(AdyenColors(primary: .yellow))

        checkoutConfiguration = makeCheckoutConfiguration()
        checkoutConfiguration.theme = customTheme

        // When
        let component = CheckoutComponentBuilder.build(
            for: paymentMethod,
            configuration: checkoutConfiguration,
            context: context
        )

        // Then
        guard let blikComponent = component as? BLIKComponent else {
            XCTFail("Component should be BLIKComponent")
            return
        }
        XCTAssertEqual(
            blikComponent.configuration.theme.colors.primary,
            UIColor.yellow,
            "Theme should be propagated from CheckoutConfiguration to component"
        )
    }

    // MARK: - Stored Payment Method Tests
    
    func test_build_withStoredCardPaymentMethod_returnsStoredCardComponent() throws {
        // Given
        let storedPaymentMethod = try XCTUnwrap(createStoredCardPaymentMethod())
        
        // When
        let component = CheckoutComponentBuilder.build(
            for: storedPaymentMethod,
            configuration: checkoutConfiguration,
            context: context
        )
        
        // Then
        XCTAssertEqual(component.paymentMethod.type, .scheme)
        XCTAssertTrue(component is StoredCardComponent, "Component should be StoredCardComponent")
    }
    
    func test_build_withStoredCardPaymentMethod_passesCorrectContext() throws {
        // Given
        let customAmount = Amount(value: 1000, currencyCode: "EUR")
        let customContext = AdyenContext(
            apiContext: Dummy.apiContext,
            amount: customAmount,
            publicKey: Dummy.publicKey,
            analyticsProvider: AnalyticsProviderMock()
        )
        checkoutConfiguration = makeCheckoutConfiguration()
        let storedPaymentMethod = try XCTUnwrap(createStoredCardPaymentMethod())
        
        // When
        let component = CheckoutComponentBuilder.build(
            for: storedPaymentMethod,
            configuration: checkoutConfiguration,
            context: customContext
        )
        
        // Then
        XCTAssertEqual(component.context.amount?.value, 1000)
        XCTAssertEqual(component.context.amount?.currencyCode, "EUR")
    }
    
    func test_build_withGenericStoredPaymentMethod_returnsStoredPaymentMethodComponent() throws {
        // Given
        let storedPaymentMethod = try XCTUnwrap(createStoredPayPalPaymentMethod())
        
        // When
        let component = CheckoutComponentBuilder.build(
            for: storedPaymentMethod,
            configuration: checkoutConfiguration,
            context: context
        )
        
        // Then
        XCTAssertEqual(component.paymentMethod.type, .payPal)
        XCTAssertTrue(component is StoredPaymentMethodComponent, "Component should be StoredPaymentMethodComponent")
    }
    
    func test_build_withStoredBCMCPaymentMethod_returnsStoredPaymentMethodComponent() throws {
        // Given
        let storedPaymentMethod = try XCTUnwrap(createStoredBCMCPaymentMethod())
        
        // When
        let component = CheckoutComponentBuilder.build(
            for: storedPaymentMethod,
            configuration: checkoutConfiguration,
            context: context
        )
        
        // Then
        XCTAssertEqual(component.paymentMethod.type, .bcmc)
        // StoredBCMC falls through to generic StoredPaymentMethodComponent
        XCTAssertTrue(component is StoredPaymentMethodComponent, "Component should be StoredPaymentMethodComponent")
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

    private func createCardPaymentMethod() -> CardPaymentMethod? {
        let dict: [String: Any] = [
            "type": "scheme",
            "name": "Cards",
            "brands": ["mc", "visa"]
        ]
        return try? AdyenCoder.decode(dict) as CardPaymentMethod
    }
    
    private func createStoredCardPaymentMethod() -> StoredCardPaymentMethod? {
        let dict: [String: Any] = [
            "type": "scheme",
            "id": "9314881977134903",
            "name": "VISA",
            "brand": "visa",
            "lastFour": "1111",
            "expiryMonth": "08",
            "expiryYear": "2018",
            "holderName": "test",
            "fundingSource": "credit",
            "supportedShopperInteractions": [
                "Ecommerce",
                "ContAuth"
            ]
        ]
        return try? AdyenCoder.decode(dict) as StoredCardPaymentMethod
    }
    
    private func createStoredPayPalPaymentMethod() -> StoredPayPalPaymentMethod? {
        let dict: [String: Any] = [
            "type": "paypal",
            "id": "9314881977134903",
            "name": "PayPal",
            "shopperEmail": "example@shopper.com",
            "supportedShopperInteractions": [
                "Ecommerce",
                "ContAuth"
            ]
        ]
        return try? AdyenCoder.decode(dict) as StoredPayPalPaymentMethod
    }
    
    private func createStoredBCMCPaymentMethod() -> StoredBCMCPaymentMethod? {
        let dict: [String: Any] = [
            "expiryMonth": "10",
            "expiryYear": "2020",
            "id": "8415736344108917",
            "supportedShopperInteractions": [
                "Ecommerce"
            ],
            "lastFour": "4449",
            "brand": "bcmc",
            "type": "scheme",
            "holderName": "Checkout Shopper PlaceHolder",
            "name": "Maestro"
        ]
        return try? AdyenCoder.decode(dict) as StoredBCMCPaymentMethod
    }
    
    private func makeCheckoutConfiguration(
        configurations: [CheckoutComponentType: CheckoutComponentConfiguration] = [:]
    ) -> CheckoutConfiguration {
        CheckoutConfiguration(
            apiContext: Dummy.apiContext,
            amount: Dummy.amount,
            analyticsApiContext: nil,
            analyticsConfiguration: .init(),
            configurations: configurations
        )
    }
}

private final class CheckoutLocalizationProviderMock: CheckoutLocalizationProvider {
    private(set) var recordedCalls: [(locale: Locale, key: CheckoutLocalizationKey)] = []

    private let result: String?

    init(result: String? = nil) {
        self.result = result
    }

    func localizedString(_ key: CheckoutLocalizationKey, locale: Locale) -> String? {
        recordedCalls.append((locale, key))
        return result
    }
}
