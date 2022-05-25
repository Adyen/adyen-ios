//
// Copyright (c) 2022 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) import Adyen
import AdyenNetworking
import Foundation

internal struct CancelOrderRequest: APIRequest {

    internal typealias ResponseType = CancelOrderResponse

    internal let order: PartialPaymentOrder
    
    internal let sessionData: String

    internal let path: String

    internal var counter: UInt = 0

    internal let method: HTTPMethod = .post

    internal let headers: [String: String] = [:]

    internal let queryParameters: [URLQueryItem] = []
    
    internal init(sessionId: String,
                  sessionData: String,
                  order: PartialPaymentOrder) {
        self.path = "checkoutshopper/v1/sessions/\(sessionId)/orders/cancel"
        self.sessionData = sessionData
        self.order = order
    }

    internal func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(order.compactOrder, forKey: .order)
        try container.encode(sessionData, forKey: .sessionData)
    }

    private enum CodingKeys: String, CodingKey {
        case order
        case sessionData
    }
}

internal struct CancelOrderResponse: SessionResponse {

    internal let sessionData: String
}
