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
    func presentPaymentComponent_shouldPushViewController() async throws {
        // Given
        let (sut, viewControllerSpy, _) = await makeSUT()
        let paymentComponent = await makePaymentComponent()

        let navController = UINavigationController(rootViewController: viewControllerSpy)
        viewControllerSpy.attachNavigationController(navController)

        // When
        sut.present(paymentComponent: paymentComponent)
        try await Task.sleep(for: .milliseconds(300))

        // Then
        #expect(navController.viewControllers.contains(paymentComponent.viewController))
    }

    @Test
    func presentActionComponent_shouldPresentModallyViewController() async {
        // Given
        let (sut, viewControllerSpy, _) = await makeSUT()
        let actionComponent = await makeActionComponent()

        // When
        sut.present(actionComponent: actionComponent, onCancel: nil)

        // Then
        #expect(viewControllerSpy.presentedViewControllerCaptured != nil)
    }

    @Test
    func presentActionComponent_shouldInjectOnCancelCallbackIntoActionWrapper() async throws {
        // Given
        let (sut, viewControllerSpy, _) = await makeSUT()
        let actionComponent = await makeActionComponent()

        var cancelWasCalled = false
        let cancelCallback = { cancelWasCalled = true }

        // When
        sut.present(actionComponent: actionComponent, onCancel: cancelCallback)

        // Then
        let wrapper = try #require(
            viewControllerSpy.presentedViewControllerCaptured as? ActionWrapperViewController
        )

        let injectedCallback = try #require(wrapper.onCancel)
        injectedCallback()

        #expect(cancelWasCalled)
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

    // MARK: - Helpers

    private func makeSUT() async -> (
        sut: ComponentContainerRouter,
        viewControllerSpy: ViewControllerSpy,
        listenerMock: ComponentContainerRouterListenerMock
    ) {
        let viewModelMock = ComponentContainerViewModelProtocolMock()
        viewModelMock.componentViewController = UIViewController()

        let viewControllerSpy = ViewControllerSpy(viewModel: viewModelMock)
        let listenerMock = ComponentContainerRouterListenerMock()
        let sut = ComponentContainerRouter(
            viewController: viewControllerSpy,
            listener: listenerMock
        )

        return (sut, viewControllerSpy, listenerMock)
    }

    private func makePaymentComponent() async -> PresentableComponentMock {
        let viewController = UIViewController()
        let cardPaymentMethodMock = CardPaymentMethodMock(
            type: .scheme,
            name: "Card",
            brands: [.visa, .masterCard]
        )

        return PresentableComponentMock(
            paymentMethod: cardPaymentMethodMock,
            viewController: viewController
        )
    }

    private func makeActionComponent() async -> PresentableComponent {
        let context = AdyenContext(
            apiContext: Dummy.apiContext,
            amount: .init(value: 100, currencyCode: "EUR"),
            publicKey: Dummy.publicKey,
            analyticsProvider: AnalyticsProviderMock()
        )
        let redirect = RedirectComponent(context: context)
        let viewController = UIViewController()
        return PresentableComponentWrapper(component: redirect, viewController: viewController)
    }
}
