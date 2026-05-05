//
// Copyright (c) 2019 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

private struct LocalizationInput {
    
    let key: String
    
    let table: String?
    
    let bundle: Bundle
    
}

/// Resolves a localized string for the given key and optionally formats it with arguments.
///
/// Current lookup order:
/// - natural mode: `Bundle.main`, then `LocalizationParameters.bundle`, then SDK resources for the active locale
/// - enforced mode: enforced locale in `Bundle.main`, then `LocalizationParameters.bundle`, then SDK resources
/// - final fallback: SDK English (`en-US`), then the raw key
///
/// - Parameters:
///   - key: The key used to identify the localized string.
///   - parameters: The localization parameters.
///   - arguments: The arguments to substitute in the templated localized string.
/// - Returns: The localized string for the given key, or the key itself if the localized string could not be found.
internal enum LocalizationSource: String, Hashable {
    case bundle
    case provider
}

internal struct LocalizationWarning: Hashable {
    internal let localeIdentifier: String
    internal let key: String
    internal let source: LocalizationSource
}

internal enum LocalizationWarningLog {
    internal static var onEmit: ((LocalizationWarning) -> Void)?
    private static var emittedWarnings = Set<LocalizationWarning>()

    internal static func emit(source: LocalizationSource, localeIdentifier: String, key: String) {
        let warning = LocalizationWarning(
            localeIdentifier: normalizedLocaleIdentifier(localeIdentifier),
            key: key,
            source: source
        )
        guard emittedWarnings.insert(warning).inserted else { return }
        onEmit?(warning)
        adyenPrint(
            "Localization warning: Missing localization for unsupported locale '" + warning.localeIdentifier
                + "' and key '" + warning.key
                + "' from the " + warning.source.rawValue
                + " source. Falling back to SDK localization."
        )
    }

    internal static func reset() {
        onEmit = nil
        emittedWarnings.removeAll()
    }
}

internal func warnIfBundleLocalizationIsMissing(key: String, parameters: LocalizationParameters, localeIdentifier: String) {
    guard isUnsupportedSDKLocale(localeIdentifier) else { return }
    guard localizationBundles(parameters).contains(where: { bundleHasLocale($0, localeIdentifier: localeIdentifier) }) else { return }

    LocalizationWarningLog.emit(source: .bundle, localeIdentifier: localeIdentifier, key: key)
}

internal func isUnsupportedSDKLocale(_ localeIdentifier: String) -> Bool {
    !bundleHasLocale(Bundle.coreInternalResources, localeIdentifier: localeIdentifier)
}

internal func resolvedLocaleIdentifier(_ parameters: LocalizationParameters) -> String {
    normalizedLocaleIdentifier(parameters.locale ?? parameters.resolvedLocale.identifier)
}

internal func normalizedLocaleIdentifier(_ localeIdentifier: String) -> String {
    localeIdentifier.replacingOccurrences(of: "_", with: "-")
}

private func localizationBundles(_ parameters: LocalizationParameters) -> [Bundle] {
    guard let customBundle = parameters.bundle, customBundle.bundleURL != Bundle.main.bundleURL else {
        return [Bundle.main]
    }

    return [Bundle.main, customBundle]
}

private func bundleHasLocale(_ bundle: Bundle, localeIdentifier: String) -> Bool {
    bundle.path(forResource: normalizedLocaleIdentifier(localeIdentifier), ofType: "lproj") != nil
}

package func localizedString(_ key: LocalizationKey, _ parameters: LocalizationParameters?, _ arguments: CVarArg...) -> String {
    let localeIdentifier = parameters.map(resolvedLocaleIdentifier)
    var resolvedTranslation: String? = resolveFromProvider(key: key, parameters: parameters)

    if resolvedTranslation == nil {
        var candidateInputs = buildLookupCandidates(key.key, parameters)
        switch parameters?.mode {
        case .enforced:
            candidateInputs.appendLookupCandidates(for: Bundle.coreInternalResources, key.key, nil)
            resolvedTranslation = resolveLocalizedString(from: candidateInputs, locale: parameters?.locale)
        case .natural, .none:
            resolvedTranslation = resolveLocalizedString(from: candidateInputs)
        }

        if resolvedTranslation == nil, let parameters, let localeIdentifier {
            warnIfBundleLocalizationIsMissing(key: key.key, parameters: parameters, localeIdentifier: localeIdentifier)
        }
    }

    let result = resolvedTranslation.flatMap(\.adyen.nilIfEmpty) ?? fallbackLocalizedString(key: key.key)

    guard !arguments.isEmpty else {
        return result
    }

    return String(format: result, arguments: arguments)
}

