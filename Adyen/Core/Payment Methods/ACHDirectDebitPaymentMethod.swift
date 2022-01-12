//
// Copyright (c) 2022 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// An ACH Direct Debit payment method.
public struct ACHDirectDebitPaymentMethod: PaymentMethod {
    
    /// :nodoc:
    public let type: String

    /// :nodoc:
    public let name: String

    /// Initializes the ACH Direct Debit payment method.
    /// - Parameters:
    ///   - type: The payment method type.
    ///   - name: The payment method name.
    internal init(type: String, name: String) {
        self.type = type
        self.name = name
    }

    /// :nodoc:
    public func buildComponent(using builder: PaymentComponentBuilder) -> PaymentComponent? {
        builder.build(paymentMethod: self)
    }

    // MARK: - Private

    private enum CodingKeys: String, CodingKey {
        case type
        case name
    }
    
}
