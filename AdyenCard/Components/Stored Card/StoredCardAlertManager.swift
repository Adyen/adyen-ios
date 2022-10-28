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
    
    // MARK: - CVC length

    private var cvvLength: Int {
        switch CardType(rawValue: paymentMethod.brand) {
        case .americanExpress:
            return 4
        default:
            return 3
        }
    }

    // MARK: - Alert Controller
    
    internal private(set) lazy var alertController: UIAlertController = {
        let title = localizedString(.cardStoredTitle, localizationParameters)
        let displayInformation = paymentMethod.localizedDisplayInformation(using: localizationParameters)
        let message = localizedString(.cardStoredMessage, localizationParameters, displayInformation.title)
        
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addTextField(configurationHandler: { [weak self] textField in
            textField.textAlignment = .center
            textField.keyboardType = .numberPad
            textField.placeholder = localizedString(.cardCvcItemPlaceholder, self?.localizationParameters)
            textField.accessibilityLabel = localizedString(.cardCvcItemTitle, self?.localizationParameters)
            textField.accessibilityIdentifier = "AdyenCard.StoredCardAlertManager.textField"
            textField.delegate = self
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
    
    internal func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let textFieldText = textField.text else {
            return false
        }
        
        let newString = (textFieldText as NSString).replacingCharacters(in: range, with: string)
        if newString.count > cvvLength {
            return false
        }
        
        defer {
            let isValidLength = newString.count == cvvLength
            submitAction.isEnabled = isValidLength
        }
        
        let isDeleting = (string.count == 0 && range.length == 1)
        if isDeleting {
            return true
        }
        
        let newCharacters = CharacterSet(charactersIn: string)
        let isNumber = CharacterSet.decimalDigits.isSuperset(of: newCharacters)
        if isNumber {
            return true
        }
        
        return false
    }
    
}
