//
// Copyright (c) 2024 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@testable import Adyen
@testable import AdyenComponents
import Foundation

class BACSRouterProtocolMock: BACSDirectDebitRouterProtocol {

    // MARK: - presentConfirmationWithData

    var presentConfirmationWithDataCallsCount = 0
    var presentConfirmationWithDataCalled: Bool {
        presentConfirmationWithDataCallsCount > 0
    }

    var presentConfirmationWithDataReceivedData: BACSDirectDebitData?

    func presentConfirmation(with data: BACSDirectDebitData) {
        presentConfirmationWithDataCallsCount += 1
        presentConfirmationWithDataReceivedData = data
    }

    // MARK: - confirmPaymentWithData

    var confirmPaymentWithDataCallsCount = 0
    var confirmPaymentWithDataCalled: Bool {
        confirmPaymentWithDataCallsCount > 0
    }

    var confirmPaymentWithDataReceivedData: BACSDirectDebitData?

    func confirmPayment(with data: BACSDirectDebitData) {
        confirmPaymentWithDataCallsCount += 1
        confirmPaymentWithDataReceivedData = data
    }

    // MARK: - cancelPayment

    var cancelPaymentCallsCount = 0
    var cancelPaymentCalled: Bool {
        cancelPaymentCallsCount > 0
    }

    func cancelPayment() {
        cancelPaymentCallsCount += 1
    }
}
