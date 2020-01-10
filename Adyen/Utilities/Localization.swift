//
// Copyright (c) 2020 Adyen N.V.
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
/// :nodoc:
///
/// - Parameters:
///   - key: The key used to identify the localized string.
///   - parameters: The localization parameters.
///   - arguments: The arguments to substitute in the templated localized string.
/// - Returns: The localized string for the given key, or the key itself if the localized string could not be found.
public func ADYLocalizedString(_ key: String, _ parameters: LocalizationParameters?, _ arguments: CVarArg...) -> String {
    
    var result = fallbackLocalizedString(key: key)
    
    let possibleInputs = buildPossibleInputs(key, parameters)
    
    if let localizedString = attempt(possibleInputs) {
        result = localizedString
    }
    
    guard !arguments.isEmpty else {
        return result
    }
    
    return String(format: result, arguments: arguments)
}

private func fallbackLocalizedString(key: String) -> String {
    return NSLocalizedString(key, tableName: nil, bundle: Bundle.internalResources, comment: "")
}

private func buildPossibleInputs(_ key: String, _ parameters: LocalizationParameters?) -> [LocalizationInput] {
    var possibleInputs = [LocalizationInput]()
    
    if let customKey = updated(key, withSeparator: parameters?.keySeparator) {
        possibleInputs.append(LocalizationInput(key: customKey, table: parameters?.tableName, bundle: Bundle.main))
    }
    
    possibleInputs.append(LocalizationInput(key: key, table: parameters?.tableName, bundle: Bundle.main))
    
    return possibleInputs
}

private func updated(_ key: String, withSeparator separator: String?) -> String? {
    guard let separator = separator else { return nil }
    return key.replacingOccurrences(of: ".", with: separator)
}

private func attempt(_ inputs: [LocalizationInput]) -> String? {
    return inputs.compactMap { attempt($0) }.first
}

private func attempt(_ input: LocalizationInput) -> String? {
    let localizedString = NSLocalizedString(input.key, tableName: input.table, bundle: input.bundle, comment: "")
    
    if localizedString != input.key {
        return localizedString
    }
    
    return nil
}

/// Helper function to create a localized submit button title. Optionally, the button title can include the given amount.
///
/// :nodoc:
///
/// - Parameter amount: The amount to include in the submit button title.
/// - Parameter parameters: The localization parameters.
public func ADYLocalizedSubmitButtonTitle(with amount: Payment.Amount?, _ parameters: LocalizationParameters?) -> String {
    guard let formattedAmount = amount?.formatted else {
        return ADYLocalizedString("adyen.submitButton", parameters)
    }
    
    return ADYLocalizedString("adyen.submitButton.formatted", parameters, formattedAmount)
}

private extension Bundle {
    
    /// The main bundle of the framework.
    static let core: Bundle = {
        Bundle(for: Coder.self)
    }()
    
    /// The bundle in which the framework's resources are located.
    static let internalResources: Bundle = {
        let url = core.url(forResource: "Adyen", withExtension: "bundle")
        let bundle = url.flatMap { Bundle(url: $0) }
        return bundle ?? core
    }()
    
}
