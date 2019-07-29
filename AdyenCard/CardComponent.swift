//
// Copyright (c) 2019 Adyen B.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// A component that provides a form for card payments.
public final class CardComponent: PaymentComponent, PresentableComponent {
    
    /// The card payment method.
    public let paymentMethod: PaymentMethod
    
    /// The delegate of the component.
    public weak var delegate: PaymentComponentDelegate?
    
    /// The supported card types.
    public var supportedCardTypes: [CardType]
    
    /// Indicates if the field for entering the holder name should be displayed in the form. Defaults to false.
    public var showsHolderNameField = false
    
    /// Indicates if the field for storing the card payment method should be displayed in the form. Defaults to true.
    public var showsStorePaymentMethodField = true
    
    /// Initializes the card component.
    ///
    /// - Parameters:
    ///   - paymentMethod: The card payment method.
    ///   - publicKey: The key used for encrypting card data.
    public init(paymentMethod: CardPaymentMethod, publicKey: String) {
        self.paymentMethod = paymentMethod
        self.publicKey = publicKey
        self.supportedCardTypes = paymentMethod.brands.compactMap(CardType.init)
    }
    
    /// Initializes the card component for stored cards.
    ///
    /// - Parameters:
    ///   - paymentMethod: The stored card payment method.
    ///   - publicKey: The key used for encrypting card data.
    public init(paymentMethod: StoredCardPaymentMethod, publicKey: String) {
        self.paymentMethod = paymentMethod
        self.publicKey = publicKey
        self.supportedCardTypes = []
    }
    
    // MARK: - Presentable Component Protocol
    
    /// :nodoc:
    public lazy var viewController: UIViewController = {
        Analytics.sendEvent(component: paymentMethod.type, flavor: _isDropIn ? .dropin : .components, environment: environment)
        if let storedCardAlertManager = storedCardAlertManager {
            return storedCardAlertManager.alertController
        } else {
            return ComponentViewController(rootViewController: formViewController, cancelButtonHandler: didSelectCancelButton)
        }
    }()
    
    /// :nodoc:
    public var preferredPresentationMode: PresentableComponentPresentationMode {
        if storedCardAlertManager != nil {
            return .present
        } else {
            return .push
        }
    }
    
    /// :nodoc:
    public func stopLoading(withSuccess success: Bool, completion: (() -> Void)?) {
        footerItem.showsActivityIndicator.value = false
        
        completion?()
    }
    
    // MARK: - Private
    
    private let publicKey: String
    
    private var encryptedCard: CardEncryptor.EncryptedCard {
        let card = CardEncryptor.Card(number: numberItem.value,
                                      securityCode: securityCodeItem.value,
                                      expiryMonth: expiryDateItem.value[0...1],
                                      expiryYear: "20" + expiryDateItem.value[2...3])
        return CardEncryptor.encryptedCard(for: card, publicKey: publicKey)
    }
    
    private func didSelectSubmitButton() {
        guard formViewController.validate() else {
            return
        }
        
        footerItem.showsActivityIndicator.value = true
        
        let details = CardDetails(paymentMethod: paymentMethod as! CardPaymentMethod, // swiftlint:disable:this force_cast
                                  encryptedCard: encryptedCard,
                                  holderName: holderNameItem?.value)
        
        let data = PaymentComponentData(paymentMethodDetails: details,
                                        storePaymentMethod: storeDetailsItem?.value ?? false)
        
        delegate?.didSubmit(data, from: self)
    }
    
    private lazy var didSelectCancelButton: (() -> Void) = { [weak self] in
        guard let self = self else { return }
        
        self.delegate?.didFail(with: ComponentError.cancelled, from: self)
    }
    
    // MARK: - Stored Card
    
    private lazy var storedCardAlertManager: StoredCardAlertManager? = {
        guard let paymentMethod = paymentMethod as? StoredCardPaymentMethod else {
            return nil
        }
        
        let manager = StoredCardAlertManager(paymentMethod: paymentMethod, publicKey: publicKey, amount: payment?.amount)
        manager.completionHandler = { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case let .success(details):
                self.delegate?.didSubmit(PaymentComponentData(paymentMethodDetails: details), from: self)
            case let .failure(error):
                self.delegate?.didFail(with: error, from: self)
            }
        }
        
