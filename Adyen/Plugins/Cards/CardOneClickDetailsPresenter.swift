//
// Copyright (c) 2017 Adyen B.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

internal class CardOneClickDetailsPresenter: PaymentDetailsPresenter {
    
    private let hostViewController: UINavigationController
    
    private let pluginConfiguration: PluginConfiguration
    
    internal weak var delegate: PaymentDetailsPresenterDelegate?
    
    internal init(hostViewController: UINavigationController, pluginConfiguration: PluginConfiguration) {
        self.hostViewController = hostViewController
        self.pluginConfiguration = pluginConfiguration
    }
    
    internal func start() {
        hostViewController.present(alertController, animated: true)
    }
    
    private func submit(cvc: String) {
        let paymentDetails = PaymentDetails(details: pluginConfiguration.paymentMethod.inputDetails ?? [])
        paymentDetails.fillCard(cvc: cvc)
        
        delegate?.paymentDetailsPresenter(self, didSubmit: paymentDetails)
    }
    
    // MARK: - Alert Controller
    
    private lazy var alertController: UIAlertController = {
        let paymentMethod = self.pluginConfiguration.paymentMethod
        let paymentSetup = self.pluginConfiguration.paymentSetup
        
        let title = ADYLocalizedString("creditCard.oneClickVerification.title")
        let message = ADYLocalizedString("creditCard.oneClickVerification.message", paymentMethod.displayName)
        
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addTextField(configurationHandler: { textField in
            textField.textAlignment = .center
            textField.keyboardType = .numberPad
            textField.placeholder = ADYLocalizedString("creditCard.cvcField.placeholder")
            textField.accessibilityLabel = ADYLocalizedString("creditCard.cvcField.title")
        })
        
        let cancelActionTitle = ADYLocalizedString("cancelButton")
        let cancelAction = UIAlertAction(title: cancelActionTitle, style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        
        let formattedAmount = CurrencyFormatter.format(paymentSetup.amount, currencyCode: paymentSetup.currencyCode) ?? ""
        let confirmActionTitle = ADYLocalizedString("payButton.formatted", formattedAmount)
        let confirmAction = UIAlertAction(title: confirmActionTitle, style: .default) { [unowned self] _ in
            self.didSelectOneClickAlertControllerConfirmAction()
        }
        alertController.addAction(confirmAction)
        
        return alertController
    }()
    
    private func didSelectOneClickAlertControllerConfirmAction() {
        // Verify that a non-empty CVC has been entered. If not, present an alert.
        guard
            let textField = alertController.textFields?.first,
            let cvc = textField.text, cvc.characters.count > 0
        else {
            presentInvalidCVCAlertController()
            
            return
        }
        
        submit(cvc: cvc)
    }
    
    private func presentInvalidCVCAlertController() {
        let alertController = UIAlertController(title: ADYLocalizedString("creditCard.oneClickVerification.invalidInput.title"),
                                                message: ADYLocalizedString("creditCard.oneClickVerification.invalidInput.message"),
                                                preferredStyle: .alert)
        
        let dismissActionTitle = ADYLocalizedString("dismissButton")
        let dismissAction = UIAlertAction(title: dismissActionTitle, style: .default) { [unowned self] _ in
            self.start() // Restart the flow.
        }
        alertController.addAction(dismissAction)
        
        hostViewController.present(alertController, animated: false)
    }
    
}
