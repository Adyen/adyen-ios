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
        let (sut, dropInFlowManagerMock, routerMock) = makeSUT()

        // When
        sut.cancel()

        // Then
        #expect(routerMock.dismissCompletionCallsCount == 1)
        #expect(dropInFlowManagerMock.cancelDropInCallsCount == 1)
        #expect(dropInFlowManagerMock.dismissDropInCallsCount == 1)
    }

    // MARK: - Helpers

    private func makeSUT() -> (
        sut: PaymentActionViewModel,
        dropInFlowManagerMock: DropInFlowManagingMock,
        routerMock: PaymentActionRoutingMock
    ) {
        let dropInFlowManagerMock = DropInFlowManagingMock()
        let sut = PaymentActionViewModel(dropInFlowManager: dropInFlowManagerMock)

        let routerMock = PaymentActionRoutingMock()
        sut.router = routerMock

        return (sut, dropInFlowManagerMock, routerMock)
    }
}
