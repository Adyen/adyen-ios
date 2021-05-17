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

    /// Card Component errors.
    public enum Error: Swift.Error {
        /// ClientKey is required for `CardPublicKeyProvider` to work, and this error is thrown in case its nil.
        case missingClientKey
    }
}

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
            let details = CardDetails(paymentMethod: cardPaymentMethod,
                                      encryptedCard: encryptedCard,
                                      holderName: card.holder,
                                      billingAddress: cardViewController.address)
            
            let data = PaymentComponentData(paymentMethodDetails: details,
                                            amount: payment?.amount,
                                            storePaymentMethod: cardViewController.storePayment)

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
        Analytics.sendEvent(component: paymentMethod.type, flavor: _isDropIn ? .dropin : .components, environment: environment)
        fetchCardPublicKey(discardError: true) { _ in /* Do nothing, to just cache the card public key value */ }
    }
}

/// :nodoc:
extension CardComponent {
    internal typealias CardKeySuccessHandler = (_ cardPublicKey: String) -> Void

    internal func fetchCardPublicKey(discardError: Bool, completion: @escaping CardKeySuccessHandler) {
        cardPublicKeyProvider.fetch { [weak self] in
            self?.handle(result: $0, discardError: discardError, completion: completion)
        }
    }

    private func handle(result: Result<String, Swift.Error>,
                        discardError: Bool,
                        completion: CardKeySuccessHandler) {
        switch result {
        case let .success(key):
            completion(key)
        case let .failure(error):
            if !discardError {
                delegate?.didFail(with: error, from: self)
            }
        }
    }
}
