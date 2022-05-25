//
// Copyright (c) 2022 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import AdyenNetworking
import UIKit

/// So that any `UIView` instance will inherit the `adyen` scope.
@_spi(AdyenInternal)
extension UIFont: AdyenCompatible {}

/// Adds helper functionality to any `UIViewController` instance through the `adyen` property.
@_spi(AdyenInternal)
public extension AdyenScope where Base: UIFont {
    
    /// Get new instance of `UIFont` with the same familyName and pointSize, but specified weight.
    /// - Parameter weight: The desired font's weight.
    func font(with weight: UIFont.Weight) -> UIFont {
        var descriptor = base.fontDescriptor
        let traits = [UIFontDescriptor.TraitKey.weight: weight]
        descriptor = descriptor.addingAttributes([UIFontDescriptor.AttributeName.traits: traits])
        return UIFont(descriptor: descriptor, size: base.pointSize)
    }
    
}
