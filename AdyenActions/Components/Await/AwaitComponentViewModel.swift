//
// Copyright (c) 2020 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
@_spi(AdyenInternal) import struct Adyen.LocalizationKey
import AdyenNetworking
import Foundation

internal struct AwaitComponentViewModel {

    /// The payment method logo URL.
    internal let logoURL: URL

    /// The await title.
    internal let title: String

    /// The await description.
    internal let description: String

    /// The progress title.
    internal let progressTitle: String

    /// Initializes the `AwaitComponentViewModel`.
    ///
    /// - Parameter paymentMethodType: The `paymentMethodType` for which the await action is used.
    /// - Parameter environment: The environment used to build the logo URL.
    /// - Parameter localizationParameters: The localization parameters to control some aspects of how strings are localized
    internal init(
        paymentMethodType: AwaitPaymentMethod,
        environment: AnyAPIEnvironment,
        localizationParameters: LocalizationParameters? = nil
    ) {
        self.logoURL = LogoURLProvider.logoURL(withName: paymentMethodType.rawValue, environment: environment)
        self.title = localizedString(.checkoutAwaitTitle, localizationParameters)
        self.description = localizedString(.checkoutAwaitDescription, localizationParameters)
        self.progressTitle = localizedString(.checkoutAwaitStatus, localizationParameters)
    }
}
