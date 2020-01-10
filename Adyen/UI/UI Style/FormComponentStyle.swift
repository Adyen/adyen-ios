//
// Copyright (c) 2020 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// Describes any form component UI style.
public protocol AnyFormComponentStyle: ViewStyle {
    
    /// Indicates the `FormHeaderItemView` UI style.
    var header: FormHeaderItem.Style { get set }
    
    /// Indicates any `FormTextItemView` UI style.
    var textField: FormTextItem.Style { get set }
    
    /// Indicates any `FormSwitchItemView` UI style.
    var `switch`: FormSwitchItem.Style { get set }
    
    /// Indicates the `FormFooterItemView` UI style.
    var footer: FormFooterItem.Style { get set }
    
}

/// Describes any form component UI style.
public struct FormComponentStyle: AnyFormComponentStyle {
    
    /// Indicates the `FormHeaderItemView` UI style.
    public var header: FormHeaderItem.Style = FormHeaderItem.Style()
    
    /// Indicates any `FormTextItemView` UI style.
    public var textField: FormTextItem.Style = FormTextItem.Style()
    
    /// Indicates any `FormSwitchItemView` UI style.
    public var `switch`: FormSwitchItem.Style = FormSwitchItem.Style()
    
    /// Indicates the `FormFooterItemView` UI style.
    public var footer: FormFooterItem.Style = FormFooterItem.Style()
    
    /// :nodoc:
    public var backgroundColor: UIColor = .componentBackground
    
    /// Initializes the Form UI style.
    ///
    /// - Parameter header: The `FormHeaderItemView` UI style.
    /// - Parameter textField: Any `FormTextItemView` UI style.
    /// - Parameter switch: Any `FormSwitchItemView` UI style.
    /// - Parameter footer: The `FormFooterItemView` UI style.
    public init(header: FormHeaderItem.Style,
                textField: FormTextItem.Style,
                switch: FormSwitchItem.Style,
                footer: FormFooterItem.Style) {
        self.header = header
        self.textField = textField
        self.switch = `switch`
        self.footer = footer
    }
    
    /// Initializes the form style with default style.
    public init() {}
    
}
