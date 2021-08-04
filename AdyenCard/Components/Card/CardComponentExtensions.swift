//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
#if canImport(AdyenEncryption)
    import AdyenEncryption
#endif
import UIKit

extension CardComponent {
    
    internal func didSelectSubmitButton() {
        guard cardViewController.validate() else {
            return
        }
        
        cardViewController.startLoading()

        fetchCardPublicKey(discardError: false) { [weak self] in
            self?.submitEncryptedCardData(cardPublicKey: $0)
        }
    }
    
    private func submitEncryptedCardData(cardPublicKey: String) {
        do {
            let card = cardViewController.card
            let encryptedCard = try CardEncryptor.encrypt(card: card, with: cardPublicKey)
            let kcpDetails = try cardViewController.kcpDetails?.encrypt(with: cardPublicKey)
            let details = CardDetails(paymentMethod: cardPaymentMethod,
                                      encryptedCard: encryptedCard,
                                      holderName: card.holder,
                                      billingAddress: cardViewController.address,
                                      kcpDetails: kcpDetails,
                                      socialSecurityNumber: cardViewController.socialSecurityNumber)
            
            let data = PaymentComponentData(paymentMethodDetails: details,
                                            amount: amountToPay,
                                            order: order,
                                            storePaymentMethod: cardViewController.storePayment)
            
            if let number = card.number {
                let lastFour = String(number.suffix(publicPanSuffixLength))
                cardComponentDelegate?.didSubmitLastFour(lastFour, component: self)
            }

            submit(data: data)
        } catch {
            delegate?.didFail(with: error, from: self)
        }
    }
}

/// :nodoc:
extension CardComponent: TrackableComponent {
    
    /// :nodoc:
    public func viewDidLoad(viewController: UIViewController) {
        Analytics.sendEvent(component: paymentMethod.type, flavor: _isDropIn ? .dropin : .components, context: apiContext)
        fetchCardPublicKey(discardError: true) { _ in /* Do nothing, to just cache the card public key value */ }
    }
}

extension KCPDetails {

    fileprivate func encrypt(with publicKey: String) throws -> KCPDetails {
        KCPDetails(taxNumber: taxNumber,
                   password: try CardEncryptor.encrypt(password: password, with: publicKey))
    }

}
