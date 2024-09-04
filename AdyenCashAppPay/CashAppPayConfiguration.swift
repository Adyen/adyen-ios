//
// Copyright (c) 2024 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import Foundation

/// Configuration for Cash App Pay Component.
public struct CashAppPayConfiguration: AnyCashAppPayConfiguration {

    /// The URL for Cash App to call in order to redirect back to your application.
    public let redirectURL: URL

    /// A reference to your system (for example, a cart or checkout identifier).
    public let referenceId: String?

    /// Indicates if the field for storing the payment method should be displayed in the form. Defaults to `true`.
    public var showsStorePaymentMethodField: Bool
    
    /// Determines whether to store this payment method. Defaults to `false`.
    /// Ignored if `showsStorePaymentMethodField` is `true`.
    public var storePaymentMethod: Bool

    /// Describes the component's UI style.
    public var style: FormComponentStyle

    /// The localization parameters, leave it nil to use the default parameters.
    public var localizationParameters: LocalizationParameters?

    /// Initializes an instance of `CashAppPayComponent.Configuration`
    ///
    /// - Parameters:
    ///   - redirectURL: The URL for Cash App to call in order to redirect back to your application.
    ///   - referenceId: A reference to your system (for example, a cart or checkout identifier).
    ///   - showsStorePaymentMethodField: Determines the visibility of the field for storing the payment method.
    ///   - storePaymentMethod: Determines whether to store this payment method.
    ///   Ignored if `showsStorePaymentMethodField` is `true`.
    ///   - style: The UI style of the component.
    ///   - localizationParameters: The localization parameters, leave it nil to use the default parameters.
    public init(
        redirectURL: URL,
        referenceId: String? = nil,
        showsStorePaymentMethodField: Bool = true,
        storePaymentMethod: Bool = false,
        style: FormComponentStyle = FormComponentStyle(),
        localizationParameters: LocalizationParameters? = nil
    ) {
        self.redirectURL = redirectURL
        self.referenceId = referenceId
        self.showsStorePaymentMethodField = showsStorePaymentMethodField
        self.storePaymentMethod = storePaymentMethod
        self.style = style
        self.localizationParameters = localizationParameters
    }
}
