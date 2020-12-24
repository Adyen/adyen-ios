//
// Copyright (c) 2020 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// Describes a single picker item in the list of selectable items.
/// :nodoc:
public struct PhoneExtensionPickerItem: Equatable {
    
    /// Picker item identifier.
    /// :nodoc:
    public let identifier: String
    
    /// Picker item title.
    /// :nodoc:
    public let title: String
    
    /// Country phone extension.
    /// :nodoc:
    public let phoneExtension: String

    /// Initializes the extension picker item.
    ///
    /// - Parameter identifier: The Picker item identifier.
    /// - Parameter title: The Picker item title.
    /// - Parameter phoneExtension: The Country phone extension.
    /// :nodoc:
    public init(identifier: String, title: String, phoneExtension: String) {
        self.identifier = identifier
        self.title = title
        self.phoneExtension = phoneExtension
    }
    
}

/// Describes a picker item.
internal final class FormPhoneExtensionPickerItem: FormValueItem, InputViewRequiringFormItem {
    
    /// :nodoc
    public var identifier: String?
    
    /// The currently selected value in the list.
    public var value: PhoneExtensionPickerItem
    
    /// The complete list of selectable values.
    internal let selectableValues: [PhoneExtensionPickerItem]
    
    /// The item UI style.
    internal let style: FormTextItemStyle
    
    /// Initializes the picker item.
    ///
    /// - Parameter selectableValues: The list of values to select from.
    /// - Parameter style: The `FormPhoneExtensionPickerItem` UI style.
    internal init(selectableValues: [PhoneExtensionPickerItem], style: FormTextItemStyle) {
        assert(selectableValues.count > 0)
        self.selectableValues = selectableValues
        self.style = style
        self.value = selectableValues.first(where: { $0.identifier == Locale.current.regionCode }) ?? selectableValues[0]
    }
    
    /// :nodoc:
    public func build(with builder: FormItemViewBuilder) -> AnyFormItemView {
        builder.build(with: self)
    }
}
