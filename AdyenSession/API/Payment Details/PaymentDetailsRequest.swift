//
// Copyright (c) 2022 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) import Adyen
import AdyenNetworking
import Foundation

internal struct PaymentDetailsRequest: APIRequest {
    internal let path: String
    
    internal var counter: UInt = 0
    
    internal let headers: [String: String] = [:]
    
    internal let queryParameters: [URLQueryItem] = []
    
    internal let method: HTTPMethod = .post
    
    internal let sessionData: String
    
    internal let paymentData: String?
    
    internal let details: AdditionalDetails
    
    internal typealias ResponseType = PaymentsResponse
    
    internal init(sessionId: String,
                  sessionData: String,
                  paymentData: String?,
                  details: AdditionalDetails) {
        self.path = "checkoutshopper/v1/sessions/\(sessionId)/paymentDetails"
        self.sessionData = sessionData
        self.paymentData = paymentData
        self.details = details
    }
    
    internal func encode(to encoder: Encoder) throws {
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
