//
// Copyright (c) 2026 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// The result of a completed advanced checkout flow.
public struct AdvancedCheckoutResult {

    /// The result code indicating the outcome of the payment.
    public let resultCode: CheckoutResultCode

    package init(resultCode: CheckoutResultCode) {
        self.resultCode = resultCode
    }
}
