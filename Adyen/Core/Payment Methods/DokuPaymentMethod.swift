//
// Copyright (c) 2020 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// A Doku Wallet, Doku Alfamart, or Doku Indomaret payment method.
public struct DokuPaymentMethod: PaymentMethod {

    public let type: PaymentMethodType

    public let name: String
    
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

// MARK: - PaymentComponentBuildable

extension DokuPaymentMethod: PaymentComponentBuildable {
    package func buildComponent(using builder: any PaymentComponentBuilder) -> PaymentComponent? {
        builder.build(paymentMethod: self)
    }
}
