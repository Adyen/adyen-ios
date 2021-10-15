//
// Copyright (c) 2020 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import UIKit

/// :nodoc:
extension UIColor {
    /// :nodoc:
    enum AdyenCore {
        internal static var componentBackground: UIColor {
            if #available(iOS 13.0, *) {
                return .systemBackground
            } else {
                return .white
            }
        }

        internal static var componentLabel: UIColor {
            if #available(iOS 13.0, *) {
                return .label
            } else {
                return .black
            }
        }

        internal static var componentSecondaryLabel: UIColor {
            if #available(iOS 13.0, *) {
                return .secondaryLabel
            } else {
                return .darkGray
            }
        }

        internal static var componentTertiaryLabel: UIColor {
            if #available(iOS 13.0, *) {
                return .tertiaryLabel
            } else {
                return .gray
            }
        }

        internal static var componentQuaternaryLabel: UIColor {
            if #available(iOS 13.0, *) {
                return .quaternaryLabel
            } else {
                return .lightGray
            }
        }

        internal static var componentPlaceholderText: UIColor {
            if #available(iOS 13.0, *) {
                return .placeholderText
            } else {
                return .gray
            }
        }

        internal static var componentSeparator: UIColor {
            if #available(iOS 13.0, *) {
                return .separator
            } else {
                return UIColor(white: 0.0, alpha: 0.2)
            }
        }

        internal static var componentLoadingMessageColor: UIColor {
            if #available(iOS 11.0, *) {
                return UIColor(named: "awaitLoadingMessageColor",
                               in: Bundle.coreInternalResources,
                               compatibleWith: nil) ?? componentPlaceholderText
            } else {
                return componentPlaceholderText
            }
        }

        internal static let defaultBlue = UIColor(hex: 0x007AFF)

        internal static let defaultRed = UIColor(hex: 0xFF3B30)
    }
}
