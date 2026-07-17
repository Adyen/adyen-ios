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
    public var viewController: UIViewController? {
        guard let presentableComponent = paymentComponent as? PresentableComponent else {
            return nil
        }
        return presentableComponent.viewController
    }
    
    package init(paymentComponent: PaymentComponent) {
        self.paymentComponent = paymentComponent
    }

    /// Indicates whether the payment component requires user interaction before submitting.
    ///
    /// When `true`, the component has a UI that the shopper must interact with (e.g., filling in card details).
    /// When `false`, the component can submit immediately without presenting any UI (e.g., direct payment methods).
    ///
    /// Use this property to determine whether to present the component's `viewController` or call `submit()` directly.
    ///
    /// ```swift
    /// if component.requiresUserInteraction, let componentViewController = component.viewController {
    ///     present(componentViewController, animated: true)
    /// } else {
    ///     component.submit()
    /// }
    /// ```
    public var requiresUserInteraction: Bool {
        viewController != nil
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
