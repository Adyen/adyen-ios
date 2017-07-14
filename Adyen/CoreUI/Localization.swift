//
// Copyright (c) 2017 Adyen B.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// Returns a localized string for the given key, and optionally uses it as a template in which the remaining argument values are substituted.
///
/// - Parameters:
///   - key: The key used to identify the localized string.
///   - arguments: The arguments to substitute in the templated localized string.
/// - Returns: The localized string for the given key, or the key itself if the localized string could not be found.
internal func ADYLocalizedString(_ key: String, _ arguments: CVarArg...) -> String {
    let localizedString = NSLocalizedString(key,
                                            tableName: nil,
                                            bundle: .resources,
                                            comment: "")
    
    guard arguments.isEmpty == false else {
        return localizedString
    }
    
    return String(format: localizedString, arguments: arguments)
}

internal extension UIView {
    
    /// The key to the localized string that should be set to the label's accessibility label property.
    @IBInspectable
    internal var localizedAccessibilityLabelKey: String? {
        get { return nil }
        
        set {
            if let key = newValue {
                accessibilityLabel = ADYLocalizedString(key)
            } else {
                accessibilityLabel = nil
            }
        }
    }
    
}

internal extension UILabel {
    
    /// The key to the localized string that should be set to the label's text property.
    @IBInspectable
    internal var localizedTextKey: String? {
        get { return nil }
        
        set {
            if let key = newValue {
                text = ADYLocalizedString(key)
            } else {
                text = nil
            }
        }
    }
    
}

internal extension UITextField {
    
    /// The key to the localized string that should be set to the text field's placeholder property.
    @IBInspectable
    internal var localizedPlaceholderKey: String? {
        get { return nil }
        
        set {
            if let key = newValue {
                placeholder = ADYLocalizedString(key)
            } else {
                placeholder = nil
            }
        }
    }
    
}
