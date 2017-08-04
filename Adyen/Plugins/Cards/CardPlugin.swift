//
// Copyright (c) 2017 Adyen B.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

internal class CardPlugin: Plugin, PluginPresentsPaymentDetails, CardScanPlugin {
    
    // MARK: - Plugin
    
    internal let configuration: PluginConfiguration
    
    internal required init(configuration: PluginConfiguration) {
        self.configuration = configuration
    }
    
    // MARK: - PluginPresentsPaymentDetails
    
    func newPaymentDetailsPresenter(hostViewController: UINavigationController, appearanceConfiguration: AppearanceConfiguration) -> PaymentDetailsPresenter {
        if configuration.paymentMethod.isOneClick {
            return CardOneClickDetailsPresenter(hostViewController: hostViewController, pluginConfiguration: configuration)
        } else {
            return CardFormDetailsPresenter(hostViewController: hostViewController, pluginConfiguration: configuration, appearanceConfiguration: appearanceConfiguration, cardScanButtonHandler: cardScanButtonHandler)
        }
    }
    
    // MARK: - CardScanPlugin
    
    var cardScanButtonHandler: ((@escaping CardScanCompletion) -> Void)?
    
}
