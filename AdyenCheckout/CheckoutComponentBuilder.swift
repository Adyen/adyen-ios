//
// Copyright (c) 2025 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) import Adyen
#if canImport(AdyenDropIn)
    @_spi(AdyenInternal) import AdyenDropIn
#endif
#if canImport(AdyenComponents)
    @_spi(AdyenInternal) import AdyenComponents
#endif
#if canImport(AdyenActions)
    @_spi(AdyenInternal) import AdyenActions
#endif

public protocol AdyenCheckoutComponent: PresentableComponent {}

internal enum CheckoutComponentBuilder {
    
    internal static func build(
        for paymentMethod: PaymentMethod,
        configuration: CheckoutConfiguration
    ) throws -> AdyenCheckoutComponent {
        if let blikPaymentMethod = paymentMethod as? BLIKPaymentMethod {
            return blikPaymentMethod.buildComponent(with: configuration)
        } else if let atomePaymentMethod = paymentMethod as? AtomePaymentMethod {}
        
        // TODO: create real checkout errors
        fatalError()
    }
    
    internal static func build(
        for action: Action,
        configuration: CheckoutConfiguration
    ) -> AdyenCheckoutComponent {
        fatalError()
    }
}

extension CheckoutConfiguration {
    func configuration(for paymentMethod: PaymentMethod) -> CheckoutComponentConfiguration? {
        configurations[.payment(paymentMethod.type)]
    }
}

extension BLIKComponent: AdyenCheckoutComponent {}

// testing different ways of creating the component
extension BLIKPaymentMethod {
    
    func buildComponent(with configuration: CheckoutConfiguration) -> BLIKComponent {
        var blikConfiguration: BLIKComponentConfiguration
        if let configuration = configuration.configuration(for: self) as? BLIKComponentConfiguration {
            blikConfiguration = configuration
        } else {
            blikConfiguration = .init()
        }
        
        let context = AdyenContext(
            apiContext: configuration.apiContext,
            payment: nil,
            amount: configuration.amount,
            analyticsConfiguration: configuration.analyticsConfiguration
        )
        var component = BLIKComponent(
            paymentMethod: self,
            context: context,
            configuration: blikConfiguration
        )
        component.setBaseCallbacks(from: configuration)
        return component
    }
}
