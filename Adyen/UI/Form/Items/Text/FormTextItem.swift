//
// Copyright (c) 2022 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation
import UIKit

/// An item in which text can be entered using a text field.
/// :nodoc:
open class FormTextItem: FormValueItem<String, FormTextItemStyle>, ValidatableFormItem, InputViewRequiringFormItem {

    /// The placeholder of the text field.
    @AdyenObservable(nil) public var placeholder: String?
    
    /// :nodoc:
    override public var value: String {
        get { publisher.wrappedValue }
        set { publishTransformed(value: newValue) }
    }

    /// The formatter to use for formatting the text in the text field.
    public var formatter: Formatter?

    /// The validator to use for validating the text in the text field.
    public var validator: Validator?

    /// A message that is displayed when validation fails. Observable.
    @AdyenObservable(nil) public var validationFailureMessage: String?

    /// The auto-capitalization style for the text field.
    public var autocapitalizationType: UITextAutocapitalizationType = .sentences

    /// The autocorrection style for the text field.
    public var autocorrectionType: UITextAutocorrectionType = .no

    /// The type of keyboard to use for text entry.
    public var keyboardType: UIKeyboardType = .default

    /// The type of content for autofill.
    public var contentType: UITextContentType?
    
    /// Determines whether the validation can occur while editing is active.
    public var allowsValidationWhileEditing: Bool = false

    public init(style: FormTextItemStyle) {
        super.init(value: "", style: style)
    }

    /// :nodoc:
    public func isValid() -> Bool {
        validator?.isValid(value) ?? true
    }
    
    /// The formatted text value.
    @AdyenObservable("") internal var formattedValue: String

    // MARK: - Private

    private func publishTransformed(value: String) {
        textDidChange(value: value)
    }

    /// :nodoc:
    @discardableResult
    internal func textDidChange(value: String) -> String {
        let sanitizedValue = formatter?.sanitizedValue(for: value) ?? value
        
        publisher.wrappedValue = sanitizedValue
        formattedValue = formatter?.formattedValue(for: value) ?? value
        return formattedValue
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
