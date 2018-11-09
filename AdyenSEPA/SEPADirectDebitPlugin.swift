//
// Copyright (c) 2018 Adyen B.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import AdyenInternal
import Foundation

/// A plugin that provides an input form for SEPA Direct Debit.
internal final class SEPADirectDebitPlugin: Plugin {
    
    internal let paymentSession: PaymentSession
    internal let paymentMethod: PaymentMethod
    
    internal init(paymentSession: PaymentSession, paymentMethod: PaymentMethod) {
        self.paymentSession = paymentSession
        self.paymentMethod = paymentMethod
    }
    
}

// MARK: - PaymentDetailsPlugin

extension SEPADirectDebitPlugin: PaymentDetailsPlugin {
    
    internal var showsDisclosureIndicator: Bool {
        return true
    }
    
    internal func present(_ details: [PaymentDetail], using navigationController: UINavigationController, appearance: Appearance, completion: @escaping Completion<[PaymentDetail]>) {
        let formViewController = SEPADirectDebitFormViewController(appearance: appearance)
        formViewController.title = paymentMethod.name
        
        let amount = paymentSession.payment.amount(for: paymentMethod)
        
        if let surcharge = paymentMethod.surcharge, let amountString = AmountFormatter.formatted(amount: surcharge.total, currencyCode: amount.currencyCode) {
            formViewController.payActionSubtitle = ADYLocalizedString("surcharge.formatted", amountString)
        }
        
        formViewController.payActionTitle = appearance.checkoutButtonAttributes.title(for: amount)
        formViewController.completion = { input in
            var details = self.paymentMethod.details
            details.sepaName?.value = input.name
            details.sepaIBAN?.value = input.iban
            completion(details)
        }
        navigationController.pushViewController(formViewController, animated: true)
    }
    
}
