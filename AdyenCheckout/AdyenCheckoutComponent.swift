//
// Copyright (c) 2025 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) import Adyen
#if canImport(AdyenSession)
    @_spi(AdyenInternal) import AdyenSession
#endif
#if canImport(AdyenDropIn)
    @_spi(AdyenInternal) import AdyenDropIn
#endif
#if canImport(AdyenComponents)
    @_spi(AdyenInternal) import AdyenComponents
#endif
#if canImport(AdyenActions)
    @_spi(AdyenInternal) import AdyenActions
#endif

// TODO: add description
public final class AdyenCheckoutComponent {
    
    private var paymentComponent: PaymentComponent?
    
    private var actionComponent: ActionComponent?
    
    private var actionHandlingComponent: ActionHandlingComponent?
    
    private var configuration: CheckoutConfiguration
    
    package init(
        paymentMethod: PaymentMethod,
        configuration: CheckoutConfiguration,
        session: AdyenSession? = nil
    ) {
        self.configuration = configuration
        self.paymentComponent = CheckoutComponentBuilder.build(for: paymentMethod, configuration: configuration)
        
    }
    
    package init(
        action: Action,
        configuration: CheckoutConfiguration,
        session: AdyenSession? = nil
    ) {
        self.configuration = configuration
        self.actionComponent = CheckoutComponentBuilder.build(for: action, configuration: configuration)
    }
}
