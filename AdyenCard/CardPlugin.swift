//
// Copyright (c) 2018 Adyen B.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import AdyenInternal
import Foundation

internal final class CardPlugin: Plugin {

    // MARK: - Plugin
    
    internal weak static var cardScanDelegate: CardScanDelegate?
    
    internal override var showsDisclosureIndicator: Bool {
        return paymentMethod.storedDetails == nil
    }
    
    override func present(using navigationController: UINavigationController, completion: @escaping Completion<[PaymentDetail]>) {
        completionHandler = completion
        navigationController.pushViewController(detailsViewController, animated: true)
    }
    
    // MARK: - Private
    
    private var completionHandler: Completion<[PaymentDetail]>?
    
    private var detailsViewController: UIViewController {
        let payment = paymentSession.payment
        
        let formViewController = CardFormViewController(appearance: appearance)
        formViewController.title = paymentMethod.name
        formViewController.formattedAmount = payment.amount.formatted
        formViewController.paymentMethod = paymentMethod
        formViewController.paymentSession = paymentSession
        formViewController.storeDetailsConfiguration = CardFormFieldConfiguration.from(paymentDetail: paymentMethod.details.storeDetails)
        formViewController.installmentsConfiguration = CardFormFieldConfiguration.from(paymentDetail: paymentMethod.details.installments)
        formViewController.cvcConfiguration = CardFormFieldConfiguration.from(paymentDetail: paymentMethod.details.encryptedSecurityCode)
        formViewController.holderNameConfiguration = CardFormFieldConfiguration.from(paymentDetail: paymentMethod.details.cardholderName)
        
        if let delegate = CardPlugin.cardScanDelegate, delegate.isCardScanEnabled(for: paymentMethod) {
            formViewController.cardScanButtonHandler = { completion in
                delegate.scanCard(for: self.paymentMethod, completion: completion)
            }
        }
        
        formViewController.cardDetailsHandler = { cardInputData in
            self.submit(cardInputData: cardInputData)
        }
        
        return formViewController
    }
    
    private func submit(cardInputData: CardInputData) {
        var details = paymentMethod.details
        
        details.encryptedCardNumber?.value = cardInputData.encryptedCard.number
        details.encryptedSecurityCode?.value = cardInputData.encryptedCard.securityCode
        details.encryptedExpiryYear?.value = cardInputData.encryptedCard.expiryYear
        details.encryptedExpiryMonth?.value = cardInputData.encryptedCard.expiryMonth
        details.installments?.value = cardInputData.installments
        details.storeDetails?.value = cardInputData.storeDetails.stringValue()
        details.cardholderName?.value = cardInputData.holderName
        
        completionHandler?(details)
    }
}