/// Consults the merchant-provided ``CheckoutLocalizationProvider`` when one is attached
/// to the supplied ``LocalizationParameters``.
///
/// Returns `nil` if no provider is configured, or if the provider returns `nil` or an empty string for the key.
///
/// The provider is consulted for every ``LocalizationKey``. Keys that have no corresponding public
/// ``CheckoutLocalizationKey`` static member are still passed through, but merchants only know
/// the public static catalog and return `nil` for unrecognized keys, which falls through to the
/// bundle chain. This avoids a hand-maintained mirror of the autogenerated ``LocalizationKey`` set.
private func resolveFromProvider(key: LocalizationKey, parameters: LocalizationParameters?) -> String? {
    guard let parameters, let provider = parameters.provider else { return nil }

    let localeIdentifier = resolvedLocaleIdentifier(parameters)
    let resolvedTranslation = provider.localizedString(
        CheckoutLocalizationKey(localizationKey: key),
        locale: parameters.resolvedLocale
    )?.adyen.nilIfEmpty

    if resolvedTranslation == nil, isUnsupportedSDKLocale(localeIdentifier) {
        LocalizationWarningLog.emit(source: .provider, localeIdentifier: localeIdentifier, key: key.key)
    }

    return resolvedTranslation
}

/// Resolves the SDK-owned fallback layers that run after app/custom bundle lookup is exhausted.
///
/// Current lookup order in this helper:
/// - SDK resources using the runtime-selected locale
/// - SDK English resources (`en-US`)
/// - raw localization key
private func fallbackLocalizedString(key: String) -> String {
    let fallbackTranslation = NSLocalizedString(key, tableName: nil, bundle: Bundle.coreInternalResources, comment: "")

    if let fallbackTranslation = resolvedLocalizedStringIfAvailable(fallbackTranslation, forKey: key) {
        return fallbackTranslation
    } else {
        // Fallback to en-US
        return Bundle.coreInternalResources.path(forResource: "en-US", ofType: "lproj")
            .flatMap(Bundle.init(path:))
            .flatMap {
                resolvedLocalizedStringIfAvailable(
                    NSLocalizedString(key, tableName: nil, bundle: $0, comment: ""),
                    forKey: key
                )
            } ?? key
    }
}

/// Builds the bundle lookup candidates for the merchant-controlled layers we support today.
///
/// Current lookup order in this helper:
/// - `Bundle.main`
/// - `LocalizationParameters.bundle` when provided
private func buildLookupCandidates(
    _ key: String,
    _ parameters: LocalizationParameters?
) -> [LocalizationInput] {
    var candidateInputs = [LocalizationInput]()
    candidateInputs.appendLookupCandidates(for: Bundle.main, key, parameters)

    if let customBundle = parameters?.bundle {
        candidateInputs.appendLookupCandidates(for: customBundle, key, parameters)
    }

    return candidateInputs
}

/// Rewrites the dotted localization key when a custom separator is configured.
///
/// This keeps the current legacy behavior where we first try the merchant's custom separator
/// and then fall back to the original dotted key in the same bundle.
private func keyByReplacingDots(in key: String, with separator: String?) -> String? {
    guard let separator else { return nil }
    return key.replacingOccurrences(of: ".", with: separator)
}

/// Resolves the first matching translation from the provided bundle candidates.
///
/// Current lookup behavior:
/// - without `locale`: ask each bundle to resolve using its natural localization behavior
/// - with `locale`: look inside that exact `.lproj` for each bundle before moving to the next candidate
private func resolveLocalizedString(from inputs: [LocalizationInput], locale: String? = nil) -> String? {
    if let locale {
        return inputs.compactMap { resolveLocalizedString(forEnforcedLocale: locale, from: $0) }.first
    }
    return inputs.compactMap(resolveLocalizedString).first
}

