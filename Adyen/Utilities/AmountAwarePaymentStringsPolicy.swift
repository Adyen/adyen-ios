//
// Copyright (c) 2026 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

package enum PaymentStyle {
    case needsRedirectToThirdParty(String)

    case immediate
}

package enum AmountAwarePaymentStringsPolicy {

    package static func payButtonTitle(
        with amount: Amount?,
        style: PaymentStyle,
        _ localizationParameters: LocalizationParameters?
    ) -> String {
        guard var amount else {
            return localizedString(.submitButton, localizationParameters)
        }

        if amount.value == 0 {
            return zeroPaymentButtonTitle(style: style, localizationParameters)
        }

        amount.localeIdentifier = amount.localeIdentifier ?? localizationParameters?.locale
        return localizedString(.submitButtonFormatted, localizationParameters, amount.formatted)
    }

    private static func zeroPaymentButtonTitle(
        style: PaymentStyle,
        _ localizationParameters: LocalizationParameters?
    ) -> String {
        switch style {
        case let .needsRedirectToThirdParty(name):
            return localizedString(.preauthorizeWith, localizationParameters, name)
        case .immediate:
            return localizedString(.confirmPreauthorization, localizationParameters)
        }
    }
}
