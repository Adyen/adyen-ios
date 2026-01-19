//
// Copyright (c) Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

#if canImport(AdyenUI)
    import AdyenUI
#endif
import Foundation

@resultBuilder
public struct CheckoutConfigurationBuilder {
    public static func buildBlock(_ components: CheckoutConfigurable...) -> [CheckoutConfigurable] {
        components
    }
    
    public static func buildOptional(_ component: CheckoutConfigurable?) -> CheckoutConfigurable? {
        component
    }
    
    public static func buildEither(first component: CheckoutConfigurable) -> CheckoutConfigurable {
        component
    }
    
    public static func buildEither(second component: CheckoutConfigurable) -> CheckoutConfigurable {
        component
    }
    
    public static func buildFinalResult(_ components: [CheckoutConfigurable]) -> CheckoutConfigurable {
        CompositeCheckoutConfiguration(configurations: components)
    }
}
