//
// Copyright (c) 2022 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import AdyenNetworking
import Foundation

// TODO: - Document
public struct CheckoutAttemptIdResponse: Response {
    public let identifier: String

    internal enum CodingKeys: String, CodingKey {
        case identifier = "id"
    }
}

public struct CheckoutAttemptIdRequest: APIRequest {

    /// :nodoc:
    public typealias ResponseType = CheckoutAttemptIdResponse

    /// :nodoc:
    public let path: String = "v2/analytics/id"

    /// :nodoc:
    public var counter: UInt = 0

    /// :nodoc:
    public let headers: [String: String] = [:]

    /// :nodoc:
    public var queryParameters: [URLQueryItem] = []

    /// :nodoc:
    public let method: HTTPMethod = .post

    public let experiments: [String]

    internal enum CodingKeys: CodingKey {
        case experiments
    }
}
