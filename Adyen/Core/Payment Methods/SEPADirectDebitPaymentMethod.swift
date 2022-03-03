//
// Copyright (c) 2022 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// A SEPA Direct Debit payment method.
public struct SEPADirectDebitPaymentMethod: PaymentMethod {
    
    /// :nodoc:
    public let type: PaymentMethodType
    
    /// :nodoc:
    public let name: String
    
    /// :nodoc:
    public func buildComponent(using builder: PaymentComponentBuilder) -> PaymentComponent? {
        builder.build(paymentMethod: self)
    }
    
}
