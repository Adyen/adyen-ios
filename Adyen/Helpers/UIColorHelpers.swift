//
// Copyright (c) 2021 Adyen N.V.
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
