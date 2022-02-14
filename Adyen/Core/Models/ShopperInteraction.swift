//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// A type of shopper interaction during a payment.
public enum ShopperInteraction: String, Decodable {
    
    /// Indicates the shopper is present during the payment.
    case shopperPresent = "Ecommerce"
    
    /// Indicates the shopper is not present during the payment.
    case shopperNotPresent = "ContAuth"
    
}
