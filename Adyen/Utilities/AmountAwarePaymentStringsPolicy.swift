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
        guard let amount else {
            return localizedString(.submitButton, localizationParameters)
        }

        if amount.value == 0 {
            return localizedString(.submitButtonSaveDetails, localizationParameters)
        }

        return localizedString(
            .submitButtonFormatted,
            localizationParameters,
            formatted(amount, localizationParameters: localizationParameters)
        )
    }

    package static func paymentMethodListHeaderTitle(
        with amount: Amount?,
        localizationParameters: LocalizationParameters?
    ) -> String {
        guard let amount else {
            return localizedString(.storedPaymentMethodManagementPaymentOptions, localizationParameters)
        }

        if amount.value == 0 {
            return localizedString(.submitButtonSaveDetails, localizationParameters)
        }

        return formatted(amount, localizationParameters: localizationParameters)
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

    package static func storedPaymentMethodSubtitle(
        for paymentMethodName: String,
        with amount: Amount?,
        localizationParameters: LocalizationParameters?
    ) -> String {
        guard let amount else {
            return localizedString(
                .dropInStoredPaymentMethodDescription,
                localizationParameters,
                paymentMethodName
            )
        }

        if amount.value == 0 {
            return localizedString(
                .dropInStoredPaymentMethodDescriptionSaveDetails,
                localizationParameters,
                paymentMethodName
            )
        }

        return localizedString(
            .dropInStoredPaymentMethodDescriptionWithAmount,
            localizationParameters,
            paymentMethodName,
            formatted(amount, localizationParameters: localizationParameters)
        )
    }

    private static func formatted(_ amount: Amount, localizationParameters: LocalizationParameters?) -> String {
        var amount = amount
        amount.localeIdentifier = amount.localeIdentifier ?? localizationParameters?.locale
        return amount.formatted
    }

}
