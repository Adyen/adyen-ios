//
// Copyright (c) 2022 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) import Adyen
import AdyenNetworking
import Foundation

struct PaymentDetailsRequest: APIRequest {
    let path: String
    
    var counter: UInt = 0
    
    let headers: [String: String] = [:]
    
    let queryParameters: [URLQueryItem] = []
    
    let method: HTTPMethod = .post
    
    let sessionData: String
    
    let paymentData: String?
    
    let details: AdditionalDetails
    
    typealias ResponseType = PaymentsResponse
    
    init(sessionId: String,
         sessionData: String,
         paymentData: String?,
         details: AdditionalDetails) {
        self.path = "checkoutshopper/v1/sessions/\(sessionId)/paymentDetails"
        self.sessionData = sessionData
        self.paymentData = paymentData
        self.details = details
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(details.encodable, forKey: .details)
        try container.encodeIfPresent(paymentData, forKey: .paymentData)
        try container.encode(sessionData, forKey: .sessionData)
    }
    
    private enum CodingKeys: String, CodingKey {
        case details
        case paymentData
        case sessionData
    }
}
