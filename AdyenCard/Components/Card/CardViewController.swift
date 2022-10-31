//
// Copyright (c) 2022 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) import Adyen
import UIKit
#if canImport(AdyenEncryption)
    import AdyenEncryption
#endif

internal protocol CardViewControllerProtocol {
    func update(storePaymentMethodFieldVisibility isVisible: Bool)
    func update(storePaymentMethodFieldValue isOn: Bool)
}

internal class CardViewController: FormViewController {

    private let configuration: CardComponent.Configuration

    private let shopperInformation: PrefilledShopperInformation?

    private let supportedCardTypes: [CardType]

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
                                   localizationParameters: localizationParameters,
                                   addressViewModelBuilder: DefaultAddressViewModelBuilder())
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
    
    internal var cardBIN: String {
        items.numberContainerItem.numberItem.binValue
    }
    
    internal var validAddress: PostalAddress? {
        guard let address = address, isAddressValid(address: address) else { return nil }
        return address
    }
    
    private func isAddressValid(address: PostalAddress) -> Bool {
        let fieldsValues: [String?]
        
        switch configuration.billingAddress.mode {
        case .full:
            fieldsValues = [address.city,
                            address.country,
                            address.postalCode,
                            address.stateOrProvince,
                            address.street,
                            address.houseNumberOrName]
        case .postalCode:
            fieldsValues = [address.postalCode]
        case .none:
            fieldsValues = []
        }
        
        let trimmedFieldsValues = fieldsValues.map {
            $0?.trimmingCharacters(in: .whitespaces).adyen.nilIfEmpty
        }
        return trimmedFieldsValues.compactMap { $0 }.count == fieldsValues.count
    }

    private var address: PostalAddress? {
        switch configuration.billingAddress.mode {
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

    internal var storePayment: Bool? {
        configuration.showsStorePaymentMethodField ? items.storeDetailsItem.value : nil
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
        
        updateBillingAddressOptionalStatus(brands: brands)
    }
    
    private func updateBillingAddressOptionalStatus(brands: [CardBrand]) {
        let isOptional = configuration.billingAddress.isOptional(for: brands.map(\.type))
        switch configuration.billingAddress.mode {
        case .full:
            items.billingAddressItem.updateOptionalStatus(isOptional: isOptional)
        case .postalCode:
            items.postalCodeItem.updateOptionalStatus(isOptional: isOptional)
        case .none:
            break
        }
        
    }
    
    /// Observe the brand changes to update all other fields.
    private func observeNumberItem() {
        // `initialBrand` is updated in cardNumberItem after binlookup response
        observe(items.numberContainerItem.numberItem.$initialBrand) { [weak self] newBrand in
            self?.updateFields(from: newBrand)
        }
        
        // `selectedDualBrand` is updated in `FormCardNumberItemView` with dual brand selection
        observe(items.numberContainerItem.numberItem.$selectedDualBrand) { [weak self] newBrand in
            self?.updateFields(from: newBrand)
        }
    }
    
    /// Updates relevant other fields after number field changes
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

        switch configuration.billingAddress.mode {
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
        observe(items.numberContainerItem.numberItem.publisher) { [weak self] in self?.didChange(pan: $0) }
        observe(items.numberContainerItem.numberItem.$binValue) { [weak self] in self?.didChange(bin: $0) }

        items.button.buttonSelectionHandler = { [weak cardDelegate] in
            cardDelegate?.didSelectSubmitButton()
        }
    }

    private func didChange(pan: String) {
        items.securityCodeItem.selectedCard = supportedCardTypes.adyen.type(forCardNumber: pan)
        cardDelegate?.didChange(pan: pan)
    }
    
    private func didChange(bin: String) {
        cardDelegate?.didChange(bin: bin)
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

    func didChange(bin: String)
    
    func didChange(pan: String)

}

extension FormValueItem where ValueType == String {
    internal var nonEmptyValue: String? {
        self.value.isEmpty ? nil : self.value
    }
}

extension CardViewController: CardViewControllerProtocol {
    func update(storePaymentMethodFieldVisibility isVisible: Bool) {
        if !isVisible {
            items.storeDetailsItem.value = false
        }
        items.storeDetailsItem.isVisible = isVisible
    }

    func update(storePaymentMethodFieldValue isOn: Bool) {
        items.storeDetailsItem.value = items.storeDetailsItem.isVisible && isOn
    }
}
