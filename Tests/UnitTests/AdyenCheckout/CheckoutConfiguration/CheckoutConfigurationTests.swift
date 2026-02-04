//
// Copyright (c) 2025 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) @testable import Adyen
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
        
        let checkoutConfig = CheckoutConfiguration(
            context: context,
            configurations: [.payment(.blik): blikConfig],
            analyticsConfiguration: AnalyticsConfiguration()
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
        let checkoutConfig = CheckoutConfiguration(context: context, analyticsConfiguration: AnalyticsConfiguration())
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
        
        let checkoutConfig = CheckoutConfiguration(
            context: context,
            configurations: [.payment(.blik): blikConfig],
            analyticsConfiguration: AnalyticsConfiguration()
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
        let checkoutConfig = CheckoutConfiguration(context: context, analyticsConfiguration: AnalyticsConfiguration())
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
    
    // MARK: - Legacy componentConfiguration Tests
    
    func testComponentConfiguration_WithExistingConfiguration_ReturnsConfiguration() throws {
        // Given
        let blikConfig = BLIKComponentConfiguration()
        let checkoutConfig = CheckoutConfiguration(
            context: context,
            configurations: [.payment(.blik): blikConfig],
            analyticsConfiguration: AnalyticsConfiguration()
        )
        let paymentMethod = try XCTUnwrap(createBLIKPaymentMethod())
        
        // When
        let resolvedConfig = checkoutConfig.configuration(for: paymentMethod, defaultValue: BLIKComponentConfiguration())
        
        // Then
        XCTAssertNotNil(resolvedConfig)
        
        XCTAssertNotNil(resolvedConfig, "Should be BLIKComponentConfiguration")
        XCTAssertEqual(resolvedConfig.componentType, .payment(.blik))
    }
    
    // MARK: - Helper Methods
    
    private func createBLIKPaymentMethod() -> BLIKPaymentMethod? {
        let dict: [String: Any] = [
            "type": "blik",
            "name": "BLIK"
        ]
        return try? AdyenCoder.decode(dict) as BLIKPaymentMethod
    }
}
