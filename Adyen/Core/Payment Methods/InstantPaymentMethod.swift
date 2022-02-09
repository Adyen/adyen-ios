//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// A payment method that does not require any handling and could be submitted directly.
public struct InstantPaymentMethod: PaymentMethod {

    /// :nodoc:
    public let type: String

    /// :nodoc:
    public let name: String

    /// :nodoc:
    public func buildComponent(using builder: PaymentComponentBuilder) -> PaymentComponent? {
        builder.build(paymentMethod: self)
    }

    private enum CodingKeys: String, CodingKey {
        case type
        case name
    }
}

/// A payment method for OXXO.
public typealias OXXOPaymentMethod = InstantPaymentMethod

/// A  payment method for Multibanco.
public typealias MultibancoPaymentMethod = InstantPaymentMethod
