//
// Copyright (c) 2018 Adyen B.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// Manages plugins for payment methods in a payment session.
internal final class PluginManager {
    /// The payment session for which the plugins are managed.
    internal let paymentSession: PaymentSession
    
    /// Initializes the plugin manager.
    ///
    /// - Parameter paymentSession: The payment session for which the plugins are managed.
    internal init(paymentSession: PaymentSession) {
        self.paymentSession = paymentSession
    }
    
    // MARK: - Retrieving Plugins
    
    /// Returns a plugin for the given payment method.
    ///
    /// - Parameter paymentMethod: The payment method to create a plugin for.
    /// - Returns: A plugin for the given payment method, or `nil` of none is available.
    internal func plugin(for paymentMethod: PaymentMethod) -> Plugin? {
        if let plugin = plugins[paymentMethod.paymentMethodData] {
            return plugin
        }
        
        guard let pluginClass = PluginManager.className(for: paymentMethod).compactMap({ NSClassFromString($0) as? Plugin.Type }).first else {
            return nil
        }
        
        let plugin = pluginClass.init(paymentMethod: paymentMethod, paymentSession: paymentSession, appearance: Appearance.shared)
        
        plugins[paymentMethod.paymentMethodData] = plugin
        
        return plugin
    }
    
    private var plugins: [String: Plugin] = [:]
    
    private static func className(for paymentMethod: PaymentMethod) -> [String] {
        let type = paymentMethod.group?.type ?? paymentMethod.type
        
        var classNames: [String] = []
        
        if paymentMethod.storedDetails != nil {
            switch type {
            case "card":
                classNames = ["AdyenCard.StoredCardPlugin", "Adyen.StoredCardPlugin"]
            default:
                classNames = ["Adyen.StoredPlugin"]
            }
        } else {
            switch type {
            case "applepay":
                classNames = ["AdyenApplePay.ApplePayPlugin", "Adyen.ApplePayPlugin"]
            case "card":
                classNames = ["AdyenCard.CardPlugin", "Adyen.CardPlugin"]
            case "bcmc":
                classNames = ["AdyenCard.CardPlugin", "Adyen.CardPlugin"]
            case "sepadirectdebit":
                classNames = ["AdyenSEPA.SEPADirectDebitPlugin", "Adyen.SEPADirectDebitPlugin"]
            default:
                if paymentMethod.requiresIssuerSelection {
                    classNames = ["Adyen.IssuerSelectionPlugin"]
                }
            }
        }
        
        return classNames
    }
    
}
