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
                return color(hex: 0xF8F9F9)
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
            UIColor(named: "awaitLoadingMessageColor",
                    in: Bundle.coreInternalResources,
                    compatibleWith: nil) ?? componentPlaceholderText
        }

        /// :nodoc:
        public static var paidSectionFooterTitleColor: UIColor {
            UIColor(named: "paidPartialPaymentSectionFooterTitleColor",
                    in: Bundle.coreInternalResources,
                    compatibleWith: nil) ?? orange
        }

        /// :nodoc:
        public static var paidSectionFooterTitleBackgroundColor: UIColor {
            UIColor(named: "paidPartialPaymentSectionFooterTitleBackgroundColor",
                    in: Bundle.coreInternalResources,
                    compatibleWith: nil) ?? yellow
        }

        /// :nodoc:
        public static let defaultBlue = color(hex: 0x007AFF)

        /// :nodoc:
        public static let defaultRed = color(hex: 0xFF3B30)

        /// :nodoc:
        public static let errorRed = color(hex: 0xD10244)

        /// :nodoc:
        public static let lightGray = color(hex: 0xE6E9EB)

        /// :nodoc:
        private static let yellow = color(hex: 0xFFEACC)

        /// :nodoc:
        private static let orange = color(hex: 0x7F4A00)
        
        /// :nodoc:
        public static let green40 = color(hex: 0x0ABF53)

        /// Create new UIColor from hex value.
        /// - Parameter hex: The hex value of color. Should be between 0 and 0xFFFFFF.
        internal static func color(hex: UInt) -> UIColor {
            assert(hex >= 0x000000 && hex <= 0xFFFFFF,
                   "Invalid Hexadecimal color, Hexadecimal number should be between 0x0 and 0xFFFFFF")
            return UIColor(
                red: CGFloat((hex >> 16) & 0xFF) / 255.0,
                green: CGFloat((hex >> 8) & 0xFF) / 255.0,
                blue: CGFloat(hex & 0xFF) / 255.0,
                alpha: 1.0
            )
        }
        
    }
    
}
