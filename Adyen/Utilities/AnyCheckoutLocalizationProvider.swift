//
// Copyright (c) 2026 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

// Key set mirrors the Android SDK `CheckoutLocalizationKey` enum for cross-platform alignment.
// Android: https://github.com/Adyen/adyen-android/blob/main/core/src/main/java/com/adyen/checkout/core/common/localization/CheckoutLocalizationKey.kt
package enum CheckoutLocalizationKeyIdentifier: String {
    /// Await
    case awaitLoading
    // Card
    case cardNumber
    case cardNumberInvalid
    case cardNumberInvalidUnsupportedBrand
    case cardExpiryDate
    case cardExpiryDateHint
    case cardExpiryDateInvalid
    case cardExpiryDateInvalidTooOld
    case cardExpiryDateInvalidTooFarInTheFuture
    case cardSecurityCode
    case cardSecurityCodeHint3Digits
    case cardSecurityCodeHint4Digits
    case cardSecurityCodeInvalid
    case cardHolderName
    case cardHolderNameInvalid
    case cardStorePaymentMethod
    case cardDualBrandSelectorTitle
    case cardDualBrandSelectorDescription
    case cardSocialSecurityNumber
    case cardSocialSecurityNumberInvalid
    // Drop-in
    case dropInManageFavoritesTitle
    case dropInManageFavoritesCardsSectionTitle
    case dropInManageFavoritesOthersSectionTitle
    case dropInManageFavoritesRemove
    case dropInManageFavoritesRemoveConfirmation
    case dropInOtherPaymentMethods
    case dropInPaymentMethodListDescription
    case dropInPmListFavoritesSectionTitle
    case dropInPmListFavoritesSectionAction
    case dropInPmListOptionsSectionTitle
    case dropInPmListOptionsTitleWithFavorites
    case dropInPaymentMethodCardDescription
    // General
    case generalBack
    case generalCancel
    case generalClose
    case generalOptional
    case generalSearchHint
    // MBWay
    case mbwayCountryCode
    case mbwayInvalidPhoneNumber
    case mbwayPhoneNumber
    // BLIK
    case blikCode
    case blikCodeHint
    case blikCodeInvalid
    case blikHelperText
}

package protocol AnyCheckoutLocalizationProvider {
    func localizedString(_ key: CheckoutLocalizationKeyIdentifier, locale: Locale) -> String?
}
