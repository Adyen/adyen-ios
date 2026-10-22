//
// Copyright (c) 2026 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import Foundation

/// Checkout flow for integrations that only need to handle actions.
@MainActor
public final class ActionOnlyCheckout {

    package let core: CheckoutCoreProtocol

    package init(core: CheckoutCoreProtocol) {
        self.core = core
    }

    /// Handles an action received from a payment or payment details response.
    public func handle(action: Action) {
        core.handle(action: action)
    }
}
