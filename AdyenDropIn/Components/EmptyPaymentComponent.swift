//
// Copyright (c) 2020 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// Provides a placeholder for payment methods that don't need any payment detail to be filled.
internal final class EmptyPaymentComponent: PaymentComponent {
    
    internal let paymentMethod: PaymentMethod
    
    /// The delegate of the component.
    internal weak var delegate: PaymentComponentDelegate?
    
    internal init(paymentMethod: PaymentMethod) {
        self.paymentMethod = paymentMethod
    }
    
    /// Generate the payment details and invoke PaymentsComponentDelegate method.
    internal func initiatePayment() {
        let details = EmptyPaymentDetails(type: paymentMethod.type)
        submit(data: PaymentComponentData(paymentMethodDetails: details))
    }
}
