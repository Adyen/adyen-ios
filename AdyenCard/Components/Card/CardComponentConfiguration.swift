//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) import Adyen
#if canImport(AdyenUI)
    @_spi(AdyenInternal) import AdyenUI
#endif

/// Card component configuration.
public struct CardComponentConfiguration: CheckoutComponentConfiguration, AnyPersonalInformationConfiguration {
    
    package let componentType: Adyen.CheckoutComponentType = .payment(.scheme)
    
    package var theme: AdyenTheme = .init()
    
    /// Describes the component's UI style.
    package var style: FormComponentStyle

    /// A boolean value that determines whether the payment button is displayed. Defaults to `true`.
    package var showsSubmitButton: Bool

    /// The shopper's information to be prefilled.
    package var shopperInformation: PrefilledShopperInformation?
    
    package var localizationParameters: LocalizationParameters?

    /// Indicates if the field for entering the holder name should be displayed in the form. Defaults to false.
    internal var showsHolderNameField: Bool

    /// Indicates if the field for storing the card payment method should be displayed in the form. Defaults to true.
    internal var showsStorePaymentMethodField: Bool

    /// Indicates whether to show the security code field at all. Defaults to true.
    internal var showsSecurityCodeField: Bool

    /// Indicates whether to show the security fields for South Korea issued cards. Defaults to `auto`.
    /// In AUTO mode the field will appear only for card issued in "KR" (South Korea).
    internal var koreanAuthenticationMode: FieldVisibility

    /// Indicates the visibility mode for the social security number field (CPF/CNPJ) for Brazilian cards. Defaults to `auto`.
    /// In `auto` mode the field will appear based on card bin lookup.
    internal var socialSecurityNumberMode: FieldVisibility

    // TODO: Move this to its own config?
    /// Stored card configuration.
    internal var stored: StoredCardConfiguration = .init()

    /// The list of allowed card types.  Defaults to nil.
    /// By default list of supported cards is extracted from component's `AnyCardPaymentMethod`.
    /// Use this property to enforce a custom collection of card types.
    internal var allowedCardTypes: [CardType]?

    /// Installments options to present to the user.
    internal var installmentConfiguration: InstallmentConfiguration?
    
    /// Billing address fields configurations.
    internal var billingAddress: BillingAddressConfiguration = .init()
    
    /// The type used for the bin lookup
    internal var binLookupType: BinLookupRequestType = .card
    
    /// Indicates whether or not to show the supported card logos under the card number item
    internal var showsSupportedCardLogos: Bool = true

    /// Configuration of Card component.
    /// - Parameters:
    ///   - style: The component's UI style.
    ///   - showsSubmitButton: Boolean value that determines whether the payment button is displayed.
    ///   Defaults to `true`.
    ///   - shopperInformation: The shopper's information to be prefilled.
    ///   - localizationParameters: Localization parameters.
    ///   - showsHolderNameField: Indicates if the field for entering the holder name should be displayed in the form.
    ///   Defaults to `false`.
    ///   - showsStorePaymentMethodField: Indicates if the field for storing the card payment method should be displayed in the form.
    ///   Defaults to `true`.
    ///   - showsSecurityCodeField: Indicates whether to show the security code field at all.
    ///   Defaults to `true`.
    ///   - koreanAuthenticationMode: Indicates the visibility option for the security fields for South Korea issued cards.
    ///   Defaults to `.auto`.
    ///   - socialSecurityNumberMode: Indicates the visibility option for the security code field. Defaults to `.auto`
    ///   - storedCardConfiguration: Stored card configuration.
    ///   - allowedCardTypes: The enforced list of allowed card types.
    ///   - installmentConfiguration: Configuration for installments. Defaults to `nil`.
    ///   - billingAddress: Billing address fields configurations.
    public init(
        style: FormComponentStyle = FormComponentStyle(),
        showsSubmitButton: Bool = true,
        shopperInformation: PrefilledShopperInformation? = nil,
        localizationParameters: LocalizationParameters? = nil,
        showsHolderNameField: Bool = false,
        showsStorePaymentMethodField: Bool = true,
        showsSecurityCodeField: Bool = true,
        koreanAuthenticationMode: FieldVisibility = .auto,
        socialSecurityNumberMode: FieldVisibility = .auto,
        allowedCardTypes: [CardType]? = nil
    ) {
        self.style = style
        self.showsSubmitButton = showsSubmitButton
        self.shopperInformation = shopperInformation
        self.localizationParameters = localizationParameters
        self.showsHolderNameField = showsHolderNameField
        self.showsSecurityCodeField = showsSecurityCodeField
        self.showsStorePaymentMethodField = showsStorePaymentMethodField
        self.allowedCardTypes = allowedCardTypes
        self.koreanAuthenticationMode = koreanAuthenticationMode
        self.socialSecurityNumberMode = socialSecurityNumberMode
    }

    internal func showAdditionalAuthenticationFields(for issuingCountryCode: String?) -> Bool {
        koreanAuthenticationMode != .hide && issuingCountryCode == "KR"
    }
}

