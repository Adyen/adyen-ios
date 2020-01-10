//
// Copyright (c) 2020 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// A component that provides a form for card payments.
public final class CardComponent: PaymentComponent, PresentableComponent, Localizable {
    
    /// Describes the component's UI style.
    public let style: AnyFormComponentStyle
    
    /// Indicates the navigation level style.
    public let navigationStyle: NavigationStyle
    
    /// The card payment method.
    public let paymentMethod: PaymentMethod
    
    /// The delegate of the component.
    public weak var delegate: PaymentComponentDelegate?
    
    /// The supported card types.
    /// The getter is O(n), since it filters out all the `excludedCardTypes` before returning
    public var supportedCardTypes: [CardType] {
        get {
            _supportedCardTypes.filter { !excludedCardTypes.contains($0) }
        }
        
        set {
            _supportedCardTypes = newValue
        }
    }
    
    /// Indicates if the field for entering the holder name should be displayed in the form. Defaults to false.
    public var showsHolderNameField = false
    
    /// Indicates if the field for storing the card payment method should be displayed in the form. Defaults to true.
    public var showsStorePaymentMethodField = true
    
    /// Indicates whether to show the security code field at all.
    internal var showsSecurityCodeField = true
    
    /// Indicates the card brands excluded from the supported brands.
    internal var excludedCardTypes: Set<CardType> = [.bcmc]
    
    private var _supportedCardTypes: [CardType]
    
    /// Initializes the card component.
    ///
    /// - Parameters:
    ///   - paymentMethod: The card payment method.
    ///   - publicKey: The key used for encrypting card data.
    ///   - style: The Component's UI style.
    ///   - navigationStyle: The navigation level style.
    public init(paymentMethod: AnyCardPaymentMethod,
                publicKey: String,
                style: AnyFormComponentStyle = FormComponentStyle(),
                navigationStyle: NavigationStyle = NavigationStyle()) {
        self.paymentMethod = paymentMethod
        self.publicKey = publicKey
        self.style = style
        self._supportedCardTypes = paymentMethod.brands.compactMap(CardType.init)
        self.navigationStyle = navigationStyle
        if !isPublicKeyValid(key: self.publicKey) {
            assertionFailure("Card Public key is invalid, please make sure it’s in the format: {EXPONENT}|{MODULUS}")
        }
    }
    
    private func isPublicKeyValid(key: String) -> Bool {
        let validator = CardPublicKeyValidator()
        return validator.isValid(key)
    }
    
    /// Initializes the card component for stored cards.
    ///
    /// - Parameters:
    ///   - paymentMethod: The stored card payment method.
    ///   - publicKey: The key used for encrypting card data.
    ///   - style: The Component's UI style.
    ///   - navigationStyle: The navigation level style.
    public init(paymentMethod: StoredCardPaymentMethod,
                publicKey: String, style: AnyFormComponentStyle = FormComponentStyle(),
                navigationStyle: NavigationStyle = NavigationStyle()) {
        self.paymentMethod = paymentMethod
        self.publicKey = publicKey
        self._supportedCardTypes = []
        self.style = style
        self.navigationStyle = navigationStyle
    }
    
    // MARK: - Presentable Component Protocol
    
