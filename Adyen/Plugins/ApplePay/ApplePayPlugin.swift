//
// Copyright (c) 2017 Adyen B.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation
import PassKit

internal class ApplePayPlugin: Plugin {
    
    internal let configuration: PluginConfiguration
    
    internal required init(configuration: PluginConfiguration) {
        self.configuration = configuration
    }
    
    fileprivate var detailsPresenter: ApplePayDetailsPresenter?
    
}

// MARK: - PluginPresentsPaymentDetails

extension ApplePayPlugin: PluginPresentsPaymentDetails {
    
    func newPaymentDetailsPresenter(hostViewController: UINavigationController, appearanceConfiguration: AppearanceConfiguration) -> PaymentDetailsPresenter {
        let detailsPresenter = ApplePayDetailsPresenter(hostViewController: hostViewController, pluginConfiguration: configuration)
        self.detailsPresenter = detailsPresenter
        
        return detailsPresenter
    }
    
}

// MARK: - PluginRequiresFinalState

extension ApplePayPlugin: PluginRequiresFinalState {
    
    func finish(with paymentStatus: PaymentStatus, completion: @escaping () -> Void) {
        detailsPresenter?.finish(with: paymentStatus, completion: completion)
    }
    
}

// MARK: - DeviceDependablePlugin

extension ApplePayPlugin: DeviceDependablePlugin {
    
    var isDeviceSupported: Bool {
        let networks: [PKPaymentNetwork] = [.visa, .masterCard, .amex]
        
        return PKPaymentAuthorizationViewController.canMakePayments(usingNetworks: networks)
    }
    
}
