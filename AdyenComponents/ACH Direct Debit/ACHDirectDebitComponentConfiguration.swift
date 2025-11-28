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

    /// Describes the component's UI style.
    public var style: FormComponentStyle

    /// The theming to apply to the component's UI.
    package var theme: AdyenTheme = .init()

    /// A Boolean value that determines whether the payment button is displayed. Defaults to `true`.
    package var showsSubmitButton: Bool

    /// The shopper's information to be prefilled.
    public var shopperInformation: PrefilledShopperInformation?

    public var localizationParameters: LocalizationParameters?

    /// Indicates if the field for storing the card payment method should be displayed in the form. Defaults to `true`.
    public var showsStorePaymentMethodField: Bool

    /// Determines whether the billing address should be displayed or not.
    /// Defaults to `true`.
    public var showsBillingAddress: Bool

    /// List of ISO country codes that is supported for the billing address.
    /// Defaults to ["US", "PR"].
    public var billingAddressCountryCodes: [String]

    /// Initializes the configuration for ACH Direct Debit Component.
    /// - Parameters:
    ///   - style: The UI style of the component.
    ///   - showsSubmitButton: Boolean value that determines whether the payment button is displayed.
    ///   Defaults to`true`.
    ///   - shopperInformation: The shopper's information to be prefilled.
    ///   - localizationParameters: Localization parameters.
    ///   - showsBillingAddress: Determines whether the billing address should be displayed or not.
    ///   Defaults to `true`.
    ///   - billingAddressCountryCodes: ISO country codes that is supported for the billing address.
    ///   Defaults to ["US", "PR"].
    public init(
        style: FormComponentStyle = FormComponentStyle(),
        showsSubmitButton: Bool = true,
        shopperInformation: PrefilledShopperInformation? = nil,
        localizationParameters: LocalizationParameters? = nil,
        showsStorePaymentMethodField: Bool = true,
        showsBillingAddress: Bool = true,
        billingAddressCountryCodes: [String] = ["US", "PR"]
    ) {
        self.style = style
        self.showsSubmitButton = showsSubmitButton
        self.shopperInformation = shopperInformation
        self.localizationParameters = localizationParameters
        self.showsStorePaymentMethodField = showsStorePaymentMethodField
        self.showsBillingAddress = showsBillingAddress
        self.billingAddressCountryCodes = billingAddressCountryCodes
    }
}
