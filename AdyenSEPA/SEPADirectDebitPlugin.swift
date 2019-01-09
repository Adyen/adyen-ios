//
// Copyright (c) 2019 Adyen B.V.
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
    
    internal var canSkipPaymentMethodSelection: Bool {
        return true
    }
    
    internal var preferredPresentationMode: PaymentDetailsPluginPresentationMode {
        return .push
    }
    
    internal func viewController(for details: [PaymentDetail], appearance: Appearance, completion: @escaping Completion<[PaymentDetail]>) -> UIViewController {
        let formViewController = SEPADirectDebitFormViewController(appearance: appearance)
        formViewController.title = paymentMethod.name
        
        let amount = paymentSession.payment.amount(for: paymentMethod)
        
        if let surcharge = paymentMethod.surcharge, let amountString = AmountFormatter.formatted(amount: surcharge.total, currencyCode: amount.currencyCode) {
            formViewController.payActionSubtitle = ADYLocalizedString("surcharge.formatted", amountString)
        }
        
        formViewController.payActionTitle = appearance.checkoutButtonAttributes.title(for: amount)
        formViewController.completion = { input in
            var details = details
            details.sepaName?.value = input.name
            details.sepaIBAN?.value = input.iban
            completion(details)
        }
        
        return formViewController
    }
    
}
