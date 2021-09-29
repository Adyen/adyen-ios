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
        supportedCardTypes // Array(supportedCardTypes.prefix(CardComponent.Constant.maxCardsVisible))
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
            FormCardLogoItem.CardTypeLogo(url: logoProvider.logoURL(withName: $0.rawValue), type: $0)
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
        return Card(number: items.numberContainerItem.numberItem.value,
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

    internal var installments: Installments? {
        guard let installmentsItem = items.installmentsItem,
              !installmentsItem.isHidden.wrappedValue else { return nil }
        return installmentsItem.value.element.installmentValue
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

//        if items.numberItem.value.isEmpty {
//            items.numberItem.showLogos(for: topCardTypes)
//        } else {
//            items.numberItem.showLogos(for: brands.map(\.type))
//        }

        let kcpItemsHidden = shouldHideKcpItems(with: binInfo.issuingCountryCode)
        let firstBrand = firstSupportedBrand(from: brands)
        
        items.numberContainerItem.numberItem.luhnCheckEnabled = brands.luhnCheckRequired
        items.numberContainerItem.numberItem.update(currentBrand: firstBrand)
        items.additionalAuthPasswordItem.isHidden.wrappedValue = kcpItemsHidden
        items.additionalAuthCodeItem.isHidden.wrappedValue = kcpItemsHidden
        items.socialSecurityNumberItem.isHidden.wrappedValue = shouldHideSocialSecurityItem(with: brands)
        items.installmentsItem?.update(cardType: firstBrand?.type) // choose first until dual brand selection feature
    }
    
    /// Returns the first supported brand in a multi(dual) brand sitation. If neither brand is supported, returns the first brand.
    private func firstSupportedBrand(from brands: [CardBrand]) -> CardBrand? {
        guard !brands.isEmpty else { return nil }
        return brands.first { $0.isSupported } ?? brands.first
    }

    // MARK: Private methods

    private func setupView() {
        append(items.numberContainerItem)

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

        if let installmentsItem = items.installmentsItem {
            append(installmentsItem)
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
        observe(items.numberContainerItem.numberItem.$binValue) { [weak self] in self?.didReceive(bin: $0) }

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
    
    private func shouldHideKcpItems(with countryCode: String?) -> Bool {
        switch configuration.koreanAuthenticationMode {
        case .show:
            return false
        case .hide:
            return true
        case .auto:
            return !configuration.showAdditionalAuthenticationFields(for: countryCode)
        }
    }
    
    private func shouldHideSocialSecurityItem(with brands: [CardBrand]) -> Bool {
        switch configuration.socialSecurityNumberMode {
        case .show:
            return false
        case .hide:
            return true
        case .auto:
            return !brands.socialSecurityNumberRequired
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
