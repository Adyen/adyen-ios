//
// Copyright (c) 2024 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) import Adyen
import AdyenNetworking
import Foundation

internal struct DisableStoredPaymentMethodRequest: APIRequest {
    
    internal typealias ResponseType = DisableStoredPaymentMethodResponse
    
    internal let path: String
    
    internal var counter: UInt = 0
    
    internal let headers: [String: String] = [:]
    
    internal let queryParameters: [URLQueryItem] = []
    
    internal let method: HTTPMethod = .post
    
    internal let sessionData: String
    
    internal let storedPaymentMethodId: String
    
    internal init(sessionId: String,
                  sessionData: String,
                  storedPaymentMethodId: String) {
        self.path = "checkoutshopper/v1/sessions/\(sessionId)/disableToken"
        self.sessionData = sessionData
        self.storedPaymentMethodId = storedPaymentMethodId
    }
    
    private enum CodingKeys: String, CodingKey {
        case sessionData
        case storedPaymentMethodId
    }
    
}

internal struct DisableStoredPaymentMethodResponse: Response {}
