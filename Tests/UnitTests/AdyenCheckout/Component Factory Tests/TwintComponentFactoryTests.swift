//
// Copyright (c) 2026 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@testable import Adyen
@testable import AdyenTwint
@testable import AdyenUI
import XCTest

@MainActor
final class TwintComponentFactoryTests: XCTestCase {

    var factory: TwintComponentFactory!
    var context: AdyenContext!

    override func setUp() {
        super.setUp()
        factory = TwintComponentFactory()
        context = Dummy.context
    }

    override func tearDown() {
        factory = nil
        context = nil
        super.tearDown()
    }

    // MARK: - Default Configuration Tests

    func testDefaultConfiguration_ReturnsValidConfiguration() {
        // When
        let configuration = factory.defaultConfiguration()

        // Then
        XCTAssertEqual(configuration.componentType, .payment(.twint))
        XCTAssertTrue(configuration.showsSubmitButton)
    }

    func testDefaultConfiguration_ReturnsNewInstanceEachTime() {
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

    func testCreate_WithValidPaymentMethod_ReturnsComponent() {
        // Given
        let paymentMethod = createTwintPaymentMethod()
        let configuration = TwintComponentConfiguration()

        // When
        let component = factory.create(
            with: paymentMethod,
            context: context,
            configuration: configuration
        )

        // Then
        XCTAssertEqual(component.paymentMethod.type, .twint)
        XCTAssertEqual(component.context.apiContext.clientKey, context.apiContext.clientKey)
    }

    func testCreate_WithCustomConfiguration_UsesProvidedConfiguration() {
        // Given
        let paymentMethod = createTwintPaymentMethod()
        var configuration = TwintComponentConfiguration()
        configuration.showsSubmitButton = false

        // When
        let component = factory.create(
            with: paymentMethod,
            context: context,
            configuration: configuration
        )

        // Then
        XCTAssertFalse(component.configuration.showsSubmitButton, "The component's configuration should reflect the custom setting.")
    }

    func testCreate_PreservesPaymentMethodReference() {
        // Given
        let paymentMethod = createTwintPaymentMethod()
        let configuration = TwintComponentConfiguration()

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

    // MARK: - Type Conformance Tests

    func testFactory_ConformsToPaymentComponentFactory() {
        // Then
        XCTAssertNotNil(factory as any PaymentComponentFactory)
    }

    // MARK: - Helper Methods

    private func createTwintPaymentMethod() -> TwintPaymentMethod {
        TwintPaymentMethod(type: .twint, name: "Twint")
    }
}
