//
// Copyright (c) 2017 Adyen B.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

class PluginLoader {
    
    func classString(for method: PaymentMethod) -> String? {
        
        switch method.txVariant {
        case .applepay:
            return "ApplePayPlugin"
        case .ideal:
            return "IdealPlugin"
        case .visa, .cards, .card:
            return "CardsPlugin"
        case .sepadirectdebit:
            return "SEPADirectDebitPlugin"
        default:
            break
        }
        
        if CardBrandCode(rawValue: method.type) != nil {
            return "CardsPlugin"
        }
        
        return "BasePlugin"
    }
    
    func plugin(for method: PaymentMethod) -> BasePlugin? {
        guard let className = classString(for: method) else {
            return nil
        }
        
        var plugin: BasePlugin?
        
        if let pluginType: BasePlugin.Type = NSClassFromString("Adyen." + className) as? BasePlugin.Type {
            plugin = pluginType.init()
            plugin?.method = method
        }
        
        return plugin
    }
}
