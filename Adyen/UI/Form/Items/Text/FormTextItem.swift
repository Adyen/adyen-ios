//
// Copyright (c) 2020 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// An item in which text can be entered using a text field.
/// :nodoc:
open class FormTextItem: FormValueItem {
    
    /// Indicates the `FormTextItemView` UI styling.
    public let style: Style
    
    /// The type of value entered in the item.
    public typealias ValueType = String
    
    /// The title displayed above the text field.
    public var title: String?
    
    /// The placeholder of the text field.
    public var placeholder: String?
    
    /// The value entered in the text field.
    public var value = "" {
        didSet {
            valueDidChange()
        }
    }
    
    /// :nodoc:
    public var identifier: String?
    
    /// The formatter to use for formatting the text in the text field.
    public var formatter: Formatter?
    
    /// The validator to use for validating the text in the text field.
    public var validator: Validator?
    
    /// A message that is displayed when validation fails.
    public var validationFailureMessage: String?
    
    /// The auto-capitalization style for the text field.
    public var autocapitalizationType = UITextAutocapitalizationType.sentences
    
    /// The autocorrection style for the text field.
    public var autocorrectionType = UITextAutocorrectionType.no
    
    /// The type of keyboard to use for text entry.
    public var keyboardType = UIKeyboardType.default
    
    /// Initializes the text item.
    ///
    /// - Parameter style: The `FormTextItemView` UI style.
    public init(style: Style = Style()) {
        self.style = style
    }
    
    /// An empty method that provides an opportunity for subclasses to know when the value changed.
    open func valueDidChange() {}
    
}
