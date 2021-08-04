//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import UIKit
#if canImport(AdyenEncryption)
    import AdyenEncryption
#endif

internal class CardViewController: FormViewController {
    
    private let configuration: CardComponent.Configuration
    
    private let formStyle: FormComponentStyle
    
    private let payment: Payment?
    
    private let logoProvider: LogoURLProvider
    
    private let supportedCardTypes: [CardType]
    
    private let scope: String
    
    private let maxCardsVisible = 4
    
    private let throttler = Throttler(minimumDelay: 0.5)
    
    private var topCardTypes: [CardType] {
        Array(supportedCardTypes.prefix(maxCardsVisible))
    }
    
    // MARK: Init view controller
    
    /// Create new instance of CardViewController
    /// - Parameters:
    ///   - configuration: The configurations of the `CardComponent`.
    ///   - formStyle: The style of form view controller.
    ///   - payment: The payment object to visialise payment amount.
    ///   - logoProvider: The provider for logo image URLs.
    ///   - supportedCardTypes: The list of supported cards.
    internal init(configuration: CardComponent.Configuration,
                  formStyle: FormComponentStyle,
                  payment: Payment?,
                  logoProvider: LogoURLProvider,
                  supportedCardTypes: [CardType],
                  scope: String) {
        self.configuration = configuration
        self.formStyle = formStyle
        self.payment = payment
        self.logoProvider = logoProvider
        self.supportedCardTypes = supportedCardTypes
        self.scope = scope
        super.init(style: formStyle)
    }
    
    override internal func viewDidLoad() {
        append(numberItem)
        numberItem.showLogos(for: topCardTypes)
        
        if configuration.showsSecurityCodeField {
            let splitTextItem = FormSplitItem(items: expiryDateItem, securityCodeItem, style: formStyle.textField)
            append(splitTextItem)
        } else {
            append(expiryDateItem)
        }
        
        if configuration.showsHolderNameField {
            append(holderNameItem)
        }

        if configuration.koreanAuthenticationMode != .hide {
            append(additionalAuthCodeItem)
            append(additionalAuthPasswordItem)
        }
        
        if configuration.socialSecurityNumberMode != .hide {
            append(socialSecurityNumberItem)
        }

        switch configuration.billingAddressMode {
        case .full:
            append(billingAddressItem)
        case .postalCode:
            append(postalCodeItem)
        case .none:
            break
        }
        
        if configuration.showsStorePaymentMethodField {
            append(storeDetailsItem)
        }
        
        append(button)
        
        super.viewDidLoad()
    }
    
    // MARK: Public methods
    
    internal weak var cardDelegate: CardViewControllerDelegate?
    
    internal var card: Card {
        Card(number: numberItem.value,
             securityCode: configuration.showsSecurityCodeField ? securityCodeItem.nonEmptyValue : nil,
             expiryMonth: expiryDateItem.value.adyen[0...1],
             expiryYear: "20" + expiryDateItem.value.adyen[2...3],
             holder: configuration.showsHolderNameField ? holderNameItem.nonEmptyValue : nil)
    }
    
    internal var address: PostalAddress? {
        switch configuration.billingAddressMode {
        case .full:
            return billingAddressItem.value
        case .postalCode:
            return PostalAddress(postalCode: postalCodeItem.value)
        case .none:
            return nil
        }
    }

    internal var kcpDetails: KCPDetails? {
        guard
            configuration.koreanAuthenticationMode != .hide,
            let taxNumber = additionalAuthCodeItem.nonEmptyValue,
            let password = additionalAuthPasswordItem.nonEmptyValue
        else { return nil }

        return KCPDetails(taxNumber: taxNumber, password: password)
    }
    
    internal var socialSecurityNumber: String? {
        guard configuration.socialSecurityNumberMode != .hide else { return nil }
        return socialSecurityNumberItem.nonEmptyValue
    }

    internal var storePayment: Bool {
        configuration.showsStorePaymentMethodField ? storeDetailsItem.value : false
    }
    
    internal func stopLoading() {
        button.showsActivityIndicator = false
        view.isUserInteractionEnabled = true
    }
    
    internal func startLoading() {
        button.showsActivityIndicator = true
        view.isUserInteractionEnabled = false
    }
    
