//
// Copyright (c) 2022 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) import Adyen
import AdyenNetworking
import Foundation

struct BalanceCheckRequest: APIRequest {
    let path: String
    
    var counter: UInt = 0
    
    let headers: [String: String] = [:]
    
    let queryParameters: [URLQueryItem] = []
    
    let method: HTTPMethod = .post
    
    let sessionData: String
    
    let data: PaymentComponentData
    
    typealias ResponseType = BalanceCheckResponse
    
    init(sessionId: String,
         sessionData: String,
         data: PaymentComponentData) {
        self.path = "checkoutshopper/v1/sessions/\(sessionId)/paymentMethodBalance"
        self.sessionData = sessionData
        self.data = data
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(data.paymentMethod.encodable, forKey: .details)
        try container.encode(sessionData, forKey: .sessionData)
    }

    private enum CodingKeys: String, CodingKey {
        case details = "paymentMethod"
        case sessionData
    }
}

struct BalanceCheckResponse: SessionResponse {

    let sessionData: String

    let balance: Amount?

    let transactionLimit: Amount?
}
