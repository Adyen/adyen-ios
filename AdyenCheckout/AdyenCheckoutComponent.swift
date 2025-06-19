//
// Copyright (c) 2025 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) import Adyen
@_spi(AdyenInternal) import AdyenSession
@_spi(AdyenInternal) import AdyenDropIn
@_spi(AdyenInternal) import AdyenComponents
@_spi(AdyenInternal) import AdyenActions

package typealias CheckoutComponentDelegate = (PaymentComponentDelegate & ActionComponentDelegate)

// TODO: add description
public final class AdyenCheckoutComponent {
    
    private var paymentComponent: PaymentComponent?
    
    private var actionComponent: ActionComponent?
    
    private var configuration: CheckoutConfiguration
    
    internal weak var delegate: CheckoutComponentDelegate?
    
    package init(
        paymentMethod: PaymentMethod,
        configuration: CheckoutConfiguration,
        delegate: CheckoutComponentDelegate?
    ) {
        self.configuration = configuration
        self.delegate = delegate
        self.paymentComponent = CheckoutComponentBuilder.build(for: paymentMethod, configuration: configuration)
        self.paymentComponent?.delegate = delegate
    }
    
    package init(
        action: Action,
        configuration: CheckoutConfiguration,
        delegate: CheckoutComponentDelegate?
    ) {
        self.configuration = configuration
        self.delegate = delegate
        self.actionComponent = CheckoutComponentBuilder.build(for: action, configuration: configuration)
        self.actionComponent?.delegate = delegate
    }
}
