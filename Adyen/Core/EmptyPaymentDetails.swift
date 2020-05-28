//
// Copyright (c) 2020 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// Describes a payment details that contains nothing but the payment method type name.
/// :nodoc:
public struct EmptyPaymentDetails: PaymentMethodDetails {
    
    /// The payment method type name.
    public let type: String
    
    /// Initializes an `EmptyPaymentDetails`.
    ///
    /// - Parameter type: The payment method type name.
    public init(type: String) {
        self.type = type
    }
    
}
