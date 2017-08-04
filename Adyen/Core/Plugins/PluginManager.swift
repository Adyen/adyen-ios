//
// Copyright (c) 2017 Adyen B.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

internal class PluginManager {
    
    /// The payment setup for which the plugins are managed.
    internal let paymentSetup: PaymentSetup
    
    /// Initializes the plugin manager.
    ///
    /// - Parameter paymentSetup: The payment setup for which the plugins are managed.
    internal init(paymentSetup: PaymentSetup) {
        self.paymentSetup = paymentSetup
    }
    
    /// Returns a plugin for the given payment method.
    ///
    /// - Parameter paymentMethod: The payment method to create a plugin for.
    /// - Returns: A plugin for the given payment method, or `nil` of none is available.
    internal func plugin(for paymentMethod: PaymentMethod) -> Plugin? {
        if let plugin = plugins[paymentMethod.paymentMethodData] {
            return plugin
        }
        
        guard let className = PluginManager.className(for: paymentMethod) else {
            return nil
        }
        
        guard let pluginClass = NSClassFromString(className) as? Plugin.Type else {
            return nil
        }
        
        let configuration = PluginConfiguration(paymentMethod: paymentMethod, paymentSetup: paymentSetup)
        let plugin = pluginClass.init(configuration: configuration)
        
        plugins[paymentMethod.paymentMethodData] = plugin
        
        return plugin
    }
    
    private var plugins: [String: Plugin] = [:]
    
    private static func className(for paymentMethod: PaymentMethod) -> String? {
        guard let namespace = NSStringFromClass(self).components(separatedBy: ".").first else {
            return nil
        }
        
        let type = paymentMethod.group?.type ?? paymentMethod.type
        
        var className = ""
        switch type {
        case "applepay":
            className = "ApplePayPlugin"
        case "ideal":
            className = "IdealPlugin"
        case "card":
            className = "CardPlugin"
        case "sepadirectdebit":
            className = "SEPADirectDebitPlugin"
        default:
            break
        }
        
        return "\(namespace).\(className)"
    }
    
}
