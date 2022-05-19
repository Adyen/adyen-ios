//
// Copyright (c) 2022 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import AdyenNetworking
import Foundation

@_spi(AdyenInternal)
public struct AppleWalletPassRequest: APIRequest {

    public typealias ResponseType = AppleWalletPassResponse

    public let path: String = "checkoutshopper/v1/createVoucherPass"

    public var counter: UInt = 0

    public let headers: [String: String] = [:]

    public let queryParameters: [URLQueryItem] = []

    public let method: HTTPMethod = .post

    public let platform: String = "apple"

    public let passToken: String

    public init(passToken: String) {
        self.passToken = passToken
    }

    public enum CodingKeys: CodingKey {
        case platform
        case passToken
    }

}
