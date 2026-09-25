//
// Copyright (c) 2026 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@testable import Adyen
@testable import AdyenDropIn
import Testing
import UIKit

@MainActor
struct PaymentActionRouterTests {

    // MARK: - Tests

    @Test
    func rootViewController_shouldBeTheInjectedViewController() {
        // Given
        let viewController = UIViewController()
        let (sut, _) = makeSUT(viewController: viewController)

        // Then
        #expect(sut.rootViewController === viewController)
    }

    @Test("The action view is dismissed along with the drop in it is presented on top of, so the listener is only informed.")
    func dismiss_shouldOnlyNotifyTheListener() {
        // Given
        let viewControllerSpy = ViewControllerSpy()
        let (sut, listenerMock) = makeSUT(viewController: viewControllerSpy)

        // When
        sut.dismiss(completion: nil)

        // Then
        #expect(listenerMock.didDismissPaymentActionCompletionCallsCount == 1)
        #expect(viewControllerSpy.dismissCallsCount == 0)
    }

    @Test
    func dismiss_shouldForwardTheCompletionToTheListener() throws {
        // Given
        let (sut, listenerMock) = makeSUT()
        var completionCalled = false

        // When
        sut.dismiss { completionCalled = true }

        // Then
        let receivedCompletion = try #require(listenerMock.didDismissPaymentActionCompletionReceivedCompletion)
        receivedCompletion()
        #expect(completionCalled)
    }

    // MARK: - Mocks

    /// The generated mock does not capture the completion, which is what the drop in dismissal relies on.
    private final class PaymentActionRouterListenerSpy: PaymentActionRouterListener {
        var didDismissPaymentActionCompletionCallsCount = 0
        var didDismissPaymentActionCompletionReceivedCompletion: (() -> Void)?

        func didDismissPaymentAction(completion: (() -> Void)?) {
            didDismissPaymentActionCompletionCallsCount += 1
            didDismissPaymentActionCompletionReceivedCompletion = completion
        }
    }

    // MARK: - Helpers

    private func makeSUT(
        viewController: UIViewController = .init()
    ) -> (
        sut: PaymentActionRouter,
        listenerMock: PaymentActionRouterListenerSpy
    ) {
        let listenerMock = PaymentActionRouterListenerSpy()
        let sut = PaymentActionRouter(
            viewController: viewController,
            viewModel: PaymentActionViewModelProtocolMock(),
            listener: listenerMock
        )

        return (sut, listenerMock)
    }
}
