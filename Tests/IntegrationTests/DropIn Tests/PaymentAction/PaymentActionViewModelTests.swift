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
struct PaymentActionViewModelTests {

    // MARK: - Tests

    @Test("The merchant is only informed about the cancellation once the drop in has been dismissed.")
    func cancel_shouldDismissActionAndCancelDropIn() {
        // Given
        var onCancelCallsCount = 0
        let (sut, routerMock) = makeSUT { onCancelCallsCount += 1 }

        var receivedCompletion: (() -> Void)?
        routerMock.dismissCompletionClosure = { receivedCompletion = $0 }

        // When
        sut.cancel()

        // Then
        #expect(routerMock.dismissCompletionCallsCount == 1)
        #expect(onCancelCallsCount == 0)

        receivedCompletion?()
        #expect(onCancelCallsCount == 1)
    }

    // MARK: - Helpers

    private func makeSUT(
        onCancel: @escaping () -> Void = {}
    ) -> (
        sut: PaymentActionViewModel,
        routerMock: PaymentActionRoutingMock
    ) {
        let sut = PaymentActionViewModel(onCancel: onCancel)

        let routerMock = PaymentActionRoutingMock()
        sut.router = routerMock

        return (sut, routerMock)
    }
}
