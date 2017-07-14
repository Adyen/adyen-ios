//
// Copyright (c) 2017 Adyen B.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

class SEPADirectDebitDetailsPresenter: PaymentMethodDetailsPresenter {
    
    private var hostViewController: UIViewController!
    
    private var paymentRequest: PaymentRequest!
    
    private var paymentDetails: PaymentDetails!
    
    private var paymentDetailsCompletion: PaymentDetailsCompletion!
    
    private var appearanceConfiguration: AppearanceConfiguration!
    
    func setup(with hostViewController: UIViewController, paymentRequest: PaymentRequest, paymentDetails: PaymentDetails, appearanceConfiguration: AppearanceConfiguration, completion: @escaping (PaymentDetails) -> Void) {
        self.hostViewController = hostViewController
        self.paymentRequest = paymentRequest
        self.paymentDetails = paymentDetails
        paymentDetailsCompletion = completion
        self.appearanceConfiguration = appearanceConfiguration
    }
    
    func present() {
        let formattedAmount = Currency.formatted(amount: paymentRequest.amount!, currency: paymentRequest.currency!)!
        
        let formViewController = SEPADirectDebitFormViewController(appearanceConfiguration: appearanceConfiguration)
        formViewController.title = paymentRequest.paymentMethod?.name
        formViewController.delegate = self
        formViewController.formattedAmount = formattedAmount
        
        let navigationController = hostViewController as? UINavigationController
        navigationController?.pushViewController(formViewController, animated: true)
    }
    
    func dismiss(animated: Bool, completion: @escaping () -> Void) {
        let navigationController = hostViewController as? UINavigationController
        navigationController?.popViewController(animated: true)
    }
    
    fileprivate func finish(withIBAN iban: String, name: String) {
        paymentDetails.fillSepa(name: name, iban: iban)
        paymentDetailsCompletion(paymentDetails)
    }
    
}

extension SEPADirectDebitDetailsPresenter: SEPADirectDebitFormViewControllerDelegate {
    
    func formViewController(_ formViewController: SEPADirectDebitFormViewController, didSubmitWithIBAN iban: String, name: String) {
        formViewController.isLoading = true
        
        finish(withIBAN: iban, name: name)
    }
    
}
