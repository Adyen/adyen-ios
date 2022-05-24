//
// Copyright (c) 2022 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// Provides a placeholder for payment methods that are already paid, just for display.
/// :nodoc:
public final class AlreadyPaidPaymentComponent: PaymentComponent {

    /// :nodoc:
    /// The context object for this component.
    public let context: AdyenContext
    
    /// :nodoc:
    public let paymentMethod: PaymentMethod

    /// :nodoc:
    public weak var delegate: PaymentComponentDelegate?

    /// :nodoc:
    public init(paymentMethod: PaymentMethod,
                context: AdyenContext) {
        self.paymentMethod = paymentMethod
        self.context = context
    }
}
