//
// Copyright (c) 2024 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
#if canImport(AdyenEncryption)
    import AdyenEncryption
#endif
import UIKit

internal final class StoredCardAlertManager: NSObject, UITextFieldDelegate, APIContextAware, Localizable {
    
    internal let apiContext: APIContext
    private let paymentMethod: StoredCardPaymentMethod
    private let amount: Amount?

    internal var publicKeyProvider: AnyPublicKeyProvider
    internal var completionHandler: Completion<Result<CardDetails, Error>>?
    internal var localizationParameters: LocalizationParameters?
    
    internal init(paymentMethod: StoredCardPaymentMethod,
                  apiContext: APIContext,
                  amount: Amount?) {
        self.apiContext = apiContext
        self.paymentMethod = paymentMethod
        self.amount = amount
        
        self.publicKeyProvider = PublicKeyProvider(apiContext: apiContext)
    }

    // MARK: - Alert Controller
        
    internal private(set) lazy var alertController: UIAlertController = {
        let title = localizedString(.cardStoredTitle, localizationParameters)
        let displayInformation = paymentMethod.localizedDisplayInformation(using: localizationParameters)
        let message = localizedString(.cardStoredMessage, localizationParameters, displayInformation.title)
        
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addTextField(configurationHandler: { [weak self] textField in
            guard let self else { return }
            textField.textAlignment = .center
            textField.keyboardType = .numberPad
            textField.placeholder = localizedString(.cardCvcItemPlaceholder, self.localizationParameters)
            textField.accessibilityLabel = localizedString(.cardCvcItemTitle, self.localizationParameters)
            textField.accessibilityIdentifier = "AdyenCard.StoredCardAlertManager.textField"
            textField.delegate = self
            textField.addTarget(self, action: #selector(self.textDidChange(textField:)), for: .editingChanged)
        })
        
        let cancelActionTitle = localizedString(.cancelButton, localizationParameters)
        let cancelAction = UIAlertAction(title: cancelActionTitle, style: .cancel) { [weak self] _ in
            self?.completionHandler?(.failure(ComponentError.cancelled))
            self?.resetAlertFields()
        }
        alertController.addAction(cancelAction)
        
        alertController.addAction(submitAction)
        
        return alertController
    }()
    
    private lazy var submitAction: UIAlertAction = {
        let actionTitle = localizedSubmitButtonTitle(with: amount,
                                                     style: .immediate,
                                                     localizationParameters)
        let action = UIAlertAction(title: actionTitle, style: .default) { [unowned self] _ in
            self.submit()
        }
        action.isEnabled = false
        return action
    }()
    
    private func submit() {
        guard let textField = alertController.textFields?.first, let securityCode = textField.text else {
            return
        }
        
        fetchCardPublicKey { [weak self] in
            self?.submit(securityCode: securityCode, cardPublicKey: $0)
            self?.resetAlertFields()
        }
    }
    
    private func resetAlertFields() {
        alertController.textFields?.first?.text = nil
        submitAction.isEnabled = false
    }
    
    private typealias CardKeyCompletion = (_ cardPublicKey: String) -> Void
    
    private func fetchCardPublicKey(successHandler: @escaping CardKeyCompletion) {
        publicKeyProvider.fetch { [weak self] in
            self?.handle(result: $0, successHandler: successHandler)
        }
    }
    
    private func handle(result: Result<String, Error>, successHandler: CardKeyCompletion) {
        switch result {
        case let .success(key):
            successHandler(key)
        case let .failure(error):
            completionHandler?(.failure(error))
        }
    }
    
    private func submit(securityCode: String, cardPublicKey: String) {
        do {
            let encryptedSecurityCode = try CardEncryptor.encrypt(securityCode: securityCode, with: cardPublicKey)
            let details = CardDetails(paymentMethod: paymentMethod, encryptedSecurityCode: encryptedSecurityCode)
            completionHandler?(.success(details))
        } catch {
            completionHandler?(.failure(error))
        }
    }
    
    // MARK: - UITextFieldDelegate
    
    @objc
    private func textDidChange(textField: UITextField) {
        guard var text = textField.text else { return }
        
        let formatter = CardSecurityCodeFormatter(cardType: .init(rawValue: paymentMethod.brand))
        let validator = CardSecurityCodeValidator(cardType: .init(rawValue: paymentMethod.brand))
        
        text = formatter.formattedValue(for: text)
        
        textField.text = text
        submitAction.isEnabled = validator.isValid(text)
    }
}
