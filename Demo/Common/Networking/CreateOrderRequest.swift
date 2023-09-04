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

struct CreateOrderRequest: APIRequest {

    typealias ResponseType = CreateOrderResponse

    let amount: Amount

    let reference: String

    let path = "orders"

    var counter: UInt = 0

    var method: HTTPMethod = .post

    var headers: [String: String] = [:]

    var queryParameters: [URLQueryItem] = []

    func encode(to encoder: Encoder) throws {
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

struct CreateOrderResponse: Response {

    enum ResultCode: String, Decodable {
        case failed = "Failed"
        case success = "Success"
    }

    let resultCode: ResultCode

    let pspReference: String

    let reference: String

    let remainingAmount: Amount

    let expiresAt: String

    let orderData: String

    var order: PartialPaymentOrder {
        PartialPaymentOrder(pspReference: pspReference, orderData: orderData)
    }
}
