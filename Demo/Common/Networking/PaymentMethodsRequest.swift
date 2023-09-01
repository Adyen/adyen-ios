//
// Copyright (c) 2022 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import AdyenNetworking
import Foundation

struct PaymentMethodsRequest: APIRequest {
    
    typealias ResponseType = PaymentMethodsResponse
    
    let path = "paymentMethods"
    
    var counter: UInt = 0
    
    var method: HTTPMethod = .post
    
    var headers: [String: String] = [:]
    
    var queryParameters: [URLQueryItem] = []

    var order: PartialPaymentOrder?
    
    // MARK: - Encoding
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        let currentConfiguration = ConfigurationConstants.current
        
        try container.encode(currentConfiguration.countryCode, forKey: .countryCode)
        try container.encode(ConfigurationConstants.shopperReference, forKey: .shopperReference)
        try container.encode(currentConfiguration.merchantAccount, forKey: .merchantAccount)
        try container.encode(currentConfiguration.amount, forKey: .amount)
        try container.encodeIfPresent(order?.compactOrder, forKey: .order)
    }
    
    enum CodingKeys: CodingKey {
        case countryCode
        case shopperReference
        case merchantAccount
        case amount
        case order
    }
    
}

struct PaymentMethodsResponse: Response {
    
    let paymentMethods: PaymentMethods
    
    init(from decoder: Decoder) throws {
        self.paymentMethods = try PaymentMethods(from: decoder)
    }
    
}
