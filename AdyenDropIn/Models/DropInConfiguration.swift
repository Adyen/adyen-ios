//
// Copyright (c) 2022 Adyen N.V.
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
    final class Configuration: AdyenContextAware {
        
        /// Card component related configuration.
        public var card = Card()
        
        /// The Apple Pay configuration.
        public var applePay: ApplePayComponent.Configuration?
        
        /// Payment methods list related configurations.
        public var paymentMethodsList = PaymentMethodListConfiguration()
        
        /// Action components related configurations.
        public var actionComponent = ActionComponentConfiguration()
        
        /// Shopper related information
        public var shopper: PrefilledShopperInformation?

        /// :nodoc:
        /// The context object for this component.
        public let context: AdyenContext
        
        /// Indicates the localization parameters, leave it nil to use the default parameters.
        public var localizationParameters: LocalizationParameters?

        /// The payment information.
        public var payment: Adyen.Payment?
        
        /// Determines whether to enable skipping payment list step
        /// when there is only one non-instant payment method.
        /// Default value: `false`.
        public let allowsSkippingPaymentList: Bool

        /// Determines whether to enable preselected stored payment method view step.
        /// Default value: `true`.
        public let allowPreselectedPaymentView: Bool
        
        /// Indicates the UI configuration of the drop in component.
        public let style: DropInComponent.Style
        
        /// Initializes the drop in configuration.
        /// - Parameters:
        ///   - context: The context object for this component.
        ///   - style: The UI styles of the components.
        ///   - allowsSkippingPaymentList: Boolean to enable skipping payment list when there is only one one non-instant payment method.
        ///   - allowPreselectedPaymentView: Boolean to enable the preselected stored payment method view step.
        public init(context: AdyenContext,
                    style: Style = Style(),
                    allowsSkippingPaymentList: Bool = false,
                    allowPreselectedPaymentView: Bool = true) {
            self.context = context
            self.style = style
            self.allowsSkippingPaymentList = allowsSkippingPaymentList
            self.allowPreselectedPaymentView = allowPreselectedPaymentView
        }
    }
    
    struct ActionComponentConfiguration {
        /// Three DS configurations
        public var threeDS: AdyenActionComponent.Configuration.ThreeDS = .init()
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

        /// Indicates the display mode of the billing address form. Defaults to none.
        public var billingAddressMode: CardComponent.AddressFormType

        /// Stored card configuration.
        public var stored: StoredCardConfiguration

        /// The list of allowed card types.  Defaults to nil.
        /// By default list of supported cards is extracted from component's `AnyCardPaymentMethod`.
        /// Use this property to enforce a custom collection of card types.
        public var allowedCardTypes: [CardType]?

        /// Indicates the card brands excluded from the supported brands.
        public var excludedCardTypes: Set<CardType> = [.bcmc]

        /// Installments options to present to the user.
        public var installmentConfiguration: InstallmentConfiguration?
        
        /// List of ISO country codes that is supported for the billing address.
        /// When nil, all countries are provided.
        public var billingAddressCountryCodes: [String]?
        
        public init(showsHolderNameField: Bool = false,
                    showsStorePaymentMethodField: Bool = true,
                    showsSecurityCodeField: Bool = true,
                    koreanAuthenticationMode: CardComponent.FieldVisibility = .auto,
                    socialSecurityNumberMode: CardComponent.FieldVisibility = .auto,
                    billingAddressMode: CardComponent.AddressFormType = .none,
                    storedCardConfiguration: StoredCardConfiguration = StoredCardConfiguration(),
                    allowedCardTypes: [CardType]? = nil,
                    installmentConfiguration: InstallmentConfiguration? = nil,
                    billingAddressCountryCodes: [String]? = nil) {
            self.showsHolderNameField = showsHolderNameField
            self.showsSecurityCodeField = showsSecurityCodeField
            self.showsStorePaymentMethodField = showsStorePaymentMethodField
            self.stored = storedCardConfiguration
            self.allowedCardTypes = allowedCardTypes
            self.billingAddressMode = billingAddressMode
            self.koreanAuthenticationMode = koreanAuthenticationMode
            self.socialSecurityNumberMode = socialSecurityNumberMode
            self.installmentConfiguration = installmentConfiguration
            self.billingAddressCountryCodes = billingAddressCountryCodes
        }
        
        public var cardComponentConfiguration: CardComponent.Configuration {
            CardComponent.Configuration(showsHolderNameField: showsHolderNameField,
                                        showsStorePaymentMethodField: showsStorePaymentMethodField,
                                        showsSecurityCodeField: showsSecurityCodeField,
                                        koreanAuthenticationMode: koreanAuthenticationMode,
                                        socialSecurityNumberMode: socialSecurityNumberMode,
                                        billingAddressMode: billingAddressMode,
                                        storedCardConfiguration: stored,
                                        allowedCardTypes: allowedCardTypes,
                                        installmentConfiguration: installmentConfiguration,
                                        billingAddressCountryCodes: billingAddressCountryCodes)
        }
        
    }
    
}
