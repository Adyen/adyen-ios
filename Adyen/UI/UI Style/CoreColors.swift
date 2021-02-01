//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import UIKit

/// :nodoc:
extension UIColor {
    
    /// :nodoc:
    public enum Adyen {

        /// :nodoc:
        public static var dimmBackground: UIColor {
            componentSeparator
        }

        /// :nodoc:
        public static var componentBackground: UIColor {
            if #available(iOS 13.0, *) {
                return .systemBackground
            } else {
                return .white
            }
        }

        /// :nodoc:
        public static var secondaryComponentBackground: UIColor {
            if #available(iOS 13.0, *) {
                return .secondarySystemBackground
            } else {
                return .white
            }
        }

        /// :nodoc:
        public static var componentLabel: UIColor {
            if #available(iOS 13.0, *) {
                return .label
            } else {
                return .black
            }
        }

        /// :nodoc:
        public static var componentSecondaryLabel: UIColor {
            if #available(iOS 13.0, *) {
                return .secondaryLabel
            } else {
                return .darkGray
            }
        }

        /// :nodoc:
        public static var componentTertiaryLabel: UIColor {
            if #available(iOS 13.0, *) {
                return .tertiaryLabel
            } else {
                return .gray
            }
        }

        /// :nodoc:
        public static var componentQuaternaryLabel: UIColor {
            if #available(iOS 13.0, *) {
                return .quaternaryLabel
            } else {
                return .lightGray
            }
        }

        /// :nodoc:
        public static var componentPlaceholderText: UIColor {
            if #available(iOS 13.0, *) {
                return .placeholderText
            } else {
                return .gray
            }
        }

        /// :nodoc:
        public static var componentSeparator: UIColor {
            if #available(iOS 13.0, *) {
                return .separator
            } else {
                return UIColor(white: 0.0, alpha: 0.2)
            }
        }

        /// :nodoc:
        public static var componentLoadingMessageColor: UIColor {
            if #available(iOS 11.0, *) {
                return UIColor(named: "awaitLoadingMessageColor",
                               in: Bundle.coreInternalResources,
                               compatibleWith: nil) ?? componentPlaceholderText
            } else {
                return componentPlaceholderText
            }
        }

        /// :nodoc:
        public static let defaultBlue = UIColor(hex: 0x007AFF)

        /// :nodoc:
        public static let defaultRed = UIColor(hex: 0xFF3B30)
        
    }
    
}
