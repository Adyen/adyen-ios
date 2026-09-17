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
internal struct AuthenticationWithInputViewModelTests {

    @Test
    internal func storedCardComponent_whenCreated_thenProvidesDropInHeaderAndComponentController() {
        let context = makeSUT()

        #expect(context.sut.title == "Security code")
        #expect(context.sut.componentViewController === context.component.viewController)
    }

    @Test
    internal func storedCardComponent_withPositiveAmount_thenProvidesLogoAndAmountDescription() {
        let context = makeSUT()

        #expect(context.sut.paymentMethodLogoURL.absoluteString.contains("visa"))
        #expect(context.sut.subtitle.string.contains("Visa"))
        #expect(context.sut.subtitle.string.contains("4556"))
        #expect(context.sut.subtitle.string.contains(Dummy.amount.formatted))
    }

    @Test
    internal func storedCardComponent_withMissingAmount_thenOmitsAmountDescription() {
        let context = makeSUT(amount: nil)

        #expect(!context.sut.subtitle.string.contains("complete the payment"))
    }

    @Test
    internal func storedCardComponent_withZeroAmount_thenOmitsAmountDescription() {
        let context = makeSUT(amount: Amount(value: 0, currencyCode: "EUR"))

        #expect(!context.sut.subtitle.string.contains("complete the payment"))
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
    internal func presentedAction_whenCancelled_thenCancelsComponentAndDismissesAuthentication() {
        let context = makeSUT()
        let router = AuthenticationWithInputRoutingSpy()
        context.sut.router = router

        context.sut.present(actionViewController: UIViewController())
        router.onCancel?()

        #expect(context.flowManager.cancelComponentReceivedComponent === context.component)
        #expect(router.dismissCallsCount == 1)
    }

    @Test
    internal func nonCardComponent_whenCreated_thenUsesGenericPaymentMethodHeader() {
        let componentViewController = UIViewController()
        let component = PresentablePaymentComponentMock(
            paymentMethod: PaymentMethodMock(type: .ideal, name: "iDEAL"),
            viewController: componentViewController
        )
        let sut = AuthenticationWithInputViewModel(
            component: component,
            theme: .default,
            logoURLProvider: LogoURLProvider(environment: Dummy.apiContext.environment),
            localizationParameters: nil,
            dropInFlowManager: DropInFlowManagingMock()
        )

        #expect(sut.title == "iDEAL")
        #expect(sut.subtitle.string == "Use iDEAL")
        #expect(sut.componentViewController === componentViewController)
    }

    private struct TestContext {
        let sut: AuthenticationWithInputViewModel
        let component: StoredCardComponent
        let flowManager: DropInFlowManagingMock
    }

    private func makeSUT(amount: Amount? = Dummy.amount) -> TestContext {
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
        let component = StoredCardComponent(
            storedCardPaymentMethod: paymentMethod,
            context: componentContext,
            theme: .default
        )
        let flowManager = DropInFlowManagingMock()
        let sut = AuthenticationWithInputViewModel(
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
private final class AuthenticationWithInputRoutingSpy: AuthenticationWithInputRouting {

    private(set) var dismissCallsCount = 0
    private(set) var onCancel: (() -> Void)?

    func present(actionViewController: UIViewController, onCancel: (() -> Void)?) {
        self.onCancel = onCancel
    }

    func dismiss() {
        dismissCallsCount += 1
    }
}
