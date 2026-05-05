//
// Copyright (c) 2020 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation
import UIKit

/// A UITextField subclass to override the default UITextField default Accessibility behaviour,
/// specifically the voice over reading of the UITextField.placeholder.
/// So in order to prevent this behaviour,
/// accessibilityValue is overriden to return an empty string in case the text var is nil or empty string.
@objc(AdyTextField)
package final class TextField: UITextField {

    private var heightConstraint: NSLayoutConstraint?
    
    internal var disablePlaceHolderAccessibility: Bool = true
    
    /// A boolean value to determine whether editing actions such as
    /// cut, copy, share are allowed for the text field. Default is `true`
    package var allowsEditingActions: Bool = true

    override package var accessibilityValue: String? {
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

    override package var font: UIFont? {
        didSet {
            let sizeToFit = sizeThatFits(CGSize(
                width: bounds.width,
                height: UIView.layoutFittingExpandedSize.height
            ))
            heightConstraint = heightConstraint ?? heightAnchor.constraint(equalToConstant: 0)
            heightConstraint?.constant = sizeToFit.height + 1
            heightConstraint?.priority = .defaultHigh
            heightConstraint?.isActive = true
        }
    }
    
    override package func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        switch action {
        case #selector(UIResponderStandardEditActions.paste(_:)):
            return super.canPerformAction(action, withSender: sender)
        default:
            return allowsEditingActions && super.canPerformAction(action, withSender: sender)
        }
    }
}

extension TextField {

    package func apply(placeholderText: String?, with style: AdyenLabelStyle) {
        if let text = placeholderText, !text.isEmpty {
            attributedPlaceholder = NSAttributedString(string: text, attributes: style.stringAttributes)
        } else {
            placeholder = nil
            attributedPlaceholder = nil
        }
    }
}
