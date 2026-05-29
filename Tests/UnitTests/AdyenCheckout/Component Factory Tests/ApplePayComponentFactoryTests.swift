//
// Copyright (c) 2026 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@testable import Adyen
@testable import AdyenComponents
@testable import AdyenUI
import PassKit
import XCTest

@MainActor
final class ApplePayComponentFactoryTests: XCTestCase {

    var factory: ApplePayComponentFactory!
    var context: AdyenContext!

    override func setUp() {
        super.setUp()
        factory = ApplePayComponentFactory()
        context = Dummy.context
    }

    override func tearDown() {
        factory = nil
        context = nil
        super.tearDown()
    }

    // MARK: - Default Configuration Tests

    func testDefaultConfiguration_Throws() {
        // Apple Pay has no usable default because merchant identifier and payment request
        // are merchant-specific and cannot be inferred. The factory must signal this
        // explicitly so callers cannot silently fall through.
        XCTAssertThrowsError(try factory.defaultConfiguration()) { error in
            XCTAssertTrue(error is UnknownError)
        }
    }

    // MARK: - Component Creation Tests

    func testCreate_WithValidConfiguration_ReturnsComponent() throws {
        // Given
        let paymentMethod = try XCTUnwrap(createApplePayPaymentMethod())
        let configuration = try ApplePayConfiguration(
            paymentRequest: Dummy.createTestApplePayPaymentRequest()
        )

        // When
        let component = try factory.create(
            with: paymentMethod,
            context: context,
            configuration: configuration
        )

        // Then
        XCTAssertEqual(component.paymentMethod.type, .applePay)
        XCTAssertEqual(component.context.apiContext.clientKey, context.apiContext.clientKey)
    }

    func testCreate_PreservesConfigurationValues() throws {
        // Given
        let paymentMethod = try XCTUnwrap(createApplePayPaymentMethod())
        let configuration = try ApplePayConfiguration(
            paymentRequest: Dummy.createTestApplePayPaymentRequest()
        )

        // When
        let component = try factory.create(
            with: paymentMethod,
            context: context,
            configuration: configuration
        )

        // Then
        XCTAssertTrue(component.configuration.allowOnboarding)
    }

    // MARK: - Type Conformance Tests

    func testFactory_ConformsToPaymentComponentFactory() {
        XCTAssertNotNil(factory as any PaymentComponentFactory)
    }

    // MARK: - Helper Methods

    private func createApplePayPaymentMethod() -> ApplePayPaymentMethod? {
        try? AdyenCoder.decode(applePayDictionary) as ApplePayPaymentMethod
    }
}
