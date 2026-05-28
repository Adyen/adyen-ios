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
///
/// ## Custom Pay Button
/// If you opted to use your own pay button, call
/// ``submit()`` when the shopper taps your button.
///
/// ```swift
/// component.submit()
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
    
    package init(
        paymentMethod: PaymentMethod,
        configuration: CheckoutConfiguration,
        context: AdyenContext,
        delegate: PaymentComponentDelegate?
    ) throws {
        // TODO: Add new v6 style here
        self.paymentComponent = try CheckoutComponentBuilder.build(
            for: paymentMethod,
            configuration: configuration,
            context: context
        )
        self.paymentComponent.delegate = delegate
    }

    package init(
        storedPaymentMethod: StoredPaymentMethod,
        configuration: CheckoutConfiguration,
        context: AdyenContext,
        delegate: PaymentComponentDelegate?
    ) {
        // TODO: Add new v6 style here
        self.paymentComponent = CheckoutComponentBuilder.build(
            for: storedPaymentMethod,
            configuration: configuration,
            context: context
        )
        self.paymentComponent.delegate = delegate
    }

    // TODO: - Instant Component

    public var requiresUserInteraction: Bool {
        viewController != nil
    }

    public func submit() {
        // TODO: - Build submit logic
        guard paymentComponent.validate() else { return }
        paymentComponent.submit()
    }
}
