//
// Copyright (c) 2026 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
#if canImport(AdyenUI)
    import AdyenUI
#endif
import Foundation

/// Configuration for Twint action handling.
package struct TwintActionConfiguration: CheckoutComponentConfiguration {
    
    package let componentType: CheckoutComponentType = .action(.twint)
    
    package var showsSubmitButton: Bool = false
    
    package var theme: CheckoutTheme = .default
    
    package var localizationParameters: LocalizationParameters?
    
    package var callbackAppScheme: String
    
    package var maxIssuerNumber: Int
    
    /// Initializes a new TwintActionConfiguration instance.
    ///
    /// - Parameters:
    ///   - callbackAppScheme: The callback app scheme invoked once the Twint app is done with the payment.
    ///     Only provide the scheme, without a host/path/... (e.g. "my-app", not a full URL like "my-app://...").
    package init(callbackAppScheme: String) {
        if !Self.isCallbackSchemeValid(callbackAppScheme) {
            AdyenAssertion.assertionFailure(message: "Format of provided callbackAppScheme '\(callbackAppScheme)' is incorrect.")
        }
        
        self.callbackAppScheme = callbackAppScheme
        self.maxIssuerNumber = .max
    }
    
    private static func isCallbackSchemeValid(_ callbackAppScheme: String) -> Bool {
        if let url = URL(string: callbackAppScheme), url.scheme != nil {
            return false
        }
        return true
    }
}

extension TwintActionConfiguration {
    
    /// Sets the maximum issuer number for Twint app queries.
    ///
    /// The issuer number of the highest scheme you listed under `LSApplicationQueriesSchemes`.
    /// E.g. pass 39, if you listed all schemes from "twint-issuer1" up to and including "twint-issuer39".
    /// The value is clamped between 0 and 39.
    ///
    /// - Important: All apps above "twint-issuer39" will always be returned if one of these apps is installed.
    /// For this to work, `LSApplicationQueriesSchemes` must include "twint-extended".
    /// If you configure any `maxIssuerNumber` below 39, the result will always contain all apps above `maxIssuerNumber`
    /// up to and including 39, even if none of them are installed.
    /// Additionally, if the fetch fails and the cache is empty, none of these apps will be found when probing.
    ///
    /// - Parameter maxIssuerNumber: The issuer number of the highest scheme listed.
    /// - Returns: A modified copy of the configuration.
    package func maxIssuerNumber(_ maxIssuerNumber: Int) -> Self {
        var copy = self
        copy.maxIssuerNumber = maxIssuerNumber
        return copy
    }
}
