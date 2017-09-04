//
// Copyright (c) 2017 Adyen B.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

internal class IdealPlugin: Plugin, PluginPresentsPaymentDetails, UniversalLinksPlugin {
    
    // MARK: - Object Lifecycle
    
    internal required init(configuration: PluginConfiguration) {
        self.configuration = configuration
    }
    
    // MARK: - PluginPresentsPaymentDetails
    
    func newPaymentDetailsPresenter(hostViewController: UINavigationController, appearanceConfiguration: AppearanceConfiguration) -> PaymentDetailsPresenter {
        return IdealDetailsPresenter(hostViewController: hostViewController, pluginConfiguration: configuration)
    }
    
    // MARK: - UniversalLinksPlugin
    
    var supportsUniversalLinks: Bool {
        guard let paymentMethodConfiguration = configuration.paymentMethod.configuration,
            let canIgnoreCookies = paymentMethodConfiguration["canIgnoreCookies"] as? String else {
            return false
        }
        
        return canIgnoreCookies == "true"
    }
    
    // MARK: - Public
    
    internal let configuration: PluginConfiguration
    
}
