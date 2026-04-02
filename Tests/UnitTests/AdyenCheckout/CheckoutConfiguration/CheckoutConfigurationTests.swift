//
// Copyright (c) 2025 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) @testable import Adyen
@_spi(AdyenInternal) @testable import AdyenActions
@_spi(AdyenInternal) @testable import AdyenCheckout
@_spi(AdyenInternal) @testable import AdyenComponents
@_spi(AdyenInternal) @testable import AdyenUI
import XCTest

final class CheckoutConfigurationTests: XCTestCase {
    
    var context: AdyenContext!
    
    override func setUp() {
        super.setUp()
        context = Dummy.context
    }
    
    override func tearDown() {
        context = nil
        super.tearDown()
    }

    // MARK: - Configuration Resolution Tests
    
    func testConfiguration_WithExistingConfiguration_ReturnsStoredConfiguration() throws {
        // Given
        var blikConfig = BLIKComponentConfiguration()
        blikConfig.showsSubmitButton = false // Custom value
        
        let checkoutConfig = makeCheckoutConfiguration(
            configurations: [.payment(.blik): blikConfig]
        )
        let paymentMethod = try XCTUnwrap(createBLIKPaymentMethod())
        
        // When
        let resolvedConfig: BLIKComponentConfiguration = checkoutConfig.configuration(
            for: paymentMethod,
            defaultValue: BLIKComponentConfiguration()
        )
        
        // Then - Should return the stored configuration with custom value
        XCTAssertEqual(resolvedConfig.componentType, .payment(.blik))
        XCTAssertFalse(resolvedConfig.showsSubmitButton, "Should use stored configuration value")
    }
    
    func testConfiguration_WithoutExistingConfiguration_ReturnsDefaultValue() throws {
        // Given
        let checkoutConfig = makeCheckoutConfiguration()
        let paymentMethod = try XCTUnwrap(createBLIKPaymentMethod())
        var defaultConfig = BLIKComponentConfiguration()
        defaultConfig.showsSubmitButton = false // Custom default
        
        // When
        let resolvedConfig: BLIKComponentConfiguration = checkoutConfig.configuration(
            for: paymentMethod,
            defaultValue: defaultConfig
        )
        
        // Then - Should return the default value
        XCTAssertEqual(resolvedConfig.componentType, .payment(.blik))
        XCTAssertFalse(resolvedConfig.showsSubmitButton, "Should use default value")
    }
    
    func testConfiguration_AutoclosureNotEvaluatedWhenConfigExists() throws {
        // Given
        var blikConfig = BLIKComponentConfiguration()
        blikConfig.showsSubmitButton = false
        
        let checkoutConfig = makeCheckoutConfiguration(
            configurations: [.payment(.blik): blikConfig]
        )
        let paymentMethod = try XCTUnwrap(createBLIKPaymentMethod())
        var defaultWasCalled = false
        
        // When
        let resolvedConfig: BLIKComponentConfiguration = checkoutConfig.configuration(
            for: paymentMethod,
            defaultValue: {
                defaultWasCalled = true
                return BLIKComponentConfiguration()
            }()
        )
        
        // Then - Default should not be evaluated since config exists
        XCTAssertFalse(defaultWasCalled, "Autoclosure should not be evaluated when config exists")
        XCTAssertFalse(resolvedConfig.showsSubmitButton, "Should use stored config")
    }
    
    func testConfiguration_AutoclosureEvaluatedWhenConfigMissing() throws {
        // Given
        let checkoutConfig = makeCheckoutConfiguration()
        let paymentMethod = try XCTUnwrap(createBLIKPaymentMethod())
        var defaultWasCalled = false
        
        // When
        let _: BLIKComponentConfiguration = checkoutConfig.configuration(
            for: paymentMethod,
            defaultValue: {
                defaultWasCalled = true
                return BLIKComponentConfiguration()
            }()
        )
        
        // Then - Default should be evaluated since no config exists
        XCTAssertTrue(defaultWasCalled, "Autoclosure should be evaluated when config is missing")
    }

