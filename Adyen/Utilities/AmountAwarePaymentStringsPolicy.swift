//
// Copyright (c) 2026 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

package enum AmountAwarePaymentStringsPolicy {

    package static func payButtonTitle(
        with amount: Amount?,
        localizationParameters: LocalizationParameters?
    ) -> String {
        guard var amount else {
            return localizedString(.submitButton, localizationParameters)
        }

        if amount.value == 0 {
            return localizedString(.submitButtonSaveDetails, localizationParameters)
        }

        amount.localeIdentifier = amount.localeIdentifier ?? localizationParameters?.locale
        return localizedString(.submitButtonFormatted, localizationParameters, amount.formatted)
    }

    package static func paymentMethodListHeaderTitle(
        with amount: Amount?,
        localizationParameters: LocalizationParameters?
    ) -> String {
        guard var amount else {
            return localizedString(.storedPaymentMethodManagementPaymentOptions, localizationParameters)
        }

        if amount.value == 0 {
            return localizedString(.submitButtonSaveDetails, localizationParameters)
        }

        amount.localeIdentifier = amount.localeIdentifier ?? localizationParameters?.locale
        return amount.formatted
    }

    package static func paymentMethodListSubtitle(
        with amount: Amount?,
        localizationParameters: LocalizationParameters?
    ) -> String {
        if let amount, amount.value == 0 {
            return localizedString(.dropInPaymentMethodListDescriptionSaveDetails, localizationParameters)
        }

        return localizedString(.dropInPaymentMethodListDescriptionCompletePayment, localizationParameters)
    }
}
