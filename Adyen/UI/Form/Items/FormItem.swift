//
// Copyright (c) 2020 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// An item in a form.
/// :nodoc:
public protocol FormItem: AnyObject {
    
    /// An identifier for the `FormItem`,
    /// that  is set to the `FormItemView.accessibilityIdentifier` when the corresponding `FormItemView` is created.
    var identifier: String? { get set }
    
    /// Builds the corresponding `AnyFormItemView`.
    func build(with builder: FormItemViewBuilder) -> AnyFormItemView
}

/// An item that is composed of multiple sub items.
/// :nodoc:
public protocol CompoundFormItem: FormItem {
    
    /// The list of sub-items.
    var subitems: [FormItem] { get }
    
}

/// :nodoc:
public extension FormItem {
    
    /// The flat list of all sub-items.
    var flatSubitems: [FormItem] {
        (self as? CompoundFormItem)?.subitems.flatMap(\.flatSubitems) ?? [self]
    }
}

/// A validatable form item.
/// :nodoc:
public protocol ValidatableFormItem: FormItem {
    
    /// A message that is displayed when validation fails.
    var validationFailureMessage: String? { get set }
    
    /// Returns a boolean value indicating if the item value is valid.
    ///
    /// - Returns: A boolean value indicating if the given value is valid.
    func isValid() -> Bool
    
}

/// A form item that requires keyboard input or otherwise custom input view.
/// :nodoc:
public protocol InputViewRequiringFormItem: FormItem {}
