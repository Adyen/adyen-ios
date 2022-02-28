//
// Copyright (c) 2022 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import AdyenNetworking
import Foundation

// TODO: - Document
internal struct CheckoutAttemptIdResponse: Response {

    // MARK: - Properties

    internal let identifier: String

    internal enum CodingKeys: String, CodingKey {
        case identifier = "id"
    }
}

internal struct CheckoutAttemptIdRequest: APIRequest {

    /// :nodoc:
    internal typealias ResponseType = CheckoutAttemptIdResponse

    /// :nodoc:
    internal let path: String = "v2/analytics/id"

    /// :nodoc:
    internal var counter: UInt = 0

    /// :nodoc:
    internal let headers: [String: String] = [:]

    /// :nodoc:
    internal let queryParameters: [URLQueryItem] = []

    /// :nodoc:
    internal let method: HTTPMethod = .post

    /// :nodoc:
    internal let experiments: [String] = []

    internal enum CodingKeys: CodingKey {
        case experiments
    }
}