    internal func update(binInfo: BinLookupResponse) {
        let brands = binInfo.brands ?? []
        securityCodeItem.update(cardBrands: brands)

        if numberItem.value.isEmpty {
            numberItem.showLogos(for: topCardTypes)
        } else {
            numberItem.showLogos(for: brands.map(\.type))
        }

        let isHidden: Bool
        switch configuration.koreanAuthenticationMode {
        case .show:
            isHidden = false
        case .hide:
            isHidden = true
        case .auto:
            isHidden = !configuration.showAdditionalAuthenticationFields(for: binInfo.issuingCountryCode)
        }

        numberItem.validator = CardNumberValidator(isLuhnCheckEnabled: brands.luhnCheckRequired)
        additionalAuthPasswordItem.isHidden.wrappedValue = isHidden
        additionalAuthCodeItem.isHidden.wrappedValue = isHidden
        socialSecurityNumberItem.isHidden.wrappedValue = !brands.socialSecurityNumberRequired
    }
    
    internal func resetItems() {
        billingAddressItem.reset()

        [postalCodeItem,
         numberItem,
         expiryDateItem,
         securityCodeItem,
         holderNameItem].forEach { $0.value = "" }
        
        storeDetailsItem.value = false
    }
    
    // MARK: Items
    
    internal lazy var billingAddressItem: FormAddressItem = {
        let identifier = ViewIdentifierBuilder.build(scopeInstance: scope, postfix: "addressVerification")
        let item = FormAddressItem(initialCountry: defaultCountryCode,
                                   style: formStyle.addressStyle,
                                   localizationParameters: localizationParameters)
        item.style.backgroundColor = UIColor.Adyen.lightGray
        return item
    }()
    
    internal lazy var postalCodeItem: FormTextItem = {
        let zipCodeItem = FormTextInputItem(style: formStyle.textField)
        zipCodeItem.title = localizedString(.postalCodeFieldTitle, localizationParameters)
        zipCodeItem.placeholder = localizedString(.postalCodeFieldPlaceholder, localizationParameters)
        zipCodeItem.validator = LengthValidator(minimumLength: 2, maximumLength: 30)
        zipCodeItem.validationFailureMessage = localizedString(.validationAlertTitle, localizationParameters)
        zipCodeItem.identifier = ViewIdentifierBuilder.build(scopeInstance: scope, postfix: "postalCodeItem")
        zipCodeItem.contentType = .postalCode
        return zipCodeItem
    }()
    
    internal lazy var numberItem: FormCardNumberItem = {
        let item = FormCardNumberItem(supportedCardTypes: supportedCardTypes,
                                      logoProvider: logoProvider,
                                      style: formStyle.textField,
                                      localizationParameters: localizationParameters)
        observe(item.$binValue) { [weak self] in self?.didReceive(bin: $0) }
        item.identifier = ViewIdentifierBuilder.build(scopeInstance: scope, postfix: "numberItem")
        return item
    }()
    
    internal lazy var expiryDateItem: FormTextInputItem = {
        let expiryDateItem = FormTextInputItem(style: formStyle.textField)
        expiryDateItem.title = localizedString(.cardExpiryItemTitle, localizationParameters)
        expiryDateItem.placeholder = localizedString(.cardExpiryItemPlaceholder, localizationParameters)
        expiryDateItem.formatter = CardExpiryDateFormatter()
        expiryDateItem.validator = CardExpiryDateValidator()
        expiryDateItem.validationFailureMessage = localizedString(.cardExpiryItemInvalid, localizationParameters)
        expiryDateItem.keyboardType = .numberPad
        expiryDateItem.identifier = ViewIdentifierBuilder.build(scopeInstance: scope, postfix: "expiryDateItem")
        
        return expiryDateItem
    }()
    
    internal lazy var securityCodeItem: FormCardSecurityCodeItem = {
        let securityCodeItem = FormCardSecurityCodeItem(style: formStyle.textField,
                                                        localizationParameters: localizationParameters)
        securityCodeItem.localizationParameters = self.localizationParameters
        securityCodeItem.identifier = ViewIdentifierBuilder.build(scopeInstance: scope, postfix: "securityCodeItem")
        return securityCodeItem
    }()
    
    internal lazy var holderNameItem: FormTextInputItem = {
        let holderNameItem = FormTextInputItem(style: formStyle.textField)
        holderNameItem.title = localizedString(.cardNameItemTitle, localizationParameters)
        holderNameItem.placeholder = localizedString(.cardNameItemPlaceholder, localizationParameters)
        holderNameItem.validator = LengthValidator(minimumLength: 2)
        holderNameItem.validationFailureMessage = localizedString(.cardNameItemInvalid, localizationParameters)
        holderNameItem.autocapitalizationType = .words
        holderNameItem.identifier = ViewIdentifierBuilder.build(scopeInstance: scope, postfix: "holderNameItem")
        holderNameItem.contentType = .name
        
        return holderNameItem
    }()