        return manager
    }()
    
    // MARK: - Form Items
    
    private lazy var formViewController: FormViewController = {
        let formViewController = FormViewController()
        
        let headerItem = FormHeaderItem()
        headerItem.title = paymentMethod.name
        formViewController.append(headerItem)
        formViewController.append(numberItem, using: FormCardNumberItemView.self)
        
        let splitTextItem = FormSplitTextItem(items: [expiryDateItem, securityCodeItem])
        formViewController.append(splitTextItem)
        
        if let holderNameItem = holderNameItem {
            formViewController.append(holderNameItem)
        }
        
        if let storeDetailsItem = storeDetailsItem {
            formViewController.append(storeDetailsItem)
        }
        
        formViewController.append(footerItem)
        
        return formViewController
    }()
    
    private lazy var numberItem: FormCardNumberItem = {
        FormCardNumberItem(supportedCardTypes: supportedCardTypes, environment: environment)
    }()
    
    private lazy var expiryDateItem: FormTextItem = {
        let expiryDateItem = FormTextItem()
        expiryDateItem.title = ADYLocalizedString("adyen.card.expiryItem.title")
        expiryDateItem.placeholder = ADYLocalizedString("adyen.card.expiryItem.placeholder")
        expiryDateItem.formatter = CardExpiryDateFormatter()
        expiryDateItem.validator = CardExpiryDateValidator()
        expiryDateItem.validationFailureMessage = ADYLocalizedString("adyen.card.expiryItem.invalid")
        expiryDateItem.keyboardType = .numberPad
        
        return expiryDateItem
    }()
    
    private lazy var securityCodeItem: FormTextItem = {
        let securityCodeItem = FormTextItem()
        securityCodeItem.title = ADYLocalizedString("adyen.card.cvcItem.title")
        securityCodeItem.placeholder = ADYLocalizedString("adyen.card.cvcItem.placeholder")
        securityCodeItem.formatter = CardSecurityCodeFormatter()
        securityCodeItem.validator = CardSecurityCodeValidator()
        securityCodeItem.validationFailureMessage = ADYLocalizedString("adyen.card.cvcItem.invalid")
        securityCodeItem.keyboardType = .numberPad
        
        return securityCodeItem
    }()
    
    private lazy var holderNameItem: FormTextItem? = {
        guard showsHolderNameField else { return nil }
        
        let holderNameItem = FormTextItem()
        holderNameItem.title = ADYLocalizedString("adyen.card.nameItem.title")
        holderNameItem.placeholder = ADYLocalizedString("adyen.card.nameItem.placeholder")
        holderNameItem.validator = LengthValidator(minimumLength: 2)
        holderNameItem.validationFailureMessage = ADYLocalizedString("adyen.card.nameItem.invalid")
        holderNameItem.autocapitalizationType = .words
        
        return holderNameItem
    }()
    
    private lazy var storeDetailsItem: FormSwitchItem? = {
        guard showsStorePaymentMethodField else { return nil }
        
        let storeDetailsItem = FormSwitchItem()
        storeDetailsItem.title = ADYLocalizedString("adyen.card.storeDetailsButton")
        
        return storeDetailsItem
    }()
    
    private lazy var footerItem: FormFooterItem = {
        let footerItem = FormFooterItem()
        footerItem.submitButtonTitle = ADYLocalizedSubmitButtonTitle(with: payment?.amount)
        footerItem.submitButtonSelectionHandler = { [weak self] in
            self?.didSelectSubmitButton()
        }
        return footerItem
    }()
    
}

public extension CardComponent {
    
    /// :nodoc:
    @available(*, deprecated, renamed: "showsHolderNameField")
    var showsHolderName: Bool {
        set {
            showsHolderNameField = newValue
        }
        get {
            return showsHolderNameField
        }
    }
}
