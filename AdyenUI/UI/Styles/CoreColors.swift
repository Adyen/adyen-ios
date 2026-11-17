//
// Copyright (c) 2020 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import UIKit

extension UIColor {
    
    package enum Adyen {

        package static var componentBackground: UIColor {
            .systemBackground
        }
        
        package static var secondaryComponentBackground: UIColor {
            .secondarySystemBackground
        }

        package static var componentLabel: UIColor {
            .label
        }

        package static var componentSecondaryLabel: UIColor {
            .secondaryLabel
        }

        package static var componentSeparator: UIColor {
            .separator
        }

        package static var componentLoadingMessageColor: UIColor {
            UIColor(
                named: "awaitLoadingMessageColor",
                in: Bundle.coreInternalResources,
                compatibleWith: nil
            ) ?? .placeholderText
        }

        package static var paidSectionFooterTitleColor: UIColor {
            UIColor(
                named: "paidPartialPaymentSectionFooterTitleColor",
                in: Bundle.coreInternalResources,
                compatibleWith: nil
            ) ?? orange
        }

        package static var paidSectionFooterTitleBackgroundColor: UIColor {
            UIColor(
                named: "paidPartialPaymentSectionFooterTitleBackgroundColor",
                in: Bundle.coreInternalResources,
                compatibleWith: nil
            ) ?? yellow
        }

        package static let defaultBlue = color(hex: 0x007AFF)

        package static let errorRed = color(hex: 0xD10244)

        package static let lightGray = color(hex: 0xE6E9EB)

        private static let yellow = color(hex: 0xFFEACC)

        private static let orange = color(hex: 0x7F4A00)
        
        package static let green40 = color(hex: 0x0ABF53)

        /// Create new UIColor from hex value.
        /// - Parameter hex: The hex value of color. Should be between 0 and 0xFFFFFF.
        internal static func color(hex: UInt) -> UIColor {
            assert(
                hex >= 0x000000 && hex <= 0xFFFFFF,
                "Invalid Hexadecimal color, Hexadecimal number should be between 0x0 and 0xFFFFFF"
            )
            return UIColor(
                red: CGFloat((hex >> 16) & 0xFF) / 255.0,
                green: CGFloat((hex >> 8) & 0xFF) / 255.0,
                blue: CGFloat(hex & 0xFF) / 255.0,
                alpha: 1.0
            )
        }
        
    }
    
}
