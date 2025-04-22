//
// Copyright (c) 2025 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

@resultBuilder
public struct CheckoutConfigurationBuilder {
    public static func buildBlock(_ components: CheckoutComponentConfiguration...) -> CheckoutConfigurable {
        CompositeCheckoutConfiguration(configurations: components)
    }
    
    public static func buildOptional(_ component: CheckoutComponentConfiguration?) -> CheckoutConfigurable? {
        component
    }
    
    public static func buildEither(first component: CheckoutComponentConfiguration) -> CheckoutConfigurable {
        component
    }
    
    public static func buildEither(second component: CheckoutComponentConfiguration) -> CheckoutConfigurable {
        component
    }
}
