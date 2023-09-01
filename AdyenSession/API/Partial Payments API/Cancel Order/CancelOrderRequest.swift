//
// Copyright (c) 2022 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) import Adyen
import AdyenNetworking
import Foundation

struct CancelOrderRequest: APIRequest {

    typealias ResponseType = CancelOrderResponse

    let order: PartialPaymentOrder
    
    let sessionData: String

    let path: String

    var counter: UInt = 0

    let method: HTTPMethod = .post

    let headers: [String: String] = [:]

    let queryParameters: [URLQueryItem] = []
    
    init(sessionId: String,
         sessionData: String,
         order: PartialPaymentOrder) {
        self.path = "checkoutshopper/v1/sessions/\(sessionId)/orders/cancel"
        self.sessionData = sessionData
        self.order = order
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(order.compactOrder, forKey: .order)
        try container.encode(sessionData, forKey: .sessionData)
    }

    private enum CodingKeys: String, CodingKey {
        case order
        case sessionData
    }
}

struct CancelOrderResponse: SessionResponse {

    let sessionData: String
}
