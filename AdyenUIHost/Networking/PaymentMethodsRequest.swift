//
// Copyright (c) 2019 Adyen B.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import Foundation

internal struct PaymentMethodsRequest: Request {
    
    internal typealias ResponseType = PaymentMethodsResponse
    
    internal let path = "paymentMethods"
    
    // MARK: - Encoding
    
    internal func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(Configuration.countryCode, forKey: .countryCode)
        try container.encode(Configuration.shopperReference, forKey: .shopperReference)
    }
    
    internal enum CodingKeys: CodingKey {
        case countryCode
        case shopperReference
    }
    
}

internal struct PaymentMethodsResponse: Response {
    
    internal let paymentMethods: PaymentMethods
    
    internal init(from decoder: Decoder) throws {
        self.paymentMethods = try PaymentMethods(from: decoder)
    }
    
}
