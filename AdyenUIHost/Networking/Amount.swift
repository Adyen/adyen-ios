//
// Copyright (c) 2020 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import Foundation

extension Payment.Amount: Encodable {
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(value, forKey: CodingKeys.value)
        try container.encode(currencyCode, forKey: CodingKeys.currencyCode)
    }
    
    public enum CodingKeys: String, CodingKey {
        case value
        case currencyCode = "currency"
    }
    
}
