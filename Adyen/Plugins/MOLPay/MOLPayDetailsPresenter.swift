//
// Copyright (c) 2018 Adyen B.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

internal class MOLPayDetailsPresenter: PaymentDetailsPresenter {
    
    private let hostViewController: UINavigationController
    
    private let pluginConfiguration: PluginConfiguration
    
    internal weak var delegate: PaymentDetailsPresenterDelegate?
    
    internal init(hostViewController: UINavigationController, pluginConfiguration: PluginConfiguration) {
        self.hostViewController = hostViewController
        self.pluginConfiguration = pluginConfiguration
    }
    
    internal func start() {
        let pickerItems = issuerItems.map(PickerItem.init)
        let pickerViewController = PickerViewController(items: pickerItems)
        pickerViewController.title = pluginConfiguration.paymentMethod.name
        pickerViewController.delegate = self
        hostViewController.pushViewController(pickerViewController, animated: true)
    }
    
    private func submit(issuerIdentifier: String) {
        let paymentDetails = PaymentDetails(details: pluginConfiguration.paymentMethod.inputDetails ?? [])
        paymentDetails.setDetail(value: issuerIdentifier, forKey: "issuer")
        delegate?.paymentDetailsPresenter(self, didSubmit: paymentDetails)
    }
    
    private var issuerItems: [InputSelectItem] {
        let paymentMethod = pluginConfiguration.paymentMethod
        let issuerInputDetail = paymentMethod.inputDetails?.first { $0.type == .select }
        
        return issuerInputDetail?.items ?? []
    }
    
}

extension MOLPayDetailsPresenter: PickerViewControllerDelegate {
    
    func didSelect(_ pickerItem: PickerItem, in pickerViewController: PickerViewController) {
        guard let index = pickerViewController.items.index(of: pickerItem) else { return }
        
        let issuerItem = issuerItems[index]
        submit(issuerIdentifier: issuerItem.identifier)
        
        pickerViewController.showActivityIndicator(for: pickerItem)
    }
    
}
