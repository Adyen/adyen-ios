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

    private let supportedCardTypes: [CardType]

    private let throttler = Throttler(minimumDelay: CardComponent.Constant.secondsThrottlingDelay)

    private let formStyle: FormComponentStyle

    private var topCardTypes: [CardType] {
        Array(supportedCardTypes.prefix(CardComponent.Constant.maxCardsVisible))
    }

    internal var items: ItemsProvider

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
                  scope: String,
                  localizationParameters: LocalizationParameters?) {
        self.configuration = configuration
        self.supportedCardTypes = supportedCardTypes
        self.formStyle = formStyle

        let countryCode = payment?.countryCode ?? Locale.current.regionCode ?? CardComponent.Constant.defaultCountryCode
        let cardLogos = supportedCardTypes.map {
            FormCardNumberItem.CardTypeLogo(url: logoProvider.logoURL(withName: $0.rawValue), type: $0)
        }
        self.items = ItemsProvider(formStyle: formStyle,
                                   payment: payment,
                                   configuration: configuration,
                                   supportedCardTypes: supportedCardTypes,
                                   cardLogos: cardLogos,
                                   scope: scope,
                                   defaultCountryCode: countryCode,
                                   localizationParameters: localizationParameters)
        super.init(style: formStyle)
        self.localizationParameters = localizationParameters
    }

    override internal func viewDidLoad() {
        setupView()
        setupViewRelations()
        super.viewDidLoad()
    }

    // MARK: Public methods

    internal weak var cardDelegate: CardViewControllerDelegate?

    internal var card: Card {
        var expiryMonth: String?
        var expiryYear: String?
        if let expiryItemValue = items.expiryDateItem.nonEmptyValue {
            expiryMonth = expiryItemValue.adyen[0...1]
            expiryYear = "20" + expiryItemValue.adyen[2...3]
        }
        return Card(number: items.numberItem.value,
                    securityCode: configuration.showsSecurityCodeField ? items.securityCodeItem.nonEmptyValue : nil,
                    expiryMonth: expiryMonth,
                    expiryYear: expiryYear,
                    holder: configuration.showsHolderNameField ? items.holderNameItem.nonEmptyValue : nil)
    }

    internal var address: PostalAddress? {
        switch configuration.billingAddressMode {
        case .full:
            return items.billingAddressItem.value
        case .postalCode:
            return PostalAddress(postalCode: items.postalCodeItem.value)
        case .none:
            return nil
        }
    }

    internal var kcpDetails: KCPDetails? {
        guard
            configuration.koreanAuthenticationMode != .hide,
            let taxNumber = items.additionalAuthCodeItem.nonEmptyValue,
            let password = items.additionalAuthPasswordItem.nonEmptyValue
        else { return nil }

        return KCPDetails(taxNumber: taxNumber, password: password)
    }

    internal var socialSecurityNumber: String? {
        guard configuration.socialSecurityNumberMode != .hide else { return nil }
        return items.socialSecurityNumberItem.nonEmptyValue
    }

    internal var storePayment: Bool {
        configuration.showsStorePaymentMethodField ? items.storeDetailsItem.value : false
    }

    internal func stopLoading() {
        items.button.showsActivityIndicator = false
        view.isUserInteractionEnabled = true
    }

    internal func startLoading() {
        items.button.showsActivityIndicator = true
        view.isUserInteractionEnabled = false
    }

    internal func update(binInfo: BinLookupResponse) {
        let brands = binInfo.brands ?? []
        items.securityCodeItem.isOptional = brands.isCVCOptional
        items.expiryDateItem.isOptional = brands.isExpiryDateOptional

        if items.numberItem.value.isEmpty {
            items.numberItem.showLogos(for: topCardTypes)
        } else {
            items.numberItem.showLogos(for: brands.map(\.type))
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

        items.numberItem.validator = CardNumberValidator(isLuhnCheckEnabled: brands.luhnCheckRequired)
        items.additionalAuthPasswordItem.isHidden.wrappedValue = isHidden
        items.additionalAuthCodeItem.isHidden.wrappedValue = isHidden
        items.socialSecurityNumberItem.isHidden.wrappedValue = !brands.socialSecurityNumberRequired
    }

    /*
     supportedCardTypes.map {
         CardTypeLogo(url: logoProvider.logoURL(withName: $0.rawValue), type: $0)
     }
     */

    internal func resetItems() {
        items.billingAddressItem.reset()

        [items.postalCodeItem,
         items.numberItem,
         items.expiryDateItem,
         items.securityCodeItem,
         items.holderNameItem].forEach { $0.value = "" }

        items.storeDetailsItem.value = false
    }

    // MARK: Private methods

    private func setupView() {
        append(items.numberItem)
        items.numberItem.showLogos(for: topCardTypes)

        if configuration.showsSecurityCodeField {
            let splitTextItem = FormSplitItem(items: items.expiryDateItem, items.securityCodeItem, style: formStyle.textField)
            append(splitTextItem)
        } else {
            append(items.expiryDateItem)
        }

        if configuration.showsHolderNameField {
            append(items.holderNameItem)
        }

        if configuration.koreanAuthenticationMode != .hide {
            append(items.additionalAuthCodeItem)
            append(items.additionalAuthPasswordItem)
        }

        if configuration.socialSecurityNumberMode != .hide {
            append(items.socialSecurityNumberItem)
        }

        switch configuration.billingAddressMode {
        case .full:
            append(items.billingAddressItem)
        case .postalCode:
            append(items.postalCodeItem)
        case .none:
            break
        }

        if configuration.showsStorePaymentMethodField {
            append(items.storeDetailsItem)
        }

        append(items.button)
    }

    private func setupViewRelations() {
        observe(items.numberItem.$binValue) { [weak self] in self?.didReceive(bin: $0) }

        items.button.buttonSelectionHandler = { [weak cardDelegate] in
            cardDelegate?.didSelectSubmitButton()
        }
    }

    private func didReceive(bin: String) {
        items.securityCodeItem.selectedCard = supportedCardTypes.adyen.type(forCardNumber: bin)
        throttler.throttle { [weak cardDelegate] in
            cardDelegate?.didChangeBIN(bin)
        }
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
