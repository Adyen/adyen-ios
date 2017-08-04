//
// Copyright (c) 2017 Adyen B.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

internal class SEPADirectDebitPlugin: Plugin {
    
    internal let configuration: PluginConfiguration
    
    internal required init(configuration: PluginConfiguration) {
        self.configuration = configuration
    }
    
}

// MARK: - PluginPresentsPaymentDetails

extension SEPADirectDebitPlugin: PluginPresentsPaymentDetails {
    
    func newPaymentDetailsPresenter(hostViewController: UINavigationController, appearanceConfiguration: AppearanceConfiguration) -> PaymentDetailsPresenter {
        return SEPADirectDebitDetailsPresenter(hostViewController: hostViewController, pluginConfiguration: configuration, appearanceConfiguration: appearanceConfiguration)
    }
    
}
