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

    private let shopperInformation: PrefilledShopperInformation?

    private let supportedCardTypes: [CardType]

    private let throttler = Throttler(minimumDelay: CardComponent.Constant.secondsThrottlingDelay)

    private let formStyle: FormComponentStyle

    internal var items: ItemsProvider
    
    private var issuingCountryCode: String?

    // MARK: Init view controller

    /// Create new instance of CardViewController
    /// - Parameters:
    ///   - configuration: The configurations of the `CardComponent`.
    ///   - shopperInformation: The shopper's information.
    ///   - formStyle: The style of form view controller.
    ///   - payment: The payment object to visualize payment amount.
    ///   - logoProvider: The provider for logo image URLs.
    ///   - supportedCardTypes: The list of supported cards.
    ///   - scope: The view's scope.
    ///   - localizationParameters: Localization parameters.
    internal init(configuration: CardComponent.Configuration,
                  shopperInformation: PrefilledShopperInformation?,
                  formStyle: FormComponentStyle,
                  payment: Payment?,
                  logoProvider: LogoURLProvider,
                  supportedCardTypes: [CardType],
                  scope: String,
                  localizationParameters: LocalizationParameters?) {
        self.configuration = configuration
        self.shopperInformation = shopperInformation
        self.supportedCardTypes = supportedCardTypes
        self.formStyle = formStyle

        let countryCode = payment?.countryCode ?? Locale.current.regionCode ?? CardComponent.Constant.defaultCountryCode
        let cardLogos = supportedCardTypes.map {
            FormCardLogosItem.CardTypeLogo(url: logoProvider.logoURL(withName: $0.rawValue), type: $0)
        }
        self.items = ItemsProvider(formStyle: formStyle,
                                   payment: payment,
                                   configuration: configuration,
                                   shopperInformation: shopperInformation,
                                   cardLogos: cardLogos,
                                   scope: scope,
                                   defaultCountryCode: countryCode,
                                   localizationParameters: localizationParameters)
        super.init(style: formStyle)
        self.localizationParameters = localizationParameters
    }

    // MARK: - View lifecycle

    override internal func viewDidLoad() {
        setupView()
        setupViewRelations()
        observeNumberItem()
        super.viewDidLoad()
    }

    override internal func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        prefill()
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
    
    internal var selectedBrand: String? {
        items.numberContainerItem.numberItem.currentBrand?.type.rawValue
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
        var brands: [CardBrand] = []
        // no dual branding if response is from regex (fallback)
        if binInfo.isCreatedLocally, let firstBrand = binInfo.brands?.first {
            brands = [firstBrand]
        } else {
            brands = binInfo.brands ?? []
        }
        issuingCountryCode = binInfo.issuingCountryCode
        items.numberContainerItem.update(brands: brands)
    }
    
    /// Observe the current brand changes to update all other fields.
    private func observeNumberItem() {
        // `currentBrand` changes are what triggers the update for all other fields
        // and it can be changed by both `FormCardNumberItemView` with dual brand selections
        // and from here via binlookup response
        observe(items.numberContainerItem.numberItem.$currentBrand) { [weak self] newBrand in
            self?.updateFields(from: newBrand)
        }
    }
    
    private func updateFields(from brand: CardBrand?) {
        items.securityCodeItem.isOptional = brand?.isCVCOptional ?? false
        items.expiryDateItem.isOptional = brand?.isExpiryDateOptional ?? false
        
        let kcpItemsHidden = shouldHideKcpItems(with: issuingCountryCode)
        items.additionalAuthPasswordItem.isHidden.wrappedValue = kcpItemsHidden
        items.additionalAuthCodeItem.isHidden.wrappedValue = kcpItemsHidden
        items.socialSecurityNumberItem.isHidden.wrappedValue = shouldHideSocialSecurityItem(with: brand)
        items.installmentsItem?.update(cardType: brand?.type)
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

        append(FormSpacerItem())
        append(items.button)
        append(FormSpacerItem(numberOfSpaces: 2))
    }

    private func prefill() {
        guard let shopperInformation = shopperInformation else { return }

        shopperInformation.billingAddress.map { billingAddress in
            items.billingAddressItem.value = billingAddress
            billingAddress.postalCode.map { items.postalCodeItem.value = $0 }
        }
        shopperInformation.card.map { items.holderNameItem.value = $0.holderName }
        shopperInformation.socialSecurityNumber.map { items.socialSecurityNumberItem.value = $0 }
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
    
    private func shouldHideSocialSecurityItem(with brand: CardBrand?) -> Bool {
        guard let brand = brand else { return true }
        switch configuration.socialSecurityNumberMode {
        case .show:
            return false
        case .hide:
            return true
        case .auto:
            return !brand.showsSocialSecurityNumber
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
