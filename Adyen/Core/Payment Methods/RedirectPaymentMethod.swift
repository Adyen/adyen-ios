//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

internal struct RedirectPaymentMethod: PaymentMethod {
    
    internal let type: String
    
    internal let name: String
    
    /// :nodoc:
    internal func buildComponent(using builder: PaymentComponentBuilder) -> PaymentComponent? {
        builder.build(paymentMethod: self)
    }
    
}

internal struct StoredRedirectPaymentMethod: StoredPaymentMethod {
    
    internal let type: String
    
    internal let name: String
    
    internal let identifier: String
    
    internal let supportedShopperInteractions: [ShopperInteraction]
    
    /// :nodoc:
    internal func buildComponent(using builder: PaymentComponentBuilder) -> PaymentComponent? {
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
