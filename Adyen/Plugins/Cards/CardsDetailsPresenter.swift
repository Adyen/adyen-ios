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
    
    func setup(with hostViewController: UIViewController, paymentRequest: PaymentRequest, paymentDetails: PaymentDetails, completion: @escaping (PaymentDetails) -> Void) {
        self.hostViewController = hostViewController
        self.paymentRequest = paymentRequest
        requiredPaymentDetails = paymentDetails
        finalCompletion = completion
        
        if let oneClick = paymentRequest.paymentMethod?.oneClick {
            oneClick ? setupOneClickFlow() : setupCardFormFlow(paymentDetails: paymentDetails)
        }
    }
    
    private func setupOneClickFlow() {
        let alert = CardsAlertController(
            title: NSLocalizedString("Verify your card", comment: ""),
            message: "Please enter the CVC code for\n\(paymentRequest!.paymentMethod!.name)",
            preferredStyle: .alert
        )
        
        alert.addTextField(configurationHandler: { textField in
            textField.placeholder = "123"
            textField.textAlignment = .center
            textField.keyboardType = .numberPad
        })
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(cancelAction)
        
        let formattedAmount = Currency.formatted(amount: paymentRequest!.amount!, currency: paymentRequest!.currency!)
        let okTittle = "Pay \(formattedAmount ?? "")"
        
        let okAction = UIAlertAction(title: okTittle, style: .default) { _ in
            if let textField = alert.textFields?.first {
                alert.detailsHandler?([
                    "cardDetails.cvc": textField.text ?? ""
                ])
            }
        }
        alert.addAction(okAction)
        
        alert.detailsHandler = { info in
            if let cvc = info["cardDetails.cvc"] as? String {
                self.requiredPaymentDetails?.fillCard(cvc: cvc)
            }
            
            self.finalCompletion?(self.requiredPaymentDetails!)
        }
        
        rootViewController = alert
    }
    
    private func setupCardFormFlow(paymentDetails: PaymentDetails) {
        if let request = paymentRequest {
            
            let cardsFormController = CardFormViewController(nibName: "CardFormViewController", bundle: Bundle(for: CardsDetailsPresenter.self))
            
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
    
    func present() {
        guard
            let rootViewController = rootViewController,
            let method = paymentRequest?.paymentMethod else {
            return
        }
        
        if method.oneClick {
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
        
        if method.oneClick {
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
