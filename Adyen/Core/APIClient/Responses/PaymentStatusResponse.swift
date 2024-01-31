//
// Copyright (c) 2024 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import AdyenNetworking
import Foundation

/// Represents the payment status code.
@_documentation(visibility: internal)
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

/// Represents a payment status response.
@_documentation(visibility: internal)
public struct PaymentStatusResponse: Response {
    
    /// The payload.
    public let payload: String
    
    /// The payment status.
    public let resultCode: PaymentResultCode
    
}
