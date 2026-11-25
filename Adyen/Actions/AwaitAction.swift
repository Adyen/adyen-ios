//
// Copyright (c) 2020 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// Describes an action in which the SDK is waiting for user action.
package struct AwaitAction: PaymentDataAware, Decodable {
    
    /// The `paymentMethodType` for which the await action is used.
    package let paymentMethodType: PaymentMethodType
    
    /// The server-generated payment data that should be submitted to the `/payments/details` endpoint.
    package let paymentData: String

    /// Initializes a await action.
    ///
    /// - Parameters:
    ///   - paymentData: The server-generated payment data that should be submitted to the `/payments/details` endpoint.
    ///   - paymentMethodType: The `paymentMethodType` for which the await action is used.
    ///   - redirectUrl: The URL to which to redirect the user.
    package init(
        paymentData: String,
        paymentMethodType: PaymentMethodType
    ) {
        self.paymentData = paymentData
        self.paymentMethodType = paymentMethodType
    }
    
}
