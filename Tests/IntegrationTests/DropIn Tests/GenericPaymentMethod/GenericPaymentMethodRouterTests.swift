//
// Copyright (c) 2026 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@testable import Adyen
@testable import AdyenActions
@testable import AdyenDropIn
import Testing
import UIKit

@MainActor
struct GenericPaymentMethodRouterTests {

    // MARK: - Tests

    @Test
    func rootViewController_returnsInjectedViewController() {
        // Given
        let viewController = UIViewController()
        let sut = makeSUT(viewController: viewController)

        // Then
        #expect(sut.rootViewController === viewController)
    }

    @Test
    func presentPaymentAction_shouldPresentResolvedRouterModally() async {
        // Given
        let viewControllerSpy = ViewControllerSpy()
        let paymentActionRouter = RouterMock()
        let sut = makeSUT(
            viewController: viewControllerSpy,
            paymentActionAssembler: makePaymentActionAssembler(router: paymentActionRouter)
        )

        // When
        await sut.presentPaymentAction(for: makeAction())

        // Then
        #expect(viewControllerSpy.presentedViewControllerCaptured === paymentActionRouter.rootViewController)
        #expect(sut.childRouter === paymentActionRouter)
    }

    @Test
    func didDismissPaymentAction_shouldReleaseChildRouter() async throws {
        // Given
        let sut = makeSUT()
        await sut.presentPaymentAction(for: makeAction())
        try #require(sut.childRouter != nil)

        // When
        sut.didDismissPaymentAction(completion: nil)

        // Then
        #expect(sut.childRouter == nil)
    }

    @Test
    func dismiss_shouldPopViewControllerAndNotifyListener() {
        // Given
        let viewController = ViewControllerSpy()
        let navigationControllerSpy = NavigationControllerSpy()
        viewController.setNavigationController(navigationControllerSpy)
        let listener = GenericPaymentMethodRouterListenerMock()
        let sut = makeSUT(viewController: viewController, listener: listener)

        // When
        sut.dismiss()

        // Then
        #expect(navigationControllerSpy.popViewControllerCallsCount == 1)
        #expect(listener.didDismissGenericPaymentMethodCallsCount == 1)
    }

    // MARK: - Spy

    private class ViewControllerSpy: UIViewController {
        var presentedViewControllerCaptured: UIViewController?

        override func present(_ viewControllerToPresent: UIViewController, animated: Bool, completion: (() -> Void)? = nil) {
            presentedViewControllerCaptured = viewControllerToPresent
            completion?()
        }

        private var _navigationController: NavigationControllerSpy?
        override var navigationController: UINavigationController? {
            _navigationController
        }

        func setNavigationController(_ navigationController: NavigationControllerSpy) {
            _navigationController = navigationController
        }
    }

    // MARK: - Helpers

    private func makeSUT(
        viewController: UIViewController? = nil,
        paymentActionAssembler: PaymentActionAssemblerProtocolMock? = nil,
        listener: GenericPaymentMethodRouterListener? = nil
    ) -> GenericPaymentMethodRouter {
        GenericPaymentMethodRouter(
            viewController: viewController ?? UIViewController(),
            paymentActionAssembler: paymentActionAssembler ?? makePaymentActionAssembler(),
            listener: listener ?? GenericPaymentMethodRouterListenerMock()
        )
    }

    private func makePaymentActionAssembler(
        router: RouterMock? = nil
    ) -> PaymentActionAssemblerProtocolMock {
        let assembler = PaymentActionAssemblerProtocolMock()
        assembler.resolvePaymentActionRouterForListenerReturnValue = router ?? RouterMock()
        return assembler
    }

    private func makeAction() -> Action {
        .redirect(RedirectAction(url: URL(string: "https://adyen.com")!, paymentData: "payment_data"))
    }
}
