//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// :nodoc:
public struct AppleWalletPassRequest: Request {

    /// :nodoc:
    public typealias ResponseType = AppleWalletPassResponse

    /// :nodoc:
    public var path: String { "checkoutshopper/v1/createVoucherPass" }

    /// :nodoc:
    public var counter: UInt = 0

    /// :nodoc:
    public let headers: [String: String] = [:]

    /// :nodoc:
    public let queryParameters: [URLQueryItem] = []

    /// :nodoc:
    public let method: HTTPMethod = .post

    /// :nodoc:
    public let platform: String = "apple"

    /// :nodoc:
    public let passToken: String

    /// :nodoc:
    public init(passToken: String) {
        self.passToken = passToken
    }

    /// :nodoc:
    public enum CodingKeys: CodingKey {
        case platform
        case passToken
    }

}
