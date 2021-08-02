//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import AdyenNetworking
import Foundation

/// :nodoc:
public struct OrderStatusRequest: APIRequest {

    /// :nodoc:
    public typealias ResponseType = OrderStatusResponse

    /// :nodoc:
    public var path: String { "checkoutshopper/v1/order/status" }

    /// :nodoc:
    public var counter: UInt = 0

    /// :nodoc:
    public let headers: [String: String] = [:]

    /// :nodoc:
    public let queryParameters: [URLQueryItem] = []

    /// :nodoc:
    public let method: HTTPMethod = .post

    /// :nodoc:
    public let orderData: String

    /// :nodoc:
    public init(orderData: String) {
        self.orderData = orderData
    }

    private enum CodingKeys: CodingKey {
        case orderData
    }

}
