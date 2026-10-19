//
// Copyright (c) 2020 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import AdyenNetworking
import Foundation

/// Represents a payment status request.
package struct PaymentStatusRequest: APIRequest {
    
    package typealias ResponseType = PaymentStatusResponse

    package let path: String = "checkoutshopper/services/PaymentInitiation/v1/status"

    package var counter: UInt = 0

    package var headers: [String: String] = [:]

    package let queryParameters: [URLQueryItem] = []

    package let method: HTTPMethod = .post

    /// The payment context data.
    package let paymentData: String

    package init(paymentData: String) {
        self.paymentData = paymentData
    }
    
    internal enum CodingKeys: String, CodingKey {
        case paymentData
    }
}
