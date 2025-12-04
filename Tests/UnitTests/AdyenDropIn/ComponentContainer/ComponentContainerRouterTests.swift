//
// Copyright (c) 2025 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Testing
@_spi(AdyenInternal) @testable import Adyen
@testable import AdyenActions
@testable import AdyenDropIn
import UIKit

@MainActor
struct ComponentContainerRouterTests {

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

    private func setupSUT() async -> (
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

    private func makePresentableComponent() async -> PresentableComponentMock {
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

    private func makeActionComponent() async -> PresentableComponentWrapper {
        let context = AdyenContext(
            apiContext: Dummy.apiContext,
            payment: nil,
            amount: .init(value: 100, currencyCode: "EUR")
        )
        let redirect = RedirectComponent(context: context)
        let viewController = UIViewController()
        return PresentableComponentWrapper(component: redirect, viewController: viewController)
    }

    // MARK: - Tests

    @Test func presentPaymentComponentShouldPushViewController() async throws {
        // Given
        let (sut, viewControllerSpy, _) = await setupSUT()
        let paymentComponent = await makePresentableComponent()

        let navController = UINavigationController(rootViewController: viewControllerSpy)
        viewControllerSpy.attachNavigationController(navController)

        // When
        sut.present(paymentComponent: paymentComponent)

        // Then
        #expect(navController.viewControllers.contains(paymentComponent.viewController))
    }

    @Test func presentActionComponentShouldPresentModallyViewController() async throws {
        // Given
        let (sut, viewControllerSpy, _) = await setupSUT()
        let actionComponent = await makeActionComponent()

        // When
        sut.present(actionComponent: actionComponent, onCancel: nil)

        // Then
        #expect(viewControllerSpy.presentedViewControllerCaptured != nil)
    }

    @Test func presentActionComponentShouldCallOnCancelCallback() async throws {
        // Given
        let (sut, _, _) = await setupSUT()
        let actionComponent = await makeActionComponent()

        var callbackCalled = false
        let onCancel: () -> Void = {
            callbackCalled = true
        }

        // When
        sut.present(actionComponent: actionComponent, onCancel: onCancel)
        actionComponent.viewController.navigationController?.viewDidDisappear(true)

        // Then
        #expect(callbackCalled)
    }

    @Test func dismissShouldCallListenerDidDismissComponentContainer() async throws {
        // Given
        let (sut, viewControllerSpy, listenerMock) = await setupSUT()

        // When
        sut.dismiss(completion: nil)

        // Then
        #expect(viewControllerSpy.dismissCalled)
        #expect(listenerMock.didDismissComponentContainerCompletionCallsCount == 1)
    }
}
