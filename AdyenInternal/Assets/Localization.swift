//
// Copyright (c) 2019 Adyen B.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation
import UIKit

/// Returns a localized string for the given key, and optionally uses it as a template in which the remaining argument values are substituted.
/// This method will try first to get the string from main application bundle.
/// If no localization is available on main application bundle, it'll return from internal one.
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
        localizedString = NSLocalizedString(key, tableName: nil, bundle: .resources, comment: "")
    }
    
    guard arguments.isEmpty == false else {
        return localizedString
    }
    
    return String(format: localizedString, arguments: arguments)
}
