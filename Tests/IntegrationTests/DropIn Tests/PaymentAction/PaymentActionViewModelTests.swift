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

    @Test
    func cancel_shouldDismissActionAndCancelDropIn() {
        // Given
        var onCancelCallsCount = 0
        let (sut, routerMock) = makeSUT { onCancelCallsCount += 1 }

        // When
        sut.cancel()

        // Then
        #expect(routerMock.dismissCompletionCallsCount == 1)
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
