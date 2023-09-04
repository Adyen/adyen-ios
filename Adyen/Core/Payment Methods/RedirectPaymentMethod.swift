//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

struct RedirectPaymentMethod: PaymentMethod {
    
    let type: String
    
    let name: String
    
    /// :nodoc:
    func buildComponent(using builder: PaymentComponentBuilder) -> PaymentComponent? {
        builder.build(paymentMethod: self)
    }
    
}

struct StoredRedirectPaymentMethod: StoredPaymentMethod {
    
    let type: String
    
    let name: String
    
    let identifier: String
    
    let supportedShopperInteractions: [ShopperInteraction]
    
    /// :nodoc:
    func buildComponent(using builder: PaymentComponentBuilder) -> PaymentComponent? {
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
