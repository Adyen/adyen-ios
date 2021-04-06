//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import UIKit

/// Picker item identifier.
/// :nodoc:
public protocol PickerElement: Equatable, CustomStringConvertible {

    /// Picker item identifier.
    /// :nodoc:
    var identifier: String { get }
}

/// :nodoc:
public struct BasePickerElement<T: CustomStringConvertible>: PickerElement {

    /// Picker item identifier.
    /// :nodoc:
    public var identifier: String

    /// Picker item value.
    /// :nodoc:
    public var item: T

    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.identifier == rhs.identifier
    }

    public var description: String { item.description }

}

/// Describes a picker item.
open class BaseFormValuePickerItem<T: CustomStringConvertible>: FormValueItem<BasePickerElement<T>, FormTextItemStyle>,
    InputViewRequiringFormItem {

    /// The complete list of selectable values.
    internal let selectableValues: [BasePickerElement<T>]

    /// The title of the item.
    public var title: String?

    /// Initializes the picker item.
    ///
    /// - Parameter selectableValues: The list of values to select from.
    /// - Parameter style: The `FormPhoneExtensionPickerItem` UI style.
    internal init(initValue: BasePickerElement<T>, selectableValues: [BasePickerElement<T>], style: FormTextItemStyle) {
        assert(selectableValues.count > 0)
        self.selectableValues = selectableValues
        super.init(value: initValue, style: style)
    }

}