    /// :nodoc:
    public lazy var viewController: UIViewController = {
        Analytics.sendEvent(component: paymentMethod.type, flavor: _isDropIn ? .dropin : .components, environment: environment)
        if let storedCardAlertManager = storedCardAlertManager {
            return storedCardAlertManager.alertController
        } else {
            return ComponentViewController(rootViewController: formViewController,
                                           style: navigationStyle,
                                           cancelButtonHandler: didSelectCancelButton)
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
    public var localizationParameters: LocalizationParameters?
    
    /// :nodoc:
    public func stopLoading(withSuccess success: Bool, completion: (() -> Void)?) {
        footerItem.showsActivityIndicator.value = false
        
        completion?()
    }
    
    // MARK: - Private
    
    private let publicKey: String
    
    private func getEncryptedCard() throws -> CardEncryptor.EncryptedCard {
        let card = CardEncryptor.Card(number: numberItem.value,
                                      securityCode: securityCodeItem.value,
                                      expiryMonth: expiryDateItem.value[0...1],
                                      expiryYear: "20" + expiryDateItem.value[2...3])
        return try CardEncryptor.encryptedCard(for: card, publicKey: publicKey)
    }
    
    private func didSelectSubmitButton() {
        guard formViewController.validate() else {
            return
        }
        
        footerItem.showsActivityIndicator.value = true
        
        do {
            let encryptedCard = try getEncryptedCard()
            let details = CardDetails(paymentMethod: paymentMethod as! AnyCardPaymentMethod, // swiftlint:disable:this force_cast
                                      encryptedCard: encryptedCard,
                                      holderName: holderNameItem?.value)
            
            let data = PaymentComponentData(paymentMethodDetails: details,
                                            storePaymentMethod: storeDetailsItem?.value ?? false)
            
            delegate?.didSubmit(data, from: self)
        } catch {
            delegate?.didFail(with: error, from: self)
        }
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
        manager.localizationParameters = localizationParameters
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
        let formViewController = FormViewController(style: style)
        formViewController.localizationParameters = localizationParameters
        
        let headerItem = FormHeaderItem(style: style.header)
        headerItem.title = paymentMethod.name
        headerItem.identifier = ViewIdentifierBuilder.build(scopeInstance: self, postfix: paymentMethod.name)
        formViewController.append(headerItem)
        formViewController.append(numberItem, using: FormCardNumberItemView.self)
        
        if showsSecurityCodeField {
            let splitTextItem = FormSplitTextItem(items: [expiryDateItem, securityCodeItem], style: style.textField)
            formViewController.append(splitTextItem)
        } else {
            formViewController.append(expiryDateItem)
        }
        
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
        let item = FormCardNumberItem(supportedCardTypes: supportedCardTypes,
                                      environment: environment,
                                      style: style.textField,
                                      localizationParameters: localizationParameters)
        item.identifier = ViewIdentifierBuilder.build(scopeInstance: self, postfix: "numberItem")
        return item
    }()
    
    internal lazy var expiryDateItem: FormTextItem = {
        let expiryDateItem = FormTextItem(style: style.textField)
        expiryDateItem.title = ADYLocalizedString("adyen.card.expiryItem.title", localizationParameters)
        expiryDateItem.placeholder = ADYLocalizedString("adyen.card.expiryItem.placeholder", localizationParameters)
        expiryDateItem.formatter = CardExpiryDateFormatter()
        expiryDateItem.validator = CardExpiryDateValidator()
        expiryDateItem.validationFailureMessage = ADYLocalizedString("adyen.card.expiryItem.invalid", localizationParameters)
        expiryDateItem.keyboardType = .numberPad
        expiryDateItem.identifier = ViewIdentifierBuilder.build(scopeInstance: self, postfix: "expiryDateItem")
        
        return expiryDateItem
    }()
    
    internal lazy var securityCodeItem: FormTextItem = {
        let securityCodeItem = FormTextItem(style: style.textField)
        securityCodeItem.title = ADYLocalizedString("adyen.card.cvcItem.title", localizationParameters)
        securityCodeItem.placeholder = ADYLocalizedString("adyen.card.cvcItem.placeholder", localizationParameters)
        securityCodeItem.formatter = CardSecurityCodeFormatter()
        securityCodeItem.validator = CardSecurityCodeValidator()
        securityCodeItem.validationFailureMessage = ADYLocalizedString("adyen.card.cvcItem.invalid", localizationParameters)
        securityCodeItem.keyboardType = .numberPad
        securityCodeItem.identifier = ViewIdentifierBuilder.build(scopeInstance: self, postfix: "securityCodeItem")
        
        return securityCodeItem
    }()
    
    internal lazy var holderNameItem: FormTextItem? = {
        guard showsHolderNameField else { return nil }
        
        let holderNameItem = FormTextItem(style: style.textField)
        holderNameItem.title = ADYLocalizedString("adyen.card.nameItem.title", localizationParameters)
        holderNameItem.placeholder = ADYLocalizedString("adyen.card.nameItem.placeholder", localizationParameters)
        holderNameItem.validator = LengthValidator(minimumLength: 2)
        holderNameItem.validationFailureMessage = ADYLocalizedString("adyen.card.nameItem.invalid", localizationParameters)
        holderNameItem.autocapitalizationType = .words
        holderNameItem.identifier = ViewIdentifierBuilder.build(scopeInstance: self, postfix: "holderNameItem")
        
        return holderNameItem
    }()
    
    internal lazy var storeDetailsItem: FormSwitchItem? = {
        guard showsStorePaymentMethodField else { return nil }
        
        let storeDetailsItem = FormSwitchItem(style: style.switch)
        storeDetailsItem.title = ADYLocalizedString("adyen.card.storeDetailsButton", localizationParameters)
        storeDetailsItem.identifier = ViewIdentifierBuilder.build(scopeInstance: self, postfix: "storeDetailsItem")
        
        return storeDetailsItem
    }()
    
    internal lazy var footerItem: FormFooterItem = {
        let footerItem = FormFooterItem(style: style.footer)
        footerItem.submitButtonTitle = ADYLocalizedSubmitButtonTitle(with: payment?.amount, localizationParameters)
        footerItem.identifier = ViewIdentifierBuilder.build(scopeInstance: self, postfix: "footer")
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
