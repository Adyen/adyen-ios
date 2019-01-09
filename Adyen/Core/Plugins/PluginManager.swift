//
// Copyright (c) 2019 Adyen B.V.
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
        
        let plugin = pluginClass.init(paymentSession: paymentSession, paymentMethod: paymentMethod)
        
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
            case "card", "bcmc":
                classNames = ["AdyenCard.CardPlugin", "Adyen.CardPlugin"]
            case "klarna", "afterpay_default":
                classNames = ["AdyenOpenInvoice.OpenInvoicePlugin", "Adyen.OpenInvoicePlugin"]
            case "sepadirectdebit":
                classNames = ["AdyenSEPA.SEPADirectDebitPlugin", "Adyen.SEPADirectDebitPlugin"]
            case "wechatpaySDK":
                classNames = ["AdyenWeChatPay.WeChatPayPlugin", "Adyen.WeChatPayPlugin"]
            case "giropay":
                classNames = ["Adyen.GiroPayPlugin"]
            default:
                if paymentMethod.requiresIssuerSelection {
                    classNames = ["Adyen.IssuerSelectionPlugin"]
                }
            }
        }
        
        return classNames
    }
    
    // MARK: - Filtering Payment Methods
    
    /// Returns the available payment methods for a collection of payment methods.
    ///
    /// - Parameter paymentMethods: The payment methods to filter for available payment methods.
    /// - Returns: A subset of the given payment methods, containing only available payment methods.
    internal func availablePaymentMethods(for paymentMethods: SectionedPaymentMethods) -> SectionedPaymentMethods {
        func isPaymentMethodAvailable(_ paymentMethod: PaymentMethod) -> Bool {
            guard let plugin = self.plugin(for: paymentMethod) else {
                return true
            }
            
            return plugin.isDeviceSupported
        }
        
        var paymentMethods = paymentMethods
        paymentMethods.preferred = paymentMethods.preferred.filter(isPaymentMethodAvailable(_:))
        paymentMethods.other = paymentMethods.other.filter(isPaymentMethodAvailable(_:))
        
        return paymentMethods
    }
    
}
