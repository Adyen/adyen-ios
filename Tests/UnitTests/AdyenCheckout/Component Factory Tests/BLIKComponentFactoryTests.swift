//
// Copyright (c) Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) @testable import Adyen
@_spi(AdyenInternal) @testable import AdyenComponents
@_spi(AdyenInternal) @testable import AdyenUI
import XCTest

final class BLIKComponentFactoryTests: XCTestCase {
    
    var factory: BLIKComponentFactory!
    var context: AdyenContext!
    
    override func setUp() {
        super.setUp()
        factory = BLIKComponentFactory()
        context = Dummy.context
    }
    
    override func tearDown() {
        factory = nil
        context = nil
        super.tearDown()
    }
    
    // MARK: - Default Configuration Tests
    
    func testdefaultConfiguration_ReturnsValidConfiguration() {
        // When
        let configuration = factory.defaultConfiguration()
        
        // Then
        XCTAssertEqual(configuration.configurationType, .payment(.blik))
        XCTAssertTrue(configuration.showsSubmitButton)
    }
    
    func testdefaultConfiguration_ReturnsNewInstanceEachTime() {
        // When
        let config1 = factory.defaultConfiguration()
        let config2 = factory.defaultConfiguration()
        
        // Then - Verify they are independent instances by checking identity
        // (For structs, we can modify one and verify the other is unchanged)
        var mutableConfig1 = config1
        mutableConfig1.showsSubmitButton = false
        
        XCTAssertTrue(config2.showsSubmitButton, "Second config should be independent")
    }
    
    // MARK: - Component Creation Tests
    
    func testCreate_WithValidPaymentMethod_ReturnsComponent() throws {
        // Given
        let paymentMethod = try XCTUnwrap(createBLIKPaymentMethod())
        let configuration = BLIKComponentConfiguration()
        
        // When
        let component = factory.create(
            with: paymentMethod,
            context: context,
            configuration: configuration
        )
        
        // Then
        XCTAssertEqual(component.paymentMethod.type, .blik)
        XCTAssertEqual(component.context.apiContext.clientKey, context.apiContext.clientKey)
    }
    
    func testCreate_WithCustomConfiguration_UsesProvidedConfiguration() throws {
        // Given
        let paymentMethod = try XCTUnwrap(createBLIKPaymentMethod())
        var configuration = BLIKComponentConfiguration()
        configuration.showsSubmitButton = false
        
        // When
        let component = factory.create(
            with: paymentMethod,
            context: context,
            configuration: configuration
        )
        
        // Then
        XCTAssertEqual(component.paymentMethod.type, .blik)
        XCTAssertFalse(component.configuration.showsSubmitButton, "The component's configuration should reflect the custom setting.")
    }
    
    func testCreate_PreservesPaymentMethodReference() throws {
        // Given
        let paymentMethod = try XCTUnwrap(createBLIKPaymentMethod())
        let configuration = BLIKComponentConfiguration()
        
        // When
        let component = factory.create(
            with: paymentMethod,
            context: context,
            configuration: configuration
        )
        
        // Then
        XCTAssertEqual(component.paymentMethod.type, paymentMethod.type)
        XCTAssertEqual(component.paymentMethod.name, paymentMethod.name)
    }
    
    func testCreate_PreservesContext() throws {
        // Given
        let customAmount = Amount(value: 999, currencyCode: "EUR")
        let customContext = AdyenContext(
            apiContext: Dummy.apiContext,
            payment: Payment(amount: customAmount, countryCode: "NL"),
            amount: customAmount
        )
        let paymentMethod = try XCTUnwrap(createBLIKPaymentMethod())
        let configuration = BLIKComponentConfiguration()
        
        // When
        let component = factory.create(
            with: paymentMethod,
            context: customContext,
            configuration: configuration
        )
        
        // Then
        XCTAssertEqual(component.context.amount.value, 999)
        XCTAssertEqual(component.context.amount.currencyCode, "EUR")
    }
    
    // MARK: - Type Conformance Tests
    
    func testFactory_ConformsToPaymentComponentFactory() {
        // Then
        XCTAssertNotNil(factory as any PaymentComponentFactory)
    }
    
    func testFactory_HasCorrectAssociatedTypes() throws {
        // Given
        let paymentMethod = try XCTUnwrap(createBLIKPaymentMethod())
        let configuration = factory.defaultConfiguration()
        
        // When
        let component = factory.create(
            with: paymentMethod,
            context: context,
            configuration: configuration
        )
        
        // Then - Verify types through their properties
        XCTAssertEqual(paymentMethod.type, .blik)
        XCTAssertEqual(configuration.configurationType, .payment(.blik))
        XCTAssertEqual(component.paymentMethod.type, .blik)
    }
    
    // MARK: - Multiple Component Creation Tests
    
    func testCreate_MultipleComponents_AreIndependent() throws {
        // Given
        let paymentMethod1 = try XCTUnwrap(createBLIKPaymentMethod())
        let paymentMethod2 = try XCTUnwrap(createBLIKPaymentMethod())
        let configuration = BLIKComponentConfiguration()
        
        // When
        let component1 = factory.create(with: paymentMethod1, context: context, configuration: configuration)
        let component2 = factory.create(with: paymentMethod2, context: context, configuration: configuration)
        
        // Then - Components should be independent instances
        XCTAssertNotIdentical(component1 as AnyObject, component2 as AnyObject)
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
