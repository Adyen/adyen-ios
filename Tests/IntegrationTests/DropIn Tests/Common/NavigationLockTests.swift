//
// Copyright (c) 2026 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@testable import AdyenDropIn
import Testing
import UIKit

@MainActor
struct NavigationLockTests {

    @Test("While no payment is in progress, the bar and swiping back work as usual.")
    func inactiveLock_shouldKeepTheNavigation() {
        // Given
        let environment = makeSUT()

        // Then
        #expect(environment.navigationController.navigationBar.isUserInteractionEnabled)
        #expect(environment.navigationController.interactivePopGestureRecognizer?.isEnabled == true)
        environment.window.isHidden = true
    }

    @Test("A submitted payment cannot be cancelled, so the shopper cannot navigate away from it.")
    func activeLock_shouldLockTheNavigation() {
        // Given
        let environment = makeSUT()

        // When
        environment.sut.isLockActive = true

        // Then
        #expect(!environment.navigationController.navigationBar.isUserInteractionEnabled)
        #expect(environment.navigationController.interactivePopGestureRecognizer?.isEnabled == false)
        environment.window.isHidden = true
    }

    @Test
    func activeLock_whenEnded_shouldUnlockTheNavigation() {
        // Given
        let environment = makeSUT()
        environment.sut.isLockActive = true

        // When
        environment.sut.isLockActive = false

        // Then
        #expect(environment.navigationController.navigationBar.isUserInteractionEnabled)
        #expect(environment.navigationController.interactivePopGestureRecognizer?.isEnabled == true)
        environment.window.isHidden = true
    }

    #if compiler(>=6.2)
        @Test("From iOS 26 swiping anywhere in the content pops too, so that gesture is locked as well.")
        func activeLock_shouldLockTheContentPopGesture() throws {
            guard #available(iOS 26.0, *) else { return }

            // Given
            let environment = makeSUT()
            let contentPopGestureRecognizer = try #require(environment.navigationController.interactiveContentPopGestureRecognizer)

            // When
            environment.sut.isLockActive = true

            // Then
            #expect(!contentPopGestureRecognizer.isEnabled)

            // When
            environment.sut.isLockActive = false

            // Then
            #expect(contentPopGestureRecognizer.isEnabled)
            environment.window.isHidden = true
        }
    #endif

    @Test("A screen pushed during the payment, such as an action, gets an interactive bar and keeps its own pop gesture state.")
    func pushingAScreen_whileLockActive_shouldHandOverTheNavigation() {
        // Given
        let environment = makeSUT()
        environment.sut.isLockActive = true

        // When
        environment.navigationController.pushViewController(PopGestureLockingViewController(), animated: false)
        environment.navigationController.view.layoutIfNeeded()

        // Then
        #expect(environment.navigationController.navigationBar.isUserInteractionEnabled)
        #expect(environment.navigationController.interactivePopGestureRecognizer?.isEnabled == false)

        // When
        environment.sut.isLockActive = false

        // Then
        #expect(environment.navigationController.interactivePopGestureRecognizer?.isEnabled == false)
        #expect(environment.onPopCallsCount() == 0)
        environment.window.isHidden = true
    }

    @Test("Going back from the screen is reported, so the payment can be cancelled.")
    func poppingTheScreen_shouldReportThePop() {
        // Given
        let environment = makeSUT()

        // When
        environment.navigationController.popViewController(animated: false)
        environment.navigationController.view.layoutIfNeeded()

        // Then
        #expect(environment.onPopCallsCount() == 1)
        environment.window.isHidden = true
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
        let sut: NavigationLockViewController
        let navigationController: UINavigationController
        let window: UIWindow
        let onPopCallsCount: () -> Int
    }

    /// Pushes a screen that hosts the lock, the way SwiftUI hosts it as a child of its hosting controller.
    private func makeSUT() -> Environment {
        let sut = NavigationLockViewController()
        let popCounter = PopCounter()
        sut.onPop = { popCounter.count += 1 }

        let screen = UIViewController()
        screen.addChild(sut)
        screen.view.addSubview(sut.view)
        sut.didMove(toParent: screen)

        let navigationController = UINavigationController(rootViewController: UIViewController())
        let window = UIWindow(frame: UIScreen.main.bounds)
        window.rootViewController = navigationController
        window.isHidden = false
        navigationController.pushViewController(screen, animated: false)
        navigationController.view.layoutIfNeeded()

        return Environment(
            sut: sut,
            navigationController: navigationController,
            window: window,
            onPopCallsCount: { popCounter.count }
        )
    }
}
