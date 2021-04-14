//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import Foundation

internal struct BalanceCheckRequest: Request {

    internal typealias ResponseType = BalanceCheckResponse

    internal let data: PaymentComponentData

    internal let path = "paymentMethods/balance"

    internal var counter: UInt = 0

    internal var method: HTTPMethod = .post

    internal var headers: [String: String] = [:]

    internal var queryParameters: [URLQueryItem] = []
    
    internal func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(data.paymentMethod.encodable, forKey: .details)
        try container.encode(Configuration.merchantAccount, forKey: .merchantAccount)
    }

    private enum CodingKeys: String, CodingKey {
        case details = "paymentMethod"
        case merchantAccount
    }
}

internal struct BalanceCheckResponse: Response {

    internal enum ResultCode: String, Decodable {
        case failed = "Failed"
    }

    internal let resultCode: ResultCode

    internal let pspReference: String

    internal let balance: Payment.Amount?

    internal let transactionLimit: Payment.Amount?
}
