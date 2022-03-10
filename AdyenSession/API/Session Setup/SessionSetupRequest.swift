//
// Copyright (c) 2022 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import AdyenNetworking
import Foundation

internal struct SessionSetupRequest: Request {
    internal let path: String
    
    internal var counter: UInt = 0
    
    internal let headers: [String: String] = [:]
    
    internal let queryParameters: [URLQueryItem] = []
    
    internal let method: HTTPMethod = .post
    
    internal let sessionData: String
    
    internal typealias ResponseType = SessionSetupResponse
    
    internal typealias ErrorResponseType = APIError
    
    internal init(sessionId: String, sessionData: String) {
        self.path = "checkoutshopper/v1/sessions/\(sessionId)/setup"
        self.sessionData = sessionData
    }
    
    private enum CodingKeys: String, CodingKey {
        case sessionData
    }
}

internal struct SessionSetupResponse: Response {
    
    internal let countryCode: String
    
    internal let shopperLocale: String
    
    internal let paymentMethods: PaymentMethods
    
    internal let amount: Amount
    
    internal let sessionData: String
    
    private enum CodingKeys: String, CodingKey {
        case countryCode
        case shopperLocale
        case paymentMethods
        case amount
        case sessionData
    }
}
