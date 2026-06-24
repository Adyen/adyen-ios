//
// Copyright (c) 2019 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
#if canImport(AdyenCard)
    import AdyenCard
#endif
#if canImport(AdyenComponents)
    import AdyenComponents
#endif
#if canImport(AdyenActions)
    import AdyenActions
#endif
#if canImport(AdyenUI)
    import AdyenUI
#endif
import Foundation
import PassKit

// TODO: get rid of duplicate component configs inside dropin. they should be only one specified by merchant
package extension DropInComponent {

    /// Contains the configuration for the drop in component and the embedded payment method components.
    final class Configuration: AnyPersonalInformationConfiguration {

        /// Card component related configuration.
        package var card = Card()

        /// The Apple Pay configuration.
        package var applePay: ApplePayConfiguration?

        /// Payment methods list related configurations.
        package var paymentMethodsList = PaymentMethodListConfiguration()

        /// Action components related configurations.
        package var actionComponent = ActionComponentConfiguration()

        /// Shopper related information
        package var shopperInformation: PrefilledShopperInformation?

        /// Indicates the localization parameters, leave it nil to use the default parameters.
        package var localizationParameters: LocalizationParameters?
        /// Determines whether to enable skipping payment list step
        /// when there is only one non-instant payment method.
        /// Default value: `false`.
        package var allowsSkippingPaymentList: Bool

        /// Determines whether to enable preselected stored payment method view step.
        /// Default value: `true`.
        package var allowPreselectedPaymentView: Bool

        /// Indicates the UI configuration of the drop in component.
        package var style: DropInComponent.Style

        /// Indicates the UI style configuration of the drop in component.
        package var theme: CheckoutTheme = .default

        /// Boleto component configuration.
        package var boleto: Boleto = .init()

        /// Configuration for the Cash App Pay component
        package var cashAppPay: CashAppPay?

        /// The ACH Direct Debit configuration.
        package var ach: ACH = .init()

        /// Gift card component configuration
        package var giftCard: GiftCard = .init()

        /// Initializes the drop in configuration.
        /// - Parameters:
        ///   - style: The UI styles of the components.
        ///   - allowsSkippingPaymentList: Boolean to enable skipping payment list when there is only one one non-instant payment method.
        ///   - allowPreselectedPaymentView: Boolean to enable the preselected stored payment method view step.
        package init(
            style: Style = Style(),
            theme: CheckoutTheme = .default,
            allowsSkippingPaymentList: Bool = false,
            allowPreselectedPaymentView: Bool = true
        ) {
            self.style = style
            self.allowsSkippingPaymentList = allowsSkippingPaymentList
            self.allowPreselectedPaymentView = allowPreselectedPaymentView
            self.theme = theme
        }
    }
    
    /// Action components related configurations.
    struct ActionComponentConfiguration {
        
        package init() { /* Empty initializer */ }

        /// Three DS configurations
        package var authentication: AuthenticationConfiguration = .init()

        /// Twint configurations
        package var twint: TwintActionConfiguration?
    }

    /// Boleto component configuration.
    struct Boleto {
        /// Indicates whether to show sendCopyByEmail checkbox and email text field
        package var showEmailAddress: Bool = true
    }

    /// ACH Component configuration specific to Drop In Component.
    struct ACH {
        
        /// Indicates if the field for storing the card payment method should be displayed in the form.
        /// Defaults to `true`.
        package var showsStorePaymentMethodField: Bool

        /// Determines whether the billing address should be displayed or not.
        /// Defaults to `true`.
        package var showsBillingAddress: Bool

        /// List of ISO country codes that is supported for the billing address.
        /// Defaults to `["US", "PR"].
        package var billingAddressCountryCodes: [String]

        /// Configuration of the ACH component.
        ///
        /// - Parameters:
        ///   - showsStorePaymentMethodField: Indicates if the field for storing the card payment method should be displayed in the form.
        ///   Defaults to `true`.
        ///   - showsBillingAddress: Determines whether the billing address should be displayed or not.
        ///   Defaults to `true`.
        ///   - billingAddressCountryCodes: List of ISO country codes that is supported for the billing address.
        ///   Defaults to `["US", "PR"].
        package init(
            showsStorePaymentMethodField: Bool = true,
            showsBillingAddress: Bool = true,
            billingAddressCountryCodes: [String] = ["US", "PR"]
        ) {
            self.showsStorePaymentMethodField = showsStorePaymentMethodField
            self.showsBillingAddress = showsBillingAddress
            self.billingAddressCountryCodes = billingAddressCountryCodes
        }
    }
    
    /// Gift card component configuration.
    struct GiftCard {
        /// Indicates whether to show the security code field. Defaults to true.
        package var showsSecurityCodeField: Bool = true
    }
    
    // TODO: since these will be removed, changes on card config don't need to be added here
    /// Card Component configuration specific to Drop In Component.
    struct Card: AnyCardComponentConfiguration {
        
        /// Indicates if the field for entering the cardholder name should be displayed in the form. Defaults to false.
        package var showCardholderName: Bool

        /// Indicates if the field for storing the card payment method should be displayed in the form. Defaults to true.
        package var showStorePaymentMethod: Bool

        /// Indicates whether to show the security code field at all. Defaults to true.
        package var showSecurityCode: Bool

        /// Indicates whether to show the security fields for South Korea issued cards. Defaults to `auto`.
        /// In AUTO mode the field will appear only for card issued in "KR" (South Korea).
        package var koreanAuthenticationVisibility: CardConfiguration.FieldVisibility

        /// Indicates the visibility mode for the social security number field (CPF/CNPJ) for Brazilian cards. Defaults to `auto`.
        /// In `auto` mode the field will appear based on card bin lookup.
        package var socialSecurityNumberVisibility: CardConfiguration.FieldVisibility

        /// Indicates whether to show the security code field for stored cards. Defaults to true.
        package var showSecurityCodeForStoredCard: Bool

        /// The list of supported card brands.  Defaults to nil.
        /// By default list of supported brands is extracted from component's `AnyCardPaymentMethod`.
        /// Use this property to enforce a custom collection of card brands.
        package var supportedCardBrands: [CardBrand]?

        /// Installments options to present to the user.
        package var installmentConfiguration: InstallmentConfiguration?

        /// Configuration of Card component.
        ///
        /// - Parameters:
        ///   - showCardholderName: Indicates if the field for entering the cardholder name should be displayed in the form.
        ///   Defaults to `false`.
        ///   - showStorePaymentMethod: Indicates if the field for storing the card payment method should be displayed in the form.
        ///   Defaults to `true`.
        ///   - showSecurityCode: Indicates whether to show the security code field at all.
        ///   Defaults to `true`.
        ///   - koreanAuthenticationVisibility: Indicates the visibility option for the security fields for South Korea issued cards.
        ///   Defaults to `.auto`.
        ///   - socialSecurityNumberVisibility: Indicates the visibility option for the security code field. Defaults to `.auto`
        ///   - showSecurityCodeForStoredCard: Indicates whether to show the security code field for stored cards. Defaults to `true`.
        ///   - supportedCardBrands: The enforced list of supported card brands.
        ///   - installmentConfiguration: Configuration for installments. Defaults to `nil`.
        ///   - billingAddress: Billing address fields configurations.
        package init(
            showCardholderName: Bool = false,
            showStorePaymentMethod: Bool = true,
            showSecurityCode: Bool = true,
            koreanAuthenticationVisibility: CardConfiguration.FieldVisibility = .auto,
            socialSecurityNumberVisibility: CardConfiguration.FieldVisibility = .auto,
            showSecurityCodeForStoredCard: Bool = true,
            supportedCardBrands: [CardBrand]? = nil,
            installmentConfiguration: InstallmentConfiguration? = nil
        ) {
            self.showCardholderName = showCardholderName
            self.showSecurityCode = showSecurityCode
            self.showStorePaymentMethod = showStorePaymentMethod
            self.showSecurityCodeForStoredCard = showSecurityCodeForStoredCard
            self.supportedCardBrands = supportedCardBrands
            self.koreanAuthenticationVisibility = koreanAuthenticationVisibility
            self.socialSecurityNumberVisibility = socialSecurityNumberVisibility
            self.installmentConfiguration = installmentConfiguration
        }
        
        internal var cardConfiguration: CardConfiguration {
            CardConfiguration()
        }
        
    }
    
    /// Cash App Pay component configuration.
    struct CashAppPay: AnyCashAppPayConfiguration {

        /// The URL for Cash App to call in order to redirect back to your application.
        package let redirectURL: URL

        /// A reference to your system (for example, a cart or checkout identifier).
        package let referenceId: String?

        /// Indicates if the field for storing the payment method should be displayed in the form. Defaults to `true`.
        package var showsStorePaymentMethodField: Bool

        /// Determines whether to store this payment method. Defaults to `false`.
        /// Ignored if `showsStorePaymentMethodField` is `true`.
        package var storePaymentMethod: Bool

        /// Initializes an instance of `CashAppPayComponent.Configuration`
        ///
        /// - Parameters:
        ///   - redirectURL: The URL for Cash App to call in order to redirect back to your application.
        ///   - referenceId: A reference to your system (for example, a cart or checkout identifier).
        ///   - showsStorePaymentMethodField: Determines the visibility of the field for storing the payment method.
        ///   - storePaymentMethod: Determines whether to store this payment method.
        ///   Ignored if `showsStorePaymentMethodField` is `true`.
        package init(
            redirectURL: URL,
            referenceId: String? = nil,
            showsStorePaymentMethodField: Bool = true,
            storePaymentMethod: Bool = false
        ) {
            self.redirectURL = redirectURL
            self.referenceId = referenceId
            self.showsStorePaymentMethodField = showsStorePaymentMethodField
            self.storePaymentMethod = storePaymentMethod
        }
    }
}
