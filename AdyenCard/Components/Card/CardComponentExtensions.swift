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
    
    internal func isPublicKeyValid(key: String) -> Bool {
        let validator = CardPublicKeyValidator()
        return validator.isValid(key)
    }
    
    private func getEncryptedCard(publicKey: String) throws -> EncryptedCard {
        let card = Card(number: numberItem.value,
                        securityCode: configuration.showsSecurityCodeField ? securityCodeItem.nonEmptyValue : nil,
                        expiryMonth: expiryDateItem.value[0...1],
                        expiryYear: "20" + expiryDateItem.value[2...3],
                        holder: configuration.showsHolderNameField ? holderNameItem.nonEmptyValue : nil)
        return try CardEncryptor.encrypt(card: card, with: publicKey)
    }
    
    internal func didSelectSubmitButton() {
        guard formViewController.validate() else {
            return
        }
        
        button.showsActivityIndicator = true
        formViewController.view.isUserInteractionEnabled = false
        
        fetchCardPublicKey { [weak self] in
            self?.submitEncryptedCardData(cardPublicKey: $0)
        }
    }
    
    private func submitEncryptedCardData(cardPublicKey: String) {
        do {
            let encryptedCard = try getEncryptedCard(publicKey: cardPublicKey)
            let details = CardDetails(paymentMethod: cardPaymentMethod,
                                      encryptedCard: encryptedCard,
                                      holderName: configuration.showsHolderNameField ? holderNameItem.value : nil)
            
            let data = PaymentComponentData(paymentMethodDetails: details,
                                            storePaymentMethod: configuration.showsStorePaymentMethodField ? storeDetailsItem.value : false)
            
            submit(data: data)
        } catch {
            delegate?.didFail(with: error, from: self)
        }
    }
}

extension CardComponent {
    typealias CardKeySuccessHandler = (_ cardPublicKey: String) -> Void
    
    typealias CardKeyFailureHandler = (_ error: Swift.Error) -> Void
    
    internal func fetchCardPublicKey(onError: CardKeyFailureHandler? = nil, completion: @escaping CardKeySuccessHandler) {
        do {
            try cardPublicKeyProvider.fetch { [weak self] in
                self?.handle(result: $0, onError: onError, completion: completion)
            }
        } catch {
            if let onError = onError {
                onError(error)
            } else {
                delegate?.didFail(with: error, from: self)
            }
        }
    }
    
    private func handle(result: Result<String, Swift.Error>, onError: CardKeyFailureHandler? = nil, completion: CardKeySuccessHandler) {
        switch result {
        case let .success(key):
            completion(key)
        case let .failure(error):
            if let onError = onError {
                onError(error)
            } else {
                delegate?.didFail(with: error, from: self)
            }
        }
    }
}

/// :nodoc:
extension CardComponent: TrackableComponent {
    
    /// :nodoc:
    public func viewDidLoad(viewController: UIViewController) {
        Analytics.sendEvent(component: paymentMethod.type, flavor: _isDropIn ? .dropin : .components, environment: environment)
        fetchCardPublicKey(onError: { _ in /* Do nothing, to just cache the card public key value */ },
                           completion: { _ in /* Do nothing, to just cache the card public key value */ })
    }
}

private extension FormValueItem where ValueType == String {
    var nonEmptyValue: String? {
        self.value.isEmpty ? nil : self.value
    }
}
