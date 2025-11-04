//
// Copyright (c) 2025 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import UIKit

// A shared instance of the  theme for easy access throughout your SDK
public struct AdyenTheme {
    
    public var currentColorScheme: AdyenColors = .default
    public var currentFonts: AdyenFonts = .default

    // Available styles
    public var buttonStyles = AdyenButtonStyles()
    public var labelStyle = AdyenLabelStyle()
    package var toggleStyle = AdyenSwitchStyle()
    package var textFieldStyle = AdyenTextFieldStyle()

    // Initialize with a default ButtonStyle, LabelStyle and ToggleStyle if none is provided
    package init(
        button: AdyenButtonStyles = AdyenButtonStyles(),
        label: AdyenLabelStyle = AdyenLabelStyle(),
        textField: AdyenTextFieldStyle = AdyenTextFieldStyle(),
        toggle: AdyenSwitchStyle = AdyenSwitchStyle()
    ) {
        self.buttonStyles = button
        self.labelStyle = label
        self.textFieldStyle = textField
        self.toggleStyle = toggle
    }
    
    public init(colorScheme: AdyenColors, fonts: AdyenFonts) {
        self.currentColorScheme = colorScheme
        self.currentFonts = fonts
    }

    public init() {}
}

extension AdyenTheme {
    // Method to allow method chaining on the theme itself.

    @discardableResult
    public func label(_ labelStyle: AdyenLabelStyle) -> AdyenTheme {
        var copy = self
        copy.labelStyle = labelStyle
        return copy
    }

    @discardableResult
    public func button(_ buttonStyle: AdyenButtonStyles) -> AdyenTheme {
        var copy = self
        copy.buttonStyles = buttonStyle
        return copy
    }
    
    @discardableResult
    package func toggle(_ toggleStyle: AdyenSwitchStyle) -> AdyenTheme {
        var copy = self
        copy.toggleStyle = toggleStyle
        return copy
    }
    
    @discardableResult
    public func textfield(_ textfieldStyle: AdyenTextFieldStyle) -> AdyenTheme {
        var copy = self
        copy.textFieldStyle = textfieldStyle
        return copy
    }
}
