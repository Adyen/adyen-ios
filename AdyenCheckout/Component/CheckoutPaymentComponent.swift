//
// Copyright (c) 2025 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import UIKit

/// A component that handles payment method UI and data collection.
///
/// Create instances using `Checkout.createPaymentComponent(for:)`.
///
/// ```swift
/// let component = try checkout.createPaymentComponent(for: .scheme)
/// ```
@MainActor
public final class CheckoutPaymentComponent {
    
    internal let paymentComponent: PaymentComponent
    
    /// The view controller of the component.
    public var viewController: UIViewController {
        paymentComponent.viewController
    }
    
    package init(paymentComponent: PaymentComponent) {
        self.paymentComponent = paymentComponent
    }

    /// Indicates whether the payment method requires user interaction before submitting.
    ///
    /// When this returns `false`, `submit()` can be called directly to skip a user action (e.g. a button click).
    /// Rendering the component's `viewController` is optional in this case.
    ///
    /// When this returns `true`, the component's `viewController` should be displayed so the shopper can provide
    /// the required input before calling `submit()`.
    ///
    /// ```swift
    /// if component.requiresUserInteraction {
    ///     present(component.viewController, animated: true)
    /// } else {
    ///     component.submit()
    /// }
    /// ```
    public var requiresUserInteraction: Bool {
        paymentComponent.requiresUserInteraction
    }

    /// Submits the payment request to initiate the payment process.
    ///
    /// Call this method to programmatically trigger the payment submission. For components with UI (`requiresUserInteraction == true`),
    /// this validates the form and submits if valid. For direct payment methods (`requiresUserInteraction == false`),
    /// this immediately initiates the payment.
    ///
    /// ```swift
    /// // For direct payment methods (no UI)
    /// if !component.requiresUserInteraction {
    ///     component.submit()
    /// }
    ///
    /// // For custom pay button integration
    /// func payButtonTapped() {
    ///     component.submit()
    /// }
    /// ```
    ///
    public func submit() {
        paymentComponent.performSubmit()
    }
}
