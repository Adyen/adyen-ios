//
// Copyright (c) 2022 Adyen N.V.
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
                cardComponentDelegate?.didSubmit(lastFour: publicSuffix, component: self)
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
        // just cache the public key value
        fetchCardPublicKey(notifyingDelegateOnFailure: false)
    }
}

extension KCPDetails {

    fileprivate func encrypt(with publicKey: String) throws -> KCPDetails {
        KCPDetails(taxNumber: taxNumber,
                   password: try CardEncryptor.encrypt(password: password, with: publicKey))
    }

}

internal enum CardBrandSorter {
    
    /// Sorts the brands by the rules below for dual branded cards.
    internal static func sortBrands(_ brands: [CardBrand]) -> [CardBrand] {
        // only try to sort if both brands are available.
        guard brands.count == 2,
              let firstBrand = brands.first,
              let secondBrand = brands.adyen[safeIndex: 1] else { return brands }
        let hasCarteBancaire = brands.contains { $0.type == .carteBancaire }
        let hasVisa = brands.contains { $0.type == .visa }
        let hasPLCC = brands.contains(where: \.isPrivateLabeled)
        
        // these rules on web include checks for BCMC as well
        // but here BCMC component only supports BCMC brand
        // so dual brand won't be visible as the second brand won't be supported
        
        switch (hasVisa, hasCarteBancaire, hasPLCC) {
        // if regular card and dual branding contains Visa & Cartebancaire - ensure Visa is first
        case (true, true, _) where secondBrand.type == .visa:
            return [secondBrand, firstBrand]
        // if regular card and dual branding contains a PLCC this should be shown first
        case (_, _, true) where secondBrand.isPrivateLabeled:
            return [secondBrand, firstBrand]
        default:
            return brands
            
        }
    }
}