    func test_checkoutConfiguration_withLocalizationProvider_shouldStoreProvider() {
        // Given
        let provider = CheckoutLocalizationProviderMock()

        // When
        let checkoutConfig = makeCheckoutConfiguration().localizationProvider(provider)

        // Then
        guard let storedProvider = checkoutConfig.localizationProvider as? CheckoutLocalizationProviderMock else {
            XCTFail("Localization provider should be stored on checkout configuration")
            return
        }

        XCTAssertTrue(storedProvider === provider)
    }
    
    // MARK: - Legacy componentConfiguration Tests
    
    func testComponentConfiguration_WithExistingConfiguration_ReturnsConfiguration() throws {
        // Given
        let blikConfig = BLIKComponentConfiguration()
        let checkoutConfig = makeCheckoutConfiguration(
            configurations: [.payment(.blik): blikConfig]
        )
        let paymentMethod = try XCTUnwrap(createBLIKPaymentMethod())
        
        // When
        let resolvedConfig = checkoutConfig.configuration(for: paymentMethod, defaultValue: BLIKComponentConfiguration())
        
        // Then
        XCTAssertNotNil(resolvedConfig)
        
        XCTAssertNotNil(resolvedConfig, "Should be BLIKComponentConfiguration")
        XCTAssertEqual(resolvedConfig.componentType, .payment(.blik))
    }
    
    // MARK: - Action Configuration Tests
    
    func testActionConfiguration_WithDefaultValue_ReturnsProvidedConfiguration() throws {
        // Given
        let threeDS2Config = try ThreeDS2ActionConfiguration()
            .requestorAppURL(XCTUnwrap(URL(string: "https://example.com")))
        
        let checkoutConfig = makeCheckoutConfiguration(
            configurations: [.action(.threeDS2): threeDS2Config]
        )
        
        // When
        let resolvedConfig: ThreeDS2ActionConfiguration = checkoutConfig.configuration(
            for: .threeDS2,
            defaultValue: ThreeDS2ActionConfiguration()
        )
        
        // Then - Should return the stored configuration
        XCTAssertEqual(resolvedConfig.componentType, .action(.threeDS2))
        XCTAssertEqual(resolvedConfig.requestorAppURL, URL(string: "https://example.com"))
    }
    
    func testActionConfiguration_WithDefaultValue_ReturnsDefaultWhenMissing() throws {
        // Given
        let checkoutConfig = makeCheckoutConfiguration()
        let defaultConfig = try ThreeDS2ActionConfiguration()
            .requestorAppURL(XCTUnwrap(URL(string: "https://default.com")))
        
        // When
        let resolvedConfig: ThreeDS2ActionConfiguration = checkoutConfig.configuration(
            for: .threeDS2,
            defaultValue: defaultConfig
        )
        
        // Then - Should return the default value
        XCTAssertEqual(resolvedConfig.componentType, .action(.threeDS2))
        XCTAssertEqual(resolvedConfig.requestorAppURL, URL(string: "https://default.com"))
    }
    
    func testActionConfiguration_Optional_ReturnsProvidedConfiguration() throws {
        // Given
        let threeDS2Config = try ThreeDS2ActionConfiguration()
            .requestorAppURL(XCTUnwrap(URL(string: "https://example.com")))
        
        let checkoutConfig = makeCheckoutConfiguration(
            configurations: [.action(.threeDS2): threeDS2Config]
        )
        
        // When
        let resolvedConfig: ThreeDS2ActionConfiguration? = checkoutConfig.configuration(for: .threeDS2)
        
        // Then - Should return the stored configuration
        XCTAssertNotNil(resolvedConfig)
        XCTAssertEqual(resolvedConfig?.componentType, .action(.threeDS2))
        XCTAssertEqual(resolvedConfig?.requestorAppURL, URL(string: "https://example.com"))
    }
    
