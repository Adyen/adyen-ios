//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import AdyenNetworking
import Foundation

package struct AppleWalletPassRequest: APIRequest {

    package typealias ResponseType = AppleWalletPassResponse

    package let path: String = "checkoutshopper/v1/createVoucherPass"

    package var counter: UInt = 0

    package var headers: [String: String] = [:]

    package let queryParameters: [URLQueryItem] = []

    package let method: HTTPMethod = .post

    package let platform: String = "apple"

    package let passToken: String

    package init(passToken: String) {
        self.passToken = passToken
    }

    package enum CodingKeys: CodingKey {
        case platform
        case passToken
    }

}
