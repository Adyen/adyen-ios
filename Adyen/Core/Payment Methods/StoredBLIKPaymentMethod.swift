//
// Copyright (c) 2022 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// Stored Blik payment.
public struct StoredBLIKPaymentMethod: StoredPaymentMethod {

    public let type: PaymentMethodType

    public let name: String
    
    public var merchantProvidedDisplayInformation: MerchantCustomDisplayInformation?

    public let identifier: String

    public let supportedShopperInteractions: [ShopperInteraction]

    /// :nodoc:
    public func buildComponent(using builder: PaymentComponentBuilder) -> PaymentComponent? {
        builder.build(paymentMethod: self)
    }

    // MARK: - Decoding

    private enum CodingKeys: String, CodingKey {
        case type
        case name
        case identifier = "id"
        case supportedShopperInteractions
    }

}
