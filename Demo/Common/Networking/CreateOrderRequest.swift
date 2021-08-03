//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import AdyenNetworking
#if canImport(AdyenCard)
    import AdyenCard
#endif
import Foundation

internal struct CreateOrderRequest: APIRequest {

    internal typealias ResponseType = CreateOrderResponse

    internal let amount: Amount

    internal let reference: String

    internal let path = "orders"

    internal var counter: UInt = 0

    internal var method: HTTPMethod = .post

    internal var headers: [String: String] = [:]

    internal var queryParameters: [URLQueryItem] = []

    internal func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        let configurations = ConfigurationConstants.current

        try container.encode(amount, forKey: .amount)
        try container.encode(reference, forKey: .reference)
        try container.encode(configurations.merchantAccount, forKey: .merchantAccount)
    }

    private enum CodingKeys: String, CodingKey {
        case amount
        case reference
        case merchantAccount
    }
}

internal struct CreateOrderResponse: Response {

    internal enum ResultCode: String, Decodable {
        case failed = "Failed"
        case success = "Success"
    }

    internal let resultCode: ResultCode

    internal let pspReference: String

    internal let reference: String

    internal let remainingAmount: Amount

    internal let expiresAt: String

    internal let orderData: String

    internal var order: PartialPaymentOrder {
        PartialPaymentOrder(pspReference: pspReference, orderData: orderData)
    }
}
