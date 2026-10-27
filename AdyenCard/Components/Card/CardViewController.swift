//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
@_spi(AdyenInternal) import struct Adyen.LocalizationKey
import UIKit
#if canImport(AdyenEncryption)
    import AdyenEncryption
#endif
#if canImport(AdyenUI)
    import AdyenUI
    @_spi(AdyenInternal) import class AdyenUI.FormViewController
#endif

internal protocol CardViewControllerProtocol {
    func update(storePaymentMethodFieldVisibility isVisible: Bool)
    func update(storePaymentMethodFieldValue isOn: Bool)
}

internal class CardViewController: FormViewController {
    
    private let configuration: CardConfiguration
    private let shopperInformation: PrefilledShopperInformation?
    private let supportedCardBrands: [CardBrand]
    private let formStyle: FormComponentStyle
    private var issuingCountryCode: String?
    private var billingAddressSectionItem: FormItem?
    private var installmentsSectionItem: FormItem?
    private let amount: Amount?
    private let initialCountryCode: String
    private let scope: String
    private let cardLogos: [FormCardLogosItem.CardBrandLogo]
    private let allowedCoBadgedCardBrands: [CardBrand] = [.carteBancaire, .bcmc, .dankort]
    private let cardScannerAnalyticsHandler: CardScannerAnalyticsHandler

    private lazy var cardScannerController: CardScannerControlling = {
        var controller: CardScannerControlling = CardScannerController(presenter: self, analyticsHandler: cardScannerAnalyticsHandler)
        controller.title = localizedString(.cardScanYourCardButton, localizationParameters)
        controller.onScanComplete = { [weak self] result in
            self?.handleCardScanningResult(result)
        }
        return controller
    }()
    
    private var isCardScannerAvailable: Bool {
        cardScannerController.isScannerAvailable
    }
    
    private var cardNumberItem: FormCardNumberItem {
        items.numberContainerItem.numberItem
    }

    internal lazy var items = {
        
        let scanCardHandler: (() -> Void)?
        if isCardScannerAvailable {
            scanCardHandler = { [weak self] in
                self?.cardScannerController.openCardScanner()
            }
        } else {
            scanCardHandler = nil
        }
        
        return ItemsProvider(
            formStyle: formStyle,
            theme: theme,
            amount: amount,
            configuration: configuration,
            shopperInformation: shopperInformation,
            cardLogos: cardLogos,
            scope: scope,
            initialCountryCode: initialCountryCode,
            localizationParameters: localizationParameters,
            addressViewModelBuilder: DefaultAddressViewModelBuilder(),
            presenter: self,
            addressMode: configuration.billingAddressMode,
            scanCardHandler: scanCardHandler
        )
    }()
    
    // MARK: Init view controller
    
