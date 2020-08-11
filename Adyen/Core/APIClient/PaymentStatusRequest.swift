//
// Copyright (c) 2020 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// :nodoc:
/// Represents a payment status request.
internal struct PaymentStatusRequest: Request {
    
    /// :nodoc:
    internal typealias ResponseType = PaymentStatusResponse
    
    /// :nodoc:
    internal let path: String = "checkoutshopper/services/PaymentInitiation/v1/status"
    
    /// :nodoc:
    internal var counter: UInt = 0
    
    /// :nodoc:
    internal let headers: [String: String] = ["Origin": "https://test.org", "Content-Type": "application/json"]
    
    /// :nodoc:
    internal let queryParameters: [URLQueryItem] = [URLQueryItem(name: "token", value: "test_YP5RJK3TL5EELNPAS7RHIRVRAIMYZXOH")]
    
    /// :nodoc:
    internal let method: HTTPMethod = .post
    
    /// :nodoc:
    /// The payment context data.
    internal let paymentData: String
    
    /// :nodoc:
    internal enum CodingKeys: String, CodingKey {
        case paymentData
    }
}
