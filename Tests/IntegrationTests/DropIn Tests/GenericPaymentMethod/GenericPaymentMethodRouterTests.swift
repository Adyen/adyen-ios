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
        listener: GenericPaymentMethodRouterListener? = nil
    ) -> GenericPaymentMethodRouter {
        GenericPaymentMethodRouter(
            viewController: viewController ?? UIViewController(),
            listener: listener ?? GenericPaymentMethodRouterListenerMock()
        )
    }
}
