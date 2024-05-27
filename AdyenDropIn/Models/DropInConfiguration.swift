//
// Copyright (c) 2024 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) import Adyen
#if canImport(AdyenCard)
    @_spi(AdyenInternal) import AdyenCard
#endif
#if canImport(AdyenComponents)
    import AdyenComponents
#endif
#if canImport(AdyenActions)
    @_spi(AdyenInternal) import AdyenActions
#endif
import Foundation
import PassKit

public extension DropInComponent {
    
    /// Contains the configuration for the drop in component and the embedded payment method components.
    final class Configuration: AnyPersonalInformationConfiguration {

        /// Card component related configuration.
        public var card = Card()
        
        /// The Apple Pay configuration.
        public var applePay: ApplePayComponent.Configuration?
        
        /// Payment methods list related configurations.
        public var paymentMethodsList = PaymentMethodListConfiguration()
        
        /// Action components related configurations.
        public var actionComponent = ActionComponentConfiguration()
        
        /// Shopper related information
        public var shopperInformation: PrefilledShopperInformation?
        
        /// Indicates the localization parameters, leave it nil to use the default parameters.
        public var localizationParameters: LocalizationParameters?
        
        /// Determines whether to enable skipping payment list step
        /// when there is only one non-instant payment method.
        /// Default value: `false`.
        public var allowsSkippingPaymentList: Bool

        /// Determines whether to enable preselected stored payment method view step.
        /// Default value: `true`.
        public var allowPreselectedPaymentView: Bool
        
        /// Indicates the UI configuration of the drop in component.
        public var style: DropInComponent.Style

        /// A Boolean value that determines whether the payment button is displayed. For the `DropInComponent` its value is always `false`.
        public var hideDefaultPayButton: Bool = false

        /// Boleto component configuration.
        public var boleto: Boleto = .init()

        /// Configuration for the Cash App Pay component
        public var cashAppPay: CashAppPay?

        /// The ACH Direct Debit configuration.
        public var ach: ACH = .init()

        /// Gift card component configuration
        public var giftCard: GiftCard = .init()

        /// Initializes the drop in configuration.
        /// - Parameters:
        ///   - style: The UI styles of the components.
        ///   - allowsSkippingPaymentList: Boolean to enable skipping payment list when there is only one one non-instant payment method.
        ///   - allowPreselectedPaymentView: Boolean to enable the preselected stored payment method view step.
        public init(style: Style = Style(),
                    allowsSkippingPaymentList: Bool = false,
                    allowPreselectedPaymentView: Bool = true) {
            self.style = style
            self.allowsSkippingPaymentList = allowsSkippingPaymentList
            self.allowPreselectedPaymentView = allowPreselectedPaymentView
        }
    }
    
    /// Action components related configurations.
    struct ActionComponentConfiguration {
        
        public init() { /* Empty initializer */ }
        
        /// Three DS configurations
        public var threeDS: AdyenActionComponent.Configuration.ThreeDS = .init()
        
        /// Twint configurations
        public var twint: AdyenActionComponent.Configuration.Twint?
    }

    /// Boleto component configuration.
    struct Boleto {
        /// Indicates whether to show sendCopyByEmail checkbox and email text field
        public var showEmailAddress: Bool = true
    }

    /// ACH Component configuration specific to Drop In Component.
    struct ACH: AnyACHDirectDebitConfiguration {
        
        /// Indicates if the field for storing the card payment method should be displayed in the form.
        /// Defaults to `true`.
        public var showsStorePaymentMethodField: Bool
        
        /// Determines whether the billing address should be displayed or not.
        /// Defaults to `true`.
        public var showsBillingAddress: Bool
        
        /// List of ISO country codes that is supported for the billing address.
        /// Defaults to `["US", "PR"].
        public var billingAddressCountryCodes: [String]
        
        /// Configuration of the ACH component.
        ///
        /// - Parameters:
        ///   - showsStorePaymentMethodField: Indicates if the field for storing the card payment method should be displayed in the form.
        ///   Defaults to `true`.
        ///   - showsBillingAddress: Determines whether the billing address should be displayed or not.
        ///   Defaults to `true`.
        ///   - billingAddressCountryCodes: List of ISO country codes that is supported for the billing address.
        ///   Defaults to `["US", "PR"].
        public init(showsStorePaymentMethodField: Bool = true,
                    showsBillingAddress: Bool = true,
                    billingAddressCountryCodes: [String] = ["US", "PR"]) {
            self.showsStorePaymentMethodField = showsStorePaymentMethodField
            self.showsBillingAddress = showsBillingAddress
            self.billingAddressCountryCodes = billingAddressCountryCodes
        }
    }
    
