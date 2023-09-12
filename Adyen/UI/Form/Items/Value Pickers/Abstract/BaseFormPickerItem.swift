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

    /// :nodoc:
    public var description: String { element.description }
    
    /// :nodoc:
    public init(identifier: String, element: ElementType) {
        self.identifier = identifier
        self.element = element
    }

}

/// Describes a picker item.
/// :nodoc:
open class BaseFormPickerItem<ElementType: CustomStringConvertible>: FormValueItem<BasePickerElement<ElementType>, FormTextItemStyle>,
    InputViewRequiringFormItem, Hidable {

    /// :nodoc:
    public var isHidden: AdyenObservable<Bool> = AdyenObservable(false)
    
    /// The complete list of selectable values, as observable.
    /// Updating this notifies the observing view `BaseFormPickerItemView`
    /// and reloads the picker view.
    @AdyenObservable([]) public var selectableValues: [BasePickerElement<ElementType>]

    /// Initializes the picker item.
    ///
    /// - Parameter selectableValues: The list of values to select from.
    /// - Parameter style: The `FormPhoneExtensionPickerItem` UI style.
    public init(preselectedValue: BasePickerElement<ElementType>, selectableValues: [BasePickerElement<ElementType>], style: FormTextItemStyle) {
        assert(selectableValues.count > 0)
        super.init(value: preselectedValue, style: style)
        self.selectableValues = selectableValues
    }

}
