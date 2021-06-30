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

        append(additionalAuthCodeItem)
        append(additionalAuthPasswordItem)

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
            configuration.showsKoreanAuthentication,
            let taxNumber = additionalAuthCodeItem.nonEmptyValue,
            let password = additionalAuthPasswordItem.nonEmptyValue
        else { return nil }

        return KCPDetails(taxNumber: taxNumber, password: password)
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
        securityCodeItem.update(cardBrands: binInfo.brands ?? [])

        switch (binInfo.brands, numberItem.value) {
        case (_, ""):
            numberItem.showLogos(for: topCardTypes)
        case let (.some(brands), _):
            numberItem.showLogos(for: brands.map(\.type))
        default:
            numberItem.showLogos(for: [])
        }

        let shouldShow = configuration.showAdditionalAuthenticationFields(for: binInfo.issuingCountryCode)
        additionalAuthPasswordItem.isHidden.wrappedValue = !shouldShow
        additionalAuthCodeItem.isHidden.wrappedValue = !shouldShow
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
        let item = FormAddressItem(initialCountry: defaultCountryCode,
                                   style: formStyle.addressStyle,
                                   localizationParameters: localizationParameters)
        item.style.backgroundColor = UIColor.Adyen.lightGray
        item.identifier = ViewIdentifierBuilder.build(scopeInstance: scope, postfix: "addressVerification")
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
        observe(item.$binValue) { [weak self] in self?.didReceived(bin: $0) }
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
        additionalItem.isHidden.wrappedValue = true

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
        additionalItem.isHidden.wrappedValue = true

        return additionalItem
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
        item.buttonSelectionHandler = { [weak self] in
            self?.cardDelegate?.didSelectSubmitButton()
        }
        return item
    }()
    
    private func didReceived(bin: String) {
        self.securityCodeItem.selectedCard = supportedCardTypes.adyen.type(forCardNumber: bin)
        let shouldShow = configuration.showsKoreanAuthentication
        throttler.throttle { [weak self] in
            self?.cardDelegate?.didChangeBIN(bin)

            let binIsLong = bin.count >= BinInfoProvider.minBinLength
            self?.additionalAuthPasswordItem.isHidden.wrappedValue.setTrueUnless(binIsLong && shouldShow)
            self?.additionalAuthCodeItem.isHidden.wrappedValue.setTrueUnless(binIsLong && shouldShow)
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

extension Bool {

    fileprivate mutating func setTrueUnless(_ needed: Bool) {
        self = !(self == false && needed)
    }

}
