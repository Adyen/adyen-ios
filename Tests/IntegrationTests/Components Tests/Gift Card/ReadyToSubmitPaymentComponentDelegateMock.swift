//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) @testable import Adyen
@testable import AdyenComponents
import Foundation

final class ReadyToSubmitPaymentComponentDelegateMock: ReadyToSubmitPaymentComponentDelegate {
    var onShowConfirmation: ((PaymentComponent, PartialPaymentOrder?) -> Void)?

    func showConfirmation(for component: PaymentComponent, with order: PartialPaymentOrder?) {
        onShowConfirmation?(component, order)
    }
}
