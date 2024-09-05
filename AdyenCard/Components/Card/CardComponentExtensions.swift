//
// Copyright (c) 2024 Adyen N.V.
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

            let details = CardDetails(
                paymentMethod: cardPaymentMethod,
                encryptedCard: encryptedCard,
                holderName: card.holder,
                selectedBrand: cardViewController.selectedBrand,
                billingAddress: cardViewController.validAddress,
                kcpDetails: kcpDetails,
                socialSecurityNumber: cardViewController.socialSecurityNumber
            )
            
            let data = PaymentComponentData(
                paymentMethodDetails: details,
                amount: payment?.amount,
                order: order,
                storePaymentMethod: cardViewController.storePayment,
                installments: cardViewController.installments
            )
            
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
extension CardComponent: TrackableComponent {
    
    public func sendDidLoadEvent() {
        var infoEvent = AnalyticsEventInfo(component: paymentMethod.type.rawValue, type: .rendered)
        infoEvent.isStoredPaymentMethod = (paymentMethod is StoredPaymentMethod) ? true : nil
        infoEvent.brand = (paymentMethod as? StoredCardPaymentMethod)?.brand.rawValue
        infoEvent.configData = CardAnalyticsConfiguration(configuration: configuration)
        context.analyticsProvider?.add(info: infoEvent)
    }
}

@_spi(AdyenInternal)
extension CardComponent: ViewControllerDelegate {

    public func viewDidLoad(viewController: UIViewController) {
        sendInitialAnalytics()
        sendDidLoadEvent()
        // just cache the public key value
        fetchCardPublicKey(notifyingDelegateOnFailure: false)
    }
}

extension KCPDetails {

    fileprivate func encrypt(with publicKey: String) throws -> KCPDetails {
        try KCPDetails(
            taxNumber: taxNumber,
            password: CardEncryptor.encrypt(password: password, with: publicKey)
        )
    }

}
