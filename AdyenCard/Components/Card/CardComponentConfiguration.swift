//
// Copyright (c) 2022 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) import Adyen

/// Billing address fields configurations
public struct BillingAddressConfiguration {
    
    /// Initializes a new instance of `BillingAddressConfiguration`.
    public init() { /* Empty initializer */ }
    
    /// Indicates the display mode of the billing address form. Defaults to none.
    public var mode: CardComponent.AddressFormType = .none
    
    /// List of ISO country codes that is supported for the billing address.
    /// When nil, all countries are provided.
    public var countryCodes: [String]?
    
    /// Indicates the requirement level of a field.
    public var requirementPolicy: RequirementPolicy = .required
    
    /// Indicates the requirement level of a field.
    public enum RequirementPolicy {

        /// Field is required.
        case required

        /// Field is optional.
        case optional

        /// Field is optional only for provided card types.
        case optionalForCardTypes(Set<CardType>)
    }
    
    @_spi(AdyenInternal)
    public func isOptional(for cardTypes: [CardType]) -> Bool {
        switch requirementPolicy {
        case .required:
            return false
        case .optional:
            return true
        case let .optionalForCardTypes(optionalCardTypes):
            return optionalCardTypes.isDisjoint(with: cardTypes) == false
        }
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
    var koreanAuthenticationMode: CardComponent.FieldVisibility { get }

    /// Indicates the visibility mode for the social security number field (CPF/CNPJ) for Brazilian cards. Defaults to `auto`.
    /// In `auto` mode the field will appear based on card bin lookup.
    var socialSecurityNumberMode: CardComponent.FieldVisibility { get }

    /// Billing address fields configurations
    var billingAddress: BillingAddressConfiguration { get }

    /// Stored card configuration.
    var stored: StoredCardConfiguration { get }

    /// The list of allowed card types.  Defaults to nil.
    /// By default list of supported cards is extracted from component's `AnyCardPaymentMethod`.
    /// Use this property to enforce a custom collection of card types.
    var allowedCardTypes: [CardType]? { get }

    /// Installments options to present to the user.
    var installmentConfiguration: InstallmentConfiguration? { get }
}

extension CardComponent {

    /// The mode of address form of card component
    public enum AddressFormType {

        /// Display full address form
        case full

        /// Display simple form with only zip code field
        case postalCode

        /// Do not display address form
        case none
    }

    /// The mode of input field on Component UI
    public enum FieldVisibility {

        /// Always show the field.
        case show

        /// Never show the field.
        case hide

        /// Show the field when a specific condition is met.
        case auto
    }

    /// Card component configuration.
    public struct Configuration: AnyCardComponentConfiguration, AnyPersonalInformationConfiguration {

        /// Describes the component's UI style.
        public var style: FormComponentStyle
        
        /// The shopper's information to be prefilled.
        public var shopperInformation: PrefilledShopperInformation?
        
        public var localizationParameters: LocalizationParameters?

        /// Indicates if the field for entering the holder name should be displayed in the form. Defaults to false.
        public var showsHolderNameField: Bool

        /// Indicates if the field for storing the card payment method should be displayed in the form. Defaults to true.
        public var showsStorePaymentMethodField: Bool

        /// Indicates whether to show the security code field at all. Defaults to true.
        public var showsSecurityCodeField: Bool

        /// Indicates whether to show the security fields for South Korea issued cards. Defaults to `auto`.
        /// In AUTO mode the field will appear only for card issued in "KR" (South Korea).
        public var koreanAuthenticationMode: FieldVisibility

        /// Indicates the visibility mode for the social security number field (CPF/CNPJ) for Brazilian cards. Defaults to `auto`.
        /// In `auto` mode the field will appear based on card bin lookup.
        public var socialSecurityNumberMode: FieldVisibility

        /// Stored card configuration.
        public var stored: StoredCardConfiguration

        /// The list of allowed card types.  Defaults to nil.
        /// By default list of supported cards is extracted from component's `AnyCardPaymentMethod`.
        /// Use this property to enforce a custom collection of card types.
        public var allowedCardTypes: [CardType]?

        /// Indicates the card brands excluded from the supported brands.
        internal var excludedCardTypes: Set<CardType> = [.bcmc]

        /// Installments options to present to the user.
        public var installmentConfiguration: InstallmentConfiguration?
        
        /// Billing address fields configurations.
        public var billingAddress: BillingAddressConfiguration

        /// Configuration of Card component.
        /// - Parameters:
        ///   - style: The component's UI style.
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
        public init(style: FormComponentStyle = FormComponentStyle(),
                    shopperInformation: PrefilledShopperInformation? = nil,
                    localizationParameters: LocalizationParameters? = nil,
                    showsHolderNameField: Bool = false,
                    showsStorePaymentMethodField: Bool = true,
                    showsSecurityCodeField: Bool = true,
                    koreanAuthenticationMode: FieldVisibility = .auto,
                    socialSecurityNumberMode: FieldVisibility = .auto,
                    storedCardConfiguration: StoredCardConfiguration = StoredCardConfiguration(),
                    allowedCardTypes: [CardType]? = nil,
                    installmentConfiguration: InstallmentConfiguration? = nil,
                    billingAddress: BillingAddressConfiguration = .init()) {
            self.style = style
            self.shopperInformation = shopperInformation
            self.localizationParameters = localizationParameters
            self.showsHolderNameField = showsHolderNameField
            self.showsSecurityCodeField = showsSecurityCodeField
            self.showsStorePaymentMethodField = showsStorePaymentMethodField
            self.stored = storedCardConfiguration
            self.allowedCardTypes = allowedCardTypes
            self.koreanAuthenticationMode = koreanAuthenticationMode
            self.socialSecurityNumberMode = socialSecurityNumberMode
            self.installmentConfiguration = installmentConfiguration
            self.billingAddress = billingAddress
        }

        internal func bcmcConfiguration() -> Configuration {
            var storedCardConfiguration = stored
            storedCardConfiguration.showsSecurityCodeField = false
            var configuration = Configuration(style: style,
                                              showsHolderNameField: showsHolderNameField,
                                              showsStorePaymentMethodField: showsStorePaymentMethodField,
                                              showsSecurityCodeField: false,
                                              storedCardConfiguration: storedCardConfiguration,
                                              allowedCardTypes: [.bcmc])
            configuration.excludedCardTypes = []
            return configuration
        }

        internal func showAdditionalAuthenticationFields(for issuingCountryCode: String?) -> Bool {
            koreanAuthenticationMode != .hide && issuingCountryCode == "KR"
        }
    }

}
