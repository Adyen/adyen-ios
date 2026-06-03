//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import AdyenNetworking
import Foundation

package struct OrderStatusRequest: APIRequest {

    package typealias ResponseType = OrderStatusResponse

    package var path: String {
        "checkoutshopper/v1/order/status"
    }

    package var counter: UInt = 0

    package var headers: [String: String] = [:]

    package let queryParameters: [URLQueryItem] = []

    package let method: HTTPMethod = .post

    package let orderData: String

    package init(orderData: String) {
        self.orderData = orderData
    }

    private enum CodingKeys: CodingKey {
        case orderData
    }

}
