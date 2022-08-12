//
// Copyright (c) 2022 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import AdyenNetworking
import Foundation

internal struct PaymentMethodsRequest: APIRequest {
    
    internal typealias ResponseType = PaymentMethodsResponse
    
    internal let path = "paymentMethods"
    
    internal var counter: UInt = 0
    
    internal var method: HTTPMethod = .post
    
    internal var headers: [String: String] = [:]
    
    internal var queryParameters: [URLQueryItem] = []

    internal var order: PartialPaymentOrder?
    
    // MARK: - Encoding
    
    internal func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        let currentConfiguration = ConfigurationConstants.current
        
        try container.encode(currentConfiguration.countryCode, forKey: .countryCode)
        try container.encode(ConfigurationConstants.shopperReference, forKey: .shopperReference)
        try container.encode(currentConfiguration.merchantAccount, forKey: .merchantAccount)
        try container.encode(currentConfiguration.amount, forKey: .amount)
        try container.encodeIfPresent(order?.compactOrder, forKey: .order)
    }
    
    internal enum CodingKeys: CodingKey {
        case countryCode
        case shopperReference
        case merchantAccount
        case amount
        case order
    }
    
}

internal struct PaymentMethodsResponse: Response {
    
    internal let paymentMethods: PaymentMethods
    
    internal init(from decoder: Decoder) throws {
        self.paymentMethods = try PaymentMethods(from: decoder)
    }
    
}
