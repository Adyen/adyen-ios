//
// Copyright (c) 2025 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import UIKit

public enum DefaultColors {

    public enum Light {

        public static let background = color(hex: 0xFFFFFF)

        public static let container = color(hex: 0xF7F7F8)

        public static let primary = color(hex: 0x00112C)

        public static let textOnPrimary = color(hex: 0xFFFFFF)

        public static let action = color(hex: 0x0070F5)

        public static let destructive = color(hex: 0xE22D2D)

        public static let textOnDestructive = color(hex: 0xFFFFFF)

        public static let disabled = color(hex: 0xEEEFF1)

        public static let textOnDisabled = color(hex: 0x00112C)

        public static let outline = color(hex: 0xDBDEE2)

        public static let text = color(hex: 0x00112C)

        public static let textSecondary = color(hex: 0x5C687C)


    }

    public enum Dark {

        public static let background = color(hex: 0x121212)

        public static let container = color(hex: 0x2A2A2A)

        public static let primary = color(hex: 0xEFEFEF)

        public static let textOnPrimary = color(hex: 0x121212)

        public static let action = color(hex: 0x7DB9FF)

        public static let destructive = color(hex: 0xF99C9C)

        public static let textOnDestructive = color(hex: 0x121212)

        public static let disabled = color(hex: 0x373737)

        public static let textOnDisabled = color(hex: 0xEFEFEF)

        public static let outline = color(hex: 0x454545)

        public static let text = color(hex: 0xEFEFEF)

        public static let textSecondary = color(hex: 0xEFEFEF)

    }

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
