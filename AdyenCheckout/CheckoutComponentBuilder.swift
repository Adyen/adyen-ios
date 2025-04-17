//
// Copyright (c) 2025 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) import Adyen
@_spi(AdyenInternal) import AdyenDropIn
@_spi(AdyenInternal) import AdyenActions
@_spi(AdyenInternal) import AdyenComponents

public protocol AdyenCheckoutComponent: PresentableComponent {
    
}

internal struct CheckoutComponentBuilder {
    
    static func build(
        for paymentMethod: PaymentMethod,
        configuration: CheckoutConfiguration
    ) throws -> AdyenCheckoutComponent {
        if let blikPaymentMethod = paymentMethod as? BLIKPaymentMethod {
            return blikPaymentMethod.buildComponent(with: configuration)
        } else if let atomePaymentMethod = paymentMethod as? AtomePaymentMethod {
            
        }
        
        
        
        
        // TODO: create real checkout errors
        throw fatalError()
    }
    
    static func build(
        for action: Action,
        configuration: CheckoutConfiguration
    ) -> AdyenCheckoutComponent {
        fatalError()
    }
}

extension CheckoutConfiguration {
    func configuration(for paymentMethod: PaymentMethod) -> CheckoutComponentConfiguration? {
        configurations[.payment(paymentMethod.type)]?.configuration
    }
}

extension BLIKComponent: AdyenCheckoutComponent {}


// testing different ways of creating the component
extension BLIKPaymentMethod {
    
    func buildComponent(with configuration: CheckoutConfiguration) -> BLIKComponent {
        var blikConfiguration: BLIKComponent.Configuration
        if let configuration = configuration.configuration(for: self) as? BLIKComponent.Configuration {
            blikConfiguration = configuration
        } else {
            blikConfiguration = .init()
        }
        return BLIKComponent(paymentMethod: self, context: AdyenContext.defaultValue(), configuration: blikConfiguration)
    }
}

