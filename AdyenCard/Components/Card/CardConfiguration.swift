//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
#if canImport(AdyenUI)
    import AdyenUI
#endif

/// Card component configuration.
public struct CardConfiguration: CheckoutComponentConfiguration, AnyPersonalInformationConfiguration {
    
    package let componentType: Adyen.CheckoutComponentType = .payment(.scheme)
    
    package var theme: CheckoutTheme
    
    /// Describes the component's UI style.
    package var style: FormComponentStyle

    /// A boolean value that determines whether the payment button is displayed. Defaults to `true`.
    package var showsSubmitButton: Bool

    /// The shopper's information to be prefilled.
    package var shopperInformation: PrefilledShopperInformation?
    
    package var localizationParameters: LocalizationParameters?

    package var localizationProvider: (any CheckoutLocalizationProvider)?

    /// Indicates if the field for entering the cardholder name should be displayed in the form. Defaults to false.
    internal var showCardholderName: Bool

    /// Indicates if the field for storing the card payment method should be displayed in the form. Defaults to true.
    internal var showStorePaymentMethod: Bool

    /// Indicates whether to show the security code field at all. Defaults to true.
    internal var showSecurityCode: Bool

    /// Indicates whether to show the security fields for South Korea issued cards. Defaults to `auto`.
    /// In AUTO mode the field will appear only for card issued in "KR" (South Korea).
    internal var koreanAuthenticationVisibility: FieldVisibility

    /// Indicates the visibility mode for the social security number field (CPF/CNPJ) for Brazilian cards. Defaults to `auto`.
    /// In `auto` mode the field will appear based on card bin lookup.
    internal var socialSecurityNumberVisibility: FieldVisibility

    /// Indicates whether to show the security code field for stored cards. Defaults to true.
    internal var showSecurityCodeForStoredCard: Bool

    /// The list of supported card brands.  Defaults to nil.
    /// By default list of supported brands is extracted from component's `AnyCardPaymentMethod`.
    /// Use this property to enforce a custom collection of card brands.
    internal var supportedCardBrands: [CardBrand]?

    /// Installments options to present to the user.
    internal var installmentConfiguration: InstallmentConfiguration?
    
    /// Billing address fields configurations.
    internal var billingAddressMode: BillingAddressMode
    
    /// The type used for the bin lookup
    internal var binLookupType: BinLookupRequestType
    
    /// Indicates whether or not to show the supported card brand logos under the card number item
    internal var showSupportedCardBrandLogos: Bool
    
    /// Called when the BIN value changes (first 6-8 digits of the card number).
    internal var onBinChange: ((String) -> Void)?
    
    /// Called when card brand(s) are detected from the entered card number.
    internal var onBinLookup: ((BinLookupData) -> Void)?
    
    // TODO: Add onFieldValidationChange closure that provides field validation
    // updates including last 4 digits, or add it here after deciding on alignment.

    /// Initializes a new instance of `CardComponentConfiguration`.
    public init() {
        self.theme = .init()
        self.style = FormComponentStyle()
        self.showSecurityCodeForStoredCard = true
        self.billingAddressMode = .none
        self.showsSubmitButton = true
        self.showCardholderName = false
        self.showSecurityCode = true
        self.showStorePaymentMethod = true
        self.koreanAuthenticationVisibility = .auto
        self.socialSecurityNumberVisibility = .auto
        self.binLookupType = .card
        self.showSupportedCardBrandLogos = true
    }

    internal func showAdditionalAuthenticationFields(for issuingCountryCode: String?) -> Bool {
        koreanAuthenticationVisibility != .hide && issuingCountryCode == "KR"
    }
}

// MARK: - Public modifiers

extension CardConfiguration {

    /// Sets the shopper's information to be prefilled.
    /// - Parameter shopperInformation: The shopper's information to be prefilled.
    /// - Returns: A modified copy of the configuration.
    public func shopperInformation(_ shopperInformation: PrefilledShopperInformation) -> Self {
        var copy = self
        copy.shopperInformation = shopperInformation
        return copy
    }
    
    /// Sets whether the field for storing the card payment method should be displayed in the form.
    /// - Parameter showStorePaymentMethod: Boolean value indicating if the store payment method toggle should be shown.
    /// - Returns: A modified copy of the configuration.
    public func showStorePaymentMethod(_ showStorePaymentMethod: Bool) -> Self {
        var copy = self
        copy.showStorePaymentMethod = showStorePaymentMethod
        return copy
    }
    
