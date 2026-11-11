//
// Copyright (c) 2026 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@testable import AdyenDropIn
import Combine
import SwiftUI
import Testing
import UIKit

@MainActor
struct NavigationLockingHostingControllerTests {

    @Test("A sheet with the screen on top cannot be swiped away, so a submitted payment is never dismissed.")
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

    @Test("A screen that can be cancelled gets the system Cancel button, which SwiftUI keeps once the screen is shown.")
    func cancellableScreen_shouldShowTheSystemCancelButton() {
        // Given
        let environment = makeSUT(onCancel: {})
        let navigationController = UINavigationController(rootViewController: environment.sut)
        let window = UIWindow(frame: UIScreen.main.bounds)
        window.rootViewController = navigationController
        window.isHidden = false

        // When
        navigationController.view.layoutIfNeeded()

        // Then
        let navigationItem = environment.sut.navigationItem
        let leadingItems = (navigationItem.leftBarButtonItems ?? []) + navigationItem.leadingItemGroups.flatMap(\.barButtonItems)
        #expect(leadingItems.contains { $0 === environment.sut.cancelButtonItem })
        #expect(environment.sut.cancelButtonItem.isEnabled)
        window.isHidden = true
    }

    @Test("A submitted payment cannot be cancelled, so the Cancel button is disabled until it ends.")
    func paymentInProgress_shouldDisableTheCancelButton() {
        // Given
        let environment = makeSUT(onCancel: {})

        // When
        environment.isNavigationLocked.send(true)

        // Then
        #expect(!environment.sut.cancelButtonItem.isEnabled)

        // When
        environment.isNavigationLocked.send(false)

        // Then
        #expect(environment.sut.cancelButtonItem.isEnabled)
    }

    @Test("The root of a sheet has no screen to go back to, so locking it does not add a back button next to Cancel.")
    func paymentInProgress_onTheRootOfASheet_shouldNotAddABackButton() {
        // Given
        let environment = makeSUT(onCancel: {})
        let navigationController = UINavigationController(rootViewController: environment.sut)
        navigationController.loadViewIfNeeded()

        // When
        environment.isNavigationLocked.send(true)

        // Then
        #expect(environment.sut.navigationItem.backAction == nil)
        #expect(!navigationController.navigationBar.isUserInteractionEnabled)
    }

    @Test("A submitted payment cannot be cancelled, so the shopper cannot navigate away from it.")
    func paymentInProgress_shouldLockTheNavigation() {
        // Given
        let environment = makeSUT()
        let navigationController = push(environment.sut)

        // When
        environment.isNavigationLocked.send(true)

        // Then
        #expect(!navigationController.navigationBar.isUserInteractionEnabled)
        #expect(navigationController.interactivePopGestureRecognizer?.isEnabled == false)
        #expect(environment.sut.navigationItem.backAction != nil)
    }

    @Test
    func paymentInProgress_whenEnded_shouldUnlockTheNavigation() {
        // Given
        let environment = makeSUT()
        let navigationController = push(environment.sut)
        environment.isNavigationLocked.send(true)

        // When
        environment.isNavigationLocked.send(false)

        // Then
        #expect(navigationController.navigationBar.isUserInteractionEnabled)
        #expect(navigationController.interactivePopGestureRecognizer?.isEnabled == true)
        #expect(environment.sut.navigationItem.backAction == nil)
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
            environment.isNavigationLocked.send(true)

            // Then
            #expect(!contentPopGestureRecognizer.isEnabled)

            // When
            environment.isNavigationLocked.send(false)

            // Then
            #expect(contentPopGestureRecognizer.isEnabled)
        }
    #endif

    @Test("A screen pushed during the payment, such as an action, gets an interactive bar and is not reported as going back.")
    func pushingAScreen_whilePaymentInProgress_shouldHandOverTheNavigation() {
        // Given
        let environment = makeSUT()
        let (navigationController, window) = pushInWindow(environment.sut)
        environment.isNavigationLocked.send(true)

        // When
        navigationController.pushViewController(PopGestureLockingViewController(), animated: false)
        navigationController.view.layoutIfNeeded()

        // Then
        #expect(navigationController.navigationBar.isUserInteractionEnabled)
        #expect(navigationController.interactivePopGestureRecognizer?.isEnabled == false)

        // When
        environment.isNavigationLocked.send(false)

        // Then
        #expect(navigationController.interactivePopGestureRecognizer?.isEnabled == false)
        #expect(environment.popCounter.count == 0)
        window.isHidden = true
    }

    @Test("Going back from the screen is reported once.")
    func poppingTheScreen_shouldReportThePop() {
        // Given
        let environment = makeSUT()
        let (navigationController, window) = pushInWindow(environment.sut)

        // When
        navigationController.popViewController(animated: false)
        navigationController.view.layoutIfNeeded()

        // Then
        #expect(environment.popCounter.count == 1)
        window.isHidden = true
    }

    @Test("A payment that starts while the screen is still being pushed keeps going back blocked once the push ends.")
    func paymentInProgress_duringThePushTransition_shouldStayLocked() async throws {
        // Given
        let environment = makeSUT()
        let navigationController = UINavigationController(rootViewController: UIViewController())
        let window = UIWindow(frame: UIScreen.main.bounds)
        window.rootViewController = navigationController
        window.isHidden = false
        navigationController.view.layoutIfNeeded()
        navigationController.pushViewController(environment.sut, animated: true)
        navigationController.view.layoutIfNeeded()

        // When
        environment.isNavigationLocked.send(true)
        try await Task.sleep(for: .seconds(1))

        // Then
        #expect(environment.sut.navigationItem.backAction != nil)
        #expect(navigationController.interactivePopGestureRecognizer?.isEnabled == false)
        window.isHidden = true
    }

    // MARK: - Helpers

    private final class PopGestureLockingViewController: UIViewController {
        override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)
            navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        }
    }

    private final class PopCounter {
        var count = 0
    }

    private struct Environment {
        let sut: NavigationLockingHostingController<Color>
        let isNavigationLocked: CurrentValueSubject<Bool, Never>
        let popCounter: PopCounter
    }

    private func makeSUT(onCancel: (() -> Void)? = nil) -> Environment {
        let isNavigationLocked = CurrentValueSubject<Bool, Never>(false)
        let popCounter = PopCounter()
        let sut = NavigationLockingHostingController(
            rootView: Color.clear,
            isNavigationLocked: isNavigationLocked.eraseToAnyPublisher(),
            onPop: { popCounter.count += 1 },
            onCancel: onCancel
        )
        return Environment(sut: sut, isNavigationLocked: isNavigationLocked, popCounter: popCounter)
    }

    private func push(_ sut: UIViewController) -> UINavigationController {
        let navigationController = UINavigationController(rootViewController: UIViewController())
        navigationController.loadViewIfNeeded()
        navigationController.pushViewController(sut, animated: false)
        sut.loadViewIfNeeded()
        return navigationController
    }

    /// The window is returned alongside the navigation controller, as appearance callbacks only run while it is visible.
    private func pushInWindow(_ sut: UIViewController) -> (UINavigationController, UIWindow) {
        let navigationController = UINavigationController(rootViewController: UIViewController())
        let window = UIWindow(frame: UIScreen.main.bounds)
        window.rootViewController = navigationController
        window.isHidden = false
        navigationController.pushViewController(sut, animated: false)
        navigationController.view.layoutIfNeeded()
        return (navigationController, window)
    }
}
