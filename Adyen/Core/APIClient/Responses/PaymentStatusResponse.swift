//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import AdyenNetworking
import Foundation

/// :nodoc:
/// Represents the payment status code.
public enum PaymentResultCode: String, Decodable {
    case authorised
    case refused
    case pending
    case cancelled
    case error
    case received
    case redirectShopper
    case identifyShopper
    case challengeShopper
}

/// :nodoc:
/// Represents a payment status response.
public struct PaymentStatusResponse: Response {
    
    /// :nodoc:
    /// The payload.
    public let payload: String
    
    /// :nodoc:
    /// The payment status.
    public let resultCode: PaymentResultCode
    
}
