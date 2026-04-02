//
// Copyright (c) 2026 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen

/// A localization key supported by the Checkout custom localization provider.
public enum CheckoutLocalizationKey: String, CaseIterable, Equatable {
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

extension CheckoutLocalizationKey {
    package init(_ identifier: CheckoutLocalizationKeyIdentifier) {
        guard let key = CheckoutLocalizationKey(rawValue: identifier.rawValue) else {
            preconditionFailure("Unsupported checkout localization key: \(identifier.rawValue)")
        }
        self = key
    }

    package var identifier: CheckoutLocalizationKeyIdentifier {
        guard let identifier = CheckoutLocalizationKeyIdentifier(rawValue: rawValue) else {
            preconditionFailure("Unsupported checkout localization key: \(rawValue)")
        }
        return identifier
    }
}
