//
// Copyright (c) 2022 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// Provides a placeholder for payment methods that are already paid, just for display.
@_spi(AdyenInternal)
public final class AlreadyPaidPaymentComponent: PaymentComponent {
    
    public let apiContext: APIContext

    public let paymentMethod: PaymentMethod

    public weak var delegate: PaymentComponentDelegate?

    public init(paymentMethod: PaymentMethod,
                apiContext: APIContext) {
        self.paymentMethod = paymentMethod
        self.apiContext = apiContext
    }
}
