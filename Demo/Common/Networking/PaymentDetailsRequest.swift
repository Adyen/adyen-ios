//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import AdyenNetworking
import Foundation

internal struct PaymentDetailsRequest: APIRequest {
    
    internal typealias ResponseType = PaymentsResponse
    
    internal let path = "payments/details"
    
    internal let details: AdditionalDetails
    
    internal let paymentData: String?

    internal let merchantAccount: String?
    
    internal var counter: UInt = 0
    
    internal var method: HTTPMethod = .post
    
    internal var queryParameters: [URLQueryItem] = []
    
    internal var headers: [String: String] = [:]
    
    internal func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(details.encodable, forKey: .details)
        try container.encode(paymentData, forKey: .paymentData)
        try container.encode(merchantAccount, forKey: .merchantAccount)
    }
    
    private enum CodingKeys: String, CodingKey {
        case details
        case paymentData
        case merchantAccount
    }
}
