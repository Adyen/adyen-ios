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

    @Test
    internal func content_whenDismissed_thenAsksListenerToUnwind() {
        let navigationController = PromptNavigationControllerSpy()
        let (sut, listener) = makeSUT(navigationController: navigationController)

        sut.dismiss()

        #expect(listener.dismissCallsCount == 1)
    }

    @Test
    internal func content_whenDismissed_thenDoesNotUnwindTheStackItself() {
        let navigationController = PromptNavigationControllerSpy()
        let (sut, _) = makeSUT(navigationController: navigationController)

        sut.dismiss()

        #expect(navigationController.popCallsCount == 0)
        #expect(navigationController.dismissCallsCount == 0)
    }

    private func makeSUT(
        navigationController: PromptNavigationControllerSpy
    ) -> (sut: StoredPaymentMethodContentRouter, listener: ListenerSpy) {
        let viewController = PromptViewControllerSpy(navigationController: navigationController)
        let listener = ListenerSpy()
        let sut = StoredPaymentMethodContentRouter(
            viewController: viewController,
            listener: listener
        )
        return (sut, listener)
    }
}

@MainActor
private final class ListenerSpy: StoredPaymentMethodContentRouterListener {
    private(set) var dismissCallsCount = 0

    func dismissStoredPaymentMethodContent() {
        dismissCallsCount += 1
    }
}

@MainActor
private final class PromptViewControllerSpy: UIViewController {
    private let navigationControllerSpy: UINavigationController

    override var navigationController: UINavigationController? {
        navigationControllerSpy
    }

    init(navigationController: UINavigationController) {
        self.navigationControllerSpy = navigationController
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

@MainActor
private final class PromptNavigationControllerSpy: UINavigationController {
    private(set) var popCallsCount = 0
    private(set) var dismissCallsCount = 0

    override func popViewController(animated: Bool) -> UIViewController? {
        popCallsCount += 1
        return nil
    }

    override func dismiss(animated flag: Bool, completion: (() -> Void)? = nil) {
        dismissCallsCount += 1
        completion?()
    }
}
