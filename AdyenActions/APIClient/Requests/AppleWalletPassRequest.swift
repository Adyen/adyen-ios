//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import Foundation

public struct AppleWalletPassRequest: Request {

    /// :nodoc:
    public typealias ResponseType = AppleWalletPassResponse

    /// :nodoc:
    public let path: String = "checkoutshopper/v1/createAppleWalletPass"

    /// :nodoc:
    public var counter: UInt = 0

    /// :nodoc:
    public let headers: [String: String] = [:]

    /// :nodoc:
    public let queryParameters: [URLQueryItem] = []

    /// :nodoc:
    public let method: HTTPMethod = .post

    /// :nodoc:
    public let action: GenericVoucherAction

    /// :nodoc:
    internal enum CodingKeys: String, CodingKey {
        case action
    }
}
