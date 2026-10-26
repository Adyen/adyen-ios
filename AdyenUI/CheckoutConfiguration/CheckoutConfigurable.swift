//
// Copyright (c) 2025 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import Foundation

/// `CheckoutConfigurable` represents any type of configuration the SDK may require for its components,
/// such as `CardComponentConfiguration`,  `DropInConfiguration`, `ActionComponentConfiguration`.
public protocol CheckoutConfigurable {}

/// Configuration interface for all Checkout Components.
package protocol CheckoutComponentConfiguration: CheckoutConfigurable {
    
    var componentType: CheckoutComponentType { get }
    
    var showsSubmitButton: Bool { get set }
    
    // Internal runtime localization state. Merchant-facing checkout flows configure
    // localization through `CheckoutConfiguration.localizationProvider(...)`.

    var localizationParameters: LocalizationParameters? { get set }

    var localizationProvider: (any CheckoutLocalizationProvider)? { get set }

    //  var style: FormComponentStyle { get }

    var theme: CheckoutTheme { get set }
    
    /// Throws when the additional callbacks lack a callback this configuration requires.
    func validate(_ callbacks: AdditionalCallbacksStore) throws

    /// Returns a copy of the configuration with the session-owned settings applied.
    ///
    /// Only configurations that need to update from session values override it.
    func applying(_ session: SessionComponentConfiguration) -> Self
}

extension CheckoutComponentConfiguration {

    /// Empty default for components that require no extra callback.
    package func validate(_: AdditionalCallbacksStore) throws {}
    
    /// Returns the configuration unchanged, for components without session-owned settings.
    package func applying(_: SessionComponentConfiguration) -> Self {
        self
    }
}

package struct CompositeCheckoutConfiguration: CheckoutConfigurable {
    
    package var configurations: [CheckoutConfigurable]
    
    package init(configurations: [CheckoutConfigurable]) {
        self.configurations = configurations
    }
}
