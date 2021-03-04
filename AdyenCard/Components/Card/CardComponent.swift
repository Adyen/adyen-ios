//
// Copyright (c) 2021 Adyen N.V.
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
    func didChangeCardBrand(_ value: [CardBrand]?, component: CardComponent)
}

/// Stored card configuration.
public struct StoredCardConfiguration {

    /// Indicates whether to show the security code field.
    public var showsSecurityCodeField = true

    /// :nodoc:
    public init() { /* empty init */ }
}

/// A component that provides a form for card payments.
public class CardComponent: PaymentComponent, PresentableComponent, Localizable, Observer, LoadingComponent {
    
    /// :nodoc:
    internal var cardPublicKeyProvider: AnyCardPublicKeyProvider
    
    /// :nodoc:
    internal var cardBrandProvider: AnyCardBrandProvider

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
        get { privateSupportedCardTypes }
        set { privateSupportedCardTypes = newValue }
    }
    
    /// :nodoc:
    public var environment: Environment = .live {
        didSet {
            environment.clientKey = clientKey
            cardPublicKeyProvider.environment = environment
            storedCardComponent?.environment = environment
            cardBrandProvider.environment = environment
        }
    }
    
    /// :nodoc:
    public var clientKey: String? {
        didSet {
            environment.clientKey = clientKey
            cardPublicKeyProvider.clientKey = clientKey
            storedCardComponent?.clientKey = clientKey
            cardBrandProvider.clientKey = clientKey
        }
    }

    /// Card component configuration.
    public let configuration: Configuration
    
    /// Initializes the card component.
    ///
    /// - Parameters:
    ///   - paymentMethod: The card payment method.
    ///   -  clientKey: The client key that corresponds to the webservice user you will use for initiating the payment.
    /// See https://docs.adyen.com/user-management/client-side-authentication for more information.
    ///   -  style: The Component's UI style.
    public convenience init(paymentMethod: AnyCardPaymentMethod,
                            configuration: Configuration,
                            clientKey: String,
                            style: FormComponentStyle = FormComponentStyle()) {
        self.init(paymentMethod: paymentMethod,
                  configuration: configuration,
                  cardPublicKeyProvider: CardPublicKeyProvider(),
                  clientKey: clientKey,
                  style: style)
    }
    
    /// :nodoc:
    /// Initializes the card component.
    ///
    /// - Parameters:
    ///   - paymentMethod: The card payment method.
    ///   - cardPublicKeyProvider: The card public key provider
    ///   - style: The Component's UI style.
    internal init(paymentMethod: AnyCardPaymentMethod,
                  configuration: Configuration = Configuration(),
                  cardPublicKeyProvider: AnyCardPublicKeyProvider = CardPublicKeyProvider(),
                  clientKey: String,
                  style: FormComponentStyle = FormComponentStyle()) {
        self.clientKey = clientKey
        self.paymentMethod = paymentMethod
        self.configuration = configuration
        self.cardPublicKeyProvider = cardPublicKeyProvider
        let paymentMethodCardTypes = paymentMethod.brands.compactMap(CardType.init)
        let supportedCardTypes = configuration.supportedCardTypes
        let excludedCardTypes = configuration.excludedCardTypes
        self.privateSupportedCardTypes = (supportedCardTypes ?? paymentMethodCardTypes)
            .minus(excludedCardTypes)
        self.style = style
        self.cardBrandProvider = CardBrandProvider(cardPublicKeyProvider: cardPublicKeyProvider)

        self.cardPublicKeyProvider.clientKey = clientKey
        self.cardBrandProvider.clientKey = clientKey
        self.environment.clientKey = clientKey
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
    public func stopLoading(completion: (() -> Void)?) {
        button.showsActivityIndicator = false
        formViewController.view.isUserInteractionEnabled = true
        completion?()
    }
    
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
        if configuration.stored.showsSecurityCodeField {
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
        
        let formViewController = FormViewController(style: style)
        formViewController.localizationParameters = localizationParameters
        formViewController.delegate = self
        
        formViewController.title = paymentMethod.name
        formViewController.append(numberItem)

        numberItem.showLogos(for: topCardTypes)
        
        if configuration.showsSecurityCodeField {
            let splitTextItem = FormSplitTextItem(items: [expiryDateItem, securityCodeItem], style: style.textField)
            formViewController.append(splitTextItem)
        } else {
            formViewController.append(expiryDateItem)
        }
        
        if configuration.showsHolderNameField {
            formViewController.append(holderNameItem)
        }
        
        if configuration.showsStorePaymentMethodField {
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
        let parameters = CardBrandProviderParameters(bin: bin, supportedTypes: supportedCardTypes)
        cardBrandProvider.provide(for: parameters) { [weak self] cardBrands in
            guard let self = self else { return }

            self.securityCodeItem.update(cardBrands: cardBrands)
            self.numberItem.showLogos(for: bin.isEmpty ? self.topCardTypes : cardBrands.map(\.type))
            self.cardComponentDelegate?.didChangeCardBrand(cardBrands, component: self)
        }
    }
}
