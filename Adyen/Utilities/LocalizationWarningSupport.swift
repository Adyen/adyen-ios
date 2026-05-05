//
// Copyright (c) 2026 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

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
