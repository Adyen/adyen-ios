//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation
import UIKit

/// An item in which text can be entered using a text field.
/// :nodoc:
open class FormTextItem: FormValueItem<String, FormTextItemStyle>, ValidatableFormItem, InputViewRequiringFormItem {

    /// The placeholder of the text field.
    @Observable(nil) public var placeholder: String?

    /// The formatter to use for formatting the text in the text field.
    public var formatter: Formatter?

    /// The validator to use for validating the text in the text field.
    public var validator: Validator?

    /// A message that is displayed when validation fails.
    public var validationFailureMessage: String?

    /// The auto-capitalization style for the text field.
    public var autocapitalizationType: UITextAutocapitalizationType = .sentences

    /// The autocorrection style for the text field.
    public var autocorrectionType: UITextAutocorrectionType = .no

    /// The type of keyboard to use for text entry.
    public var keyboardType: UIKeyboardType = .default

    public init(style: FormTextItemStyle) {
        super.init(value: "", style: style)
    }

    /// :nodoc:
    public func isValid() -> Bool {
        validator?.isValid(value) ?? true
    }

}

/// :nodoc:
extension AnyFormItemView {

    /// :nodoc:
    internal func applyTextDelegateIfNeeded(delegate: FormTextItemViewDelegate) {
        if let formTextItemView = self as? AnyFormTextItemView {
            formTextItemView.delegate = delegate
        }

        self.childItemViews.forEach { $0.applyTextDelegateIfNeeded(delegate: delegate) }
    }
    
}
