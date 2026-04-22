//
// Copyright (c) 2026 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

// Key set mirrors the Android SDK `CheckoutLocalizationKey` enum for cross-platform alignment.
// Android: https://github.com/Adyen/adyen-android/blob/main/core/src/main/java/com/adyen/checkout/core/common/localization/CheckoutLocalizationKey.kt
/// A localization key passed to ``CheckoutLocalizationProvider``.
///
/// Compare against the well-known static members (e.g. `.cardNumber`) to identify which
/// string the SDK is requesting. New keys may be added in future SDK versions — always
/// include a `default` branch when switching over values.
public struct CheckoutLocalizationKey: Hashable {

    /// The internal ``LocalizationKey`` used for SDK string resolution.
    internal let localizationKey: LocalizationKey

    internal init(localizationKey: LocalizationKey) {
        self.localizationKey = localizationKey
    }

    /// Creates a key that has no direct ``LocalizationKey`` counterpart,
    /// identified by its camelCase name within the `checkout.*` namespace.
    internal init(name: String) {
        localizationKey = LocalizationKey(key: "checkout.\(name)")
    }

    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.localizationKey.key == rhs.localizationKey.key
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(localizationKey.key)
    }
}

// swiftlint:disable identifier_name

// MARK: - General

extension CheckoutLocalizationKey {
    public static let generalBack = CheckoutLocalizationKey(name: "generalBack")
    public static let generalCancel = CheckoutLocalizationKey(localizationKey: .cancelButton)
    public static let generalClose = CheckoutLocalizationKey(name: "generalClose")
    public static let generalOptional = CheckoutLocalizationKey(localizationKey: .fieldTitleOptional)
    public static let generalSearchHint = CheckoutLocalizationKey(localizationKey: .searchPlaceholder)
}

// MARK: - Card

extension CheckoutLocalizationKey {
    public static let cardNumber = CheckoutLocalizationKey(localizationKey: .cardNumberItemTitle)
    public static let cardNumberInvalid = CheckoutLocalizationKey(localizationKey: .cardNumberItemInvalid)
    public static let cardNumberInvalidUnsupportedBrand = CheckoutLocalizationKey(localizationKey: .cardNumberItemUnsupportedBrand)
    public static let cardExpiryDate = CheckoutLocalizationKey(localizationKey: .cardExpiryItemTitle)
    public static let cardExpiryDateHint = CheckoutLocalizationKey(localizationKey: .cardExpiryItemPlaceholder)
    public static let cardExpiryDateInvalid = CheckoutLocalizationKey(localizationKey: .cardExpiryItemInvalid)
    public static let cardExpiryDateInvalidTooOld = CheckoutLocalizationKey(name: "cardExpiryDateInvalidTooOld")
    public static let cardExpiryDateInvalidTooFarInTheFuture = CheckoutLocalizationKey(name: "cardExpiryDateInvalidTooFarInTheFuture")
    public static let cardSecurityCode = CheckoutLocalizationKey(localizationKey: .cardCvcItemTitle)
    public static let cardSecurityCodeHint3Digits = CheckoutLocalizationKey(name: "cardSecurityCodeHint3Digits")
    public static let cardSecurityCodeHint4Digits = CheckoutLocalizationKey(name: "cardSecurityCodeHint4Digits")
    public static let cardSecurityCodeInvalid = CheckoutLocalizationKey(localizationKey: .cardCvcItemInvalid)
    public static let cardHolderName = CheckoutLocalizationKey(localizationKey: .cardNameItemTitle)
    public static let cardHolderNameInvalid = CheckoutLocalizationKey(localizationKey: .cardNameItemInvalid)
    public static let cardStorePaymentMethod = CheckoutLocalizationKey(localizationKey: .cardStoreDetailsButton)
    public static let cardDualBrandSelectorTitle = CheckoutLocalizationKey(localizationKey: .creditCardDualBrandTitle)
    public static let cardDualBrandSelectorDescription = CheckoutLocalizationKey(localizationKey: .creditCardDualBrandDescription)
    public static let cardSocialSecurityNumber = CheckoutLocalizationKey(name: "cardSocialSecurityNumber")
    public static let cardSocialSecurityNumberInvalid = CheckoutLocalizationKey(name: "cardSocialSecurityNumberInvalid")
}

// MARK: - Drop-in

extension CheckoutLocalizationKey {
    public static let dropInManageFavoritesTitle = CheckoutLocalizationKey(name: "dropInManageFavoritesTitle")
    public static let dropInManageFavoritesCardsSectionTitle = CheckoutLocalizationKey(name: "dropInManageFavoritesCardsSectionTitle")
    public static let dropInManageFavoritesOthersSectionTitle = CheckoutLocalizationKey(name: "dropInManageFavoritesOthersSectionTitle")
    public static let dropInManageFavoritesRemove = CheckoutLocalizationKey(name: "dropInManageFavoritesRemove")
    public static let dropInManageFavoritesRemoveConfirmation = CheckoutLocalizationKey(name: "dropInManageFavoritesRemoveConfirmation")
    public static let dropInOtherPaymentMethods = CheckoutLocalizationKey(name: "dropInOtherPaymentMethods")
    public static let dropInPaymentMethodListDescription = CheckoutLocalizationKey(name: "dropInPaymentMethodListDescription")
    // swiftlint:disable:next line_length
    public static let dropInPaymentMethodListFavoritesSectionTitle = CheckoutLocalizationKey(name: "dropInPaymentMethodListFavoritesSectionTitle")
    // swiftlint:disable:next line_length
    public static let dropInPaymentMethodListFavoritesSectionAction = CheckoutLocalizationKey(name: "dropInPaymentMethodListFavoritesSectionAction")
    // swiftlint:disable:next line_length
    public static let dropInPaymentMethodListOptionsSectionTitle = CheckoutLocalizationKey(name: "dropInPaymentMethodListOptionsSectionTitle")
    // swiftlint:disable:next line_length
    public static let dropInPaymentMethodListOptionsTitleWithFavorites = CheckoutLocalizationKey(name: "dropInPaymentMethodListOptionsTitleWithFavorites")
    public static let dropInPaymentMethodCardDescription = CheckoutLocalizationKey(name: "dropInPaymentMethodCardDescription")
}

