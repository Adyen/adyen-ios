//
// Copyright (c) 2023 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
#if canImport(AdyenUI)
    import AdyenUI
#endif
import Foundation

/// Configuration for Cash App Pay Component.
package struct CashAppPayConfiguration: AnyCashAppPayConfiguration {

    /// The URL for Cash App to call in order to redirect back to your application.
    package let redirectURL: URL

    /// A reference to your system (for example, a cart or checkout identifier).
    package let referenceId: String?

    /// Indicates if the field for storing the payment method should be displayed in the form. Defaults to `true`.
    package var showsStorePaymentMethodField: Bool

    /// Determines whether to store this payment method. Defaults to `false`.
    /// Ignored if `showsStorePaymentMethodField` is `true`.
    package var storePaymentMethod: Bool

    /// Describes the component's UI style.
    package var style: FormComponentStyle

    /// A boolean value that determines whether the payment button is displayed. Defaults to `true`.
    internal let showsSubmitButton: Bool

    /// The localization parameters, leave it nil to use the default parameters.
    package var localizationParameters: LocalizationParameters?

    /// Initializes an instance of `CashAppPayComponent.Configuration`
    ///
    /// - Parameters:
    ///   - redirectURL: The URL for Cash App to call in order to redirect back to your application.
    ///   - referenceId: A reference to your system (for example, a cart or checkout identifier).
    ///   - showsStorePaymentMethodField: Determines the visibility of the field for storing the payment method.
    ///   - storePaymentMethod: Determines whether to store this payment method.
    ///   Ignored if `showsStorePaymentMethodField` is `true`.
    ///   - style: The UI style of the component.
    ///   - showsSubmitButton: Boolean value that determines whether the payment button is displayed.
    ///   Defaults to `true`.
    ///   - localizationParameters: The localization parameters, leave it nil to use the default parameters.
    package init(
        redirectURL: URL,
        referenceId: String? = nil,
        showsStorePaymentMethodField: Bool = true,
        storePaymentMethod: Bool = false,
        style: FormComponentStyle = FormComponentStyle(),
        showsSubmitButton: Bool = true
    ) {
        self.init(
            redirectURL: redirectURL,
            referenceId: referenceId,
            showsStorePaymentMethodField: showsStorePaymentMethodField,
            storePaymentMethod: storePaymentMethod,
            style: style,
            showsSubmitButton: showsSubmitButton,
            localizationParameters: nil
        )
    }

    package init(
        redirectURL: URL,
        referenceId: String? = nil,
        showsStorePaymentMethodField: Bool = true,
        storePaymentMethod: Bool = false,
        style: FormComponentStyle = FormComponentStyle(),
        showsSubmitButton: Bool = true,
        localizationParameters: LocalizationParameters? = nil
    ) {
        self.redirectURL = redirectURL
        self.referenceId = referenceId
        self.showsStorePaymentMethodField = showsStorePaymentMethodField
        self.storePaymentMethod = storePaymentMethod
        self.style = style
        self.showsSubmitButton = showsSubmitButton
        self.localizationParameters = localizationParameters
    }
}
