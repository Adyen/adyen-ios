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
public struct BasePickerElement<ElementType: CustomStringConvertible>: PickerElement {

    /// Picker item identifier.
    /// :nodoc:
    public let identifier: String

    /// Picker item value.
    /// :nodoc:
    public let element: ElementType

    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.identifier == rhs.identifier
    }

    public var description: String { element.description }

}

/// Describes a picker item.
/// :nodoc:
open class BaseFormPickerItem<ElementType: CustomStringConvertible>: FormValueItem<BasePickerElement<ElementType>, FormTextItemStyle>,
    InputViewRequiringFormItem {

    /// The complete list of selectable values.
    internal var selectableValues: [BasePickerElement<ElementType>]

    /// Initializes the picker item.
    ///
    /// - Parameter selectableValues: The list of values to select from.
    /// - Parameter style: The `FormPhoneExtensionPickerItem` UI style.
    internal init(preselectedValue: BasePickerElement<ElementType>, selectableValues: [BasePickerElement<ElementType>], style: FormTextItemStyle) {
        assert(selectableValues.count > 0)
        self.selectableValues = selectableValues
        super.init(value: preselectedValue, style: style)
    }

}
