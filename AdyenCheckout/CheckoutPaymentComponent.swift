//
// Copyright (c) Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) import Adyen
import UIKit

package typealias CheckoutComponentDelegate = (PaymentComponentDelegate & ActionComponentDelegate)

// TODO: add description
public final class CheckoutPaymentComponent {
    
    internal let paymentComponent: PaymentComponent?
    
    private var configuration: CheckoutConfiguration
    
    internal weak var delegate: CheckoutComponentDelegate?
    
    public var viewController: UIViewController? {
        guard let presentableComponent = paymentComponent as? PresentableComponent else {
            return nil
        }
        return presentableComponent.viewController
    }
    
    package init(
        paymentMethod: PaymentMethod,
        configuration: CheckoutConfiguration,
        delegate: CheckoutComponentDelegate?
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
        delegate: CheckoutComponentDelegate?
    ) {
        self.configuration = configuration
        self.delegate = delegate
        // TODO: Add new v6 style here
        self.paymentComponent = CheckoutComponentBuilder.build(for: storedPaymentMethod, configuration: configuration)
        self.paymentComponent?.delegate = delegate
    }
}
