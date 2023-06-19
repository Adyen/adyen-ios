//
// Copyright (c) 2023 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) import Adyen
#if canImport(AdyenEncryption)
    import AdyenEncryption
#endif
#if canImport(AdyenAuthentication)
    import AdyenAuthentication
#endif
import UIKit

extension CardComponent {
    
    internal func didSelectSubmitButton() {
        guard cardViewController.validate() else {
            return
        }
        
        cardViewController.startLoading()

        fetchCardPublicKey(notifyingDelegateOnFailure: true) { [weak self] in
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
                                      selectedBrand: cardViewController.selectedBrand,
                                      billingAddress: cardViewController.validAddress,
                                      kcpDetails: kcpDetails,
                                      socialSecurityNumber: cardViewController.socialSecurityNumber)
            
            let data = PaymentComponentData(paymentMethodDetails: details,
                                            amount: payment?.amount,
                                            order: order,
                                            storePaymentMethod: cardViewController.storePayment,
                                            installments: cardViewController.installments)
            
            if let number = card.number {
                let publicSuffix = String(number.suffix(Constant.publicPanSuffixLength))
                cardComponentDelegate?.didSubmit(lastFour: publicSuffix, finalBIN: cardViewController.cardBIN, component: self)
            }

            submit(data: data)
        } catch {
            delegate?.didFail(with: error, from: self)
        }
    }
}

@_spi(AdyenInternal)
extension CardComponent: TrackableComponent {}

@_spi(AdyenInternal)
extension CardComponent: ViewControllerDelegate {

    public func viewDidLoad(viewController: UIViewController) {
        Analytics.sendEvent(component: paymentMethod.type.rawValue,
                            flavor: _isDropIn ? .dropin : .components,
                            context: context.apiContext)
        // just cache the public key value
        fetchCardPublicKey(notifyingDelegateOnFailure: false)
    }

    public func viewWillAppear(viewController: UIViewController) {
        sendTelemetryEvent()
    }
}

extension KCPDetails {

    fileprivate func encrypt(with publicKey: String) throws -> KCPDetails {
        try KCPDetails(taxNumber: taxNumber,
                       password: CardEncryptor.encrypt(password: password, with: publicKey))
    }

}
