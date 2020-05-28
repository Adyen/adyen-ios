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
    public var footer: FormFooterStyle
    
    /// The main button style.
    public var mainButton = ButtonStyle(title: TextStyle(font: .systemFont(ofSize: 17.0, weight: .semibold),
                                                         color: .white,
                                                         textAlignment: .center),
                                        cornerRadius: 8.0)
    
    /// The secondary button style.
    public var secondaryButton = ButtonStyle(title: TextStyle(font: .systemFont(ofSize: 17.0, weight: .regular),
                                                              color: UIColor.AdyenCore.defaultBlue,
                                                              textAlignment: .center),
                                             cornerRadius: 0.0,
                                             background: .clear)
    
    /// The color for separator element.
    public var separatorColor: UIColor = UIColor.AdyenCore.componentSeparator
    
    /// :nodoc:
    public var backgroundColor: UIColor = UIColor.AdyenCore.componentBackground
    
    /// Initializes the Form UI style.
    ///
    /// - Parameter header: The header style.
    /// - Parameter textField: The text field style.
    /// - Parameter switch: The switch style.
    /// - Parameter footer: The footer style.
    /// - Parameter mainButton: The main button style.
    /// - Parameter secondaryButton: The secondary button style.
    public init(header: FormHeaderStyle,
                textField: FormTextItemStyle,
                switch: FormSwitchItemStyle,
                footer: FormFooterStyle,
                mainButton: ButtonStyle,
                secondaryButton: ButtonStyle) {
        self.header = header
        self.textField = textField
        self.switch = `switch`
        self.footer = footer
        self.mainButton = mainButton
        self.secondaryButton = secondaryButton
    }
    
    /// Initializes the Form UI style.
    ///
    /// - Parameter header: The header style.
    /// - Parameter textField: The text field style.
    /// - Parameter switch: The switch style.
    /// - Parameter mainButton: The main button style.
    /// - Parameter secondaryButton: The secondary button style.
    public init(header: FormHeaderStyle,
                textField: FormTextItemStyle,
                switch: FormSwitchItemStyle,
                mainButton: ButtonStyle,
                secondaryButton: ButtonStyle) {
        self.header = header
        self.textField = textField
        self.switch = `switch`
        self.footer = FormFooterStyle(button: mainButton)
        self.mainButton = mainButton
        self.secondaryButton = secondaryButton
    }
    
    /// Initializes the form style with the default style.
    public init() {
        self.footer = FormFooterStyle()
    }
    
}
