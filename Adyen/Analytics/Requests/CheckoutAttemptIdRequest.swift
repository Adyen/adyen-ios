//
// Copyright (c) 2022 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import AdyenNetworking
import Foundation

struct CheckoutAttemptIdResponse: Response {

    // MARK: - Properties

    let identifier: String

    enum CodingKeys: String, CodingKey {
        case identifier = "id"
    }
}

struct CheckoutAttemptIdRequest: APIRequest {

    typealias ResponseType = CheckoutAttemptIdResponse

    let path: String = "checkoutshopper/v2/analytics/id"

    var counter: UInt = 0

    let headers: [String: String] = [:]

    let queryParameters: [URLQueryItem] = []

    let method: HTTPMethod = .post

    let experiments: [String] = []

    enum CodingKeys: CodingKey {
        case experiments
    }
}
