//
// Copyright (c) 2025 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@testable import Adyen
@testable import AdyenComponents
@testable import AdyenUI
import XCTest

@MainActor
final class ACHDirectDebitComponentFactoryTests: XCTestCase {

    var sut: ACHDirectDebitComponentFactory!
    var context: AdyenContext!

    override func setUp() {
        super.setUp()
        sut = ACHDirectDebitComponentFactory()
        context = Dummy.context
    }

    override func tearDown() {
        sut = nil
        context = nil
        super.tearDown()
    }

    // MARK: - Default Configuration Tests

    func test_defaultConfiguration_returnsValidConfiguration() {
        // When
        let configuration = sut.defaultConfiguration()

        // Then
        XCTAssertEqual(configuration.componentType, .payment(.achDirectDebit))
        XCTAssertTrue(configuration.showsSubmitButton)
    }

    func test_defaultConfiguration_returnsNewInstanceEachTime() {
        // When
        let config1 = sut.defaultConfiguration()
        let config2 = sut.defaultConfiguration()

        // Then - Verify they are independent instances
        var mutableConfig1 = config1
        mutableConfig1.showsSubmitButton = false

        XCTAssertTrue(config2.showsSubmitButton, "Second config should be independent")
    }

    // MARK: - Component Creation Tests

    func test_create_withValidPaymentMethod_returnsComponent() throws {
        // Given
        let paymentMethod = try XCTUnwrap(createACHPaymentMethod())
        let configuration = ACHDirectDebitComponentConfiguration()

        // When
        let component = sut.create(
            with: paymentMethod,
            context: context,
            configuration: configuration
        )

        // Then
        XCTAssertEqual(component.paymentMethod.type, .achDirectDebit)
        XCTAssertEqual(component.context.apiContext.clientKey, context.apiContext.clientKey)
    }

    func test_create_withCustomConfiguration_usesProvidedConfiguration() throws {
        // Given
        let paymentMethod = try XCTUnwrap(createACHPaymentMethod())
        var configuration = ACHDirectDebitComponentConfiguration()
        configuration.showsSubmitButton = false

        // When
        let component = sut.create(
            with: paymentMethod,
            context: context,
            configuration: configuration
        )

        // Then
        XCTAssertEqual(component.paymentMethod.type, .achDirectDebit)
        XCTAssertFalse(
            component.configuration.showsSubmitButton,
            "The component's configuration should reflect the custom setting."
        )
    }

    func test_create_preservesPaymentMethodReference() throws {
        // Given
        let paymentMethod = try XCTUnwrap(createACHPaymentMethod())
        let configuration = ACHDirectDebitComponentConfiguration()

        // When
        let component = sut.create(
            with: paymentMethod,
            context: context,
            configuration: configuration
        )

        // Then
        XCTAssertEqual(component.paymentMethod.type, paymentMethod.type)
        XCTAssertEqual(component.paymentMethod.name, paymentMethod.name)
    }

    func test_create_preservesContext() throws {
        // Given
        let customAmount = Amount(value: 999, currencyCode: "USD")
        let customContext = AdyenContext(
            apiContext: Dummy.apiContext,
            amount: customAmount,
            publicKey: Dummy.publicKey,
            analyticsProvider: AnalyticsProviderMock()
        )
        let paymentMethod = try XCTUnwrap(createACHPaymentMethod())
        let configuration = ACHDirectDebitComponentConfiguration()

        // When
        let component = sut.create(
            with: paymentMethod,
            context: customContext,
            configuration: configuration
        )

        // Then
        XCTAssertEqual(component.context.amount?.value, 999)
        XCTAssertEqual(component.context.amount?.currencyCode, "USD")
    }

    // MARK: - Theme Propagation Tests

    func test_create_withCustomTheme_propagatesThemeToComponent() throws {
        // Given
        let paymentMethod = try XCTUnwrap(createACHPaymentMethod())
        var configuration = ACHDirectDebitComponentConfiguration()

        let customTheme = CheckoutTheme()
            .colors(AdyenColors(primary: .systemPink))
        configuration.theme = customTheme

        // When
        let component = sut.create(
            with: paymentMethod,
            context: context,
            configuration: configuration
        )

        // Then - Theme should be preserved in configuration
        XCTAssertEqual(
            component.configuration.theme.colors.primary,
            UIColor.systemPink,
            "Theme should be propagated to component configuration"
        )
    }

    // MARK: - Type Conformance Tests

    func test_factory_conformsToPaymentComponentFactory() {
        // Then
        XCTAssertNotNil(sut as any PaymentComponentFactory)
    }

    func test_factory_hasCorrectAssociatedTypes() throws {
        // Given
        let paymentMethod = try XCTUnwrap(createACHPaymentMethod())
        let configuration = sut.defaultConfiguration()

        // When
        let component = sut.create(
            with: paymentMethod,
            context: context,
            configuration: configuration
        )

        // Then - Verify types through their properties
        XCTAssertEqual(paymentMethod.type, .achDirectDebit)
        XCTAssertEqual(configuration.componentType, .payment(.achDirectDebit))
        XCTAssertEqual(component.paymentMethod.type, .achDirectDebit)
    }

    // MARK: - Multiple Component Creation Tests

    func test_create_multipleComponents_areIndependent() throws {
        // Given
        let paymentMethod1 = try XCTUnwrap(createACHPaymentMethod())
        let paymentMethod2 = try XCTUnwrap(createACHPaymentMethod())
        let configuration = ACHDirectDebitComponentConfiguration()

        // When
        let component1 = sut.create(
            with: paymentMethod1, context: context, configuration: configuration
        )
        let component2 = sut.create(
            with: paymentMethod2, context: context, configuration: configuration
        )

        // Then - Components should be independent instances
        XCTAssertNotIdentical(component1 as AnyObject, component2 as AnyObject)
    }

    // MARK: - Helper Methods

    private func createACHPaymentMethod() -> ACHDirectDebitPaymentMethod? {
        let dict: [String: Any] = [
            "type": "ach",
            "name": "ACH Direct Debit"
        ]
        return try? AdyenCoder.decode(dict) as ACHDirectDebitPaymentMethod
    }
}
