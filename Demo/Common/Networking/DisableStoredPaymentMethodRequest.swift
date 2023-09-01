//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import AdyenNetworking
import Foundation

struct DisableStoredPaymentMethodRequest: APIRequest {
    
    typealias ResponseType = DisableStoredPaymentMethodResponse
    
    let recurringDetailReference: String
    
    let path = "Recurring/v68/disable"

    var counter: UInt = 0

    var method: HTTPMethod = .post

    var headers: [String: String] = [:]

    var queryParameters: [URLQueryItem] = []

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        let configurations = ConfigurationConstants.current

        try container.encode(recurringDetailReference, forKey: .recurringDetailReference)
        try container.encode(ConfigurationConstants.shopperReference, forKey: .shopperReference)
        try container.encode(configurations.merchantAccount, forKey: .merchantAccount)
    }

    private enum CodingKeys: String, CodingKey {
        case recurringDetailReference
        case shopperReference
        case merchantAccount
    }
}

struct DisableStoredPaymentMethodResponse: Response {

    enum ResultCode: String, Decodable {
        case detailsDisabled = "[detail-successfully-disabled]"
        case allDetailsDisabled = "[all-details-successfully-disabled]"
    }

    let response: ResultCode
}