    /// Sets whether to show the security code field.
    /// - Parameter showSecurityCode: Boolean value indicating if the security code field should be shown.
    /// - Returns: A modified copy of the configuration.
    public func showSecurityCode(_ showSecurityCode: Bool) -> Self {
        var copy = self
        copy.showSecurityCode = showSecurityCode
        return copy
    }
    
    /// Sets whether to show the cardholder name field.
    /// - Parameter showCardholderName: Boolean value indicating if the cardholder name field should be shown.
    /// - Returns: A modified copy of the configuration.
    public func showCardholderName(_ showCardholderName: Bool) -> Self {
        var copy = self
        copy.showCardholderName = showCardholderName
        return copy
    }
    
    /// Sets the visibility mode for the security fields for South Korea issued cards.
    /// - Parameter koreanAuthenticationVisibility: The visibility mode. In `.auto` mode the field will appear
    /// only for cards issued in "KR" (South Korea).
    /// - Returns: A modified copy of the configuration.
    public func koreanAuthenticationVisibility(_ koreanAuthenticationVisibility: FieldVisibility) -> Self {
        var copy = self
        copy.koreanAuthenticationVisibility = koreanAuthenticationVisibility
        return copy
    }
    
    /// Sets the visibility mode for the social security number field (CPF/CNPJ) for Brazilian cards.
    /// - Parameter socialSecurityNumberVisibility: The visibility mode. In `.auto` mode the field will appear based on card bin lookup.
    /// - Returns: A modified copy of the configuration.
    public func socialSecurityNumberVisibility(_ socialSecurityNumberVisibility: FieldVisibility) -> Self {
        var copy = self
        copy.socialSecurityNumberVisibility = socialSecurityNumberVisibility
        return copy
    }
    
    /// Sets whether to show the security code field for stored cards.
    /// - Parameter showSecurityCodeForStoredCard: Boolean value indicating if the security code field should be shown for stored cards.
    /// - Returns: A modified copy of the configuration.
    public func showSecurityCodeForStoredCard(_ showSecurityCodeForStoredCard: Bool) -> Self {
        var copy = self
        copy.showSecurityCodeForStoredCard = showSecurityCodeForStoredCard
        return copy
    }
    
    /// Sets the list of supported card brands.
    /// By default the list of supported brands is extracted from component's `AnyCardPaymentMethod`.
    /// Use this to enforce a custom collection of card brands.
    /// - Parameter supportedCardBrands: The list of supported card brands, or `nil` to use the default.
    /// - Returns: A modified copy of the configuration.
    public func supportedCardBrands(_ supportedCardBrands: [CardBrand]?) -> Self {
        var copy = self
        copy.supportedCardBrands = supportedCardBrands
        return copy
    }
    
    /// Sets the installment configuration.
    /// - Parameter installmentConfiguration: The installment options to present to the user, or `nil` for no installments.
    /// - Returns: A modified copy of the configuration.
    public func installmentConfiguration(_ installmentConfiguration: InstallmentConfiguration?) -> Self {
        var copy = self
        copy.installmentConfiguration = installmentConfiguration
        return copy
    }
    
    /// Sets the billing address mode.
    /// - Parameter mode: The billing address display mode.
    /// - Returns: A modified copy of the configuration.
    public func billingAddressMode(_ mode: BillingAddressMode) -> Self {
        var copy = self
        copy.billingAddressMode = mode
        return copy
    }
    
    /// Sets the handler to be called when the BIN value changes.
    /// The BIN is the first 6-8 digits of the card number.
    /// - Parameter onBinChange: The closure to call with the BIN value.
    /// - Returns: A modified copy of the configuration.
    public func onBinChange(_ onBinChange: @escaping (String) -> Void) -> Self {
        var copy = self
        copy.onBinChange = onBinChange
        return copy
    }
    
    /// Sets the handler to be called when card brand(s) are detected.
    /// - Parameter onBinLookup: The closure to call with the BIN lookup result.
    /// - Returns: A modified copy of the configuration.
    public func onBinLookup(_ onBinLookup: @escaping (BinLookupData) -> Void) -> Self {
        var copy = self
        copy.onBinLookup = onBinLookup
        return copy
    }
}

extension CardConfiguration {

    /// The mode of input field on Component UI
    public enum FieldVisibility: String, Codable, CaseIterable {

        /// Always show the field.
        case show

        /// Never show the field.
        case hide

        /// Show the field when a specific condition is met.
        case auto
    }

}
