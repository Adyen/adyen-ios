//
// Copyright (c) 2025 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import UIKit

public extension UIColor {
    /// Create new UIColor from hex value.
    /// - Parameter hex: The hex value of color. Should be between 0 and 0xFFFFFF.
    static func color(hex: UInt) -> UIColor {
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
