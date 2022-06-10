//
// Copyright (c) 2022 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation
import UIKit

/// A UITextField subclass to override the default UITextField default Accessibility behaviour,
/// specifically the voice over reading of the UITextField.placeholder.
/// So in order to prevent this behaviour,
/// accessibilityValue is overriden to return an empty string in case the text var is nil or empty string.
@_spi(AdyenInternal)
@objc(AdyTextField)
public final class TextField: UITextField {
    
    private var heightConstraint: NSLayoutConstraint?
    
    internal var disablePlaceHolderAccessibility: Bool = true
    
    /// A boolean value to determine whether editing actions such as
    /// cut, copy, share are allowed for the text field. Default is `true`
    public var allowsEditingActions: Bool = true

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
    
    override public func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        switch action {
        case #selector(UIResponderStandardEditActions.paste(_:)):
            return super.canPerformAction(action, withSender: sender)
        default:
            return allowsEditingActions && super.canPerformAction(action, withSender: sender)
        }
    }
}

@_spi(AdyenInternal)
extension TextField {

    public func apply(placeholderText: String?, with style: TextStyle?) {
        if let text = placeholderText, let style = style {
            attributedPlaceholder = NSAttributedString(string: text, attributes: style.stringAttributes)
        } else {
            placeholder = placeholderText
        }
    }

}
