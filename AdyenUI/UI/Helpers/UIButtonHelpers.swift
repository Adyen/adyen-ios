//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) import Adyen
import AdyenNetworking
import UIKit

@_spi(AdyenInternal)
extension UIButton {
    
    /// Initializes UIButton with given `ButtonStyle`
    /// Sets `translatesAutoresizingMaskIntoConstraints` to `false`
    /// Sets `adjustsFontForContentSizeCategory` to the `titleLabel` to `true`
    /// - Parameter style: `ButtonStyle` to be applied
    public convenience init(style: ButtonStyle) {
        self.init()
        translatesAutoresizingMaskIntoConstraints = false
        adyen.apply(style)
    }
}

package extension AdyenScope where Base: UIButton {
    
    /// Applies given `ButtonStyle` to the UIButton
    /// Sets `translatesAutoresizingMaskIntoConstraints` to `false`
    /// Sets `adjustsFontForContentSizeCategory` to the `titleLabel` to `true`
    /// - Parameter style: `ButtonStyle` to be applied
    internal func apply(_ style: ButtonStyle) {
        base.titleLabel?.adyen.apply(style.title)
        base.setTitleColor(style.title.color, for: .normal)
        round(using: style.cornerRounding)
        base.layer.borderColor = style.borderColor?.cgColor
        base.layer.borderWidth = style.borderWidth
        base.backgroundColor = style.backgroundColor
    }
}
