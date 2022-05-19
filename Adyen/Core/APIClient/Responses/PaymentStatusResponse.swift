//
// Copyright (c) 2022 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import AdyenNetworking
import Foundation

/// Represents the payment status code.
@_spi(AdyenInternal)
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
@_spi(AdyenInternal)
public struct PaymentStatusResponse: Response {
    
    /// The payload.
    public let payload: String
    
    /// The payment status.
    public let resultCode: PaymentResultCode
    
}
