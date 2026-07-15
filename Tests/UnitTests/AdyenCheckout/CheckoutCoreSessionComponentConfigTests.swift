//
// Copyright (c) 2026 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) @testable import Adyen
@testable import AdyenCard
@testable import AdyenCheckout
@testable import AdyenComponents
@testable import AdyenSession
import XCTest

/// Tests that Checkout assembly applies session-driven component configuration before component initialization.
@MainActor
final class CheckoutCoreSessionComponentConfigTests: XCTestCase {

    private var paymentMethods: PaymentMethods!
    private var configuration: CheckoutConfiguration!

    override func setUp() {
        super.setUp()
        let paymentMethodsDictionary: [String: Any] = ["paymentMethods": [creditCardDictionary, achDirectDebit]]
        paymentMethods = try! AdyenCoder.decode(paymentMethodsDictionary) as PaymentMethods
        configuration = CheckoutConfiguration(
            apiContext: Dummy.apiContext,
            amount: Dummy.amount,
            analyticsApiContext: nil,
            analyticsConfiguration: .init()
        )
    }

    // MARK: - isSession

    func test_isSession_withSession_isTrue() {
        let sut = makeSessionCheckoutCore()
        XCTAssertTrue(sut.isSession)
    }

    func test_isSession_withoutSession_isFalse() {
        let sut = makeAdvancedCheckoutCore()
        XCTAssertFalse(sut.isSession)
    }

    // MARK: - Card component configuration

    func test_cardComponent_sessionFlow_installmentConfiguration_appliedFromSession() throws {
        let installments = InstallmentConfiguration(
            defaultOptions: InstallmentOptions(maxInstallmentMonth: 6, includesRevolving: false)
        )
        let sut = makeSessionCheckoutCore(installmentOptions: installments)

        let component = try sut.createPaymentComponent(for: .scheme)
        let cardComponent = try XCTUnwrap(component.paymentComponent as? CardComponent)

        XCTAssertEqual(cardComponent.configuration.installmentConfiguration, installments)
    }

    func test_cardComponent_sessionFlow_showStorePaymentMethod_falseAppliedFromSession() throws {
        let sut = makeSessionCheckoutCore(enableStoreDetails: false)

        let component = try sut.createPaymentComponent(for: .scheme)
        let cardComponent = try XCTUnwrap(component.paymentComponent as? CardComponent)

        XCTAssertFalse(cardComponent.configuration.showStorePaymentMethod)
    }

    func test_cardComponent_sessionFlow_showStorePaymentMethod_trueAppliedFromSession() throws {
        let sut = makeSessionCheckoutCore(enableStoreDetails: true)

        let component = try sut.createPaymentComponent(for: .scheme)
        let cardComponent = try XCTUnwrap(component.paymentComponent as? CardComponent)

        XCTAssertTrue(cardComponent.configuration.showStorePaymentMethod)
    }

    func test_cardComponent_advancedFlow_merchantInstallments_notClobbered() throws {
        let merchantInstallments = InstallmentConfiguration(
            defaultOptions: InstallmentOptions(maxInstallmentMonth: 12, includesRevolving: true)
        )
        configuration.configurations[.payment(.scheme)] = CardConfiguration()
            .installmentConfiguration(merchantInstallments)
        let sut = makeAdvancedCheckoutCore()

        // When
        let component = try sut.createPaymentComponent(for: .scheme)
        let cardComponent = try XCTUnwrap(component.paymentComponent as? CardComponent)

        XCTAssertEqual(cardComponent.configuration.installmentConfiguration, merchantInstallments)
    }

    func test_cardComponent_advancedFlow_showStorePaymentMethod_notClobbered() throws {
        configuration.configurations[.payment(.scheme)] = CardConfiguration()
            .showStorePaymentMethod(false)
        let sut = makeAdvancedCheckoutCore()

        // When
        let component = try sut.createPaymentComponent(for: .scheme)
        let cardComponent = try XCTUnwrap(component.paymentComponent as? CardComponent)

        XCTAssertFalse(cardComponent.configuration.showStorePaymentMethod)
    }

    // MARK: - ACH component configuration

    func test_achComponent_sessionFlow_showStorePaymentMethod_falseAppliedFromSession() throws {
        let sut = makeSessionCheckoutCore(enableStoreDetails: false)

        let component = try sut.createPaymentComponent(for: .achDirectDebit)
        let achComponent = try XCTUnwrap(component.paymentComponent as? ACHDirectDebitComponent)

        XCTAssertFalse(achComponent.configuration.showStorePaymentMethodField)
    }

    func test_achComponent_advancedFlow_showStorePaymentMethod_notClobbered() throws {
        configuration.configurations[.payment(.achDirectDebit)] = ACHDirectDebitComponentConfiguration()
            .showStorePaymentMethodField(false)
        let sut = makeAdvancedCheckoutCore()

        let component = try sut.createPaymentComponent(for: .achDirectDebit)
        let achComponent = try XCTUnwrap(component.paymentComponent as? ACHDirectDebitComponent)

        XCTAssertFalse(achComponent.configuration.showStorePaymentMethodField)
    }

    // MARK: - Helpers

    private func makeSessionCheckoutCore(
        installmentOptions: InstallmentConfiguration? = nil,
        enableStoreDetails: Bool = true
    ) -> CheckoutCore {
        let session = AdyenSessionMock(state: .init(
            data: "test_data",
            identifier: "test_id",
            countryCode: "US",
            shopperLocale: "en_US",
            amount: Dummy.amount,
            paymentMethods: paymentMethods,
            responseConfiguration: .init(
                installmentOptions: installmentOptions,
                enableStoreDetails: enableStoreDetails
            )
        ))
        let callbackStore = SessionCheckoutCallbackStore()
        return CheckoutCore(
            configuration: configuration,
            session: session,
            paymentMethods: paymentMethods,
            adyenContext: Dummy.context,
            presentationDelegate: nil,
            resultCallbacks: callbackStore,
            callbackHandler: BeforeSubmitCallbackHandler(
                handler: SessionCallbackHandler(session: session),
                session: session,
                callbackStore: callbackStore
            )
        )
    }

    private func makeAdvancedCheckoutCore() -> CheckoutCore {
        let callbackStore = AdvancedCheckoutCallbackStore()
        return CheckoutCore(
            configuration: configuration,
            paymentMethods: paymentMethods,
            adyenContext: Dummy.context,
            presentationDelegate: nil,
            resultCallbacks: callbackStore,
            callbackHandler: AdvancedCallbackHandler(callbackStore: callbackStore)
        )
    }
}
