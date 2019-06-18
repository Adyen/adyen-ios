//
// Copyright (c) 2019 Adyen B.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// Returns a localized string for the given key, and optionally uses it as a template
/// in which the remaining argument values are substituted.
/// This method will try first to get the string from main bundle.
/// If no localization is available on main bundle, it'll return from internal one.
///
/// :nodoc:
///
/// - Parameters:
///   - key: The key used to identify the localized string.
///   - arguments: The arguments to substitute in the templated localized string.
/// - Returns: The localized string for the given key, or the key itself if the localized string could not be found.
public func ADYLocalizedString(_ key: String, _ arguments: CVarArg...) -> String {
    
    // Check main application bundle first.
    var localizedString = NSLocalizedString(key, tableName: nil, bundle: Bundle.main, comment: "")
    
    // If no string is available on main bundle, try internal one.
    if localizedString == key {
        localizedString = NSLocalizedString(key, tableName: nil, bundle: Bundle.internalResources, comment: "")
    }
    
    guard arguments.isEmpty == false else {
        return localizedString
    }
    
    return String(format: localizedString, arguments: arguments)
}

/// Helper function to create a localized submit button title. Optionally, the button title can include the given amount.
///
/// :nodoc:
///
/// - Parameter amount: The amount to include in the submit button title.
public func ADYLocalizedSubmitButtonTitle(with amount: Payment.Amount?) -> String {
    guard let formattedAmount = amount?.formatted else {
        return ADYLocalizedString("adyen.submitButton")
    }
    
    return ADYLocalizedString("adyen.submitButton.formatted", formattedAmount)
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
