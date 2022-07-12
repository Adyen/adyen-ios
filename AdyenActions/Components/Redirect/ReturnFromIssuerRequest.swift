//
// Copyright (c) 2022 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import AdyenNetworking
import Foundation
@_spi(AdyenInternal) import Adyen

internal struct ReturnFromIssuerRequest: Request {
    internal typealias ResponseType = ReturnFromIssuerResponse
    
    internal typealias ErrorResponseType = APIError
    
    internal let path: String = "checkoutshopper/v1/didReturnFromIssuer"
    
    internal var counter: UInt = 0
    
    internal let headers: [String: String] = [:]
    
    internal let queryParameters: [URLQueryItem] = []
    
    internal let method: HTTPMethod = .post
    
    internal let redirectId: String?
    
    internal let redirectData: String?
    
    internal let returnQueryString: String
    
    internal init(redirectId: String?, redirectData: String?, returnQueryString: String) {
        self.redirectId = redirectId
        self.redirectData = redirectData
        self.returnQueryString = returnQueryString
    }
    
    private enum CodingKeys: String, CodingKey {
        case redirectId
        case redirectData
        case returnQueryString
    }
}

internal struct ReturnFromIssuerResponse: Response {
    internal let returnUrl: URL
    
    private enum CodingKeys: String, CodingKey {
        case returnUrl
    }
}
