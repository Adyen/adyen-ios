//
// Copyright (c) 2019 Adyen B.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation
import UIKit

/// Returns a localized string for the given key, and optionally uses it as a template in which the remaining argument values are substituted.
///
/// - Parameters:
///   - key: The key used to identify the localized string.
///   - arguments: The arguments to substitute in the templated localized string.
/// - Returns: The localized string for the given key, or the key itself if the localized string could not be found.
public func ADYLocalizedString(_ key: String, _ arguments: CVarArg...) -> String {
    let localizedString = NSLocalizedString(key,
                                            tableName: nil,
                                            bundle: .resources,
                                            comment: "")
    
    guard arguments.isEmpty == false else {
        return localizedString
    }
    
    return String(format: localizedString, arguments: arguments)
}
