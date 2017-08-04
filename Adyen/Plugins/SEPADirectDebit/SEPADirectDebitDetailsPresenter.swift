//
// Copyright (c) 2017 Adyen B.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

internal class SEPADirectDebitDetailsPresenter: PaymentDetailsPresenter {
    
    private let hostViewController: UINavigationController
    
    private let pluginConfiguration: PluginConfiguration
    
    private let appearanceConfiguration: AppearanceConfiguration
    
    internal weak var delegate: PaymentDetailsPresenterDelegate?
    
    internal init(hostViewController: UINavigationController, pluginConfiguration: PluginConfiguration, appearanceConfiguration: AppearanceConfiguration) {
        self.hostViewController = hostViewController
        self.pluginConfiguration = pluginConfiguration
        self.appearanceConfiguration = appearanceConfiguration
    }
    
    func start() {
        let paymentSetup = pluginConfiguration.paymentSetup
        let formattedAmount = CurrencyFormatter.format(paymentSetup.amount, currencyCode: paymentSetup.currencyCode)
        
        let formViewController = SEPADirectDebitFormViewController(appearanceConfiguration: appearanceConfiguration)
        formViewController.title = pluginConfiguration.paymentMethod.name
        formViewController.formattedAmount = formattedAmount
        formViewController.delegate = self
        hostViewController.pushViewController(formViewController, animated: true)
    }
    
    fileprivate func submit(iban: String, name: String) {
        let paymentDetails = PaymentDetails(details: pluginConfiguration.paymentMethod.inputDetails ?? [])
        paymentDetails.fillSepa(name: name, iban: iban)
        delegate?.paymentDetailsPresenter(self, didSubmit: paymentDetails)
    }
    
}

// MARK: - SEPADirectDebitFormViewControllerDelegate

extension SEPADirectDebitDetailsPresenter: SEPADirectDebitFormViewControllerDelegate {
    
    func formViewController(_ formViewController: SEPADirectDebitFormViewController, didSubmitWithIBAN iban: String, name: String) {
        submit(iban: iban, name: name)
    }
    
}
