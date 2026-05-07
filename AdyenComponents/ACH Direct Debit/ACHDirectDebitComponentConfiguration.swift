//
// Copyright (c) 2025 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) import Adyen
import Foundation
import UIKit

#if canImport(AdyenUI)
    import AdyenUI
#endif

/// Configuration for ACH Direct Debit Component.
public struct ACHDirectDebitComponentConfiguration: AnyPersonalInformationConfiguration, CheckoutComponentConfiguration {

    package let componentType: CheckoutComponentType = .payment(.achDirectDebit)

    package var style: FormComponentStyle

    package var theme: CheckoutTheme

    package var showsSubmitButton: Bool

    package var shopperInformation: PrefilledShopperInformation?

    package var localizationParameters: LocalizationParameters?

    package var localizationProvider: (any CheckoutLocalizationProvider)?

    package var showStorePaymentMethodField: Bool

    package var showBillingAddress: Bool

    package var billingAddressCountryCodes: [String]

    /// Initializes the configuration for ACH Direct Debit Component.
    public init() {
        self.style = FormComponentStyle()
        self.showsSubmitButton = true
        self.shopperInformation = nil
        self.localizationParameters = nil
        self.showStorePaymentMethodField = true
        self.showBillingAddress = true
        self.billingAddressCountryCodes = ["US", "PR"]
        self.theme = .init()
    }
}

extension ACHDirectDebitComponentConfiguration {
    /// Sets the shopper's information to be prefilled.
    /// - Parameter shopperInformation: The shopper's information to prefill.
    /// - Returns: A modified configuration with the updated shopper information.
    public func shopperInformation(_ shopperInformation: PrefilledShopperInformation?) -> Self {
        var config = self
        config.shopperInformation = shopperInformation
        return config
    }

    /// Sets the localization parameters.
    /// - Parameter localizationParameters: The localization parameters to use.
    /// - Returns: A modified configuration with the updated localization parameters.
    package func localizationParameters(_ localizationParameters: LocalizationParameters?) -> Self {
        var config = self
        config.localizationParameters = localizationParameters
        return config
    }

    /// Sets whether the field for storing the payment method should be displayed.
    /// - Parameter showStorePaymentMethodField: A Boolean value indicating whether to show the store payment method field.
    /// - Returns: A modified configuration with the updated setting.
    public func showStorePaymentMethodField(_ showStorePaymentMethodField: Bool) -> Self {
        var config = self
        config.showStorePaymentMethodField = showStorePaymentMethodField
        return config
    }

    /// Sets whether the billing address should be displayed.
    /// - Parameter showBillingAddress: A Boolean value indicating whether to show the billing address.
    /// - Returns: A modified configuration with the updated setting.
    public func showBillingAddress(_ showBillingAddress: Bool) -> Self {
        var config = self
        config.showBillingAddress = showBillingAddress
        return config
    }

    /// Sets the list of ISO country codes supported for the billing address.
    /// - Parameter billingAddressCountryCodes: An array of ISO country codes.
    /// - Returns: A modified configuration with the updated country codes.
    public func billingAddressCountryCodes(_ billingAddressCountryCodes: [String]) -> Self {
        var config = self
        config.billingAddressCountryCodes = billingAddressCountryCodes
        return config
    }
}
