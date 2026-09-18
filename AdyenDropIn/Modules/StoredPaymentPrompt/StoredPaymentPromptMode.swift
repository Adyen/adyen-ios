//
// Copyright (c) 2026 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) import Adyen

/// The way the shopper completes a payment with a stored payment method.
internal enum StoredPaymentPromptMode {

    /// The component requires input from the shopper, for example the security code of a stored
    /// card, and therefore provides both its own view controller and its own submit button.
    case input(PaymentComponent)

    /// The component submits directly, so Drop-in asks the shopper to confirm and owns the
    /// confirmation button.
    case confirmation(any StoredPaymentComponent)

    /// The component the prompt was created for.
    internal var component: PaymentComponent {
        switch self {
        case let .input(component):
            component
        case let .confirmation(component):
            component
        }
    }
}
