//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import AdyenNetworking
import Foundation

internal struct DisableStoredPaymentMethodRequest: APIRequest {
    
    internal typealias ResponseType = DisableStoredPaymentMethodResponse
    
    internal let recurringDetailReference: String
    
    internal let path = "Recurring/v68/disable"

    internal var counter: UInt = 0

    internal var method: HTTPMethod = .post

    internal var headers: [String: String] = [:]

    internal var queryParameters: [URLQueryItem] = []

    internal func encode(to encoder: Encoder) throws {
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

internal struct DisableStoredPaymentMethodResponse: Response {

    internal enum ResultCode: String, Decodable {
        case detailsDisabled = "[detail-successfully-disabled]"
        case allDetailsDisabled = "[all-details-successfully-disabled]"
    }

    internal let response: ResultCode
}
