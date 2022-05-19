//
// Copyright (c) 2022 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import AdyenNetworking
import Foundation

@_spi(AdyenInternal)
public struct OrderStatusRequest: APIRequest {

    public typealias ResponseType = OrderStatusResponse

    public var path: String { "checkoutshopper/v1/order/status" }

    public var counter: UInt = 0
    
    public let headers: [String: String] = [:]

    public let queryParameters: [URLQueryItem] = []

    public let method: HTTPMethod = .post

    public let orderData: String

    public init(orderData: String) {
        self.orderData = orderData
    }

    private enum CodingKeys: CodingKey {
        case orderData
    }

}
