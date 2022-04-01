//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// Provides a placeholder for payment methods that are already paid, just for display.
/// :nodoc:
public final class AlreadyPaidPaymentComponent: PaymentComponent {

    /// :nodoc:
    public let apiContext: APIContext

    /// The Adyen context.
    public let adyenContext: AdyenContext

    /// :nodoc:
    public let paymentMethod: PaymentMethod

    /// :nodoc:
    public weak var delegate: PaymentComponentDelegate?

    /// :nodoc:
    public init(paymentMethod: PaymentMethod,
                apiContext: APIContext,
                adyenContext: AdyenContext) {
        self.paymentMethod = paymentMethod
        self.apiContext = apiContext
        self.adyenContext = adyenContext
    }
}