    internal lazy var additionalAuthCodeItem: FormTextInputItem = {
        let additionalItem = FormTextInputItem(style: formStyle.textField)
        additionalItem.title = localizedString(.cardTaxNumberLabelShort, localizationParameters)
        additionalItem.placeholder = localizedString(.cardTaxNumberPlaceholder, localizationParameters)
        additionalItem.validator = LengthValidator(minimumLength: 6, maximumLength: 10)
        additionalItem.validationFailureMessage = localizedString(.cardTaxNumberInvalid, localizationParameters)
        additionalItem.autocapitalizationType = .none
        additionalItem.identifier = ViewIdentifierBuilder.build(scopeInstance: scope, postfix: "additionalAuthCodeItem")
        additionalItem.keyboardType = .numberPad
        additionalItem.isHidden.wrappedValue = !(configuration.koreanAuthenticationMode == .show)

        return additionalItem
    }()

    internal lazy var additionalAuthPasswordItem: FormTextInputItem = {
        let additionalItem = FormTextInputItem(style: formStyle.textField)
        additionalItem.title = localizedString(.cardEncryptedPasswordLabel, localizationParameters)
        additionalItem.placeholder = localizedString(.cardEncryptedPasswordPlaceholder, localizationParameters)
        additionalItem.validator = LengthValidator(minimumLength: 2, maximumLength: 2)
        additionalItem.validationFailureMessage = localizedString(.cardEncryptedPasswordInvalid, localizationParameters)
        additionalItem.autocapitalizationType = .none
        additionalItem.identifier = ViewIdentifierBuilder.build(scopeInstance: scope, postfix: "additionalAuthPasswordItem")
        additionalItem.keyboardType = .numberPad
        additionalItem.isHidden.wrappedValue = !(configuration.koreanAuthenticationMode == .show)

        return additionalItem
    }()
    
    internal lazy var socialSecurityNumberItem: FormTextInputItem = {
        let securityNumberItem = FormTextInputItem(style: formStyle.textField)
        securityNumberItem.title = localizedString(.boletoSocialSecurityNumber, localizationParameters)
        securityNumberItem.placeholder = localizedString(.cardBrazilSSNPlaceholder, localizationParameters)
        securityNumberItem.formatter = BrazilSocialSecurityNumberFormatter()
        securityNumberItem.validator = NumericStringValidator(minimumLength: 11, maximumLength: 11)
            || NumericStringValidator(minimumLength: 14, maximumLength: 14)
        securityNumberItem.validationFailureMessage = localizedString(.validationAlertTitle, localizationParameters)
        securityNumberItem.autocapitalizationType = .none
        securityNumberItem.identifier = ViewIdentifierBuilder.build(scopeInstance: scope, postfix: "socialSecurityNumberItem")
        securityNumberItem.keyboardType = .numberPad
        securityNumberItem.isHidden.wrappedValue = !(configuration.socialSecurityNumberMode == .show)

        return securityNumberItem
    }()

    internal lazy var storeDetailsItem: FormToggleItem = {
        let storeDetailsItem = FormToggleItem(style: formStyle.toggle)
        storeDetailsItem.title = localizedString(.cardStoreDetailsButton, localizationParameters)
        storeDetailsItem.identifier = ViewIdentifierBuilder.build(scopeInstance: scope, postfix: "storeDetailsItem")
        
        return storeDetailsItem
    }()
    
    internal lazy var button: FormButtonItem = {
        let item = FormButtonItem(style: formStyle.mainButtonItem)
        item.identifier = ViewIdentifierBuilder.build(scopeInstance: scope, postfix: "payButtonItem")
        item.title = localizedSubmitButtonTitle(with: payment?.amount,
                                                style: .immediate,
                                                localizationParameters)
        item.buttonSelectionHandler = { [weak cardDelegate] in
            cardDelegate?.didSelectSubmitButton()
        }
        return item
    }()
    
    private func didReceive(bin: String) {
        securityCodeItem.selectedCard = supportedCardTypes.adyen.type(forCardNumber: bin)
        throttler.throttle { [weak cardDelegate] in
            cardDelegate?.didChangeBIN(bin)
        }
    }
    
    private var defaultCountryCode: String {
        payment?.countryCode ?? Locale.current.regionCode ?? "US"
    }
    
}

internal protocol CardViewControllerDelegate: AnyObject {
    
    func didSelectSubmitButton()
    
    func didChangeBIN(_ value: String)
    
}

extension FormValueItem where ValueType == String {
    internal var nonEmptyValue: String? {
        self.value.isEmpty ? nil : self.value
    }
}
