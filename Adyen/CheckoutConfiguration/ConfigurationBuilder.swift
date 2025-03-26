//
// Copyright (c) 2025 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

@resultBuilder
public struct ConfigurationBuilder {
    public static func buildBlock(_ components: CheckoutConfigurable...) -> CheckoutConfigurable {
        CompositeCheckoutConfiguration(configurations: components)
    }
    
    public static func buildEither(first component: any CheckoutConfigurable) -> any CheckoutConfigurable {
        component
    }
    
    public static func buildEither(second component: any CheckoutConfigurable) -> any CheckoutConfigurable {
        component
    }
}

public protocol CheckoutConfigurable {}

internal struct CompositeCheckoutConfiguration: CheckoutConfigurable {
    
    internal var configurations: [CheckoutConfigurable]
}
