//
// Copyright (c) 2020 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import Foundation

// swiftlint:disable explicit_acl

internal extension CardComponent {
    
    func isPublicKeyValid(key: String) -> Bool {
        let validator = CardPublicKeyValidator()
        return validator.isValid(key)
    }
    
    private func getEncryptedCard(publicKey: String) throws -> CardEncryptor.EncryptedCard {
        let card = CardEncryptor.Card(number: numberItem.value,
                                      securityCode: securityCodeItem.value,
                                      expiryMonth: expiryDateItem.value[0...1],
                                      expiryYear: "20" + expiryDateItem.value[2...3])
        return try CardEncryptor.encryptedCard(for: card, publicKey: publicKey)
    }
    
    func didSelectSubmitButton() {
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
            let details = CardDetails(paymentMethod: paymentMethod as! AnyCardPaymentMethod, // swiftlint:disable:this force_cast
                                      encryptedCard: encryptedCard,
                                      holderName: showsHolderNameField ? holderNameItem.value : nil)
            
            let data = PaymentComponentData(paymentMethodDetails: details,
                                            storePaymentMethod: showsStorePaymentMethodField ? storeDetailsItem.value : false,
                                            billingAddress: AddressInfo(postalCode: postalCodeItem.value))
            
            submit(data: data)
        } catch {
            delegate?.didFail(with: error, from: self)
        }
    }
}

extension CardComponent {
    typealias CardKeySuccessHandler = (_ cardPublicKey: String) -> Void
    
    typealias CardKeyFailureHandler = (_ error: Swift.Error) -> Void
    
    func fetchCardPublicKey(onError: CardKeyFailureHandler? = nil, completion: @escaping CardKeySuccessHandler) {
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
extension CardComponent: FormViewControllerDelegate {
    
    /// :nodoc:
    public func viewDidLoad(formViewController: FormViewController) {
        fetchCardPublicKey(onError: { _ in /* Do nothing, to just cache the card public key value */ },
                           completion: { _ in /* Do nothing, to just cache the card public key value */ })
    }
}

/// :nodoc:
/// Deprecated initializers
public extension CardComponent {
    
    /// Initializes the card component.
    ///
    /// - Parameters:
    ///   - paymentMethod: The card payment method.
    ///   - publicKey: The key used for encrypting card data.
    ///   - style: The Component's UI style.
    @available(*, deprecated, message: "Use init(paymentMethod:clientKey:style:) instead.")
    convenience init(paymentMethod: AnyCardPaymentMethod,
                     publicKey: String,
                     style: FormComponentStyle = FormComponentStyle()) {
        let cardPublicKeyProvider = CardPublicKeyProvider(cardPublicKey: publicKey)
        self.init(paymentMethod: paymentMethod, cardPublicKeyProvider: cardPublicKeyProvider, style: style)
        if !isPublicKeyValid(key: publicKey) {
            assertionFailure("Card Public key is invalid, please make sure it’s in the format: {EXPONENT}|{MODULUS}")
        }
    }
    
    /// :nodoc:
    /// Initializes the card component.
    ///
    /// - Parameters:
    ///   - paymentMethod: The card payment method.
    ///   - cardPublicKeyProvider: The card public key provider
    ///   - style: The Component's UI style.
    static func component(paymentMethod: AnyCardPaymentMethod,
                          publicKey: String,
                          style: FormComponentStyle = FormComponentStyle()) -> CardComponent {
        let cardPublicKeyProvider = CardPublicKeyProvider(cardPublicKey: publicKey)
        return CardComponent(paymentMethod: paymentMethod, cardPublicKeyProvider: cardPublicKeyProvider, style: style)
    }
}

// swiftlint:enable explicit_acl
