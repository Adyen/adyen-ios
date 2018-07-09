//
// Copyright (c) 2018 Adyen B.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

internal class SEPADirectDebitDetailsPresenter: PaymentDetailsPresenter {

    var navigationMode: NavigationMode = .push

    private let hostViewController: UINavigationController
    
    private let pluginConfiguration: PluginConfiguration
    
    internal weak var delegate: PaymentDetailsPresenterDelegate?
    
    internal init(hostViewController: UINavigationController, pluginConfiguration: PluginConfiguration) {
        self.hostViewController = hostViewController
        self.pluginConfiguration = pluginConfiguration
    }
    
    func start() {
        let paymentSetup = pluginConfiguration.paymentSetup
        
        let formViewController = SEPADirectDebitFormViewController()
        formViewController.title = pluginConfiguration.paymentMethod.name
        formViewController.payButtonTitle = AppearanceConfiguration.shared.payActionTitle(forAmount: paymentSetup.amount, currencyCode: paymentSetup.currencyCode)
        formViewController.delegate = self
        present(formViewController)
    }

    private func present(_ viewController: UIViewController) {
        switch navigationMode {
        case .present:
            hostViewController.viewControllers = [viewController]
            viewController.navigationItem.hidesBackButton = true
            viewController.navigationItem.leftBarButtonItem = AppearanceConfiguration.shared.cancelButtonItem(target: self, selector: #selector(didSelect(cancelButtonItem:)))
        case .push:
            hostViewController.pushViewController(viewController, animated: true)
        }
    }

    @objc private func didSelect(cancelButtonItem: Any) {
        hostViewController.dismiss(animated: true, completion: nil)
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
        formViewController.isLoading = true
        
        submit(iban: iban, name: name)
    }
    
}
