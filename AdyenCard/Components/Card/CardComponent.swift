//
// Copyright (c) 2020 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import Foundation
import UIKit

/// Delegate for observing user's activity on `CardComponent`.
public protocol CardComponentDelegate: AnyObject {
    
    /// Called when user enters PAN in `CardComponent`.
    /// - Parameter value: Up to 6 first digits in entered PAN.
    /// - Parameter component: The `CardComponent` instance.
    func didChangeBIN(_ value: String, component: CardComponent)
    
    /// Called when `CardComponent` detected card type(s) in entered PAN.
    /// - Parameter value: Array of card types matching entered value. Null - if no data entered.
    /// - Parameter component: The `CardComponent` instance.
    func didChangeCardType(_ value: [CardType]?, component: CardComponent)
}

/// Stored card configuration.
public struct StoredCardConfiguration {

    /// Indicates whether to show the security code field.
    public var showsSecurityCodeField = true

    /// :nodoc:
    public init() { /* empty init */ }
}

/// A component that provides a form for card payments.
public final class CardComponent: PaymentComponent, PresentableComponent, Localizable, Observer {
    
    /// :nodoc:
    internal var cardPublicKeyProvider: AnyCardPublicKeyProvider
    
    /// :nodoc:
    internal var cardTypeProvider: AnyCardTypeProvider

    private static let maxCardsVisible = 4
    private static let publicBinLenght = 6
    private let throttler = Throttler(minimumDelay: 0.5)
    
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

    public var payment: Payment? {
        didSet {
            storedCardComponent?.payment = payment
        }
    }
    
    /// The delegate for user activity on card component.
    public weak var cardComponentDelegate: CardComponentDelegate?
    
    /// The supported card types.
    /// The getter is O(n), since it filters out all the `excludedCardTypes` before returning.
    public var supportedCardTypes: [CardType] {
        get { privateSupportedCardTypes.filter { !excludedCardTypes.contains($0) } }
        set { privateSupportedCardTypes = newValue }
    }
    
    /// :nodoc:
    public var environment: Environment = .live {
        didSet {
            environment.clientKey = clientKey
            cardPublicKeyProvider.environment = environment
            storedCardComponent?.environment = environment
            cardTypeProvider.environment = environment
        }
    }
    
    /// :nodoc:
    public var clientKey: String? {
        didSet {
            environment.clientKey = clientKey
            cardPublicKeyProvider.clientKey = clientKey
            storedCardComponent?.clientKey = clientKey
            cardTypeProvider.clientKey = clientKey
        }
    }
    
    /// Indicates if the field for entering the holder name should be displayed in the form. Defaults to false.
    public var showsHolderNameField = false

    /// Indicates if the field for entering the postal code should be displayed in the form. Defaults to false.
    public var showsPostalCodeField = false
    
    /// Indicates if the field for storing the card payment method should be displayed in the form. Defaults to true.
    public var showsStorePaymentMethodField = true
    
    /// Indicates whether to show the security code field at all.
    public var showsSecurityCodeField = true

    /// Stored card configuration.
    public var storedCardConfiguration = StoredCardConfiguration()
    
    /// Indicates if form will show a large header title. True - show title; False - assign title to a view controller's title.
    /// Defaults to true.
    @available(*, deprecated, message: """
     The `showsLargeTitle` property is deprecated.
     For Component title, please, introduce your own lable implementation.
     You can access componet's title from `viewController.title`.
    """)
    public var showsLargeTitle: Bool {
        get {
            guard !_isDropIn else { return false }
            return _showsLargeTitle
        }

        set {
            _showsLargeTitle = newValue
        }
    }

    /// :nodoc:
    internal var _showsLargeTitle = true // swiftlint:disable:this identifier_name
    
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
        self.privateSupportedCardTypes = paymentMethod.brands.compactMap(CardType.init)
        self.style = style
        self.clientKey = clientKey
        self.cardTypeProvider = CardTypeProvider(cardPublicKeyProvider: self.cardPublicKeyProvider)

