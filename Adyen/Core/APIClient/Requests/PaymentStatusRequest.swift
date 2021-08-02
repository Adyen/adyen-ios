//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import AdyenNetworking
import Foundation

/// :nodoc:
/// Represents a payment status request.
public struct PaymentStatusRequest: APIRequest {
    
    /// :nodoc:
    public typealias ResponseType = PaymentStatusResponse
    
    /// :nodoc:
    public let path: String = "checkoutshopper/services/PaymentInitiation/v1/status"
    
    /// :nodoc:
    public var counter: UInt = 0
    
    /// :nodoc:
    public let headers: [String: String] = [:]
    
    /// :nodoc:
    public let queryParameters: [URLQueryItem] = []
    
    /// :nodoc:
    public let method: HTTPMethod = .post
    
    /// :nodoc:
    /// The payment context data.
    public let paymentData: String

    /// :nodoc:
    public init(paymentData: String) {
        self.paymentData = paymentData
    }
    
    /// :nodoc:
    internal enum CodingKeys: String, CodingKey {
        case paymentData
    }
}
