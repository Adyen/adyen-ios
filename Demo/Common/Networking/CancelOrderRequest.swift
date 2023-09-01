//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import AdyenNetworking
import Foundation

struct CancelOrderRequest: APIRequest {

    typealias ResponseType = CancelOrderResponse

    let order: PartialPaymentOrder

    let path = "orders/cancel"

    var counter: UInt = 0

    var method: HTTPMethod = .post

    var headers: [String: String] = [:]

    var queryParameters: [URLQueryItem] = []

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        let configurations = ConfigurationConstants.current

        try container.encode(order.compactOrder, forKey: .order)
        try container.encode(configurations.merchantAccount, forKey: .merchantAccount)
    }

    private enum CodingKeys: String, CodingKey {
        case order
        case merchantAccount
    }
}

struct CancelOrderResponse: Response {

    enum ResultCode: String, Decodable {
        case received = "Received"
    }

    let resultCode: ResultCode

    let pspReference: String
}