// MARK: - Public modifiers

extension CardComponentConfiguration {
    
    /// Sets the shopper's information to be prefilled.
    /// - Parameter shopperInformation: The shopper's information to be prefilled.
    /// - Returns: A modified copy of the configuration.
    public func shopperInformation(_ shopperInformation: PrefilledShopperInformation) -> Self {
        var copy = self
        copy.shopperInformation = shopperInformation
        return copy
    }
    
    /// Sets whether the field for storing the card payment method should be displayed in the form.
    /// - Parameter showsStorePaymentMethodField: Boolean value indicating if the store payment method toggle should be shown.
    /// - Returns: A modified copy of the configuration.
    public func showsStorePaymentMethodField(_ showsStorePaymentMethodField: Bool) -> Self {
        var copy = self
        copy.showsStorePaymentMethodField = showsStorePaymentMethodField
        return copy
    }
    
    /// Sets whether to show the security code field.
    /// - Parameter showsSecurityCodeField: Boolean value indicating if the security code field should be shown.
    /// - Returns: A modified copy of the configuration.
    public func showsSecurityCodeField(_ showsSecurityCodeField: Bool) -> Self {
        var copy = self
        copy.showsSecurityCodeField = showsSecurityCodeField
        return copy
    }
    
    /// Sets the visibility mode for the security fields for South Korea issued cards.
    /// - Parameter koreanAuthenticationMode: The visibility mode. In `.auto` mode the field will appear only for cards issued in "KR" (South Korea).
    /// - Returns: A modified copy of the configuration.
    public func koreanAuthenticationMode(_ koreanAuthenticationMode: FieldVisibility) -> Self {
        var copy = self
        copy.koreanAuthenticationMode = koreanAuthenticationMode
        return copy
    }
    
    /// Sets the visibility mode for the social security number field (CPF/CNPJ) for Brazilian cards.
    /// - Parameter socialSecurityNumberMode: The visibility mode. In `.auto` mode the field will appear based on card bin lookup.
    /// - Returns: A modified copy of the configuration.
    public func socialSecurityNumberMode(_ socialSecurityNumberMode: FieldVisibility) -> Self {
        var copy = self
        copy.socialSecurityNumberMode = socialSecurityNumberMode
        return copy
    }
    
    /// Sets the stored card configuration.
    /// - Parameter stored: The stored card configuration.
    /// - Returns: A modified copy of the configuration.
    public func stored(_ stored: StoredCardConfiguration) -> Self {
        var copy = self
        copy.stored = stored
        return copy
    }
    
    /// Sets the list of allowed card types.
    /// By default list of supported cards is extracted from component's `AnyCardPaymentMethod`.
    /// Use this to enforce a custom collection of card types.
    /// - Parameter allowedCardTypes: The list of allowed card types, or `nil` to use the default.
    /// - Returns: A modified copy of the configuration.
    public func allowedCardTypes(_ allowedCardTypes: [CardType]?) -> Self {
        var copy = self
        copy.allowedCardTypes = allowedCardTypes
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
    
    /// Sets the billing address fields configuration.
    /// - Parameter billingAddress: The billing address configuration.
    /// - Returns: A modified copy of the configuration.
    public func billingAddress(_ billingAddress: BillingAddressConfiguration) -> Self {
        var copy = self
        copy.billingAddress = billingAddress
        return copy
    }
}

/// Describes any configuration for the card component.
public protocol AnyCardComponentConfiguration {
    
    /// Indicates if the field for entering the holder name should be displayed in the form. Defaults to false.
    var showsHolderNameField: Bool { get }

    /// Indicates if the field for storing the card payment method should be displayed in the form. Defaults to true.
    var showsStorePaymentMethodField: Bool { get }

    /// Indicates whether to show the security code field at all. Defaults to true.
    var showsSecurityCodeField: Bool { get }

    /// Indicates whether to show the security fields for South Korea issued cards. Defaults to `auto`.
    /// In AUTO mode the field will appear only for card issued in "KR" (South Korea).
    var koreanAuthenticationMode: CardComponentConfiguration.FieldVisibility { get }

    /// Indicates the visibility mode for the social security number field (CPF/CNPJ) for Brazilian cards. Defaults to `auto`.
    /// In `auto` mode the field will appear based on card bin lookup.
    var socialSecurityNumberMode: CardComponentConfiguration.FieldVisibility { get }

    /// Billing address fields configurations
//    var billingAddress: BillingAddressConfiguration { get }

    /// Stored card configuration.
    var stored: StoredCardConfiguration { get }

    /// The list of allowed card types.  Defaults to nil.
    /// By default list of supported cards is extracted from component's `AnyCardPaymentMethod`.
    /// Use this property to enforce a custom collection of card types.
    var allowedCardTypes: [CardType]? { get }

    /// Installments options to present to the user.
    var installmentConfiguration: InstallmentConfiguration? { get }
}

extension CardComponentConfiguration {

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
