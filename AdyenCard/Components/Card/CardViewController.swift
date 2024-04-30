//
// Copyright (c) 2024 Adyen N.V.
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
    
    private var issuingCountryCode: String?
    
    private let payment: Payment?
    
    private let initialCountryCode: String
    
    private let scope: String
    
    private let cardLogos: [FormCardLogosItem.CardTypeLogo]
    
    internal lazy var items = {
        
        ItemsProvider(
            formStyle: formStyle,
            payment: payment,
            configuration: configuration,
            shopperInformation: shopperInformation,
            cardLogos: cardLogos,
            scope: scope,
            initialCountryCode: initialCountryCode,
            localizationParameters: localizationParameters,
            addressViewModelBuilder: DefaultAddressViewModelBuilder(),
            presenter: self,
            addressMode: configuration.billingAddress.mode
        )
    }()

    // MARK: Init view controller

    /// Create new instance of CardViewController
    /// - Parameters:
    ///   - configuration: The configurations of the `CardComponent`.
    ///   - shopperInformation: The shopper's information.
    ///   - formStyle: The style of form view controller.
    ///   - payment: The payment object to visualize payment amount.
    ///   - logoProvider: The provider for logo image URLs.
    ///   - supportedCardTypes: The list of supported cards.
    ///   - initialCountryCode: The initially used country code for the billing address
    ///   - scope: The view's scope.
    ///   - localizationParameters: Localization parameters.
    internal init(configuration: CardComponent.Configuration,
                  shopperInformation: PrefilledShopperInformation?,
                  formStyle: FormComponentStyle,
                  payment: Payment?,
                  logoProvider: LogoURLProvider,
                  supportedCardTypes: [CardType],
                  initialCountryCode: String,
                  scope: String,
                  localizationParameters: LocalizationParameters?) {
        self.configuration = configuration
        self.shopperInformation = shopperInformation
        self.supportedCardTypes = supportedCardTypes
        self.formStyle = formStyle
        self.scope = scope
        self.initialCountryCode = initialCountryCode
        self.payment = payment
        
        self.cardLogos = supportedCardTypes.map {
            .init(url: logoProvider.logoURL(withName: $0.rawValue), type: $0)
        }
        
        super.init(
            style: formStyle,
            localizationParameters: localizationParameters
        )
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
        let expiryMonth = items.expiryDateItem.expiryMonth
        let expiryYear = items.expiryDateItem.expiryYear
        
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
        let address: PostalAddress
        let requiredFields: Set<AddressField>
        
        switch configuration.billingAddress.mode {
        case .lookup, .full:
            guard
                let billingAddressItem = items.billingAddressPickerItem,
                let lookupBillingAddress = billingAddressItem.value
            else { return nil }
            
            address = lookupBillingAddress
            requiredFields = billingAddressItem.addressViewModel.requiredFields
            
        case .postalCode:
            address = PostalAddress(postalCode: items.postalCodeItem.value)
            requiredFields = [.postalCode]
            
        case .none:
            return nil
        }
        
        guard address.satisfies(requiredFields: requiredFields) else { return nil }
        
        return address
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
}

// MARK: - Private methods

extension CardViewController {
    
    private func updateBillingAddressOptionalStatus(brands: [CardBrand]) {
        let isOptional = configuration.billingAddress.isOptional(for: brands.map(\.type))
        switch configuration.billingAddress.mode {
        case .lookup, .full:
            items.billingAddressPickerItem?.updateOptionalStatus(isOptional: isOptional)
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
        items.securityCodeItem.displayMode = brand?.securityCodeItemDisplayMode ?? .required
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
        
        if configuration.showsStorePaymentMethodField {
            append(items.storeDetailsItem)
            append(FormSpacerItem())
        }
        
        if let billingAddressItem {
            append(billingAddressItem)
        }

        append(FormSpacerItem())
        append(items.button)
        append(FormSpacerItem(numberOfSpaces: 2))
    }
    
    private var billingAddressItem: FormItem? {
        
        switch configuration.billingAddress.mode {
        case .lookup:
            return items.billingAddressPickerItem
        case .full:
            return items.billingAddressPickerItem
            
        case .postalCode:
            return items.postalCodeItem
            
        case .none:
            return nil
        }
    }

    private func prefill() {
        guard let shopperInformation else { return }

        shopperInformation.billingAddress.map { billingAddress in
            items.billingAddressPickerItem?.value = billingAddress
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
        guard let brand else { return true }
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
    internal func update(storePaymentMethodFieldVisibility isVisible: Bool) {
        if !isVisible {
            items.storeDetailsItem.value = false
        }
        items.storeDetailsItem.isVisible = isVisible
    }

    internal func update(storePaymentMethodFieldValue isOn: Bool) {
        items.storeDetailsItem.value = items.storeDetailsItem.isVisible && isOn
    }
}

extension CardBrand {
    
    internal var securityCodeItemDisplayMode: FormCardSecurityCodeItem.DisplayMode {
        switch self.cvcPolicy {
        case .hidden: return .hidden
        case .optional: return .optional
        case .required: return .required
        }
    }
}
