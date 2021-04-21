//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation
import UIKit

/// A UITextField subclass to override the default UITextField default Accessibility behaviour,
/// specifically the voice over reading of the UITextField.placeholder.
/// So in order to prevent this behaviour,
/// accessibilityValue is overriden to return an empty string in case the text var is nil or empty string.
internal final class TextField: UITextField {
    
    private var heightConstraint: NSLayoutConstraint?
    
    internal var disablePlaceHolderAccessibility: Bool = true
    
    override internal var accessibilityValue: String? {
        get {
            guard disablePlaceHolderAccessibility else { return super.accessibilityValue }
            if let text = super.text, !text.isEmpty {
                return super.accessibilityValue
            } else {
                return ""
            }
        }
        
        set { super.accessibilityValue = newValue }
    }
    
    override internal var font: UIFont? {
        didSet {
            heightConstraint = heightConstraint ?? heightAnchor.constraint(equalToConstant: 0)
            let sizeToFit = sizeThatFits(CGSize(width: bounds.width,
                                                height: UIView.layoutFittingExpandedSize.height))
            heightConstraint?.constant = sizeToFit.height + 1
            heightConstraint?.priority = .defaultHigh
            heightConstraint?.isActive = true
        }
    }
}
