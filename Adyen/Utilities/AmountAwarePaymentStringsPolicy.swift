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

    /// Returns the stored payment method subtitle as an attributed string,
    /// formatting the payment method name and a positive amount when present.
    package static func storedPaymentMethodAttributedSubtitle(
        for paymentMethodName: String,
        with amount: Amount?,
        localizationParameters: LocalizationParameters?,
        attributes: [NSAttributedString.Key: Any],
        emphasizedAttributes: [NSAttributedString.Key: Any]
    ) -> NSAttributedString {
        let text = storedPaymentMethodSubtitle(
            for: paymentMethodName,
            with: amount,
            localizationParameters: localizationParameters
        )
        let attributedString = NSMutableAttributedString(string: text, attributes: attributes)

        let emphasizedValues = [
            paymentMethodName,
            formattedPositiveAmount(with: amount, localizationParameters: localizationParameters)
        ].compactMap { $0 }
        for value in emphasizedValues {
            let range = (text as NSString).range(of: value)
            guard range.location != NSNotFound else { continue }
            attributedString.addAttributes(emphasizedAttributes, range: range)
        }
        return attributedString
    }

    /// Returns the formatted amount when it is greater than zero, otherwise `nil`.
    package static func formattedPositiveAmount(
        with amount: Amount?,
        localizationParameters: LocalizationParameters?
    ) -> String? {
        guard let amount, amount.value > 0 else { return nil }
        return formatted(amount, localizationParameters: localizationParameters)
    }

    private static func formatted(_ amount: Amount, localizationParameters: LocalizationParameters?) -> String {
        var amount = amount
        amount.localeIdentifier = amount.localeIdentifier ?? localizationParameters?.locale
        return amount.formatted
    }

}
