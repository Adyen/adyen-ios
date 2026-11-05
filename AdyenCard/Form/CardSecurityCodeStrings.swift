//
// Copyright (c) 2026 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
@_spi(AdyenInternal) import struct Adyen.LocalizationKey

internal enum CardSecurityCodeStrings {
    internal static func hint(
        for brand: CardBrand?,
        localizationParameters: LocalizationParameters?
    ) -> String {
        let key: LocalizationKey = brand.expectedSecurityCodeLength == 4
            ? .cardSecurityCodeHintFourDigits
            : .cardSecurityCodeHintThreeDigits
        return localizedString(key, localizationParameters)
    }

    internal static func validationMessage(
        for error: CardValidationError?,
        brand: CardBrand?,
        localizationParameters: LocalizationParameters?
    ) -> String? {
        let isFourDigitCode = brand.expectedSecurityCodeLength == 4
        let key: LocalizationKey
        switch error {
        case .securityCodeEmpty:
            key = isFourDigitCode ? .cardSecurityCodeErrorEmptyFourDigits : .cardSecurityCodeErrorEmptyThreeDigits
        case .securityCodePartial:
            key = isFourDigitCode ? .cardSecurityCodeErrorIncompleteFourDigits : .cardSecurityCodeErrorIncompleteThreeDigits
        default:
            return nil
        }
        return localizedString(key, localizationParameters)
    }
}
