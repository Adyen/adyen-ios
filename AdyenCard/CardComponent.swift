//
// Copyright (c) 2020 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// A component that provides a form for card payments.
public final class CardComponent: PaymentComponent, PresentableComponent, Localizable {
    
    /// Describes the component's UI style.
    public let style: FormComponentStyle
    
    /// The card payment method.
    public let paymentMethod: PaymentMethod
    
    /// The delegate of the component.
    public weak var delegate: PaymentComponentDelegate?
    
    /// The supported card types.
    /// The getter is O(n), since it filters out all the `excludedCardTypes` before returning.
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
    
    /// Indicates if form will show a large header title. True - show title; False - assign title to a view controller's title.
    /// Defaults to true.
    public var showsLargeTitle = true
    
    /// Initializes the card component.
    ///
    /// - Parameters:
    ///   - paymentMethod: The card payment method.
    ///   - publicKey: The key used for encrypting card data.
    ///   - style: The Component's UI style.
    public init(paymentMethod: AnyCardPaymentMethod,
                publicKey: String,
                style: FormComponentStyle = FormComponentStyle()) {
        self.paymentMethod = paymentMethod
        self.publicKey = publicKey
        self.style = style
        self._supportedCardTypes = paymentMethod.brands.compactMap(CardType.init)
        if !isPublicKeyValid(key: self.publicKey) {
            assertionFailure("Card Public key is invalid, please make sure it’s in the format: {EXPONENT}|{MODULUS}")
        }
    }
    
    /// Initializes the card component for stored cards.
    ///
    /// - Parameters:
    ///   -  paymentMethod: The stored card payment method.
    ///   -  publicKey: The key used for encrypting card data.
    ///   -  style: The Component's UI style.
    public init(paymentMethod: StoredCardPaymentMethod,
                publicKey: String,
                style: FormComponentStyle = FormComponentStyle()) {
        self.paymentMethod = paymentMethod
        self.publicKey = publicKey
        self._supportedCardTypes = []
        self.style = style
    }
    
    // MARK: - Presentable Component Protocol
    
    /// :nodoc:
    public var viewController: UIViewController {
        if let storedCardAlertManager = storedCardAlertManager {
            return storedCardAlertManager.alertController
        }
        
        return formViewController
    }
    
    /// :nodoc:
    public var requiresModalPresentation: Bool { storedCardAlertManager == nil }
    
    /// :nodoc:
    public var localizationParameters: LocalizationParameters?
    
    /// :nodoc:
    public func stopLoading(withSuccess success: Bool, completion: (() -> Void)?) {
        footerItem.showsActivityIndicator.value = false
        formViewController.view.isUserInteractionEnabled = true
        completion?()
    }
    
    // MARK: - Protected
    
    /// Indicates whether to show the security code field at all.
    internal var showsSecurityCodeField = true
    
    /// Indicates the card brands excluded from the supported brands.
    internal var excludedCardTypes: Set<CardType> = [.bcmc]
    
    // MARK: - Private
    
    private var _supportedCardTypes: [CardType]
    
    private func isPublicKeyValid(key: String) -> Bool {
        let validator = CardPublicKeyValidator()
        return validator.isValid(key)
    }
    
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
        formViewController.view.isUserInteractionEnabled = false
        
