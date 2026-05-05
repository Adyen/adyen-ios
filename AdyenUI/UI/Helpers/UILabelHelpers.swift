//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import AdyenNetworking
import UIKit

extension UILabel {
    
    /// Initializes UILabel with given `TextStyle`
    /// Sets `translatesAutoresizingMaskIntoConstraints` to `false`
    /// Sets `adjustsFontForContentSizeCategory` to `true`
    /// - Parameter style: `TextStyle` to be applied
    package convenience init(style: TextStyle) {
        self.init()
        translatesAutoresizingMaskIntoConstraints = false
        adyen.apply(style)
    }
    
}

extension AdyenScope where Base: UILabel {
    
    /// Applies given `TextStyle` to the UILabel
    /// Sets `adjustsFontForContentSizeCategory` to `true`
    /// - Parameter style: `TextStyle` to be applied
    package func apply(_ style: TextStyle) {
        base.font = style.font
        base.textColor = style.color
        base.textAlignment = style.textAlignment
        base.backgroundColor = style.backgroundColor
        round(using: style.cornerRounding)
        
        base.adjustsFontForContentSizeCategory = true
    }
}