        self.cardPublicKeyProvider.clientKey = clientKey
        self.cardTypeProvider.clientKey = clientKey
        self.environment.clientKey = clientKey
    }
    
    /// :nodoc:
    /// Initializes the card component.
    ///
    /// - Parameters:
    ///   - paymentMethod: The card payment method.
    ///   - cardPublicKeyProvider: The card public key provider
    ///   - style: The Component's UI style.
    internal init(paymentMethod: AnyCardPaymentMethod,
                  cardPublicKeyProvider: AnyCardPublicKeyProvider,
                  style: FormComponentStyle = FormComponentStyle()) {
        self.paymentMethod = paymentMethod
        self.cardPublicKeyProvider = cardPublicKeyProvider
        self.privateSupportedCardTypes = paymentMethod.brands.compactMap(CardType.init)
        self.style = style
        self.cardTypeProvider = CardTypeProvider(cardPublicKeyProvider: cardPublicKeyProvider)
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
        button.showsActivityIndicator = false
        formViewController.view.isUserInteractionEnabled = true
        completion?()
    }
    
    // MARK: - Protected
    
    /// Indicates the card brands excluded from the supported brands.
    internal var excludedCardTypes: Set<CardType> = [.bcmc]
    
    // MARK: - Private

    private var privateSupportedCardTypes: [CardType]

    private var topCardTypes: [CardType] {
        Array(privateSupportedCardTypes.prefix(CardComponent.maxCardsVisible))
    }
    
    // MARK: - Stored Card
    
    internal lazy var storedCardComponent: (PaymentComponent & PresentableComponent)? = {
        guard let paymentMethod = paymentMethod as? StoredCardPaymentMethod else {
            return nil
        }
        var component: PaymentComponent & PresentableComponent
        if storedCardConfiguration.showsSecurityCodeField {
            component = StoredCardComponent(storedCardPaymentMethod: paymentMethod)
        } else {
            component = StoredPaymentMethodComponent(paymentMethod: paymentMethod)
        }
        component.clientKey = clientKey
        component.environment = environment
        component.payment = payment
        return component
    }()
    
    // MARK: - Form Items
    
    private lazy var securedViewController = SecuredViewController(child: formViewController, style: style)
    
    internal lazy var formViewController: FormViewController = {
        Analytics.sendEvent(component: paymentMethod.type, flavor: _isDropIn ? .dropin : .components, environment: environment)
        
        let formViewController = FormViewController(style: style)
        formViewController.localizationParameters = localizationParameters
        formViewController.delegate = self
        
        if _showsLargeTitle, !_isDropIn {
            let headerItem = FormHeaderItem(style: style.header)
            headerItem.title = paymentMethod.name
            headerItem.identifier = ViewIdentifierBuilder.build(scopeInstance: self, postfix: paymentMethod.name)
            formViewController.append(headerItem)
        }
        
        formViewController.title = paymentMethod.name
        formViewController.append(numberItem)

        numberItem.showLogos(for: topCardTypes)
        
        if showsSecurityCodeField {
            let splitTextItem = FormSplitTextItem(items: [expiryDateItem, securityCodeItem], style: style.textField)
            formViewController.append(splitTextItem)
        } else {
            formViewController.append(expiryDateItem)
        }
        
        if showsHolderNameField {
            formViewController.append(holderNameItem)
        }

        if showsPostalCodeField {
            formViewController.append(postalCodeItem)
        }
        
        if showsStorePaymentMethodField {
            formViewController.append(storeDetailsItem)
        }
        
        formViewController.append(button.withPadding(padding: .init(top: 8, left: 0, bottom: -16, right: 0)))
        
        return formViewController
    }()
    
    internal lazy var numberItem: FormCardNumberItem = {
        let item = FormCardNumberItem(supportedCardTypes: supportedCardTypes,
                                      environment: environment,
                                      style: style.textField,
                                      localizationParameters: localizationParameters)
        
        observe(item.$binValue) { [weak self] bin in
            self?.didReceived(bin: bin)
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

    internal lazy var postalCodeItem: FormTextInputItem = {
        let zipCodeItem = FormTextInputItem(style: style.textField)
        zipCodeItem.title = ADYLocalizedString("adyen.postalCodeField.title", localizationParameters)
        zipCodeItem.placeholder = ADYLocalizedString("adyen.postalCodeField.placeholder", localizationParameters)
        zipCodeItem.validator = LengthValidator(minimumLength: 2, maximumLength: 30)
        zipCodeItem.validationFailureMessage = ADYLocalizedString("adyen.errorFeedback.incorrectFormat", localizationParameters)
        zipCodeItem.identifier = ViewIdentifierBuilder.build(scopeInstance: self, postfix: "postalCodeItem")
        return zipCodeItem
    }()
    
    internal lazy var storeDetailsItem: FormSwitchItem = {
        let storeDetailsItem = FormSwitchItem(style: style.switch)
        storeDetailsItem.title = ADYLocalizedString("adyen.card.storeDetailsButton", localizationParameters)
        storeDetailsItem.identifier = ViewIdentifierBuilder.build(scopeInstance: self, postfix: "storeDetailsItem")
        
        return storeDetailsItem
    }()

    internal lazy var button: FormButtonItem = {
        let item = FormButtonItem(style: style.mainButtonItem)
        item.identifier = ViewIdentifierBuilder.build(scopeInstance: self, postfix: "payButtonItem")
        item.title = ADYLocalizedSubmitButtonTitle(with: payment?.amount,
                                                   style: .immediate,
                                                   localizationParameters)
        item.buttonSelectionHandler = { [weak self] in
            self?.didSelectSubmitButton()
        }
        return item
    }()
    
    private func didReceived(bin: String) {
        self.securityCodeItem.selectedCard = supportedCardTypes.adyen.type(forCardNumber: bin)
        self.cardComponentDelegate?.didChangeBIN(String(bin.prefix(CardComponent.publicBinLenght)), component: self)
        
        throttler.throttle { [weak self] in
            self?.requestCardTypes(for: bin)
        }
    }
    
    private func requestCardTypes(for bin: String) {
        cardTypeProvider.requestCardTypes(for: bin, supported: self.supportedCardTypes) { [weak self] cardTypes in
            guard let self = self else { return }
            
            self.numberItem.showLogos(for: bin.isEmpty ? self.topCardTypes : cardTypes)
            self.cardComponentDelegate?.didChangeCardType(cardTypes, component: self)
        }
    }
}
