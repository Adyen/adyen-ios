//
// Copyright (c) 2026 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) @testable import Adyen
@testable import AdyenDropIn
@_spi(AdyenInternal) @testable import AdyenUI
import Testing
import UIKit

@MainActor
internal struct StoredPaymentMethodContentAssemblerTests {

    /// Any stored payment method gets its own stored payment screen to be completed on.
    @Test
    internal func storedComponent_whenResolved_thenReturnsContentRouter() {
        let component = StoredComponentMock(
            paymentMethod: PaymentMethodMock(type: .payPal, name: "PayPal"),
            viewController: UIViewController()
        )
        let sut = makeSUT()
        let router = sut.resolveStoredPaymentMethodContentRouter(
            for: component,
            isPresentedModally: false,
            listener: ContentRouterListenerSpy()
        )
        #expect(router?.rootViewController is NavigationLockingHostingController<StoredPaymentMethodContentView>)
    }

    /// The root of a sheet has nothing to go back to, so it gets the system Cancel button. A pushed screen keeps the back button.
    @Test(arguments: [true, false])
    internal func storedComponent_whenResolved_thenShowsCancelButtonOnlyWhenPresentedModally(isPresentedModally: Bool) {
        let component = StoredComponentMock(
            paymentMethod: PaymentMethodMock(type: .payPal, name: "PayPal"),
            viewController: UIViewController()
        )
        let router = makeSUT().resolveStoredPaymentMethodContentRouter(
            for: component,
            isPresentedModally: isPresentedModally,
            listener: ContentRouterListenerSpy()
        )
        #expect((router?.rootViewController.navigationItem.leftBarButtonItem != nil) == isPresentedModally)
    }

    /// A submitted payment cannot be cancelled, so the Cancel button follows the payment progress of the drop in.
    @Test
    internal func storedComponent_whilePaymentInProgress_thenDisablesCancelButton() throws {
        let component = StoredComponentMock(
            paymentMethod: PaymentMethodMock(type: .payPal, name: "PayPal"),
            viewController: UIViewController()
        )
        let flowManager = DropInFlowManagingMock()
        let router = makeSUT(dropInFlowManager: flowManager).resolveStoredPaymentMethodContentRouter(
            for: component,
            isPresentedModally: true,
            listener: ContentRouterListenerSpy()
        )
        let cancelButton = try #require(router?.rootViewController.navigationItem.leftBarButtonItem)

        flowManager.paymentInProgressSubject.send(true)
        #expect(!cancelButton.isEnabled)

        flowManager.paymentInProgressSubject.send(false)
        #expect(cancelButton.isEnabled)
    }

    /// A real stored payment method that needs no input at all, such as stored Cash App Pay, also gets
    /// the stored payment screen: it shows the payment method and a pay button, with nothing to fill in.
    @Test
    internal func storedComponentWithoutInput_whenResolved_thenReturnsContentRouter() {
        let component = StoredPaymentMethodComponent(
            paymentMethod: StoredCashAppPayPaymentMethod(
                type: .cashAppPay,
                name: "Cash App Pay",
                cashtag: "$arjenLandstra",
                identifier: "cash-app-id",
                supportedShopperInteractions: [.shopperPresent]
            ),
            context: Dummy.context
        )
        let sut = makeSUT()
        #expect(sut.resolveStoredPaymentMethodContentRouter(
            for: component,
            isPresentedModally: false,
            listener: ContentRouterListenerSpy()
        ) != nil)
    }

    /// Anything that is not a stored payment method gets nothing back. Returning nothing is how the
    /// assembler tells the list and preselected screens to present the component the generic way instead.
    @Test
    internal func componentThatIsNotStored_whenResolved_thenReturnsNil() {
        let component = PaymentComponentMock(paymentMethod: PaymentMethodMock(type: .payPal, name: "PayPal"))
        let sut = makeSUT()
        #expect(sut.resolveStoredPaymentMethodContentRouter(
            for: component,
            isPresentedModally: false,
            listener: ContentRouterListenerSpy()
        ) == nil)
    }

    private func makeSUT(dropInFlowManager: DropInFlowManaging? = nil) -> StoredPaymentMethodContentAssembler {
        StoredPaymentMethodContentAssembler(
            dropInFlowManager: dropInFlowManager ?? DropInFlowManagingMock(),
            logoURLProvider: LogoURLProvider(environment: Dummy.apiContext.environment),
            theme: .default,
            localizationParameters: nil
        )
    }
}

@MainActor
private final class ContentRouterListenerSpy: StoredPaymentMethodContentRouterListener {
    func dismissStoredPaymentMethodContent() {}
}
