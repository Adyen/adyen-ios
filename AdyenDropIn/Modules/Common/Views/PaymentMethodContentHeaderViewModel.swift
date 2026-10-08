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
    internal let subtitle: AttributedString
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
        let attributedSubtitle = AmountAwarePaymentStringsPolicy.storedPaymentMethodAttributedSubtitle(
            for: paymentMethod.name,
            with: context.amount,
            localizationParameters: localizationParameters,
            attributes: [
                .font: theme.elements.labels.body.font,
                .foregroundColor: theme.elements.labels.body.color
            ],
            emphasizedAttributes: [
                .font: theme.elements.labels.bodyEmphasized.font,
                .foregroundColor: theme.elements.labels.bodyEmphasized.color
            ]
        )

        self.logoURL = logoURLProvider.logoURL(withName: displayInformation.logoName, size: .large)
        self.title = displayInformation.title
        self.subtitle = AttributedString(attributedSubtitle)
        self.theme = theme
    }

    internal init(
        logoURL: URL,
        title: String,
        subtitle: AttributedString,
        theme: CheckoutTheme
    ) {
        self.logoURL = logoURL
        self.title = title
        self.subtitle = subtitle
        self.theme = theme
    }
}
