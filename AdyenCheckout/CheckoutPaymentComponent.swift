//
// Copyright (c) Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) import Adyen
import UIKit

/// A component that handles payment method UI and data collection.
///
/// Create instances using `AdyenCheckout.createPaymentComponent(for:)`.
///
/// ```swift
/// let component = checkout.createPaymentComponent(for: .scheme)
/// ```
///
/// ## Custom Pay Button
/// If you opted to use your own pay button, call
/// ``submit()`` when the shopper taps your button.
///
/// ```swift
/// component.submit()
/// ```
public final class CheckoutPaymentComponent {
    
    internal let paymentComponent: PaymentComponent?
    
    private var configuration: CheckoutConfiguration
    
    internal weak var delegate: PaymentComponentDelegate?
    
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
        delegate: PaymentComponentDelegate?
    ) {
        self.configuration = configuration
        self.delegate = delegate
        // TODO: Add new v6 style here
        self.paymentComponent = CheckoutComponentBuilder.build(for: paymentMethod, configuration: configuration)
        self.paymentComponent?.delegate = delegate
    }
    
    package init(
        storedPaymentMethod: StoredPaymentMethod,
        configuration: CheckoutConfiguration,
        delegate: PaymentComponentDelegate?
    ) {
        self.configuration = configuration
        self.delegate = delegate
        // TODO: Add new v6 style here
        self.paymentComponent = CheckoutComponentBuilder.build(for: storedPaymentMethod, configuration: configuration)
        self.paymentComponent?.delegate = delegate
    }
}
