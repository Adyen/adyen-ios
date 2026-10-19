//
// Copyright (c) 2026 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
#if canImport(AdyenUI)
    import AdyenUI
#endif
import Foundation

internal struct PaymentMethodContentHeaderViewModel {

    internal let logoURL: URL
    internal let title: String
    internal let subtitle: String
    internal let theme: CheckoutTheme

    internal init(
        paymentMethod: PaymentMethod,
        context: AdyenContext,
        localizationParameters: LocalizationParameters?,
        theme: CheckoutTheme,
        logoURLProvider: LogoURLProvider? = nil
    ) {
        let displayInformation = paymentMethod.displayInformation(using: localizationParameters)
        let logoURLProvider = logoURLProvider ?? LogoURLProvider(environment: context.apiContext.environment)
        let subtitle = AmountAwarePaymentStringsPolicy.storedPaymentMethodSubtitle(
            for: paymentMethod.name,
            with: context.amount,
            localizationParameters: localizationParameters
        )

        self.logoURL = logoURLProvider.logoURL(withName: displayInformation.logoName, size: .large)
        self.title = displayInformation.title
        self.subtitle = subtitle
        self.theme = theme
    }

    internal init(
        logoURL: URL,
        title: String,
        subtitle: String,
        theme: CheckoutTheme
    ) {
        self.logoURL = logoURL
        self.title = title
        self.subtitle = subtitle
        self.theme = theme
    }
}
