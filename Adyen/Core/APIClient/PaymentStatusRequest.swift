//
// Copyright (c) 2020 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

internal struct PaymentStatusRequest: Request {
    
    internal typealias ResponseType = PaymentStatusResponse
    
    internal let path: String = "checkoutshopper/services/PaymentInitiation/v1/status"
    
    internal var counter: Int = 0
    
    internal let headers: [String: String] = [:]
    
    internal let queryParameters: [URLQueryItem] = []
    
    internal let method: HTTPMethod = .post
    
    internal let paymentData: String
    
    internal enum CodingKeys: String, CodingKey {
        case paymentData
    }
}
