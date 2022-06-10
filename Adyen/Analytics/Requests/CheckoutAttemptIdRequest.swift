//
// Copyright (c) 2022 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import AdyenNetworking
import Foundation

internal struct CheckoutAttemptIdResponse: Response {

    // MARK: - Properties

    internal let identifier: String

    internal enum CodingKeys: String, CodingKey {
        case identifier = "id"
    }
}

internal struct CheckoutAttemptIdRequest: APIRequest {

    internal typealias ResponseType = CheckoutAttemptIdResponse

    internal let path: String = "checkoutshopper/v2/analytics/id"

    internal var counter: UInt = 0

    internal let headers: [String: String] = [:]

    internal let queryParameters: [URLQueryItem] = []

    internal let method: HTTPMethod = .post

    internal let experiments: [String] = []

    internal enum CodingKeys: CodingKey {
        case experiments
    }
}
