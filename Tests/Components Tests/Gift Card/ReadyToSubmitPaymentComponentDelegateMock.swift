//
// Copyright (c) 2024 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) @testable import Adyen
import Foundation

final class ReadyToSubmitPaymentComponentDelegateMock: ReadyToSubmitPaymentComponentDelegate {
    var onShowConfirmation: ((InstantPaymentComponent, PartialPaymentOrder?) -> Void)?

    func showConfirmation(for component: InstantPaymentComponent, with order: PartialPaymentOrder?) {
        onShowConfirmation?(component, order)
    }
}
