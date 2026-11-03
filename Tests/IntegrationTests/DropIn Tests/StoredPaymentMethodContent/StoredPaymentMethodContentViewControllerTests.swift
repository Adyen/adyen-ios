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
struct StoredPaymentMethodContentViewControllerTests {

    @Test("A sheet with the screen as its root cannot be swiped away, so a submitted payment is never dismissed.")
    func init_shouldPreventTheInteractiveDismissal() {
        // When
        let environment = makeSUT()

        // Then
        #expect(environment.sut.isModalInPresentation)
    }

    @Test("A pushed screen keeps the system back button, so swiping back works while no payment is in progress.")
    func pushedScreen_shouldKeepTheSystemBackButton() {
        // Given
        let environment = makeSUT()

        // When
        let navigationController = push(environment.sut)

        // Then
        #expect(environment.sut.navigationItem.leftBarButtonItem == nil)
        #expect(!environment.sut.navigationItem.hidesBackButton)
        #expect(navigationController.navigationBar.isUserInteractionEnabled)
        #expect(navigationController.interactivePopGestureRecognizer?.isEnabled == true)
    }

    @Test("The root of a sheet has nothing to go back to, so it gets the system Cancel button.")
    func rootOfSheet_shouldShowTheSystemCancelButton() {
        // Given
        let environment = makeSUT(showsCancelButton: true)
        let navigationController = UINavigationController(rootViewController: environment.sut)
        let window = UIWindow(frame: UIScreen.main.bounds)
        window.rootViewController = navigationController
        window.isHidden = false

        // When
        navigationController.view.layoutIfNeeded()

        // Then
        #expect(environment.sut.navigationItem.leftBarButtonItem === environment.sut.cancelButtonItem)
        #expect(environment.sut.cancelButtonItem.isEnabled)
        window.isHidden = true
    }

    @Test("A submitted payment cannot be cancelled, so the shopper cannot navigate away from it.")
    func paymentInProgress_shouldLockTheNavigation() {
        // Given
        let environment = makeSUT()
        let navigationController = push(environment.sut)

        // When
        environment.flowManager.paymentInProgressSubject.send(true)

        // Then
        #expect(!navigationController.navigationBar.isUserInteractionEnabled)
        #expect(navigationController.interactivePopGestureRecognizer?.isEnabled == false)
    }

    @Test
    func paymentInProgress_whenEnded_shouldUnlockTheNavigation() {
        // Given
        let environment = makeSUT()
        let navigationController = push(environment.sut)
        environment.flowManager.paymentInProgressSubject.send(true)

        // When
        environment.flowManager.paymentInProgressSubject.send(false)

        // Then
        #expect(navigationController.navigationBar.isUserInteractionEnabled)
        #expect(navigationController.interactivePopGestureRecognizer?.isEnabled == true)
    }

    #if compiler(>=6.2)
        @Test("From iOS 26 swiping anywhere in the content pops too, so that gesture is locked as well.")
        func paymentInProgress_shouldLockTheContentPopGesture() throws {
            guard #available(iOS 26.0, *) else { return }

            // Given
            let environment = makeSUT()
            let navigationController = push(environment.sut)
            let contentPopGestureRecognizer = try #require(navigationController.interactiveContentPopGestureRecognizer)

            // When
            environment.flowManager.paymentInProgressSubject.send(true)

            // Then
            #expect(!contentPopGestureRecognizer.isEnabled)

            // When
            environment.flowManager.paymentInProgressSubject.send(false)

            // Then
            #expect(contentPopGestureRecognizer.isEnabled)
        }
    #endif

    @Test("A submitted payment cannot be cancelled, so the Cancel button is disabled until it ends.")
    func paymentInProgress_shouldDisableTheCancelButton() {
        // Given
        let environment = makeSUT(showsCancelButton: true)

        // When
        environment.flowManager.paymentInProgressSubject.send(true)

        // Then
        #expect(!environment.sut.cancelButtonItem.isEnabled)

        // When
        environment.flowManager.paymentInProgressSubject.send(false)

        // Then
        #expect(environment.sut.cancelButtonItem.isEnabled)
    }

    @Test("A screen pushed during the payment, such as an action, gets an interactive bar and does not cancel the payment.")
    func pushingAScreen_whilePaymentInProgress_shouldHandOverTheNavigation() {
        // Given
        let environment = makeSUT()
        let (navigationController, window) = pushInWindow(environment.sut)
        environment.flowManager.paymentInProgressSubject.send(true)

        // When
        navigationController.pushViewController(PopGestureLockingViewController(), animated: false)
        navigationController.view.layoutIfNeeded()

        // Then
        #expect(navigationController.navigationBar.isUserInteractionEnabled)
        #expect(navigationController.interactivePopGestureRecognizer?.isEnabled == false)

        // When
        environment.flowManager.paymentInProgressSubject.send(false)

        // Then
        #expect(navigationController.interactivePopGestureRecognizer?.isEnabled == false)
        #expect(environment.flowManager.cancelComponentCallsCount == 0)
        window.isHidden = true
    }

    @Test("Going back from the screen cancels the component.")
    func poppingTheScreen_shouldCancelTheComponent() {
        // Given
        let environment = makeSUT()
        let (navigationController, window) = pushInWindow(environment.sut)

        // When
        navigationController.popViewController(animated: false)
        navigationController.view.layoutIfNeeded()

        // Then
        #expect(environment.flowManager.cancelComponentCallsCount == 1)
        window.isHidden = true
    }

    // MARK: - Helpers

    private final class PopGestureLockingViewController: UIViewController {
        override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)
            navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        }
    }

    private struct Environment {
        let sut: StoredPaymentMethodContentViewController
        let flowManager: DropInFlowManagingMock
    }

    private func makeSUT(showsCancelButton: Bool = false) -> Environment {
        let flowManager = DropInFlowManagingMock()
        let viewModel = StoredPaymentMethodContentViewModel(
            component: StoredComponentMock(
                paymentMethod: PaymentMethodMock(type: .payPal, name: "PayPal"),
                viewController: UIViewController()
            ),
            theme: .default,
            showsCancelButton: showsCancelButton,
            logoURLProvider: LogoURLProvider(environment: Dummy.apiContext.environment),
            localizationParameters: nil,
            dropInFlowManager: flowManager
        )
        return Environment(sut: StoredPaymentMethodContentViewController(viewModel: viewModel), flowManager: flowManager)
    }

    private func push(_ sut: StoredPaymentMethodContentViewController) -> UINavigationController {
        let navigationController = UINavigationController(rootViewController: UIViewController())
        navigationController.loadViewIfNeeded()
        navigationController.pushViewController(sut, animated: false)
        sut.loadViewIfNeeded()
        return navigationController
    }

    /// The window is returned alongside the navigation controller, as appearance callbacks only run while it is visible.
    private func pushInWindow(_ sut: StoredPaymentMethodContentViewController) -> (UINavigationController, UIWindow) {
        let navigationController = UINavigationController(rootViewController: UIViewController())
        let window = UIWindow(frame: UIScreen.main.bounds)
        window.rootViewController = navigationController
        window.isHidden = false
        navigationController.pushViewController(sut, animated: false)
        navigationController.view.layoutIfNeeded()
        return (navigationController, window)
    }
}
