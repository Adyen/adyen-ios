//
// Copyright (c) 2019 Adyen B.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

internal struct RedirectPaymentMethod: PaymentMethod {
    
    internal let type: String
    
    internal let name: String
    
}

internal struct StoredRedirectPaymentMethod: StoredPaymentMethod {
    
    internal let type: String
    
    internal let name: String
    
    internal let identifier: String
    
    internal let supportedShopperInteractions: [ShopperInteraction]
    
    // MARK: - Decoding
    
    private enum CodingKeys: String, CodingKey {
        case type
        case name
        case identifier = "id"
        case supportedShopperInteractions
    }
    
}
