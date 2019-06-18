//
// Copyright (c) 2019 Adyen B.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// The data supplied by a payment component upon completion.
public struct PaymentComponentData {
    
    /// The payment method details submitted by the payment component.
    public let paymentMethod: PaymentMethodDetails
    
    /// Indicates whether the user has chosen to store the payment method.
    public let storePaymentMethod: Bool
    
    /// Initializes the payment component data.
    ///
    /// :nodoc:
    ///
    /// - Parameters:
    ///   - paymentMethodDetails: The payment method details submitted from the payment component.
    ///   - storePaymentMethod: Whether the user has chosen to store the payment method.
    public init(paymentMethodDetails: PaymentMethodDetails, storePaymentMethod: Bool = false) {
        self.paymentMethod = paymentMethodDetails
        self.storePaymentMethod = storePaymentMethod
    }
    
}
