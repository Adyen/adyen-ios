//
// Copyright (c) 2025 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) import Adyen
import AdyenUI
#if canImport(AdyenComponents)
    @_spi(AdyenInternal) import AdyenComponents
#endif

internal enum CheckoutComponentBuilder {
    
    internal static func build(
        for paymentMethod: PaymentMethod,
        configuration: CheckoutConfiguration
    ) -> PaymentComponent {
        if let blikPaymentMethod = paymentMethod as? BLIKPaymentMethod {
            return blikPaymentMethod.buildComponent(with: configuration)
        } else if let atomePaymentMethod = paymentMethod as? AtomePaymentMethod {}
        
        // TODO: create real checkout errors
        fatalError()
    }
    
    internal static func build(
        for action: Action,
        configuration: CheckoutConfiguration
    ) -> ActionComponent {
        fatalError()
    }
}

extension CheckoutConfiguration {
    func componentConfiguration(for paymentMethod: PaymentMethod) -> CheckoutComponentConfiguration? {
        configurations[.payment(paymentMethod.type)]
    }
    
//    func componentConfiguration(for action: Action) -> CheckoutComponentConfiguration? {
//        configurations[.action(...)]
//    }
}

// TODO: testing different ways of creating the component
// we can go back to payment component builder or choose another way as well
extension BLIKPaymentMethod {
    
    func buildComponent(with configuration: CheckoutConfiguration) -> BLIKComponent {
        var blikConfiguration: BLIKComponentConfiguration
        if let configuration = configuration.componentConfiguration(for: self) as? BLIKComponentConfiguration {
            blikConfiguration = configuration
        } else {
            blikConfiguration = .init()
        }
        // TODO: find a better place to carry over global settings to individual configs
        blikConfiguration.showsSubmitButton = configuration.showsSubmitButton
        blikConfiguration.theme = configuration.theme
        let component = BLIKComponent(
            paymentMethod: self,
            context: configuration.context,
            configuration: blikConfiguration
        )
        return component
    }
}