        do {
            let encryptedCard = try getEncryptedCard()
            let details = CardDetails(paymentMethod: paymentMethod as! AnyCardPaymentMethod, // swiftlint:disable:this force_cast
                                      encryptedCard: encryptedCard,
                                      holderName: showsHolderNameField ? holderNameItem.value : nil)
            
            let data = PaymentComponentData(paymentMethodDetails: details,
                                            storePaymentMethod: showsStorePaymentMethodField ? storeDetailsItem.value : false)
            
            submit(data: data)
        } catch {
            delegate?.didFail(with: error, from: self)
        }
    }
    
    // MARK: - Stored Card
    
    private lazy var storedCardAlertManager: StoredCardAlertManager? = {
        guard let paymentMethod = paymentMethod as? StoredCardPaymentMethod else {
            return nil
        }
        
        Analytics.sendEvent(component: paymentMethod.type, flavor: _isDropIn ? .dropin : .components, environment: environment)
        let manager = StoredCardAlertManager(paymentMethod: paymentMethod, publicKey: publicKey, amount: payment?.amount)
        manager.localizationParameters = localizationParameters
        manager.completionHandler = { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case let .success(details):
                self.submit(data: PaymentComponentData(paymentMethodDetails: details))
            case let .failure(error):
                self.delegate?.didFail(with: error, from: self)
            }
        }
        
        return manager
    }()
    
    // MARK: - Form Items
    
    private lazy var formViewController: FormViewController = {
        Analytics.sendEvent(component: paymentMethod.type, flavor: _isDropIn ? .dropin : .components, environment: environment)
        
        let formViewController = FormViewController(style: style)
        formViewController.localizationParameters = localizationParameters
        
        if showsLargeTitle {
            let headerItem = FormHeaderItem(style: style.header)
            headerItem.title = paymentMethod.name
            headerItem.identifier = ViewIdentifierBuilder.build(scopeInstance: self, postfix: paymentMethod.name)
            formViewController.append(headerItem)
        } else {
            formViewController.title = paymentMethod.name
        }
        
        formViewController.append(numberItem)
        
        if showsSecurityCodeField {
            let splitTextItem = FormSplitTextItem(items: [expiryDateItem, securityCodeItem], style: style.textField)
            formViewController.append(splitTextItem)
        } else {
            formViewController.append(expiryDateItem)
        }
        
        if showsHolderNameField {
            formViewController.append(holderNameItem)
        }
        
        if showsStorePaymentMethodField {
            formViewController.append(storeDetailsItem)
        }
        
        formViewController.append(footerItem)
        
        return formViewController
    }()
    
    internal lazy var numberItem: FormCardNumberItem = {
        let item = FormCardNumberItem(supportedCardTypes: supportedCardTypes,
                                      environment: environment,
                                      style: style.textField,
                                      localizationParameters: localizationParameters)
        item.identifier = ViewIdentifierBuilder.build(scopeInstance: self, postfix: "numberItem")
        return item
    }()
    
    internal lazy var expiryDateItem: FormTextInputItem = {
        let expiryDateItem = FormTextInputItem(style: style.textField)
        expiryDateItem.title = ADYLocalizedString("adyen.card.expiryItem.title", localizationParameters)
        expiryDateItem.placeholder = ADYLocalizedString("adyen.card.expiryItem.placeholder", localizationParameters)
        expiryDateItem.formatter = CardExpiryDateFormatter()
        expiryDateItem.validator = CardExpiryDateValidator()
        expiryDateItem.validationFailureMessage = ADYLocalizedString("adyen.card.expiryItem.invalid", localizationParameters)
        expiryDateItem.keyboardType = .numberPad
        expiryDateItem.identifier = ViewIdentifierBuilder.build(scopeInstance: self, postfix: "expiryDateItem")
        
        return expiryDateItem
    }()
    
    internal lazy var securityCodeItem: FormCardSecurityCodeItem = {
        let securityCodeItem = FormCardSecurityCodeItem(environment: environment,
                                                        style: style.textField,
                                                        localizationParameters: localizationParameters)
        securityCodeItem.identifier = ViewIdentifierBuilder.build(scopeInstance: self, postfix: "securityCodeItem")
        numberItem.delegate = securityCodeItem
        return securityCodeItem
    }()
    
    internal lazy var holderNameItem: FormTextInputItem = {
        let holderNameItem = FormTextInputItem(style: style.textField)
        holderNameItem.title = ADYLocalizedString("adyen.card.nameItem.title", localizationParameters)
        holderNameItem.placeholder = ADYLocalizedString("adyen.card.nameItem.placeholder", localizationParameters)
        holderNameItem.validator = LengthValidator(minimumLength: 2)
        holderNameItem.validationFailureMessage = ADYLocalizedString("adyen.card.nameItem.invalid", localizationParameters)
        holderNameItem.autocapitalizationType = .words
        holderNameItem.identifier = ViewIdentifierBuilder.build(scopeInstance: self, postfix: "holderNameItem")
        
        return holderNameItem
    }()
    
    internal lazy var storeDetailsItem: FormSwitchItem = {
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