    func testActionConfiguration_Optional_ReturnsNilWhenMissing() {
        // Given
        let checkoutConfig = makeCheckoutConfiguration()

        // When
        let resolvedConfig: ThreeDS2ActionConfiguration? = checkoutConfig.configuration(for: .threeDS2)
        
        // Then - Should return nil
        XCTAssertNil(resolvedConfig)
    }
    
    func testActionConfiguration_TwintConfiguration_ReturnsProvidedConfiguration() {
        // Given
        let twintConfig = TwintActionConfiguration(callbackAppScheme: "my-app")
            .maxIssuerNumber(39)
        
        let checkoutConfig = makeCheckoutConfiguration(
            configurations: [.action(.twint): twintConfig]
        )
        
        // When - Using defaultValue variant
        let resolvedConfig: TwintActionConfiguration = checkoutConfig.configuration(
            for: .twint,
            defaultValue: TwintActionConfiguration(callbackAppScheme: "default-app")
        )
        
        // Then
        XCTAssertEqual(resolvedConfig.componentType, .action(.twint))
        XCTAssertEqual(resolvedConfig.callbackAppScheme, "my-app")
        XCTAssertEqual(resolvedConfig.maxIssuerNumber, 39)
    }
    
    func testActionConfiguration_TwintConfiguration_Optional_ReturnsProvidedConfiguration() {
        // Given
        let twintConfig = TwintActionConfiguration(callbackAppScheme: "my-app")
            .maxIssuerNumber(39)
        
        let checkoutConfig = makeCheckoutConfiguration(
            configurations: [.action(.twint): twintConfig]
        )
        
        // When - Using optional variant
        let resolvedConfig: TwintActionConfiguration? = checkoutConfig.configuration(for: .twint)
        
        // Then
        XCTAssertNotNil(resolvedConfig)
        XCTAssertEqual(resolvedConfig?.callbackAppScheme, "my-app")
        XCTAssertEqual(resolvedConfig?.maxIssuerNumber, 39)
    }
    
    func testActionConfiguration_AutoclosureNotEvaluatedWhenConfigExists() {
        // Given
        let threeDS2Config = ThreeDS2ActionConfiguration()
        
        let checkoutConfig = makeCheckoutConfiguration(
            configurations: [.action(.threeDS2): threeDS2Config]
        )
        var defaultWasCalled = false
        
        // When
        let _: ThreeDS2ActionConfiguration = checkoutConfig.configuration(
            for: .threeDS2,
            defaultValue: {
                defaultWasCalled = true
                return ThreeDS2ActionConfiguration()
            }()
        )
        
        // Then - Default should not be evaluated since config exists
        XCTAssertFalse(defaultWasCalled, "Autoclosure should not be evaluated when config exists")
    }
    
    func testActionConfiguration_AutoclosureEvaluatedWhenConfigMissing() {
        // Given
        let checkoutConfig = makeCheckoutConfiguration()
        var defaultWasCalled = false
        
        // When
        let _: ThreeDS2ActionConfiguration = checkoutConfig.configuration(
            for: .threeDS2,
            defaultValue: {
                defaultWasCalled = true
                return ThreeDS2ActionConfiguration()
            }()
        )
        
        // Then - Default should be evaluated since no config exists
        XCTAssertTrue(defaultWasCalled, "Autoclosure should be evaluated when config is missing")
    }
    
    // MARK: - Helper Methods
    
    private func createBLIKPaymentMethod() -> BLIKPaymentMethod? {
        let dict: [String: Any] = [
            "type": "blik",
            "name": "BLIK"
        ]
        return try? AdyenCoder.decode(dict) as BLIKPaymentMethod
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
    func localizedString(_ key: CheckoutLocalizationKey, locale: Locale) -> String? {
        nil
    }
}
