//
// Copyright (c) 2020 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
@_spi(AdyenInternal) import protocol Adyen.PaymentComponent
#if canImport(AdyenEncryption)
    import AdyenEncryption
#endif
#if canImport(AdyenAuthentication)
    import AdyenAuthentication
#endif
#if canImport(AdyenUI)
    import AdyenUI
    @_spi(AdyenInternal) import class AdyenUI.FormViewController
#endif
import UIKit

extension CardComponent {
    
    internal func didSelectSubmitButton() {
        guard cardViewController.validate() else {
            return
        }
        
        cardViewController.startLoading()
        submitEncryptedCardData(cardPublicKey: context.publicKey)
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
                amount: context.amount,
                order: order,
                storePaymentMethod: cardViewController.storePayment,
                installments: cardViewController.installments
            )
            
            if let number = card.number {
                let publicSuffix = String(number.suffix(Constant.publicPanSuffixLength))
                // TODO: Implement onFieldValidationChange closure to provide last four digits and final BIN.
                // This will replace the removed CardComponentDelegate.didSubmit(lastFour:finalBIN:component:) method.
            }

            submit(data: data)
        } catch {
            sendEncryptionErrorEvent()
            delegate?.didFail(with: error, from: self)
        }
    }
    
    private func sendEncryptionErrorEvent() {
        var errorEvent = AnalyticsEventError(
            component: paymentMethod.type.rawValue,
            type: .internal
        )
        errorEvent.code = AnalyticsConstants.ErrorCode.encryptionError.stringValue
        context.analyticsProvider?.add(error: errorEvent)
    }
}

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
