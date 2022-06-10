//
// Copyright (c) 2022 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) import Adyen
import AdyenNetworking
import Foundation

internal struct BalanceCheckRequest: APIRequest {
    internal let path: String
    
    internal var counter: UInt = 0
    
    internal let headers: [String: String] = [:]
    
    internal let queryParameters: [URLQueryItem] = []
    
    internal let method: HTTPMethod = .post
    
    internal let sessionData: String
    
    internal let data: PaymentComponentData
    
    internal typealias ResponseType = BalanceCheckResponse
    
    internal init(sessionId: String,
                  sessionData: String,
                  data: PaymentComponentData) {
        self.path = "checkoutshopper/v1/sessions/\(sessionId)/paymentMethodBalance"
        self.sessionData = sessionData
        self.data = data
    }
    
    internal func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(data.paymentMethod.encodable, forKey: .details)
        try container.encode(sessionData, forKey: .sessionData)
    }

    private enum CodingKeys: String, CodingKey {
        case details = "paymentMethod"
        case sessionData
    }
}

internal struct BalanceCheckResponse: SessionResponse {

    internal let sessionData: String

    internal let balance: Amount?

    internal let transactionLimit: Amount?
}
