//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import AdyenNetworking
import Foundation

struct PaymentDetailsRequest: APIRequest {
    
    typealias ResponseType = PaymentsResponse
    
    let path = "payments/details"
    
    let details: AdditionalDetails
    
    let paymentData: String?

    let merchantAccount: String?
    
    var counter: UInt = 0
    
    var method: HTTPMethod = .post
    
    var queryParameters: [URLQueryItem] = []
    
    var headers: [String: String] = [:]
    
    func encode(to encoder: Encoder) throws {
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
