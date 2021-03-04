//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
#if canImport(AdyenEncryption)
    import AdyenEncryption
#endif
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
        Analytics.sendEvent(component: paymentMethod.type, flavor: _isDropIn ? .dropin : .components, environment: environment)
        fetchCardPublicKey(onError: { _ in /* Do nothing, to just cache the card public key value */ },
                           completion: { _ in /* Do nothing, to just cache the card public key value */ })
    }

    public func viewDidAppear(formViewController: FormViewController) { /* Not Implemented */ }
}

extension CardComponent {

    /// Card component configuration.
    public struct Configuration {

        /// Indicates if the field for entering the holder name should be displayed in the form. Defaults to false.
        public var showsHolderNameField: Bool

        /// Indicates if the field for storing the card payment method should be displayed in the form. Defaults to true.
        public var showsStorePaymentMethodField: Bool

        /// Indicates whether to show the security code field at all.
        public var showsSecurityCodeField: Bool

        /// Stored card configuration.
        public var stored: StoredCardConfiguration

        /// The supported card types.
        public var supportedCardTypes: [CardType]?

        /// Indicates the card brands excluded from the supported brands.
        internal var excludedCardTypes: Set<CardType> = [.bcmc]

        public init(showsHolderNameField: Bool = false,
                    showsStorePaymentMethodField: Bool = true,
                    showsSecurityCodeField: Bool = true,
                    storedCardConfiguration: StoredCardConfiguration = StoredCardConfiguration(),
                    supportedCardTypes: [CardType]? = nil) {
            self.showsHolderNameField = showsHolderNameField
            self.showsSecurityCodeField = showsSecurityCodeField
            self.showsStorePaymentMethodField = showsStorePaymentMethodField
            self.stored = storedCardConfiguration
            self.supportedCardTypes = supportedCardTypes
        }

        internal func bcmcConfiguration() -> Configuration {
            var storedCardConfiguration = stored
            storedCardConfiguration.showsSecurityCodeField = false
            var configuration = Configuration(showsHolderNameField: showsHolderNameField,
                                              showsStorePaymentMethodField: showsStorePaymentMethodField,
                                              showsSecurityCodeField: false,
                                              storedCardConfiguration: storedCardConfiguration,
                                              supportedCardTypes: [.bcmc])
            configuration.excludedCardTypes = []
            return configuration
        }
    }

}

// swiftlint:enable explicit_acl
