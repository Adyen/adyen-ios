//
// Copyright (c) 2025 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) import Adyen
@_spi(AdyenInternal) import AdyenDropIn
@_spi(AdyenInternal) import AdyenActions

public protocol AdyenCheckoutComponent: PresentableComponent {
    
}

internal struct CheckoutComponentBuilder {
    
    static func build(
        for paymentMethod: PaymentMethod,
        configuration: CheckoutConfiguration
    ) -> AdyenCheckoutComponent {
        
    }
    
    static func build(
        for action: Action,
        configuration: CheckoutConfiguration
    ) -> AdyenCheckoutComponent {
        
    }
}

