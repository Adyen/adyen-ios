//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// A Doku Wallet, Doku Alfamart, or Doku Indomaret payment method.
public struct DokuPaymentMethod: PaymentMethod {

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

/// A Doku Wallet payment method.
public typealias DokuWalletPaymentMethod = DokuPaymentMethod

/// A Doku Alfamart payment method.
public typealias AlfamartPaymentMethod = DokuPaymentMethod

/// A Doku Indomaret payment method.
public typealias IndomaretPaymentMethod = DokuPaymentMethod