    /// Gift card component configuration.
    struct GiftCard {
        /// Indicates whether to show the security code field. Defaults to true.
        public var showsSecurityCodeField: Bool = true
    }
    
    /// Card Component configuration specific to Drop In Component.
    struct Card: AnyCardComponentConfiguration {
        
        /// Indicates if the field for entering the holder name should be displayed in the form. Defaults to false.
        public var showsHolderNameField: Bool

        /// Indicates if the field for storing the card payment method should be displayed in the form. Defaults to true.
        public var showsStorePaymentMethodField: Bool

        /// Indicates whether to show the security code field at all. Defaults to true.
        public var showsSecurityCodeField: Bool

        /// Indicates whether to show the security fields for South Korea issued cards. Defaults to `auto`.
        /// In AUTO mode the field will appear only for card issued in "KR" (South Korea).
        public var koreanAuthenticationMode: CardComponent.FieldVisibility

        /// Indicates the visibility mode for the social security number field (CPF/CNPJ) for Brazilian cards. Defaults to `auto`.
        /// In `auto` mode the field will appear based on card bin lookup.
        public var socialSecurityNumberMode: CardComponent.FieldVisibility

        /// Stored card configuration.
        public var stored: StoredCardConfiguration

        /// The list of allowed card types.  Defaults to nil.
        /// By default list of supported cards is extracted from component's `AnyCardPaymentMethod`.
        /// Use this property to enforce a custom collection of card types.
        public var allowedCardTypes: [CardType]?

        /// Installments options to present to the user.
        public var installmentConfiguration: InstallmentConfiguration?
        
        /// Billing address fields configurations.
        public var billingAddress: BillingAddressConfiguration
        
        /// Configuration of Card component.
        ///
        /// - Parameters:
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
        public init(showsHolderNameField: Bool = false,
                    showsStorePaymentMethodField: Bool = true,
                    showsSecurityCodeField: Bool = true,
                    koreanAuthenticationMode: CardComponent.FieldVisibility = .auto,
                    socialSecurityNumberMode: CardComponent.FieldVisibility = .auto,
                    storedCardConfiguration: StoredCardConfiguration = StoredCardConfiguration(),
                    allowedCardTypes: [CardType]? = nil,
                    installmentConfiguration: InstallmentConfiguration? = nil,
                    billingAddress: BillingAddressConfiguration = .init()) {
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
        
        internal var cardComponentConfiguration: CardComponent.Configuration {
            CardComponent.Configuration(showsHolderNameField: showsHolderNameField,
                                        showsStorePaymentMethodField: showsStorePaymentMethodField,
                                        showsSecurityCodeField: showsSecurityCodeField,
                                        koreanAuthenticationMode: koreanAuthenticationMode,
                                        socialSecurityNumberMode: socialSecurityNumberMode,
                                        storedCardConfiguration: stored,
                                        allowedCardTypes: allowedCardTypes,
                                        installmentConfiguration: installmentConfiguration,
                                        billingAddress: billingAddress)
        }
        
    }
    
    /// Cash App Pay component configuration.
    struct CashAppPay: AnyCashAppPayConfiguration {
        
        /// The URL for Cash App to call in order to redirect back to your application.
        public let redirectURL: URL

        /// A reference to your system (for example, a cart or checkout identifier).
        public let referenceId: String?

        /// Indicates if the field for storing the payment method should be displayed in the form. Defaults to `true`.
        public var showsStorePaymentMethodField: Bool
        
        /// Determines whether to store this payment method. Defaults to `false`.
        /// Ignored if `showsStorePaymentMethodField` is `true`.
        public var storePaymentMethod: Bool
        
        /// Initializes an instance of `CashAppPayComponent.Configuration`
        ///
        /// - Parameters:
        ///   - redirectURL: The URL for Cash App to call in order to redirect back to your application.
        ///   - referenceId: A reference to your system (for example, a cart or checkout identifier).
        ///   - showsStorePaymentMethodField: Determines the visibility of the field for storing the payment method.
        ///   - storePaymentMethod: Determines whether to store this payment method.
        ///   Ignored if `showsStorePaymentMethodField` is `true`.
        public init(redirectURL: URL,
                    referenceId: String? = nil,
                    showsStorePaymentMethodField: Bool = true,
                    storePaymentMethod: Bool = false) {
            self.redirectURL = redirectURL
            self.referenceId = referenceId
            self.showsStorePaymentMethodField = showsStorePaymentMethodField
            self.storePaymentMethod = storePaymentMethod
        }
    }
    
}
