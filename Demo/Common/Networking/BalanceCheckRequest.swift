//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import AdyenNetworking
import Foundation

internal struct BalanceCheckRequest: APIRequest {

    internal typealias ResponseType = BalanceCheckResponse

    internal let data: PaymentComponentData

    internal let path = "paymentMethods/balance"

    internal var counter: UInt = 0

    internal var method: HTTPMethod = .post

    internal var headers: [String: String] = [:]

    internal var queryParameters: [URLQueryItem] = []
    
    internal func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        let configurations = ConfigurationConstants.current

        try container.encode(data.paymentMethod.encodable, forKey: .details)
        try container.encode(configurations.merchantAccount, forKey: .merchantAccount)
    }

    private enum CodingKeys: String, CodingKey {
        case details = "paymentMethod"
        case merchantAccount
    }
}

internal struct BalanceCheckResponse: Response {

    internal enum ResultCode: String, Decodable {
        case failed = "Failed"
        case notEnoughBalance = "NotEnoughBalance"
        case cancelled = "Cancelled"
        case acquirerFraud = "AcquirerFraud"
        case declined = "Declined"
        case blockCard = "BlockCard"
        case cardExpired = "CardExpired"
        case invalidAmount = "InvalidAmount"
        case invalidCard = "InvalidCard"
        case notSupported = "NotSupported"
        case error = "Error"
        case invalidPin = "InvalidPin"
        case pinTriesExceeded = "PinTriesExceeded"
        case issuerUnavailable = "IssuerUnavailable"
        case withdrawalAmountExceeded = "WithdrawalAmountExceeded"
        case withdrawalCountExceeded = "WithdrawalCountExceeded"
        case allowPartialAuth = "AllowPartialAuth"
        case success = "Success"
    }

    internal let resultCode: ResultCode

    internal let pspReference: String

    internal let balance: Amount?

    internal let transactionLimit: Amount?
}
