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
/// :nodoc:
@objc(AdyTextField)
public final class TextField: UITextField {
    
    private var heightConstraint: NSLayoutConstraint?
    
    internal var disablePlaceHolderAccessibility: Bool = true

    /// :nodoc:
    override public var accessibilityValue: String? {
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

    /// :nodoc:
    override public var font: UIFont? {
        didSet {
            let sizeToFit = sizeThatFits(CGSize(width: bounds.width,
                                                height: UIView.layoutFittingExpandedSize.height))
            heightConstraint = heightConstraint ?? heightAnchor.constraint(equalToConstant: 0)
            heightConstraint?.constant = sizeToFit.height + 1
            heightConstraint?.priority = .defaultHigh
            heightConstraint?.isActive = true
        }
    }
}

extension TextField {

    public func apply(placeholderText: String?, with style: TextStyle?) {
        if let text = placeholderText, let style = style {
            attributedPlaceholder = NSAttributedString(string: text, attributes: style.stringAttributes)
        } else {
            placeholder = placeholderText
        }
    }

}
