//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import AdyenNetworking
import Foundation

internal struct CancelOrderRequest: APIRequest {

    internal typealias ResponseType = CancelOrderResponse

    internal let order: PartialPaymentOrder

    internal let path = "orders/cancel"

    internal var counter: UInt = 0

    internal var method: HTTPMethod = .post

    internal var headers: [String: String] = [:]

    internal var queryParameters: [URLQueryItem] = []

    internal func encode(to encoder: Encoder) throws {
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

internal struct CancelOrderResponse: Response {

    internal enum ResultCode: String, Decodable {
        case received = "Received"
    }

    internal let resultCode: ResultCode

    internal let pspReference: String
}
