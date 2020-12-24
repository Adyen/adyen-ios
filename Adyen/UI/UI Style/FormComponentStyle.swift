//
// Copyright (c) 2020 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation
import UIKit

/// Contains the styling customization options for any form-based component.
public struct FormComponentStyle: ViewStyle {
    
    /// :nodoc:
    public var backgroundColor = UIColor.Adyen.componentBackground
    
    /// The text field style.
    public var textField = FormTextItemStyle()
    
    /// The switch style.
    public var `switch` = FormSwitchItemStyle()

    /// The helper message style.
    public var hintLabel: TextStyle = .init(font: .preferredFont(forTextStyle: .body),
                                            color: UIColor.Adyen.componentLabel,
                                            textAlignment: .natural)
    
    /// The main button style.
    public var mainButtonItem: FormButtonItemStyle = .main(font: .preferredFont(forTextStyle: .headline),
                                                           textColor: .white,
                                                           mainColor: UIColor.Adyen.defaultBlue)
    
    /// The secondary button style.
    public var secondaryButtonItem: FormButtonItemStyle = .secondary(font: .preferredFont(forTextStyle: .body),
                                                                     textColor: UIColor.Adyen.defaultBlue)
    
    /// The color for separator element.
    /// When set, updates separator colors for all undelying styles unless the value were set previously.
    /// If value is nil, the default color would be used.
    public var separatorColor: UIColor? {
        didSet {
            textField.separatorColor = textField.separatorColor ?? separatorColor
            `switch`.separatorColor = `switch`.separatorColor ?? separatorColor
        }
    }
    
    /// Initializes the Form UI style.
    ///
    /// - Parameter textField: The text field style.
    /// - Parameter switch: The switch style.
    /// - Parameter mainButton: The main button style.
    /// - Parameter secondaryButton: The secondary button style.
    /// - Parameter helper: The helper message style.
    public init(textField: FormTextItemStyle,
                switch: FormSwitchItemStyle,
                mainButton: FormButtonItemStyle,
                secondaryButton: FormButtonItemStyle,
                helper: TextStyle) {
        self.textField = textField
        self.switch = `switch`
        self.mainButtonItem = mainButton
        self.secondaryButtonItem = secondaryButton
        self.hintLabel = helper
    }
    
    /// Initializes the Form UI style.
    ///
    /// - Parameter textField: The text field style.
    /// - Parameter switch: The switch style.
    /// - Parameter mainButton: The main button style.
    /// - Parameter secondaryButton: The secondary button style.
    public init(textField: FormTextItemStyle,
                switch: FormSwitchItemStyle,
                mainButton: ButtonStyle,
                secondaryButton: ButtonStyle) {
        self.textField = textField
        self.switch = `switch`
        self.mainButtonItem = FormButtonItemStyle(button: mainButton)
        self.secondaryButtonItem = FormButtonItemStyle(button: secondaryButton)
    }
    
    /// Initializes the form style with the default style and custom tint for all elements.
    /// - Parameter tintColor: The color for tinting buttons. textfields, icons and switches.
    public init(tintColor: UIColor) {
        
        mainButtonItem.button.backgroundColor = tintColor
        secondaryButtonItem.button.title.color = tintColor
        
        textField = FormTextItemStyle(tintColor: tintColor)
        `switch`.tintColor = tintColor
    }
    
    /// Initializes the form style with the default style.
    public init() { /* public */ }
    
}
