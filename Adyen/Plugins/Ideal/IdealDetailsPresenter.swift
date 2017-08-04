//
// Copyright (c) 2017 Adyen B.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

internal class IdealDetailsPresenter: PaymentDetailsPresenter {
    
    private let hostViewController: UINavigationController
    
    private let pluginConfiguration: PluginConfiguration
    
    internal weak var delegate: PaymentDetailsPresenterDelegate?
    
    internal init(hostViewController: UINavigationController, pluginConfiguration: PluginConfiguration) {
        self.hostViewController = hostViewController
        self.pluginConfiguration = pluginConfiguration
    }
    
    internal func start() {
        let paymentMethod = pluginConfiguration.paymentMethod
        let issuerInputDetail = paymentMethod.inputDetails?.first { $0.type == .select }
        let issuerItems = issuerInputDetail?.items ?? []
        
        let issuerPickerViewController = IdealIssuerPickerViewController(items: issuerItems) { selectedItem in
            self.submit(issuerIdentifier: selectedItem.identifier)
        }
        issuerPickerViewController.title = paymentMethod.name
        hostViewController.pushViewController(issuerPickerViewController, animated: true)
    }
    
    private func submit(issuerIdentifier: String) {
        let paymentDetails = PaymentDetails(details: pluginConfiguration.paymentMethod.inputDetails ?? [])
        paymentDetails.fillIdeal(issuerIdentifier: issuerIdentifier)
        delegate?.paymentDetailsPresenter(self, didSubmit: paymentDetails)
    }
    
}
