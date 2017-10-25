//
// Copyright (c) 2017 Adyen B.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

internal class IdealPlugin: Plugin, PluginPresentsPaymentDetails {
    
    // MARK: - Object Lifecycle
    
    internal required init(configuration: PluginConfiguration) {
        self.configuration = configuration
    }
    
    // MARK: - PluginPresentsPaymentDetails
    
    func newPaymentDetailsPresenter(hostViewController: UINavigationController) -> PaymentDetailsPresenter {
        return IdealDetailsPresenter(hostViewController: hostViewController, pluginConfiguration: configuration)
    }
    
    // MARK: - Public
    
    internal let configuration: PluginConfiguration
    
}
