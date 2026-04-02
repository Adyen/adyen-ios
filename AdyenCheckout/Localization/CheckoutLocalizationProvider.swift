//
// Copyright (c) 2026 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import Foundation

/// Provides custom localized strings for Checkout UI.
public protocol CheckoutLocalizationProvider {
    func localizedString(_ key: CheckoutLocalizationKey, locale: Locale) -> String?
}

package struct CheckoutLocalizationProviderAdapter: AnyCheckoutLocalizationProvider {
    package let provider: any CheckoutLocalizationProvider

    package init(_ provider: any CheckoutLocalizationProvider) {
        self.provider = provider
    }

    package func localizedString(_ key: CheckoutLocalizationKeyIdentifier, locale: Locale) -> String? {
        provider.localizedString(CheckoutLocalizationKey(key), locale: locale)
    }
}
