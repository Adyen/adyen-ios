//
// Copyright (c) 2017 Adyen B.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation
import AdyenCSE
import UIKit

class CardsDetailsPresenter: PaymentMethodDetailsPresenter {
    
    var rootViewController: UIViewController?
    var hostViewController: UIViewController?
    var finalCompletion: ((PaymentDetails) -> Void)?
    var requiredPaymentDetails: PaymentDetails?
    var paymentRequest: PaymentRequest?
    var appearanceConfiguration: AppearanceConfiguration!
    
    func setup(with hostViewController: UIViewController, paymentRequest: PaymentRequest, paymentDetails: PaymentDetails, appearanceConfiguration: AppearanceConfiguration, completion: @escaping (PaymentDetails) -> Void) {
        self.hostViewController = hostViewController
        self.paymentRequest = paymentRequest
        requiredPaymentDetails = paymentDetails
        finalCompletion = completion
        self.appearanceConfiguration = appearanceConfiguration
        
        if let oneClick = paymentRequest.paymentMethod?.isOneClick {
            oneClick ? setupOneClickFlow() : setupCardFormFlow(paymentDetails: paymentDetails)
        }
    }
    
    // MARK: One-Click Flow
    
    private func setupOneClickFlow() {
        rootViewController = oneClickAlertController
    }
    
    private lazy var oneClickAlertController: UIAlertController = {
        let paymentRequest = self.paymentRequest!
        
        let title = ADYLocalizedString("creditCard.oneClickVerification.title")
        let message = ADYLocalizedString("creditCard.oneClickVerification.message", paymentRequest.paymentMethod!.name)
        
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addTextField(configurationHandler: { textField in
            textField.textAlignment = .center
            textField.keyboardType = .numberPad
            textField.placeholder = ADYLocalizedString("creditCard.cvcField.placeholder")
            textField.accessibilityLabel = ADYLocalizedString("creditCard.cvcField.title")
        })
        
        let cancelActionTitle = ADYLocalizedString("cancelButton.title")
        let cancelAction = UIAlertAction(title: cancelActionTitle, style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        
        let formattedAmount = Currency.formatted(amount: paymentRequest.amount!, currency: paymentRequest.currency!) ?? ""
        let confirmActionTitle = ADYLocalizedString("payButton.title.formatted", formattedAmount)
        let confirmAction = UIAlertAction(title: confirmActionTitle, style: .default) { [unowned self] _ in
            self.didSelectOneClickAlertControllerConfirmAction()
        }
        alertController.addAction(confirmAction)
        
        return alertController
    }()
    
    private func didSelectOneClickAlertControllerConfirmAction() {
        // Verify that a non-empty CVC has been entered. If not, present an alert.
        guard
            let textField = oneClickAlertController.textFields?.first,
            let cvc = textField.text, cvc.characters.count > 0 else {
            presentInvalidCVCAlertController()
            
            return
        }
        
        let requiredPaymentDetails = self.requiredPaymentDetails!
        requiredPaymentDetails.fillCard(cvc: cvc)
        finalCompletion?(requiredPaymentDetails)
    }
    
    private func presentInvalidCVCAlertController() {
        let alertController = UIAlertController(title: ADYLocalizedString("creditCard.oneClickVerification.invalidInput.title"),
                                                message: ADYLocalizedString("creditCard.oneClickVerification.invalidInput.message"),
                                                preferredStyle: .alert)
        
        let dismissActionTitle = ADYLocalizedString("dismissButton.title")
        let dismissAction = UIAlertAction(title: dismissActionTitle, style: .default) { [unowned self] _ in
            self.present() // Restart the flow.
        }
        alertController.addAction(dismissAction)
        
        hostViewController?.present(alertController, animated: false)
    }
    
    // MARK: Form Flow
    
    private func setupCardFormFlow(paymentDetails: PaymentDetails) {
        if let request = paymentRequest {
            
            let cardsFormController = CardFormViewController(appearanceConfiguration: appearanceConfiguration)
            
            cardsFormController.formattedAmount = Currency.formatted(amount: request.amount!, currency: request.currency!)
            cardsFormController.paymentMethod = request.paymentMethod
            cardsFormController.shouldHideStoreDetails = paymentDetails.list.filter({ $0.key == "storeDetails" }).count == 0
            cardsFormController.cardDetailsHandler = { info, completion in
                guard
                    let number = info["number"] as? String,
                    let month = info["expiryMonth"] as? String,
                    let year = info["expiryYear"] as? String,
                    let cvc = info["cvc"] as? String
                else {
                    return
                }
                
                let cardToken = self.cardTokenWith(
                    number: number,
                    expiryMonth: month,
                    expiryYear: year,
                    cvc: cvc
                )
                
                let storeDetails = (info["storeDetails"] as? Bool) ?? false
                
                if let token = cardToken {
                    self.requiredPaymentDetails?.fillCard(token: token, storeDetails: storeDetails)
                }
                
                self.finalCompletion?(self.requiredPaymentDetails!)
            }
            
            rootViewController = cardsFormController
        }
    }
    
    // MARK: Presentation & Dismissal
    
    func present() {
        guard
            let rootViewController = rootViewController,
            let method = paymentRequest?.paymentMethod else {
            return
        }
        
        if method.isOneClick {
            hostViewController?.present(rootViewController, animated: true, completion: nil)
        } else {
            if let navController = hostViewController as? UINavigationController {
                navController.pushViewController(rootViewController, animated: true)
            }
        }
    }
    
    func dismiss(animated: Bool, completion: @escaping () -> Void) {
        guard let method = paymentRequest?.paymentMethod else {
            completion()
            return
        }
        
        if method.isOneClick {
            rootViewController?.dismiss(animated: true, completion: nil)
        } else {
            rootViewController?.navigationController?.popViewController(animated: true)
        }
    }
}

extension CardsDetailsPresenter: RequiresFinalState {
    func finishWith(state: PaymentStatus, completion: (() -> Void)?) {}
}

extension CardsDetailsPresenter {
    
    func cardTokenWith(number: String, expiryMonth: String, expiryYear: String, cvc: String, holderName: String = "Checkout Shopper") -> String? {
        
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        
        guard
            let publicKey = paymentRequest?.publicKey,
            let generationTime = paymentRequest?.generationTime,
            let generationDate = dateFormatter.date(from: generationTime) else {
            return nil
        }
        
        let card = ADYCard()
        card.generationtime = generationDate
        card.holderName = holderName
        card.number = number
        card.expiryMonth = expiryMonth
        card.expiryYear = expiryYear
        card.cvc = cvc
        
        return ADYEncrypter.encrypt(card.encode(), publicKeyInHex: publicKey)
    }
}
