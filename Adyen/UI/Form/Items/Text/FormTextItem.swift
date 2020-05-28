//
// Copyright (c) 2020 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// An item in which text can be entered using a text field.
/// :nodoc:
public protocol FormTextItem: FormValueItem, ValidatableFormItem {
    
    /// The text item style.
    var style: FormTextItemStyle { get }
    
    /// The title displayed above the text field.
    var title: String? { get set }
    
    /// The placeholder of the text field.
    var placeholder: String? { get set }
    
    /// :nodoc:
    var identifier: String? { get set }
    
    /// The formatter to use for formatting the text in the text field.
    var formatter: Formatter? { get set }
    
    /// The validator to use for validating the text in the text field.
    var validator: Validator? { get set }
    
    /// The auto-capitalization style for the text field.
    var autocapitalizationType: UITextAutocapitalizationType { get set }
    
    /// The autocorrection style for the text field.
    var autocorrectionType: UITextAutocorrectionType { get set }
    
    /// The type of keyboard to use for text entry.
    var keyboardType: UIKeyboardType { get set }
    
}

public extension FormTextItem where ValueType == String {
    
    /// :nodoc:
    var value: String {
        get {
            let value = objc_getAssociatedObject(self, &FormTextItemAssociatedKeys.value) as? ValueType
            return value ?? ""
        }
        set {
            objc_setAssociatedObject(self,
                                     &FormTextItemAssociatedKeys.value,
                                     newValue,
                                     objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            valueDidChange()
        }
    }
    
    /// :nodoc:
    func isValid() -> Bool {
        validator?.isValid(value) ?? true
    }
}

public extension FormTextItem {
    
    /// The auto-capitalization style for the text field.
    var autocapitalizationType: UITextAutocapitalizationType {
        get {
            let value = objc_getAssociatedObject(self, &FormTextItemAssociatedKeys.autocapitalizationType) as? UITextAutocapitalizationType
            return value ?? UITextAutocapitalizationType.sentences
        }
        set {
            objc_setAssociatedObject(self,
                                     &FormTextItemAssociatedKeys.autocapitalizationType,
                                     newValue,
                                     objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    /// The autocorrection style for the text field.
    var autocorrectionType: UITextAutocorrectionType {
        get {
            let value = objc_getAssociatedObject(self, &FormTextItemAssociatedKeys.autocorrectionType) as? UITextAutocorrectionType
            return value ?? UITextAutocorrectionType.no
        }
        set {
            objc_setAssociatedObject(self,
                                     &FormTextItemAssociatedKeys.autocorrectionType,
                                     newValue,
                                     objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    /// The type of keyboard to use for text entry.
    var keyboardType: UIKeyboardType {
        get {
            let value = objc_getAssociatedObject(self, &FormTextItemAssociatedKeys.keyboardType) as? UIKeyboardType
            return value ?? UIKeyboardType.default
        }
        set {
            objc_setAssociatedObject(self,
                                     &FormTextItemAssociatedKeys.keyboardType,
                                     newValue,
                                     objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    /// The text item style.
    var style: FormTextItemStyle {
        get {
            let value = objc_getAssociatedObject(self, &FormTextItemAssociatedKeys.style) as? FormTextItemStyle
            return value ?? FormTextItemStyle()
        }
        set {
            objc_setAssociatedObject(self,
                                     &FormTextItemAssociatedKeys.style,
                                     newValue,
                                     objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    /// The title displayed above the text field.
    var title: String? {
        get {
            objc_getAssociatedObject(self, &FormTextItemAssociatedKeys.title) as? String
        }
        set {
            objc_setAssociatedObject(self,
                                     &FormTextItemAssociatedKeys.title,
                                     newValue,
                                     objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    /// The placeholder of the text field.
    var placeholder: String? {
        get {
            objc_getAssociatedObject(self, &FormTextItemAssociatedKeys.placeholder) as? String
        }
        set {
            objc_setAssociatedObject(self,
                                     &FormTextItemAssociatedKeys.placeholder,
                                     newValue,
                                     objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    /// :nodoc:
    var identifier: String? {
        get {
            objc_getAssociatedObject(self, &FormTextItemAssociatedKeys.identifier) as? String
        }
        set {
            objc_setAssociatedObject(self,
                                     &FormTextItemAssociatedKeys.identifier,
                                     newValue,
                                     objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    /// The formatter to use for formatting the text in the text field.
    var formatter: Formatter? {
        get {
            objc_getAssociatedObject(self, &FormTextItemAssociatedKeys.formatter) as? Formatter
        }
        set {
            objc_setAssociatedObject(self,
                                     &FormTextItemAssociatedKeys.formatter,
                                     newValue,
                                     objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    /// The validator to use for validating the text in the text field.
    var validator: Validator? {
        get {
            objc_getAssociatedObject(self, &FormTextItemAssociatedKeys.validator) as? Validator
        }
        set {
            objc_setAssociatedObject(self,
                                     &FormTextItemAssociatedKeys.validator,
                                     newValue,
                                     objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    /// A message that is displayed when validation fails.
    var validationFailureMessage: String? {
        get {
            objc_getAssociatedObject(self, &FormTextItemAssociatedKeys.validationFailureMessage) as? String
        }
        set {
            objc_setAssociatedObject(self,
                                     &FormTextItemAssociatedKeys.validationFailureMessage,
                                     newValue,
                                     objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
}

private struct FormTextItemAssociatedKeys {
    internal static var autocapitalizationType = "autocapitalizationType"
    internal static var autocorrectionType = "autocorrectionType"
    internal static var keyboardType = "keyboardType"
    internal static var value = "value"
    internal static var title = "title"
    internal static var style = "style"
    internal static var placeholder = "placeholder"
    internal static var identifier = "identifier"
    internal static var formatter = "formatter"
    internal static var validator = "validator"
    internal static var validationFailureMessage = "validationFailureMessage"
}
