//
// Copyright (c) 2020 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import UIKit

internal extension UIColor {
    // swiftlint:disable explicit_acl
    
    static var componentBackground: UIColor {
        if #available(iOS 13.0, *) {
            return .systemBackground
        } else {
            return .white
        }
    }
    
    static var componentLabel: UIColor {
        if #available(iOS 13.0, *) {
            return .label
        } else {
            return .black
        }
    }
    
    static var componentSecondaryLabel: UIColor {
        if #available(iOS 13.0, *) {
            return .secondaryLabel
        } else {
            return .darkGray
        }
    }
    
    static var componentTertiaryLabel: UIColor {
        if #available(iOS 13.0, *) {
            return .tertiaryLabel
        } else {
            return .gray
        }
    }
    
    static var componentQuaternaryLabel: UIColor {
        if #available(iOS 13.0, *) {
            return .quaternaryLabel
        } else {
            return .lightGray
        }
    }
    
    static var componentPlaceholderText: UIColor {
        if #available(iOS 13.0, *) {
            return .placeholderText
        } else {
            return .gray
        }
    }
    
    static var componentSeparator: UIColor {
        if #available(iOS 13.0, *) {
            return .separator
        } else {
            return UIColor(white: 0.0, alpha: 0.2)
        }
    }
    
    static let defaultBlue: UIColor = UIColor(hex: 0x007AFF)
    
    convenience init(hex: UInt) {
        assert(hex >= 0x000000 && hex <= 0xFFFFFF,
               "Invalid Hexadecimal color, Hexadecimal number should be between 0x0 and 0xFFFFFF")
        self.init(
            red: CGFloat((hex >> 16) & 0xFF) / 255.0,
            green: CGFloat((hex >> 8) & 0xFF) / 255.0,
            blue: CGFloat(hex & 0xFF) / 255.0,
            alpha: 1.0
        )
    }
    
    // swiftlint:enable explicit-acl
}
