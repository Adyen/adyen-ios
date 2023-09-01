//
// Copyright (c) 2022 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) import Adyen
@_spi(AdyenInternal) import AdyenNetworking
import Foundation

struct CreateOrderRequest: APIRequest {

    typealias ResponseType = CreateOrderResponse

    let path: String

    var counter: UInt = 0

    let method: HTTPMethod = .post

    let headers: [String: String] = [:]

    let queryParameters: [URLQueryItem] = []

    let sessionData: String
    
    init(sessionId: String,
         sessionData: String) {
        self.path = "checkoutshopper/v1/sessions/\(sessionId)/orders"
        self.sessionData = sessionData
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(sessionData, forKey: .sessionData)
    }

    private enum CodingKeys: String, CodingKey {
        case sessionData
    }
}

struct CreateOrderResponse: SessionResponse {

    let pspReference: String

    let orderData: String

    let sessionData: String

    var order: PartialPaymentOrder {
        PartialPaymentOrder(pspReference: pspReference, orderData: orderData)
    }
    
    private enum CodingKeys: String, CodingKey {
        case pspReference
        case orderData
        case sessionData
    }
}
