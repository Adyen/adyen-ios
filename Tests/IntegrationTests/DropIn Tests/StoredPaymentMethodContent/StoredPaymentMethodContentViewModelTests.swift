//
// Copyright (c) 2026 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) @testable import Adyen
@testable import AdyenCard
@testable import AdyenDropIn
@_spi(AdyenInternal) @testable import AdyenUI
import Testing

@MainActor
internal struct StoredPaymentMethodContentViewModelTests {

    @Test
    internal func storedCardSecurityCodeComponent_whenCreated_thenProvidesSharedHeaderAndComponentController() {
        let context = makeSUTStoredCardWithCVC()

        #expect(context.sut.title == "\(String.Adyen.securedString)4556")
        #expect(context.sut.paymentMethodLogoURL.absoluteString.contains("visa"))
        #expect(context.sut.subtitle.string == "Use Visa to pay \(Dummy.amount.formatted)")
    }

    @Test
    internal func storedCardSecurityCodeComponent_withMissingAmount_thenProvidesUnformattedPayDescription() {
        let context = makeSUTStoredCardWithCVC(amount: nil)
        #expect(context.sut.subtitle.string == "Use Visa to pay")
    }

    @Test
    internal func storedCardSecurityCodeComponent_withZeroAmount_thenProvidesSaveDetailsDescription() {
        let context = makeSUTStoredCardWithCVC(amount: Amount(value: 0, currencyCode: "EUR"))
        #expect(context.sut.subtitle.string == "Use Visa to save details")
    }

    @Test
    internal func directStoredPaymentComponent_whenCreated_thenProvidesSharedHeaderAndComponentController() {
        let paymentMethod = StoredCashAppPayPaymentMethod(
            type: .cashAppPay,
            name: "Cash App Pay",
            cashtag: "$arjenLandstra",
            identifier: "cash-app-id",
            supportedShopperInteractions: [.shopperPresent]
        )
        let component = StoredPaymentMethodComponent(
            paymentMethod: paymentMethod,
            context: Dummy.context
        )
        let context = makeSUT(component: component)

        #expect(context.sut.title == "$arjenLandstra")
        #expect(context.sut.subtitle.string == "Use Cash App Pay to pay \(Dummy.amount.formatted)")
    }

    @Test
    internal func component_whenSubmitting_thenForwardsToDropInFlowManager() throws {
        let context = makeSUTStoredCardWithCVC()
        let paymentMethod = try #require(context.component.paymentMethod as? StoredPaymentMethod)
        let data = PaymentComponentData(
            paymentMethodDetails: StoredPaymentDetails(paymentMethod: paymentMethod),
            order: nil
        )

        context.sut.didSubmit(data, from: context.component)

        #expect(context.flowManager.submitFromActionPresenterCalled)
    }

    private struct TestContext {
        let sut: StoredPaymentMethodContentViewModel
        let component: any StoredPaymentComponent
        let flowManager: DropInFlowManagingMock
    }

    private func makeSUTStoredCardWithCVC(amount: Amount? = Dummy.amount) -> TestContext {
        let paymentMethod = StoredCardPaymentMethod(
            type: .scheme,
            name: "Visa",
            identifier: "stored-card-id",
            fundingSource: .credit,
            supportedShopperInteractions: [.shopperPresent],
            brand: .visa,
            lastFour: "4556",
            expiryMonth: "12",
            expiryYear: "2030",
            holderName: nil
        )
        let componentContext = AdyenContext(
            apiContext: Dummy.apiContext,
            amount: amount,
            publicKey: Dummy.publicKey,
            analyticsProvider: nil
        )
        let component = StoredCardSecurityCodeComponent(
            storedCardPaymentMethod: paymentMethod,
            context: componentContext,
            theme: .default
        )
        return makeSUT(component: component)
    }

    private func makeSUT(component: any StoredPaymentComponent) -> TestContext {
        let flowManager = DropInFlowManagingMock()
        let sut = StoredPaymentMethodContentViewModel(
            component: component,
            theme: .default,
            logoURLProvider: LogoURLProvider(environment: Dummy.apiContext.environment),
            localizationParameters: nil,
            dropInFlowManager: flowManager
        )
        return TestContext(sut: sut, component: component, flowManager: flowManager)
    }
}

@MainActor
private final class StoredPaymentMethodContentRoutingSpy: StoredPaymentMethodContentRouting {

    private(set) var dismissCallsCount = 0
    private(set) var onCancel: (() -> Void)?

    func present(actionViewController: UIViewController, onCancel: (() -> Void)?) {
        self.onCancel = onCancel
    }

    func dismiss() {
        dismissCallsCount += 1
    }
}
