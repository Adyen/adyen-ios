//
// Copyright (c) 2023 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

private struct LocalizationInput {
    
    let key: String
    
    let table: String?
    
    let bundle: Bundle
    
}

/// Returns a localized string for the given key, and optionally uses it as a template
/// in which the remaining argument values are substituted.
/// This method will try first to get the string from main bundle.
/// If no localization is available on main bundle, it'll return from internal one.
///
///
/// - Parameters:
///   - key: The key used to identify the localized string.
///   - parameters: The localization parameters.
///   - arguments: The arguments to substitute in the templated localized string.
/// - Returns: The localized string for the given key, or the key itself if the localized string could not be found.
@_spi(AdyenInternal)
public func localizedString(_ key: LocalizationKey, _ parameters: LocalizationParameters?, _ arguments: CVarArg...) -> String {
    var translationAttempt: String?

    switch parameters?.mode {
    case let .enforced(locale: enforcedLocale):
        translationAttempt = enforceLocalizedString(key: key.key, locale: enforcedLocale)
    case .natural, .none:
        translationAttempt = attempt(buildPossibleInputs(key.key, parameters))
    }

    // Use fallback in case attempt result is nil or empty
    let result = translationAttempt.flatMap(\.adyen.nilIfEmpty) ?? fallbackLocalizedString(key: key.key)
    
    guard !arguments.isEmpty else {
        return result
    }
    
    return String(format: result, arguments: arguments)
}

private func fallbackLocalizedString(key: String) -> String {
    let localizedFallback = NSLocalizedString(key, tableName: nil, bundle: Bundle.coreInternalResources, comment: "")
    
    if localizedFallback != key, localizedFallback.isEmpty == false {
        return localizedFallback
    } else {
        // Fallback to en-US
        return Bundle.coreInternalResources.path(forResource: "en-US", ofType: "lproj")
            .flatMap(Bundle.init(path:))
            .map { NSLocalizedString(key, tableName: nil, bundle: $0, comment: "") } ?? key
    }
}

private func enforceLocalizedString(key: String, locale: String) -> String? {
    Bundle.coreInternalResources.path(forResource: locale, ofType: "lproj")
        .flatMap(Bundle.init(path:))
        .map { NSLocalizedString(key, tableName: nil, bundle: $0, comment: "") }
}

private func buildPossibleInputs(_ key: String,
                                 _ parameters: LocalizationParameters?) -> [LocalizationInput] {
    var possibleInputs = buildPossibleInputs(for: Bundle.main, key, parameters)

    if let customBundle = parameters?.bundle {
        let inputs = buildPossibleInputs(for: customBundle, key, parameters)
        possibleInputs.append(contentsOf: inputs)
    }

    return possibleInputs
}

private func buildPossibleInputs(for bundle: Bundle,
                                 _ key: String,
                                 _ parameters: LocalizationParameters?) -> [LocalizationInput] {
    var possibleInputs = [LocalizationInput]()
    
    if let customKey = updated(key, withSeparator: parameters?.keySeparator) {
        possibleInputs.append(LocalizationInput(key: customKey, table: parameters?.tableName, bundle: bundle))
    }
    
    possibleInputs.append(LocalizationInput(key: key, table: parameters?.tableName, bundle: bundle))
    
    return possibleInputs
}

private func updated(_ key: String, withSeparator separator: String?) -> String? {
    guard let separator else { return nil }
    return key.replacingOccurrences(of: ".", with: separator)
}

private func attempt(_ inputs: [LocalizationInput]) -> String? {
    inputs.compactMap { attempt($0) }.first
}

private func attempt(_ input: LocalizationInput) -> String? {
    let localizedString = NSLocalizedString(input.key, tableName: input.table, bundle: input.bundle, comment: "")
    
    if localizedString != input.key {
        return localizedString
    }
    
    return nil
}

@_spi(AdyenInternal)
public enum PaymentStyle {
    case needsRedirectToThirdParty(String)

    case immediate
}

/// Helper function to create a localized submit button title. Optionally, the button title can include the given amount.
///
///
/// - Parameter amount: The amount to include in the submit button title.
/// - Parameter paymentMethodName: The payment method name.
/// - Parameter parameters: The localization parameters.
@_spi(AdyenInternal)
public func localizedSubmitButtonTitle(with amount: Amount?,
                                       style: PaymentStyle,
                                       _ parameters: LocalizationParameters?) -> String {
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

private func localizedZeroPaymentAuthorisationButtonTitle(style: PaymentStyle,
                                                          _ parameters: LocalizationParameters?) -> String {
    switch style {
    case let .needsRedirectToThirdParty(name):
        return localizedString(.preauthorizeWith, parameters, name)
    case .immediate:
        return localizedString(.confirmPreauthorization, parameters)
    }
}
