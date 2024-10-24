//
// Copyright (c) 2024 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import AdyenNetworking
import UIKit

@_spi(AdyenInternal)
extension UIImageView {
    
    /// Initializes UIImageView with given `ImageStyle`
    /// Sets `translatesAutoresizingMaskIntoConstraints` to `false`
    /// - Parameter style: `ImageStyle` to be applied
    public convenience init(style: ImageStyle) {
        self.init()
        translatesAutoresizingMaskIntoConstraints = false
        adyen.apply(style)
    }
}

public extension AdyenScope where Base: UIImageView {
    
    /// Applies given `ImageStyle` to the UIImageView
    /// Sets `translatesAutoresizingMaskIntoConstraints` to `false`
    /// - Parameter style: `ImageStyle` to be applied
    internal func apply(_ style: ImageStyle) {
        round(using: style.cornerRounding)
        base.layer.borderColor = style.borderColor?.cgColor
        base.layer.borderWidth = style.borderWidth
        base.backgroundColor = style.backgroundColor
        base.tintColor = style.tintColor
        base.clipsToBounds = style.clipsToBounds
    }
}
