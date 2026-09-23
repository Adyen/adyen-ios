//
// Copyright (c) 2025 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) @testable import Adyen
@testable import AdyenActions
@testable import AdyenDropIn
import Testing
import UIKit

@MainActor
struct ComponentContainerRouterTests {

    // MARK: - Tests

    @Test
    func presentPaymentComponent_shouldPushViewController() async {
        // Given
        let (sut, viewControllerSpy, _) = await makeSUT()
        let paymentComponent = await makePaymentComponent()

        let navigationControllerSpy = NavigationControllerSpy()
        viewControllerSpy.attachNavigationController(navigationControllerSpy)

        // When
        sut.present(paymentComponent: paymentComponent)

        // Then
        #expect(navigationControllerSpy.pushViewControllerCallsCount == 1)
        #expect(navigationControllerSpy.capturedPushedViewController === paymentComponent.viewController)
    }

    @Test
    func presentPaymentActionRouter_shouldPresentRouterModally() async {
        // Given
        let (sut, viewControllerSpy, _) = await makeSUT()
        let paymentActionRouter = RouterMock()

        // When
        sut.present(paymentActionRouter: paymentActionRouter)

        // Then
        #expect(viewControllerSpy.presentedViewControllerCaptured === paymentActionRouter.rootViewController)
        #expect(sut.childRouter === paymentActionRouter)
    }

    @Test
    func didDismissPaymentAction_shouldReleaseChildRouter() async throws {
        // Given
        let (sut, _, _) = await makeSUT()
        sut.present(paymentActionRouter: RouterMock())
        try #require(sut.childRouter != nil)

        // When
        sut.didDismissPaymentAction(completion: nil)

        // Then
        #expect(sut.childRouter == nil)
    }

    @Test
    func dismiss_shouldCall_listener_didDismissComponentContainer() async {
        // Given
        let (sut, viewControllerSpy, listenerMock) = await makeSUT()

        // When
        sut.dismiss(completion: nil)

        // Then
        #expect(viewControllerSpy.dismissCalled)
        #expect(listenerMock.didDismissComponentContainerCompletionCallsCount == 1)
    }

    // MARK: - Spy

    private class ViewControllerSpy: ComponentContainerViewController {
        var pushedViewController: UIViewController?
        var presentedViewControllerCaptured: UIViewController?
        var dismissCalled = false
        var dismissCompletion: (() -> Void)?

        override var navigationController: UINavigationController? {
            _navigationController
        }

        private var _navigationController: UINavigationController?

        func attachNavigationController(_ nav: UINavigationController) {
            _navigationController = nav
        }

        override func present(_ vc: UIViewController, animated: Bool, completion: (() -> Void)? = nil) {
            presentedViewControllerCaptured = vc
            completion?()
        }

        override func dismiss(animated: Bool, completion: (() -> Void)? = nil) {
            dismissCalled = true
            dismissCompletion = completion
            completion?()
        }
    }

    // MARK: - Mocks

    private class ComponentContainerRouterListenerMock: ComponentContainerRouterListener {
        var didDismissComponentContainerCompletionCallsCount = 0
        var didDismissComponentContainerCompletionReceivedCompletion: (() -> Void)?

        func didDismissComponentContainer(completion: (() -> Void)?) {
            didDismissComponentContainerCompletionCallsCount += 1
            didDismissComponentContainerCompletionReceivedCompletion = completion
            completion?()
        }
    }

    private class ComponentContainerViewModelProtocolMock: ComponentContainerViewModelProtocol {
        var componentViewController: UIViewController = .init()
        var cancelCallsCount = 0

        func cancel() {
            cancelCallsCount += 1
        }
    }

    // MARK: - Helpers

    private func makeSUT() async -> (
        sut: ComponentContainerRouter,
        viewControllerSpy: ViewControllerSpy,
        listenerMock: ComponentContainerRouterListenerMock
    ) {
        let viewModelMock = ComponentContainerViewModelProtocolMock()

        let viewControllerSpy = ViewControllerSpy(viewModel: viewModelMock)
        let listenerMock = ComponentContainerRouterListenerMock()
        let sut = ComponentContainerRouter(
            viewController: viewControllerSpy,
            listener: listenerMock
        )

        return (sut, viewControllerSpy, listenerMock)
    }

    private func makePaymentComponent() async -> PresentablePaymentComponentMock {
        let viewController = UIViewController()
        let cardPaymentMethodMock = CardPaymentMethodMock(
            type: .scheme,
            name: "Card",
            brands: [.visa, .masterCard]
        )

        return PresentablePaymentComponentMock(
            paymentMethod: cardPaymentMethodMock,
            viewController: viewController
        )
    }
}
