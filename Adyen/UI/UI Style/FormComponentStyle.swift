//
// Copyright (c) 2020 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// Contains the styling customization options for any form-based component.
public struct FormComponentStyle: ViewStyle {
    
    /// The header style.
    public var header: FormHeaderStyle = FormHeaderStyle()
    
    /// The text field style.
    public var textField: FormTextItemStyle = FormTextItemStyle()
    
    /// The switch style.
    public var `switch`: FormSwitchItemStyle = FormSwitchItemStyle()
    
    /// The footer style.
    public var footer: FormFooterStyle = FormFooterStyle()
    
    /// :nodoc:
    public var backgroundColor: UIColor = UIColor.AdyenCore.componentBackground
    
    /// Initializes the Form UI style.
    ///
    /// - Parameter header: The header style.
    /// - Parameter textField: The text field style.
    /// - Parameter switch: The switch style.
    /// - Parameter footer: The footer style.
    public init(header: FormHeaderStyle,
                textField: FormTextItemStyle,
                switch: FormSwitchItemStyle,
                footer: FormFooterStyle) {
        self.header = header
        self.textField = textField
        self.switch = `switch`
        self.footer = footer
    }
    
    /// Initializes the form style with the default style.
    public init() {}
    
}
