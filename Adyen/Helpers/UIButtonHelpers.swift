//
// Copyright (c) 2022 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import AdyenNetworking
import UIKit

/// :nodoc:
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

/// :nodoc:
public extension AdyenScope where Base: UIButton {
    
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
