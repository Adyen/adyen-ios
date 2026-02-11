//
// Copyright (c) 2019 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import AdyenNetworking
import Foundation

internal struct DisableStoredPaymentMethodRequest: APIRequest {
    
    internal typealias ResponseType = EmptyResponse
    
    internal let storedPaymentId: String
    internal let merchantAccount: String
    internal let shopperReference: String

    internal var path: String {
        "storedPaymentMethods/\(storedPaymentId)"
    }

    internal var counter: UInt = 0

    internal var method: HTTPMethod = .delete

    internal var headers: [String: String] = [:]

    internal var queryParameters: [URLQueryItem] {
        [
            .init(name: "merchantAccount", value: merchantAccount),
            .init(name: "shopperReference", value: shopperReference)
        ]
    }

    internal func encode(to encoder: Encoder) throws {}

}
