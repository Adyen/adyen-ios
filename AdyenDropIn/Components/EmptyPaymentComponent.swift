//
// Copyright (c) 2019 Adyen B.V.
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
    internal func generateDetails() {
        let details = EmptyPaymentDetails(type: paymentMethod.type)
        delegate?.didSubmit(PaymentComponentData(paymentMethodDetails: details), from: self)
    }
}

internal struct EmptyPaymentDetails: PaymentMethodDetails {
    
    internal let type: String
    
}
