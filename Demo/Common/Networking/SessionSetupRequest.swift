//
// Copyright (c) 2022 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import AdyenNetworking
import Foundation

internal struct SessionSetupRequest: APIRequest {
    
    internal typealias ResponseType = SessionSetupResponse
    
    internal let path = "sessions"
    
    internal var counter: UInt = 0
    
    internal var method: HTTPMethod = .post
    
    internal var headers: [String: String] = [:]
    
    internal var queryParameters: [URLQueryItem] = []
    
    internal func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        let currentConfiguration = ConfigurationConstants.current
        
        try container.encode(currentConfiguration.countryCode, forKey: .countryCode)
        try container.encode(currentConfiguration.merchantAccount, forKey: .merchantAccount)
        try container.encode(currentConfiguration.amount, forKey: .amount)
        try container.encode(ConfigurationConstants.returnUrl, forKey: .returnUrl)
        try container.encode(ConfigurationConstants.reference, forKey: .reference)
        
    }
    
    internal enum CodingKeys: CodingKey {
        case countryCode
        case merchantAccount
        case amount
        case order
        case returnUrl
        case reference
    }
    
}

internal struct SessionSetupResponse: Response {
    
    internal let sessionData: String
    
    internal let sessionId: String
    
    internal enum CodingKeys: String, CodingKey {
        case sessionData
        case sessionId = "id"
    }
}
