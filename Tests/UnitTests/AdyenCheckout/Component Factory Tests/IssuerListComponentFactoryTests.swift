//
// Copyright (c) 2026 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@testable import Adyen
@testable import AdyenComponents
@testable import AdyenUI
import XCTest

@MainActor
final class IssuerListComponentFactoryTests: XCTestCase {

    var factory: IssuerListComponentFactory!
    var context: AdyenContext!

    override func setUp() {
        super.setUp()
        factory = IssuerListComponentFactory()
        context = Dummy.context
    }

    override func tearDown() {
        factory = nil
        context = nil
        super.tearDown()
    }

    // MARK: - Default Configuration Tests

    func test_defaultConfiguration_shouldShowSubmitButton() {
        // When
        let configuration = factory.defaultConfiguration()

        // Then
        XCTAssertTrue(configuration.showsSubmitButton)
    }

    func test_defaultConfiguration_shouldReturnIndependentInstances() {
        // Given
        var configuration1 = factory.defaultConfiguration()
        let configuration2 = factory.defaultConfiguration()

        // When
        configuration1.showsSubmitButton = false

        // Then
        XCTAssertTrue(configuration2.showsSubmitButton, "Second config should be independent")
    }

    // MARK: - Component Creation Tests

    func test_create_withPaymentMethod_shouldReturnComponentForPaymentMethod() throws {
        // Given
        let paymentMethod = try makePaymentMethod()

        // When
        let component = try factory.create(
            with: paymentMethod,
            context: context,
            configuration: factory.defaultConfiguration(),
            callbacks: nil
        )

        // Then
        XCTAssertEqual(component.paymentMethod.type, .eps)
        XCTAssertEqual(component.paymentMethod.name, paymentMethod.name)
        XCTAssertEqual(component.context.apiContext.clientKey, context.apiContext.clientKey)
    }

    func test_create_withCustomConfiguration_shouldUseProvidedConfiguration() throws {
        // Given
        let paymentMethod = try makePaymentMethod()
        var configuration = IssuerListConfiguration()
        configuration.showsSubmitButton = false

        // When
        let component = try factory.create(
            with: paymentMethod,
            context: context,
            configuration: configuration,
            callbacks: nil
        )

        // Then
        XCTAssertFalse(component.configuration.showsSubmitButton)
    }

    func test_create_withCustomContext_shouldPreserveContext() throws {
        // Given
        let customContext = AdyenContext(
            apiContext: Dummy.apiContext,
            amount: Amount(value: 999, currencyCode: "EUR"),
            publicKey: Dummy.publicKey,
            browserInfo: nil,
            analyticsProvider: AnalyticsProviderMock()
        )

        // When
        let component = try factory.create(
            with: makePaymentMethod(),
            context: customContext,
            configuration: factory.defaultConfiguration(),
            callbacks: nil
        )

        // Then
        XCTAssertEqual(component.context.amount?.value, 999)
        XCTAssertEqual(component.context.amount?.currencyCode, "EUR")
    }

    func test_create_calledTwice_shouldReturnIndependentComponents() throws {
        // Given
        let paymentMethod = try makePaymentMethod()
        let configuration = factory.defaultConfiguration()

        // When
        let component1 = try factory.create(with: paymentMethod, context: context, configuration: configuration, callbacks: nil)
        let component2 = try factory.create(with: paymentMethod, context: context, configuration: configuration, callbacks: nil)

        // Then
        XCTAssertNotIdentical(component1, component2)
    }

    func test_create_withoutIssuers_shouldThrowPaymentMethodFailure() throws {
        // Given
        let paymentMethod = try makePaymentMethod(issuerCount: 0)

        // When / Then
        XCTAssertThrowsError(
            try factory.create(
                with: paymentMethod,
                context: context,
                configuration: factory.defaultConfiguration(),
                callbacks: nil
            )
        ) { error in
            XCTAssertEqual((error as? CheckoutError)?.code, .paymentMethodFailure)
        }
    }

    // MARK: - Availability Tests

    func test_isAvailable_withIssuers_shouldReturnTrue() throws {
        XCTAssertTrue(try factory.isAvailable(for: makePaymentMethod(), configuration: factory.defaultConfiguration()))
    }

    func test_isAvailable_withoutIssuers_shouldReturnFalse() throws {
        XCTAssertFalse(try factory.isAvailable(for: makePaymentMethod(issuerCount: 0), configuration: factory.defaultConfiguration()))
    }

    // MARK: - Helpers

    private func makePaymentMethod(issuerCount: Int = 2) throws -> IssuerListPaymentMethod {
        let issuers = (0..<issuerCount).map { ["id": "issuer_\($0)", "name": "Issuer \($0)"] }
        return try AdyenCoder.decode([
            "type": "eps",
            "name": "EPS",
            "issuers": issuers
        ] as [String: Any]) as IssuerListPaymentMethod
    }
}
