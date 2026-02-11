//
// Copyright (c) 2026 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import AdyenNetworking
import Foundation

package struct CheckoutAttemptIdResponse: Response {

    // MARK: - Properties

    package let checkoutAttemptId: String

    package enum CodingKeys: String, CodingKey {
        case checkoutAttemptId
    }
}

package struct CheckoutAttemptIdRequest: APIRequest {

    package typealias ResponseType = CheckoutAttemptIdResponse

    package let path: String = AnalyticsConstants.analyticsRequestPath

    package var counter: UInt = 0

    package var headers: [String: String] = [:]

    package let queryParameters: [URLQueryItem] = []

    package let method: HTTPMethod = .post

    package init() {}

    // MARK: - Initializers

    internal enum CodingKeys: CodingKey {}

}
