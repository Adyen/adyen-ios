//
// Copyright (c) 2018 Adyen B.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// A plugin that provides an input form for SEPA Direct Debit.
internal final class SEPADirectDebitPlugin: Plugin {

    // MARK: - Plugin
    
    internal override var showsDisclosureIndicator: Bool {
        return true
    }
    
    internal override func present(using navigationController: UINavigationController, completion: @escaping Completion<[PaymentDetail]>) {
        let formViewController = SEPADirectDebitFormViewController(appearance: appearance)
        formViewController.title = paymentMethod.name
        
        let paymentAmount = paymentSession.payment.amount
        formViewController.payActionTitle = appearance.checkoutButtonAttributes.title(forAmount: paymentAmount.value, currencyCode: paymentAmount.currencyCode)
        formViewController.completion = { [unowned formViewController] input in
            formViewController.isLoading = true
            
            var details = self.paymentMethod.details
            details.sepaName?.value = input.name
            details.sepaIBAN?.value = input.iban
            completion(details)
        }
        navigationController.pushViewController(formViewController, animated: true)
    }
    
}
