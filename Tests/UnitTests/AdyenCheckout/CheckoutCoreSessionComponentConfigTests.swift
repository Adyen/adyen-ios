//
// Copyright (c) 2026 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) @testable import Adyen
@testable import AdyenCard
@testable import AdyenCheckout
@testable import AdyenSession
import XCTest

/// Tests that `CheckoutCore` correctly forwards session-driven component configuration
/// (installments and store-payment-method) to components via the protocol-inversion
/// mechanism in their `delegate.didSet` blocks.
@MainActor
final class CheckoutCoreSessionComponentConfigTests: XCTestCase {

    private var paymentMethods: PaymentMethods!
    private var configuration: CheckoutConfiguration!

    override func setUp() {
        super.setUp()
        let paymentMethodsDictionary: [String: Any] = ["paymentMethods": [creditCardDictionary]]
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

    // MARK: - InstallmentConfigurationAware

    func test_installmentConfiguration_withSession_forwardsFromSession() {
        let installments = InstallmentConfiguration(
            defaultOptions: InstallmentOptions(maxInstallmentMonth: 3, includesRevolving: false)
        )
        let sut = makeSessionCheckoutCore(installmentOptions: installments)
        XCTAssertEqual(sut.installmentConfiguration, installments)
    }

    func test_installmentConfiguration_withSession_whenNil_isNil() {
        let sut = makeSessionCheckoutCore(installmentOptions: nil)
        XCTAssertNil(sut.installmentConfiguration)
    }

    func test_installmentConfiguration_withoutSession_isNil() {
        let sut = makeAdvancedCheckoutCore()
        XCTAssertNil(sut.installmentConfiguration)
    }

    // MARK: - StorePaymentMethodFieldAware

    func test_showStorePaymentMethodField_withSession_whenTrue_forwardsTrue() {
        let sut = makeSessionCheckoutCore(enableStoreDetails: true)
        XCTAssertEqual(sut.showStorePaymentMethodField, true)
    }

    func test_showStorePaymentMethodField_withSession_whenFalse_forwardsFalse() {
        let sut = makeSessionCheckoutCore(enableStoreDetails: false)
        XCTAssertEqual(sut.showStorePaymentMethodField, false)
    }

    func test_showStorePaymentMethodField_withoutSession_isNil() {
        let sut = makeAdvancedCheckoutCore()
        XCTAssertNil(sut.showStorePaymentMethodField)
    }

    // MARK: - End-to-end: CardComponent picks up session config via delegate

    func test_cardComponent_sessionFlow_installmentConfiguration_appliedFromSession() throws {
        // Given: session provides installment options
        let installments = InstallmentConfiguration(
            defaultOptions: InstallmentOptions(maxInstallmentMonth: 6, includesRevolving: false)
        )
        let sut = makeSessionCheckoutCore(installmentOptions: installments)

        // When: card component is created — delegate assignment triggers didSet
        let component = try sut.createPaymentComponent(for: .scheme)
        let cardComponent = try XCTUnwrap(component.paymentComponent as? CardComponent)

        // Then: the card component has the session-provided installments
        XCTAssertEqual(cardComponent.configuration.installmentConfiguration, installments)
    }

    func test_cardComponent_sessionFlow_showStorePaymentMethod_falseAppliedFromSession() throws {
        // Given: session disables the store toggle
        let sut = makeSessionCheckoutCore(enableStoreDetails: false)

        // When
        let component = try sut.createPaymentComponent(for: .scheme)
        let cardComponent = try XCTUnwrap(component.paymentComponent as? CardComponent)

        // Then: store toggle is off
        XCTAssertFalse(cardComponent.configuration.showStorePaymentMethod)
    }

    func test_cardComponent_sessionFlow_showStorePaymentMethod_trueAppliedFromSession() throws {
        // Given: session enables the store toggle
        let sut = makeSessionCheckoutCore(enableStoreDetails: true)

        // When
        let component = try sut.createPaymentComponent(for: .scheme)
        let cardComponent = try XCTUnwrap(component.paymentComponent as? CardComponent)

        // Then: store toggle is on
        XCTAssertTrue(cardComponent.configuration.showStorePaymentMethod)
    }

    func test_cardComponent_advancedFlow_merchantInstallments_notClobbered() throws {
        // Given: advanced flow with merchant-configured installments, no session
        let merchantInstallments = InstallmentConfiguration(
            defaultOptions: InstallmentOptions(maxInstallmentMonth: 12, includesRevolving: true)
        )
        configuration.configurations[.payment(.scheme)] = CardConfiguration()
            .installmentConfiguration(merchantInstallments)
        let sut = makeAdvancedCheckoutCore()

        // When
        let component = try sut.createPaymentComponent(for: .scheme)
        let cardComponent = try XCTUnwrap(component.paymentComponent as? CardComponent)

        // Then: merchant installments are intact — isSession == false so didSet branches are skipped
        XCTAssertEqual(cardComponent.configuration.installmentConfiguration, merchantInstallments)
    }

    func test_cardComponent_advancedFlow_showStorePaymentMethod_notClobbered() throws {
        // Given: advanced flow; merchant has explicitly hidden the store toggle
        configuration.configurations[.payment(.scheme)] = CardConfiguration()
            .showStorePaymentMethod(false)
        let sut = makeAdvancedCheckoutCore()

        // When
        let component = try sut.createPaymentComponent(for: .scheme)
        let cardComponent = try XCTUnwrap(component.paymentComponent as? CardComponent)

        // Then: merchant preference is preserved — isSession == false so didSet branches are skipped
        XCTAssertFalse(cardComponent.configuration.showStorePaymentMethod)
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
