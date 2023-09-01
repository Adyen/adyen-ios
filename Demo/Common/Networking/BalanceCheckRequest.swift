//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import AdyenNetworking
import Foundation

struct BalanceCheckRequest: APIRequest {

    typealias ResponseType = BalanceCheckResponse

    let data: PaymentComponentData

    let path = "paymentMethods/balance"

    var counter: UInt = 0

    var method: HTTPMethod = .post

    var headers: [String: String] = [:]

    var queryParameters: [URLQueryItem] = []
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        let configurations = ConfigurationConstants.current

        try container.encode(data.paymentMethod.encodable, forKey: .details)
        try container.encode(data.amount, forKey: .amount)
        try container.encode(configurations.merchantAccount, forKey: .merchantAccount)
    }

    private enum CodingKeys: String, CodingKey {
        case details = "paymentMethod"
        case merchantAccount
        case amount
    }
}

struct BalanceCheckResponse: Response {

    enum ResultCode: String, Decodable {
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

    let resultCode: ResultCode

    let pspReference: String

    let balance: Amount?

    let transactionLimit: Amount?
}
