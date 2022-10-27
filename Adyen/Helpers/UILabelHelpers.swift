//
// Copyright (c) 2022 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import AdyenNetworking
import UIKit

/// :nodoc:
extension UILabel {
    
    /// Initializes UILabel with given `TextStyle`
    /// Sets `translatesAutoresizingMaskIntoConstraints` to `false`
    /// Sets `adjustsFontForContentSizeCategory` to `true`
    /// - Parameter style: `TextStyle` to be applied
    public convenience init(style: TextStyle) {
        self.init()
        translatesAutoresizingMaskIntoConstraints = false
        adyen.apply(style)
    }
    
}

/// :nodoc:
public extension AdyenScope where Base: UILabel {
    
    /// Applies given `TextStyle` to the UILabel
    /// Sets `adjustsFontForContentSizeCategory` to `true`
    /// - Parameter style: `TextStyle` to be applied
    internal func apply(_ style: TextStyle) {
        base.font = style.font
        base.textColor = style.color
        base.textAlignment = style.textAlignment
        base.backgroundColor = style.backgroundColor
        round(using: style.cornerRounding)
        
        base.adjustsFontForContentSizeCategory = true
    }
}
