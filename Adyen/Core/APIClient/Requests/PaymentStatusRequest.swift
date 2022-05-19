//
// Copyright (c) 2022 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import AdyenNetworking
import Foundation

/// Represents a payment status request.
@_spi(AdyenInternal)
public struct PaymentStatusRequest: APIRequest {
    
    public typealias ResponseType = PaymentStatusResponse
    
    public let path: String = "checkoutshopper/services/PaymentInitiation/v1/status"
    
    public var counter: UInt = 0
    
    public let headers: [String: String] = [:]
    
    public let queryParameters: [URLQueryItem] = []
    
    public let method: HTTPMethod = .post
    
    /// The payment context data.
    public let paymentData: String

    public init(paymentData: String) {
        self.paymentData = paymentData
    }
    
    internal enum CodingKeys: String, CodingKey {
        case paymentData
    }
}