// MARK: - Await

extension CheckoutLocalizationKey {
    public static let awaitLoading = CheckoutLocalizationKey(localizationKey: .awaitWaitForConfirmation)
}

// MARK: - MBWay

extension CheckoutLocalizationKey {
    public static let mbwayCountryCode = CheckoutLocalizationKey(name: "mbwayCountryCode")
    public static let mbwayInvalidPhoneNumber = CheckoutLocalizationKey(name: "mbwayInvalidPhoneNumber")
    public static let mbwayPhoneNumber = CheckoutLocalizationKey(name: "mbwayPhoneNumber")
}

// MARK: - BLIK

extension CheckoutLocalizationKey {
    public static let blikCode = CheckoutLocalizationKey(localizationKey: .blikCode)
    public static let blikCodeHint = CheckoutLocalizationKey(name: "blikCodeHint")
    public static let blikCodeInvalid = CheckoutLocalizationKey(localizationKey: .blikInvalid)
    public static let blikHelperText = CheckoutLocalizationKey(localizationKey: .blikHelp)
}

// swiftlint:enable identifier_name

/// An interface for providing selective programmatic overrides of Adyen Checkout UI strings.
///
/// Use this provider when you need to override a small number of strings.
/// Return a non-`nil` value only for the keys you want to override;
/// returning `nil` will let the SDK apply its normal localization fallback chain.
///
/// ## Adding support for a completely new language
/// This protocol is not the recommended path for adding a language that the SDK does not ship.
/// Instead, place a `.strings` or `.xcstrings` file in your app bundle with the `adyen.*` keys
/// translated into the target language. The SDK resolves strings from `Bundle.main` first,
/// so your translations are picked up automatically with no provider required.
///
// TODO: Provide reference doc/link to the file with all SDK keys
public protocol CheckoutLocalizationProvider {
    func localizedString(_ key: CheckoutLocalizationKey, locale: Locale) -> String?
}

// MARK: - Reverse lookup

extension CheckoutLocalizationKey {

    /// Every well-known ``CheckoutLocalizationKey`` declared on this type.
    ///
    /// Keep this list in sync with the static members declared above.
    /// The Phase 3 resolver uses this to reverse-map a raw ``LocalizationKey``
    /// back to its corresponding ``CheckoutLocalizationKey`` before consulting
    /// the merchant's ``CheckoutLocalizationProvider``.
    internal static let allKnownKeys: [CheckoutLocalizationKey] = [
        // General
        .generalBack,
        .generalCancel,
        .generalClose,
        .generalOptional,
        .generalSearchHint,
        // Card
        .cardNumber,
        .cardNumberInvalid,
        .cardNumberInvalidUnsupportedBrand,
        .cardExpiryDate,
        .cardExpiryDateHint,
        .cardExpiryDateInvalid,
        .cardExpiryDateInvalidTooOld,
        .cardExpiryDateInvalidTooFarInTheFuture,
        .cardSecurityCode,
        .cardSecurityCodeHint3Digits,
        .cardSecurityCodeHint4Digits,
        .cardSecurityCodeInvalid,
        .cardHolderName,
        .cardHolderNameInvalid,
        .cardStorePaymentMethod,
        .cardDualBrandSelectorTitle,
        .cardDualBrandSelectorDescription,
        .cardSocialSecurityNumber,
        .cardSocialSecurityNumberInvalid,
        // Drop-in
        .dropInManageFavoritesTitle,
        .dropInManageFavoritesCardsSectionTitle,
        .dropInManageFavoritesOthersSectionTitle,
        .dropInManageFavoritesRemove,
        .dropInManageFavoritesRemoveConfirmation,
        .dropInOtherPaymentMethods,
        .dropInPaymentMethodListDescription,
        .dropInPaymentMethodListFavoritesSectionTitle,
        .dropInPaymentMethodListFavoritesSectionAction,
        .dropInPaymentMethodListOptionsSectionTitle,
        .dropInPaymentMethodListOptionsTitleWithFavorites,
        .dropInPaymentMethodCardDescription,
        // Await
        .awaitLoading,
        // MBWay
        .mbwayCountryCode,
        .mbwayInvalidPhoneNumber,
        .mbwayPhoneNumber,
        // BLIK
        .blikCode,
        .blikCodeHint,
        .blikCodeInvalid,
        .blikHelperText
    ]

    /// Reverse lookup from the underlying ``LocalizationKey`` string to a
    /// ``CheckoutLocalizationKey``.
    ///
    /// Used by the package-level localized-string resolver to hand the merchant's
    /// ``CheckoutLocalizationProvider`` a stable public key instead of the
    /// internal ``LocalizationKey``.
    internal static let byLocalizationKey: [String: CheckoutLocalizationKey] = Dictionary(
        allKnownKeys.map { ($0.localizationKey.key, $0) },
        uniquingKeysWith: { first, _ in first }
    )
}
