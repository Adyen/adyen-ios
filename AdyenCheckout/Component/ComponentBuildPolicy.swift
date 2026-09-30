//
// Copyright (c) 2026 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
#if canImport(AdyenUI)
    import AdyenUI
#endif

/// Settings the builder applies to every component, chosen by the flow that shows the component.
///
/// Only settings whose value depends on that flow belong here. Settings that are the same everywhere,
/// such as the theme, are copied from `CheckoutConfiguration` directly.
package struct ComponentBuildPolicy {

    /// Whether components render their own submit button.
    package let showsSubmitButton: Bool
}

extension ComponentBuildPolicy {

    /// The policy for components created with `createPaymentComponent`.
    ///
    /// Standalone components follow the merchant's checkout-wide settings.
    package static func components(_ configuration: CheckoutConfiguration) -> Self {
        Self(showsSubmitButton: configuration.showsSubmitButton)
    }

    /// The policy for components shown by Drop-in.
    ///
    /// Drop-in owns every screen it shows, so merchant presentation flags can't hide its UI.
    package static let dropIn = Self(showsSubmitButton: true)
}

extension CheckoutComponentConfiguration {

    /// Returns a copy of the configuration with the policy's settings applied.
    package func applying(_ policy: ComponentBuildPolicy) -> Self {
        var copy = self
        copy.showsSubmitButton = policy.showsSubmitButton
        return copy
    }
}
