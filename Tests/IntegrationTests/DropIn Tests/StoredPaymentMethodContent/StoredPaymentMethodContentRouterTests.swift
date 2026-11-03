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
internal struct StoredPaymentMethodContentRouterTests {

    /// Closing the stored payment screen does not close it directly: the screen asks whoever presented it
    /// to take it away, because only that module knows whether it was pushed or presented modally.
    @Test
    internal func storedPaymentMethodContent_whenDismissed_thenAsksListenerToUnwind() {
        let (sut, listener, _) = makeSUT()

        sut.dismiss()

        #expect(listener.dismissCallsCount == 1)
    }

    /// The stored payment screen must never touch the navigation stack it sits in, so dismissing it
    /// pops nothing and dismisses nothing: it only notifies the module that presented it.
    @Test
    internal func storedPaymentMethodContent_whenDismissed_thenDoesNotTouchTheNavigationStack() {
        let (sut, _, navigationController) = makeSUT()

        sut.dismiss()

        #expect(navigationController.popViewControllerCallsCount == 0)
        #expect(navigationController.dismissCallsCount == 0)
    }

    private func makeSUT() -> (
        sut: StoredPaymentMethodContentRouter,
        listener: ContentRouterListenerSpy,
        navigationController: NavigationControllerSpy
    ) {
        let navigationController = NavigationControllerSpy()
        let viewController = ViewControllerSpy()
        viewController.setNavigationController(navigationController)
        let listener = ContentRouterListenerSpy()

        let sut = StoredPaymentMethodContentRouter(
            viewController: viewController,
            listener: listener
        )
        return (sut, listener, navigationController)
    }
}

@MainActor
private final class ContentRouterListenerSpy: StoredPaymentMethodContentRouterListener {
    private(set) var dismissCallsCount = 0

    func dismissStoredPaymentMethodContent() {
        dismissCallsCount += 1
    }
}
