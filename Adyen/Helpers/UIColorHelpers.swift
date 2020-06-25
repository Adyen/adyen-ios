//
// Copyright (c) 2019 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import UIKit

internal extension UIColor {
    
    // swiftlint:disable:next explicit_acl
    func withBrightnessMultiple(_ brightnessMultiple: Float) -> UIColor {
        var hue: CGFloat = 1.0
        var saturation: CGFloat = 1.0
        var brightness: CGFloat = 1.0
        var alpha: CGFloat = 1.0
        guard getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha) else {
            return self
        }
        
        return UIColor(hue: hue,
                       saturation: saturation,
                       brightness: min(max(brightness * CGFloat(brightnessMultiple), 0.0), 1.0),
                       alpha: alpha)
    }
    
}

/// :nodoc:
public extension UIColor {
    
    /// Create new UIColor from hex value.
    /// - Parameter hex: The hex value of color. Should be between 0 and 0xFFFFFF.
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
    
}