/// Resolves one bundle candidate using the bundle's natural localization behavior.
///
/// This is the current path for:
/// - `Bundle.main`
/// - `LocalizationParameters.bundle`
/// - SDK resources when we fall back without an enforced locale
private func resolveLocalizedString(_ input: LocalizationInput) -> String? {
    let localizedString = NSLocalizedString(input.key, tableName: input.table, bundle: input.bundle, comment: "")

    return resolvedLocalizedStringIfAvailable(localizedString, forKey: input.key)
}

/// Resolves one bundle candidate for an enforced locale by reading the matching `.lproj` bundle directly.
///
/// This is the current path for enforced-locale lookup in:
/// - `Bundle.main`
/// - `LocalizationParameters.bundle`
/// - SDK resources
private func resolveLocalizedString(forEnforcedLocale locale: String, from input: LocalizationInput) -> String? {
    let localizedString = input.bundle.path(forResource: locale, ofType: "lproj")
        .flatMap(Bundle.init(path:))
        .map { NSLocalizedString(input.key, tableName: input.table, bundle: $0, comment: "") }

    return resolvedLocalizedStringIfAvailable(localizedString, forKey: input.key)
}

/// Normalizes `NSLocalizedString` output into "usable translation" or "keep falling back".
///
/// Current values treated as missing:
/// - `nil`
/// - empty strings
/// - the original raw key
/// - the uppercased key produced by Xcode's debug option "Show non-localized strings"
/// Xcode's debug option "Show non-localized strings" returns the missing key uppercased.
/// Treat that value the same as a missing translation so we keep searching fallbacks.
internal func resolvedLocalizedStringIfAvailable(_ localizedString: String?, forKey key: String) -> String? {
    guard let localizedString = localizedString?.adyen.nilIfEmpty else {
        return nil
    }

    guard localizedString != key, localizedString != key.uppercased() else {
        return nil
    }

    return localizedString
}

package enum PaymentStyle {
    case needsRedirectToThirdParty(String)

    case immediate
}

/// Builds the localized submit button title using the same fallback chain as `localizedString(_:_:_:)`.
///
/// - Parameter amount: The amount to include in the submit button title.
/// - Parameter paymentMethodName: The payment method name.
/// - Parameter parameters: The localization parameters.
package func localizedSubmitButtonTitle(
    with amount: Amount?,
    style: PaymentStyle,
    _ parameters: LocalizationParameters?
) -> String {
    guard let amount else {
        return localizedString(.submitButton, parameters)
    }

    if amount.value == 0 {
        return localizedZeroPaymentAuthorisationButtonTitle(style: style, parameters)
    }

    var tempAmount = amount
    tempAmount.localeIdentifier = amount.localeIdentifier ?? parameters?.locale
    return localizedString(.submitButtonFormatted, parameters, tempAmount.formatted)
}

/// Handles the zero-amount submit button variants while keeping the same localization fallback chain.
private func localizedZeroPaymentAuthorisationButtonTitle(
    style: PaymentStyle,
    _ parameters: LocalizationParameters?
) -> String {
    switch style {
    case let .needsRedirectToThirdParty(name):
        return localizedString(.preauthorizeWith, parameters, name)
    case .immediate:
        return localizedString(.confirmPreauthorization, parameters)
    }
}

extension [LocalizationInput] {

    /// Appends the key variants we currently support for a single bundle candidate.
    ///
    /// Current lookup order in a bundle:
    /// - custom-separator key when `LocalizationParameters.keySeparator` is configured
    /// - original dotted key
    fileprivate mutating func appendLookupCandidates(
        for bundle: Bundle,
        _ key: String,
        _ parameters: LocalizationParameters?
    ) {
        if let customKey = keyByReplacingDots(in: key, with: parameters?.keySeparator) {
            self.append(LocalizationInput(key: customKey, table: parameters?.tableName, bundle: bundle))
        }
        self.append(LocalizationInput(key: key, table: parameters?.tableName, bundle: bundle))
    }

}
