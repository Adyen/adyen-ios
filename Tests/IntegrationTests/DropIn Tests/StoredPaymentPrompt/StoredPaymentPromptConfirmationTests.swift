//
// Copyright (c) 2026 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) @testable import Adyen
@testable import AdyenDropIn
@_spi(AdyenInternal) @testable import AdyenUI
import Testing

@MainActor
internal struct StoredPaymentPromptConfirmationTests {

    @Test
    internal func storedCard_whenCreated_thenProvidesCardConfirmationPresentation() {
        let context = makeSUT()

        #expect(context.sut.title == "\(String.Adyen.securedString)4556")
        #expect(context.sut.subtitle.string.contains("Visa"))
        #expect(context.sut.subtitle.string.contains(Dummy.amount.formatted))
        #expect(context.sut.submitButtonTitle == "Pay €1.00")
        #expect(context.sut.showsLockIcon)
        #expect(context.sut.componentViewController == nil)
    }

    @Test
    internal func storedCashAppPay_whenCreated_thenProvidesGenericConfirmationPresentation() {
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
        let sut = makeSUT(component: component).sut

        #expect(sut.title == "$arjenLandstra")
        #expect(sut.subtitle.string.contains("Cash App Pay"))
        #expect(sut.subtitle.string.contains(Dummy.amount.formatted))
        #expect(sut.submitButtonTitle == "Use Cash App Pay")
        #expect(!sut.showsLockIcon)
    }

    @Test
    internal func storedCard_withMissingAmount_thenOmitsAmountDescription() {
        let context = makeSUT(amount: nil)

        #expect(context.sut.subtitle.string == "Use Visa")
    }

    @Test
    internal func storedCard_withZeroAmount_thenOmitsAmountDescription() {
        let context = makeSUT(amount: Amount(value: 0, currencyCode: "EUR"))

        #expect(context.sut.subtitle.string == "Use Visa")
    }

    @Test
    internal func idlePrompt_whenSubmittingTwice_thenStartsLoadingAndSubmitsOnce() {
        let component = StoredComponentMock(
            paymentMethod: PaymentMethodMock(type: .payPal, name: "PayPal"),
            viewController: UIViewController()
        )
        component.shouldCallDelegateOnSubmit = false
        let sut = makeSUT(component: component).sut

        sut.submit()
        sut.submit()

        #expect(sut.isSubmitting)
        #expect(component.submitCallsCount == 1)
    }

    @Test
    internal func component_whenSubmitting_thenForwardsToDropInFlowManager() throws {
        let context = makeSUT()
        let paymentMethod = try #require(context.component.paymentMethod as? StoredPaymentMethod)
        let data = PaymentComponentData(
            paymentMethodDetails: StoredPaymentDetails(paymentMethod: paymentMethod),
            order: nil
        )

        context.sut.didSubmit(data, from: context.component)

        #expect(context.flowManager.submitFromActionPresenterCalled)
        #expect(context.flowManager.submitFromActionPresenterReceivedArguments?.component === context.component)
        #expect(context.flowManager.submitFromActionPresenterReceivedArguments?.actionPresenter === context.sut)
    }

    @Test
    internal func presentedAction_whenCancelled_thenCancelsComponentAndDismissesPrompt() {
        let context = makeSUT()
        let router = ConfirmationRoutingSpy()
        context.sut.router = router

        context.sut.present(actionViewController: UIViewController())
        router.onCancel?()

        #expect(context.flowManager.cancelComponentReceivedComponent === context.component)
        #expect(router.dismissCallsCount == 1)
    }

    @Test
    internal func submittingPrompt_whenParentStopsLoading_thenReturnsToIdle() {
        let context = makeSUT()
        context.sut.didAppear()
        context.sut.submit()

        context.flowManager.setLoadingPresenterReceivedPresenter?.stopLoading()

        #expect(context.flowManager.setLoadingPresenterReceivedPresenter === context.sut)
        #expect(!context.sut.isSubmitting)
    }

    @Test
    internal func submittingPrompt_whenComponentFails_thenReturnsToIdleAndForwardsFailure() {
        let context = makeSUT()
        context.sut.submit()

        context.sut.didFail(with: Dummy.error, from: context.component)

        #expect(!context.sut.isSubmitting)
        #expect(context.flowManager.failWithFromCalled)
    }

    private struct TestContext {
        let sut: StoredPaymentPromptViewModel
        let component: any StoredPaymentComponent
        let flowManager: DropInFlowManagingMock
    }

    private func makeSUT(amount: Amount? = Dummy.amount) -> TestContext {
        let componentContext = AdyenContext(
            apiContext: Dummy.apiContext,
            amount: amount,
            publicKey: Dummy.publicKey,
            analyticsProvider: nil
        )
        let component = StoredPaymentMethodComponent(
            paymentMethod: makeStoredCardPaymentMethod(),
            context: componentContext
        )
        return makeSUT(component: component)
    }

    private func makeSUT(component: any StoredPaymentComponent) -> TestContext {
        let flowManager = DropInFlowManagingMock()
        let sut = StoredPaymentPromptViewModel(
            mode: .confirmation(component),
            theme: .default,
            logoURLProvider: LogoURLProvider(environment: Dummy.apiContext.environment),
            localizationParameters: nil,
            dropInFlowManager: flowManager
        )
        return TestContext(sut: sut, component: component, flowManager: flowManager)
    }

    private func makeStoredCardPaymentMethod() -> StoredCardPaymentMethod {
        StoredCardPaymentMethod(
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
    }
}

@MainActor
private final class ConfirmationRoutingSpy: StoredPaymentPromptRouting {

    private(set) var dismissCallsCount = 0
    private(set) var onCancel: (() -> Void)?

    func present(actionViewController: UIViewController, onCancel: (() -> Void)?) {
        self.onCancel = onCancel
    }

    func dismiss() {
        dismissCallsCount += 1
    }
}
