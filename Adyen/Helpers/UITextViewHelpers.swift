//
// Copyright (c) 2024 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import AdyenNetworking
import UIKit

@_spi(AdyenInternal)
extension UITextView {
    
    /// Initializes UITextView with given `TextStyle`
    /// Sets `translatesAutoresizingMaskIntoConstraints` to `false`
    /// - Parameter style: `TextStyle` to be applied
    public convenience init(style: TextStyle) {
        self.init()
        translatesAutoresizingMaskIntoConstraints = false
        adyen.apply(style)
    }
}

public extension AdyenScope where Base: UITextView {
    
    /// Applies given `TextStyle` to the UITextView
    /// Sets `translatesAutoresizingMaskIntoConstraints` to `false`
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
