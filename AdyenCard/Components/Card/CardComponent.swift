//
// Copyright (c) 2020 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// Delegate for observing user's activity on `CardComponent`.
public protocol CardComponentDelegate: class {
    
    /// Called when user enters PAN in `CardComponent`.
    /// - Parameter value: Up to 6 first digits in entered PAN.
    /// - Parameter component: The `CardComponent` instance.
    func didChangeBIN(_ value: String, component: CardComponent)
    
    /// Called when `CardComponent` detected card type(s) in entered PAN.
    /// - Parameter value: Array of card types matching entered value. Null - if no data entered.
    /// - Parameter component: The `CardComponent` instance.
    func didChangeCardType(_ value: [CardType]?, component: CardComponent)
}

/// A component that provides a form for card payments.
public final class CardComponent: PaymentComponent, PresentableComponent, Localizable, Observer {
    
    /// Card Component errors.
    public enum Error: Swift.Error {
        /// ClientKey is required for `CardPublicKeyProvider` to work, and this error is thrown in case its nil.
        case missingClientKey
    }
    
    /// Describes the component's UI style.
    public let style: FormComponentStyle
    
    /// The card payment method.
    public let paymentMethod: PaymentMethod
    
    /// The delegate of the component.
    public weak var delegate: PaymentComponentDelegate? {
        didSet {
            storedCardComponent?.delegate = delegate
        }
    }
    
    /// The delegate for user activity on card component.
    public weak var cardComponentDelegate: CardComponentDelegate?
    
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
    
    /// :nodoc:
    public var environment: Environment = .live {
        didSet {
            environment.clientKey = clientKey
            cardPublicKeyProvider.environment = environment
            storedCardComponent?.environment = environment
        }
    }
    
    /// :nodoc:
    public var clientKey: String? {
        didSet {
            environment.clientKey = clientKey
            cardPublicKeyProvider.clientKey = clientKey
            storedCardComponent?.clientKey = clientKey
        }
    }
    
    /// Indicates if the field for entering the holder name should be displayed in the form. Defaults to false.
    public var showsHolderNameField = false
    
    /// Indicates if the field for storing the card payment method should be displayed in the form. Defaults to true.
    public var showsStorePaymentMethodField = true
    
    /// Indicates whether to show the security code field at all.
    public var showsSecurityCodeField = true
    
    /// Indicates if form will show a large header title. True - show title; False - assign title to a view controller's title.
    /// Defaults to true.
    public var showsLargeTitle = true
    
    /// Initializes the card component.
    ///
    /// - Parameters:
    ///   - paymentMethod: The card payment method.
    ///   - publicKey: The key used for encrypting card data.
    ///   - style: The Component's UI style.
    @available(*, deprecated, message: "Use init(paymentMethod:clientKey:style:) instead.")
    public init(paymentMethod: AnyCardPaymentMethod,
                publicKey: String,
                style: FormComponentStyle = FormComponentStyle()) {
        self.paymentMethod = paymentMethod
        self.cardPublicKeyProvider = CardPublicKeyProvider(cardPublicKey: publicKey)
        self.style = style
        self._supportedCardTypes = paymentMethod.brands.compactMap(CardType.init)
        if !isPublicKeyValid(key: publicKey) {
            assertionFailure("Card Public key is invalid, please make sure it’s in the format: {EXPONENT}|{MODULUS}")
        }
    }
    
    /// Initializes the card component for stored cards.
    ///
    /// - Parameters:
    ///   -  paymentMethod: The stored card payment method.
    ///   -  publicKey: The key used for encrypting card data.
    ///   -  style: The Component's UI style.
    @available(*, deprecated, message: "Use init(paymentMethod:clientKey:style:) instead.")
    public init(paymentMethod: StoredCardPaymentMethod,
                publicKey: String,
                style: FormComponentStyle = FormComponentStyle()) {
        self.paymentMethod = paymentMethod
        self.cardPublicKeyProvider = CardPublicKeyProvider(cardPublicKey: publicKey)
        self._supportedCardTypes = []
        self.style = style
        if !isPublicKeyValid(key: publicKey) {
            assertionFailure("Card Public key is invalid, please make sure it’s in the format: {EXPONENT}|{MODULUS}")
        }
    }
    
    internal let cardPublicKeyProvider: CardPublicKeyProvider
    
    /// Initializes the card component.
    ///
    /// - Parameters:
    ///   - paymentMethod: The card payment method.
    ///   -  clientKey: The client key that corresponds to the webservice user you will use for initiating the payment.
    /// See https://docs.adyen.com/user-management/client-side-authentication for more information.
    ///   -  style: The Component's UI style.
    public init(paymentMethod: AnyCardPaymentMethod,
                clientKey: String,
                style: FormComponentStyle = FormComponentStyle()) {
        self.paymentMethod = paymentMethod
        self.cardPublicKeyProvider = CardPublicKeyProvider()
        self._supportedCardTypes = paymentMethod.brands.compactMap(CardType.init)
        self.style = style
        self.clientKey = clientKey
    }
    
    // MARK: - Presentable Component Protocol
    
    /// :nodoc:
    public var viewController: UIViewController {
        if let storedCardComponent = storedCardComponent {
            return storedCardComponent.viewController
        }
        
        return securedViewController
    }
    
    /// :nodoc:
    public var requiresModalPresentation: Bool { storedCardComponent?.requiresModalPresentation ?? true }
    
    /// :nodoc:
    public var localizationParameters: LocalizationParameters?
    
    /// :nodoc:
    public func stopLoading(withSuccess success: Bool, completion: (() -> Void)?) {
        footerItem.showsActivityIndicator = false
        formViewController.view.isUserInteractionEnabled = true
        completion?()
    }
    
    // MARK: - Protected
    
    /// Indicates the card brands excluded from the supported brands.
    internal var excludedCardTypes: Set<CardType> = [.bcmc]
    
    // MARK: - Private
    
    private var _supportedCardTypes: [CardType]
    
    // MARK: - Stored Card
    
    private lazy var storedCardComponent: StoredCardComponent? = {
        guard let paymentMethod = paymentMethod as? StoredCardPaymentMethod else {
            return nil
        }
        return StoredCardComponent(storedCardPaymentMethod: paymentMethod)
    }()
    
    // MARK: - Form Items
    
    private lazy var securedViewController: SecuredViewController = SecuredViewController(child: formViewController, style: style)
    
    internal lazy var formViewController: FormViewController = {
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
        observe(item.$binValue) { [weak self] bin in
            guard let self = self else { return }
            self.cardComponentDelegate?.didChangeBIN(bin, component: self)
        }
        observe(item.$detectedCardTypes) { [weak self] cardTypes in
            guard let self = self else { return }
            self.cardComponentDelegate?.didChangeCardType(cardTypes, component: self)
            self.securityCodeItem.selectedCard = cardTypes?.first
        }
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
        securityCodeItem.localizationParameters = self.localizationParameters
        securityCodeItem.identifier = ViewIdentifierBuilder.build(scopeInstance: self, postfix: "securityCodeItem")
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