    /// Create new instance of CardViewController
    /// - Parameters:
    ///   - configuration: The configurations of the `CardComponent`.
    ///   - shopperInformation: The shopper's information.
    ///   - formStyle: The style of form view controller.
    ///   - amount: The payment amount.
    ///   - logoProvider: The provider for logo image URLs.
    ///   - supportedCardBrands: The list of supported cards.
    ///   - initialCountryCode: The initially used country code for the billing address
    ///   - scope: The view's scope.
    ///   - localizationParameters: Localization parameters.
    ///   - theme: The theme to use for styling.
    internal init(
        configuration: CardConfiguration,
        shopperInformation: PrefilledShopperInformation?,
        formStyle: FormComponentStyle,
        amount: Amount?,
        logoProvider: LogoURLProvider,
        supportedCardBrands: [CardBrand],
        initialCountryCode: String,
        scope: String,
        localizationParameters: LocalizationParameters?,
        theme: CheckoutTheme,
        cardScannerAnalyticsHandler: @escaping CardScannerAnalyticsHandler
    ) {
        self.configuration = configuration
        self.shopperInformation = shopperInformation
        self.supportedCardBrands = supportedCardBrands
        self.formStyle = formStyle
        self.scope = scope
        self.initialCountryCode = initialCountryCode
        self.amount = amount
        self.cardScannerAnalyticsHandler = cardScannerAnalyticsHandler

        self.cardLogos = supportedCardBrands.map {
            .init(url: logoProvider.logoURL(withName: $0.rawValue), brand: $0)
        }

        super.init(
            scrollEnabled: configuration.showsSubmitButton,
            localizationParameters: localizationParameters,
            theme: theme
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
        
        return Card(
            number: cardNumberItem.value,
            securityCode: configuration.showSecurityCode ? items.securityCodeItem.nonEmptyValue : nil,
            expiryMonth: expiryMonth,
            expiryYear: expiryYear,
            holder: configuration.showCardholderName ? items.holderNameItem.nonEmptyValue : nil
        )
    }
    
    internal var selectedBrand: String? {
        cardNumberItem.currentBrand?.brand.rawValue
    }
    
    internal var cardBIN: String {
        cardNumberItem.binValue
    }

    internal var validAddress: PostalAddress? {
        let address: PostalAddress
        let requiredFields: Set<AddressField>
        
        switch configuration.billingAddressMode {
        case .lookup, .full:
            guard
                let billingAddressItem = items.billingAddressPickerItem,
                billingAddressItem.isVisible,
                let lookupBillingAddress = billingAddressItem.value
            else { return nil }
            
            address = lookupBillingAddress
            requiredFields = billingAddressItem.addressViewModel.requiredFields
            
        case .postalCode:
            guard items.postalCodeItem.isVisible else { return nil }
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
            configuration.koreanAuthenticationVisibility != .hide,
            let taxNumber = items.additionalAuthCodeItem.nonEmptyValue,
            let password = items.additionalAuthPasswordItem.nonEmptyValue
        else { return nil }
        
        return KCPDetails(taxNumber: taxNumber, password: password)
    }

    internal var socialSecurityNumber: String? {
        guard configuration.socialSecurityNumberVisibility != .hide else { return nil }
        return items.socialSecurityNumberItem.nonEmptyValue
    }
    
    internal var storePayment: Bool? {
        if amount?.value == 0 {
            return true
        }

        return configuration.showStorePaymentMethod ? items.storeDetailsItem.value : nil
    }

    internal var installments: Installments? {
        guard let installmentsItem = items.installmentsItem,
              !installmentsItem.isHidden.wrappedValue else { return nil }
        return installmentsItem.value?.installmentValue
    }
    
    internal func stopLoading() {
        items.button.showsActivityIndicator = false
        view.isUserInteractionEnabled = true
    }
    
    internal func startLoading() {
        items.button.showsActivityIndicator = true
        view.isUserInteractionEnabled = false
    }
    
    internal func handleBinLookupResponse(_ response: BinLookupResponse) {
        let brands: [DetectedCardBrand]
        if response.isCreatedLocally {
            // no dual branding on regex response, get the 1st element
            brands = Array(response.brands?.prefix(1) ?? [])
        } else {
            brands = response.brands ?? []
        }
        
        cardNumberItem.isBrandDetectedLocally = response.isCreatedLocally
        updateBrandDisplayMode(for: brands, isLocal: response.isCreatedLocally)
        
        issuingCountryCode = response.issuingCountryCode
        items.numberContainerItem.update(brands: brands)
        
        updateAddressItemVisibility(basedOn: brands)
    }

    private func triggerBrandEvent(
        of type: AnalyticsEventInfo.InfoType,
        brands: [DetectedCardBrand]
    ) {
        items.triggerInfoEvent(of: type, target: .dualBrandButton, brands: brands)
    }

    private func updateBrandDisplayMode(for brands: [DetectedCardBrand], isLocal: Bool) {
        guard !isLocal else {
            cardNumberItem.brandDisplayMode = .single
            return
        }
        
        let isDualBranded = brands.count == 2 && brands.allSatisfy(\.isSupported)
        let containsAllowedBrands = brands.contains { allowedCoBadgedCardBrands.contains($0.brand) }
        
        if isDualBranded, containsAllowedBrands {
            cardNumberItem.brandDisplayMode = .dualSelectable
            triggerBrandEvent(of: .displayed, brands: brands)
        } else if isDualBranded {
            cardNumberItem.brandDisplayMode = .dualUnselectable
        } else {
            cardNumberItem.brandDisplayMode = .single
        }
    }
}

// MARK: - Private methods

extension CardViewController {
    
    private func updateAddressItemVisibility(basedOn brands: [DetectedCardBrand]) {
        let shouldHide = configuration.billingAddressMode.shouldHide(for: brands.map(\.brand))
        switch configuration.billingAddressMode {
        case .lookup, .full:
            items.billingAddressPickerItem?.isVisible = !shouldHide
            billingAddressSectionItem?.isVisible = !shouldHide
        case .postalCode:
            items.postalCodeItem.isVisible = !shouldHide
        case .none:
            break
        }
    }
    
    /// Observe the brand changes to update all other fields.
    private func observeNumberItem() {
        observe(cardNumberItem.$selectedBrand) { [weak self] newBrand in
            self?.updateFields(from: newBrand)
        }
        cardNumberItem.onUserBrandSelection = { [weak self] selectedBrand in
            self?.triggerBrandEvent(of: .selected, brands: [selectedBrand])
        }
    }

    /// Updates relevant other fields after number field changes
    private func updateFields(from brand: DetectedCardBrand?) {
        items.securityCodeItem.displayMode = brand?.securityCodeItemDisplayMode ?? .required
        items.expiryDateItem.isOptional = brand?.isExpiryDateOptional ?? false
        
        let kcpItemsHidden = shouldHideKcpItems(with: issuingCountryCode)
        items.additionalAuthPasswordItem.isHidden.wrappedValue = kcpItemsHidden
        items.additionalAuthCodeItem.isHidden.wrappedValue = kcpItemsHidden
        items.socialSecurityNumberItem.isHidden.wrappedValue = shouldHideSocialSecurityItem(with: brand)
        // Card-based installment options only apply to brands confirmed by `/binLookup`.
        let reliableBrand = brand?.isReliable == true ? brand?.brand : nil
        items.installmentsItem?.update(cardBrand: reliableBrand)
    }
    
    // MARK: Private methods
    
    private func setupView() {
        append(items.numberContainerItem)

        append(items.expiryDateItem)
        
        if configuration.showSecurityCode {
            append(items.securityCodeItem)
        }
        
        if configuration.showCardholderName {
            append(items.holderNameItem)
        }

        if configuration.koreanAuthenticationVisibility != .hide {
            append(items.additionalAuthCodeItem)
            append(items.additionalAuthPasswordItem)
        }
        
        if configuration.socialSecurityNumberVisibility != .hide {
            append(items.socialSecurityNumberItem)
        }
        
        if let installmentsItem {
            installmentsSectionItem = installmentsItem
            append(installmentsItem)
            bindInstallmentsSectionVisibility()
        }
        
        if StorePaymentMethodPolicy.shouldShowConsent(
            configuredVisible: configuration.showStorePaymentMethod,
            amount: amount
        ) {
            append(items.storeDetailsItem)
            append(FormSpacerItem())
        }
        
        if let billingAddressItem {
            billingAddressSectionItem = billingAddressItem
            append(billingAddressItem)
        }
        
        if configuration.showsSubmitButton {
            append(FormSpacerItem())
            append(items.button)
            append(FormSpacerItem(numberOfSpaces: 2))
        }
    }
    
    /// Keeps the installments section (header + field) visibility in sync with the
    /// installments item, which toggles its own `isHidden` from `update(cardBrand:)`.
    private func bindInstallmentsSectionVisibility() {
        guard let installmentsFormItem = items.installmentsItem else { return }
        installmentsSectionItem?.isVisible = !installmentsFormItem.isHidden.wrappedValue
        observe(installmentsFormItem.isHidden) { [weak self] isHidden in
            self?.installmentsSectionItem?.isVisible = !isHidden
        }
    }
    
    private var installmentsItem: FormItem? {
        guard let installmentsItem = items.installmentsItem else { return nil }
        return installmentsItem.withSectionHeader(
            title: localizedString(.cardInstallmentsTitle, localizationParameters)
        )
    }
    
    private var billingAddressItem: FormItem? {
        
        switch configuration.billingAddressMode {
        case .lookup, .full:
            guard let pickerItem = items.billingAddressPickerItem else { return nil }
            return pickerItem.withSectionHeader(
                title: localizedString(.billingAddressSectionTitle, localizationParameters)
            )

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
        observe(cardNumberItem.publisher) { [weak self] in self?.didChange(pan: $0) }
        observe(cardNumberItem.$binValue) { [weak self] in self?.didChange(bin: $0) }
        
        items.button.buttonSelectionHandler = { [weak cardDelegate] in
            cardDelegate?.didSelectSubmitButton()
        }
    }
    
    private func didChange(pan: String) {
        items.securityCodeItem.selectedCard = supportedCardBrands.adyen.type(forCardNumber: pan)
        cardDelegate?.didChange(pan: pan)
    }
    
    private func didChange(bin: String) {
        cardDelegate?.didChange(bin: bin)
    }
    
    private func shouldHideKcpItems(with countryCode: String?) -> Bool {
        switch configuration.koreanAuthenticationVisibility {
        case .show:
            return false
        case .hide:
            return true
        case .auto:
            return !configuration.showAdditionalAuthenticationFields(for: countryCode)
        }
    }
    
    private func shouldHideSocialSecurityItem(with brand: DetectedCardBrand?) -> Bool {
        guard let brand else { return true }
        switch configuration.socialSecurityNumberVisibility {
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
        let shouldShowConsent = StorePaymentMethodPolicy.shouldShowConsent(
            configuredVisible: isVisible,
            amount: amount
        )
        if !shouldShowConsent {
            items.storeDetailsItem.value = false
        }
        items.storeDetailsItem.isVisible = shouldShowConsent
    }
    
    internal func update(storePaymentMethodFieldValue isOn: Bool) {
        items.storeDetailsItem.value = items.storeDetailsItem.isVisible && isOn
    }
}

// MARK: - Card scanner

extension CardViewController {
    private func handleCardScanningResult(_ result: Result<CardScannerCardDetails, Error>) {
        switch result {
        case let .success((number, expiryDate)):
            if let number {
                items.numberContainerItem.setCardNumber(number)
            }

            if let expiryDate {
                items.expiryDateItem.setExpiryDate(expiryDate)
            }

            focusNextInputField()
        case .failure:
            cardScannerController.dismiss(completion: nil)
        }
    }
}

extension DetectedCardBrand {
    
    internal var securityCodeItemDisplayMode: FormCardSecurityCodeItem.DisplayMode {
        switch self.cvcPolicy {
        case .hidden: return .hidden
        case .optional: return .optional
        case .required: return .required
        }
    }
}
