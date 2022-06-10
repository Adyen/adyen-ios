//
// Copyright (c) 2022 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) import Adyen
@_spi(AdyenInternal) import AdyenNetworking
import Foundation

internal struct CreateOrderRequest: APIRequest {

    internal typealias ResponseType = CreateOrderResponse

    internal let path: String

    internal var counter: UInt = 0

    internal let method: HTTPMethod = .post

    internal let headers: [String: String] = [:]

    internal let queryParameters: [URLQueryItem] = []

    internal let sessionData: String
    
    internal init(sessionId: String,
                  sessionData: String) {
        self.path = "checkoutshopper/v1/sessions/\(sessionId)/orders"
        self.sessionData = sessionData
    }
    
    internal func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(sessionData, forKey: .sessionData)
    }

    private enum CodingKeys: String, CodingKey {
        case sessionData
    }
}

internal struct CreateOrderResponse: SessionResponse {

    internal let pspReference: String

    internal let orderData: String

    internal let sessionData: String

    internal var order: PartialPaymentOrder {
        PartialPaymentOrder(pspReference: pspReference, orderData: orderData)
    }
    
    private enum CodingKeys: String, CodingKey {
        case pspReference
        case orderData
        case sessionData
    }
}
