//
// Copyright (c) 2026 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) @testable import Adyen
@testable import AdyenDropIn
import Testing
import UIKit

@MainActor
struct PreselectedPaymentMethodRouterTests {

    // MARK: - Payment Method List Tests

    @Test("The list is the root of its own module, so the preselected module embeds it in a navigation controller.")
    func presentPaymentMethodList_shouldPresentTheListInANavigationController() throws {
        // Given
        let listRouter = RouterMock()
        let viewController = ViewControllerSpy()
        let sut = makeSUT(viewController: viewController, paymentMethodListRouter: listRouter)

        // When
        sut.presentPaymentMethodList()

        // Then
        let navigationController = try #require(viewController.capturedPresentedViewController as? UINavigationController)
        #expect(navigationController.viewControllers == [listRouter.rootViewController])
        #expect(sut.childRouter === listRouter)
    }

    @Test("Closing the list closes the drop in it was opened from, as the shopper asked to leave the flow.")
    func didDismissPaymentMethodList_shouldDismissTheDropInAndNotifyTheListener() throws {
        // Given
        let listener = PreselectedPaymentMethodRouterListenerMock()
        let sut = makeSUT(listener: listener)
        let presentation = present(sut.rootViewController)
        sut.presentPaymentMethodList()
        try #require(sut.childRouter != nil)

        var forwardedCompletion: (() -> Void)?
        listener.didDismissPreselectedPaymentMethodCompletionClosure = { forwardedCompletion = $0 }
        var completionCalled = false

        // When
        sut.didDismissPaymentMethodList { completionCalled = true }

        // Then
        #expect(presentation.presenter.dismissCallsCount == 1)
        #expect(sut.childRouter == nil)
        #expect(listener.didDismissPreselectedPaymentMethodCompletionCallsCount == 1)

        let receivedCompletion = try #require(forwardedCompletion)
        receivedCompletion()
        #expect(completionCalled)
    }

    // MARK: - Spies

    /// Presents the drop in, so that its dismissal can be observed on the presenting view controller.
    private final class PresentingViewControllerSpy: UIViewController {
        var dismissCallsCount = 0

        override func dismiss(animated flag: Bool, completion: (() -> Void)? = nil) {
            dismissCallsCount += 1
            completion?()
        }
    }

    // MARK: - Helpers

    private func makeSUT(
        viewController: UIViewController = UIViewController(),
        listener: PreselectedPaymentMethodRouterListenerMock? = nil,
        paymentMethodListRouter: RouterMock? = nil
    ) -> PreselectedPaymentMethodRouter {
        let paymentMethodListAssembler = PaymentMethodListAssemblerProtocolMock()
        paymentMethodListAssembler.resolvePaymentMethodListRouterListenerReturnValue = paymentMethodListRouter ?? RouterMock()

        return PreselectedPaymentMethodRouter(
            viewController: viewController,
            listener: listener ?? PreselectedPaymentMethodRouterListenerMock(),
            paymentMethodListAssembler: paymentMethodListAssembler,
            componentContainerAssembler: ComponentContainerAssemblerProtocolMock()
        )
    }

    /// The window is returned alongside the presenter, as the presentation only holds while the window does.
    private func present(
        _ viewController: UIViewController
    ) -> (window: UIWindow, presenter: PresentingViewControllerSpy) {
        let presenter = PresentingViewControllerSpy()
        let window = UIWindow(frame: UIScreen.main.bounds)
        window.rootViewController = presenter
        window.isHidden = false
        presenter.present(viewController, animated: false)

        return (window, presenter)
    }
}
