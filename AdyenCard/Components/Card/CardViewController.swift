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
        self.securityCodeItem.update(cardBrands: binInfo.brands ?? [])

        switch (binInfo.brands, self.numberItem.value) {
        case (_, ""):
            self.numberItem.showLogos(for: self.topCardTypes)
        case let (.some(brands), _):
            self.numberItem.showLogos(for: brands.map(\.type))
        default:
            self.numberItem.showLogos(for: [])
        }
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

    internal lazy var storeDetailsItem: FormToggleItem = {
        let storeDetailsItem = FormToggleItem(style: formStyle.toggle)
		
		observe(storeDetailsItem.publisher) { [weak self] isEnabled in
			self?.button.enabled = isEnabled
		}
		
        storeDetailsItem.title = localizedString(.payment_authorize, localizationParameters)
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
		
		// is this necessary?
		if !configuration.showsStorePaymentMethodField {
			item.enabled = false
		}
		
        return item
    }()

    private func didReceived(bin: String) {
        self.securityCodeItem.selectedCard = supportedCardTypes.adyen.type(forCardNumber: bin)
        throttler.throttle { [weak self] in self?.cardDelegate?.didChangeBIN(bin) }
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
