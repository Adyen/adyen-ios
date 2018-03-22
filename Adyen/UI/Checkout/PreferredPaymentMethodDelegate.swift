//
// Copyright (c) 2018 Oktawian Chojnacki
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

/// The `PreferredPaymentMethodDelegate` protocol defines the methods that a paymentMethodDelegate of `CheckoutViewController` should implement to provide preffered payment method.

public protocol PreferredPaymentMethodDelegate: class {
    /// Invoked when the payment methods are available and client can select the preffered one to continue with.
    ///
    /// - Parameters:
    ///   - controller: The checkout view controller that finished the payment flow.
    ///   - available: Available payment methods.
    /// - Returns: Preferred payment method or nil then selection will be presented.
    func preferredMethod(_ controller: CheckoutViewController, available availableMethods: [PaymentMethod]) -> PaymentMethod?
}
