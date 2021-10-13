//
// Copyright (c) 2020 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// :nodoc:
/// Represents the payment status code.
internal enum PaymentResultCode: String, Decodable {
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
internal struct PaymentStatusResponse: Response {
    /// :nodoc:
    /// The payload.
    internal let payload: String

    /// :nodoc:
    /// The payment status.
    internal let resultCode: PaymentResultCode
}
