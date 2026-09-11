//
// Copyright (c) 2026 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

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
    func present_shouldPresentActionViewControllerModally() {
        // Given
        let viewControllerSpy = ViewControllerSpy()
        let sut = makeSUT(viewController: viewControllerSpy)
        let actionViewController = UIViewController()

        // When
        sut.present(actionViewController: actionViewController, onCancel: nil)

        // Then
        #expect(viewControllerSpy.presentedViewControllerCaptured != nil)
    }

    @Test
    func dismiss_shouldPopViewControllerAndNotifyListener() {
        // Given
        let viewController = UIViewController()
        let navigationController = UINavigationController(rootViewController: UIViewController())
        navigationController.pushViewController(viewController, animated: false)
        let listener = GenericPaymentMethodRouterListenerMock()
        let sut = makeSUT(viewController: viewController, listener: listener)

        // When
        sut.dismiss()

        // Then
        #expect(listener.didDismissGenericPaymentMethodCallsCount == 1)
    }

    // MARK: - Spy

    private class ViewControllerSpy: UIViewController {
        var presentedViewControllerCaptured: UIViewController?

        override func present(_ viewControllerToPresent: UIViewController, animated: Bool, completion: (() -> Void)? = nil) {
            presentedViewControllerCaptured = viewControllerToPresent
            completion?()
        }
    }

    // MARK: - Helpers

    private func makeSUT(
        viewController: UIViewController? = nil,
        listener: GenericPaymentMethodRouterListener? = nil
    ) -> GenericPaymentMethodRouter {
        GenericPaymentMethodRouter(
            viewController: viewController ?? UIViewController(),
            listener: listener ?? GenericPaymentMethodRouterListenerMock()
        )
    }
}
