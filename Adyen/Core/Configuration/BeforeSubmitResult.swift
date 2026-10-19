//
// Copyright (c) 2026 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// Result returned by `onBeforeSubmit` callback in the session flow.
public enum BeforeSubmitResult: Sendable {

    /// Continue the submission flow with the provided data.
    /// - Parameters:
    ///   - data: The submit data (pass back unchanged if unmodified).
    ///   - sessionData: Optional. Pass the sessionData you received from your server's `PATCH` request
    ///     so the SDK can update the current session state data before continuing.
    case proceed(data: BeforeSubmitData, sessionData: String?)

    /// Stop the submission and reset the state.
    case abort
}

public struct BeforeSubmitData: Sendable {

    /// Billing address of the shopper.
    public var billingAddress: PostalAddress?

    /// Delivery address of the shopper.
    public var deliveryAddress: PostalAddress?

    /// Name of the shopper.
    public var shopperName: ShopperName?

    /// Email address of the shopper.
    public var shopperEmail: String?

    package init(
        billingAddress: PostalAddress? = nil,
        deliveryAddress: PostalAddress? = nil,
        shopperName: ShopperName? = nil,
        shopperEmail: String? = nil
    ) {
        self.billingAddress = billingAddress
        self.deliveryAddress = deliveryAddress
        self.shopperName = shopperName
        self.shopperEmail = shopperEmail
    }
}
