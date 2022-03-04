//
//  PaymentDetailsRequest.swift
//  AdyenSession
//
//  Created by Mohamed Eldoheiri on 3/4/22.
//  Copyright © 2022 Adyen. All rights reserved.
//

import Foundation
import Adyen
import AdyenNetworking

internal struct PaymentDetailsRequest: Request {
    internal let path: String
    
    internal var counter: UInt = 0
    
    internal let headers: [String: String] = [:]
    
    internal let queryParameters: [URLQueryItem] = []
    
    internal let method: HTTPMethod = .post
    
    internal let sessionData: String
    
    internal let paymentData: String?
    
    internal let details: AdditionalDetails
    
    internal typealias ResponseType = PaymentsResponse
    
    internal typealias ErrorResponseType = APIError
    
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
