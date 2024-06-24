//
// Copyright (c) 2024 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// Describes an action in which the SDK is waiting for user action.
public struct RedirectableAwaitAction: PaymentDataAware, Decodable {

    /// The `paymentMethodType` for which the await action is used.
    public let paymentMethodType: AwaitPaymentMethod

    /// The server-generated payment data that should be submitted to the `/payments/details` endpoint.
    public let paymentData: String

    /// The URL to which to redirect the user.
    public let url: URL

    /// Initializes a await action.
    ///
    /// - Parameters:
    ///   - paymentData: The server-generated payment data that should be submitted to the `/payments/details` endpoint.
    ///   - paymentMethodType: The `paymentMethodType` for which the await action is used.
    ///   - url: The URL to which to redirect the user.
    public init(paymentData: String,
                paymentMethodType: AwaitPaymentMethod,
                url: URL) {
        self.paymentData = paymentData
        self.paymentMethodType = paymentMethodType
        self.url = url
    }
}
