//
// Copyright (c) 2024 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation
import UIKit

/// An item in which text can be entered using a text field.
@_spi(AdyenInternal)
open class FormTextItem: FormValidatableValueItem<String>, InputViewRequiringFormItem {

    /// The placeholder of the text field.
    @AdyenObservable(nil) public var placeholder: String?
    
    override public var value: String {
        get { publisher.wrappedValue }
        set { publishTransformed(value: newValue) }
    }

    /// The formatter to use for formatting the text in the text field.
    public var formatter: Formatter?

    /// The validator to use for validating the text in the text field.
    public var validator: Validator?

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
    
    /// Closure that is called when the view of this item begins editing..
    public var onDidBeginEditing: (() -> Void)?
    
    /// Closure that is called when the view of this item ends editing.
    public var onDidEndEditing: (() -> Void)?

    public init(style: FormTextItemStyle) {
        super.init(value: "", style: style)
    }

    override public func isValid() -> Bool {
        validator?.isValid(value) ?? true
    }
    
    override public func validationStatus() -> ValidationStatus? {
        guard let statusValidator = validator as? StatusValidator else { return nil }
        return statusValidator.validate(value)
    }
    
    /// The formatted text value.
    @AdyenObservable("") internal var formattedValue: String

    // MARK: - Private

    private func publishTransformed(value: String) {
        textDidChange(value: value)
    }

    @discardableResult
    internal func textDidChange(value: String) -> String {
        let sanitizedValue = formatter?.sanitizedValue(for: value) ?? value
        
        publisher.wrappedValue = sanitizedValue
        formattedValue = formatter?.formattedValue(for: value) ?? value
        return formattedValue
    }
    
    @discardableResult
    internal func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard
            let text = textField.text,
            let textRange = Range(range, in: text),
            let selectedTextRange = textField.selectedTextRange
        else { return true }
        
        /// 1234 56|31 0
        /// 1234 567|3 10 // Adding 7 -> move 1 to the right
        /// 1234 5678 |310 // Adding 8 -> move 2 to the right
        /// 1234 5678 9|310 // Adding 9 -> move 1 to the right
        /// 1234 5678| 310 // Removing 9 -> move 2 to the left
        /// 1234 567|3 10 // Removing 8 -> move 1 to the left
        /// 1234 56|31 0 // Removing 7 -> move 1 to the left
        
        let updatedText = text.replacingCharacters(in: textRange, with: string)

        let sanitizedText = formatter?.sanitizedValue(for: updatedText) ?? updatedText
        let formattedText = formatter?.formattedValue(for: sanitizedText) ?? sanitizedText
        
        let oldCursorOffset = textField.offset(from: textField.beginningOfDocument, to: selectedTextRange.end)
        let replacementLength = string.count - range.length
        
        let isAdding = formattedText.count > text.count
        
        func numberOfSpaces(in text: String, beforeOffset offset: Int) -> Int {
            max(0, text.prefix(max(0, offset)).split(separator: " ").count - 1)
        }
        
        let oldNumberOfSpacesBeforeCursor = numberOfSpaces(in: text, beforeOffset: oldCursorOffset)
        let newNumberOfSpacesBeforeCursor = numberOfSpaces(in: formattedText, beforeOffset: oldCursorOffset + replacementLength + (isAdding ? 1 : 0))
        
        let spaceDifference = newNumberOfSpacesBeforeCursor - oldNumberOfSpacesBeforeCursor
        let newCursorOffset = oldCursorOffset + replacementLength + spaceDifference
        
        textField.text = formattedText
        
        if let newPosition = textField.position(from: textField.beginningOfDocument, offset: newCursorOffset) {
            textField.selectedTextRange = textField.textRange(from: newPosition, to: newPosition)
        }
        
        return false
    }

}

@_spi(AdyenInternal)
extension AnyFormItemView {

    internal func applyTextDelegateIfNeeded(delegate: FormTextItemViewDelegate) {
        if let formTextItemView = self as? AnyFormTextItemView {
            formTextItemView.delegate = delegate
        }

        self.childItemViews.forEach { $0.applyTextDelegateIfNeeded(delegate: delegate) }
    }
    
}
