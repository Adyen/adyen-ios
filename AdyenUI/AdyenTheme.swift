//
// Copyright (c) 2025 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import UIKit

// A shared instance of the  theme for easy access throughout your SDK
public class AdyenTheme {
    
    public var currentColorScheme: ColorScheme = .default
    public var currentFontStyle: FontStyle = .default

    // Available styles
    public var buttonStyle = AdyenButtonStyles()
    public var labelStyle = LabelStyle()

    // Initialize with a default ButtonStyle and LabelStyle if none is provided
    public init(
        button: AdyenButtonStyles = AdyenButtonStyles(),
        label: LabelStyle = LabelStyle(),
        inputTextField: InputTextFieldStyle = InputTextFieldStyle()
    ) {
        self.buttonStyle = button
        self.labelStyle = label
    }
    
    public init(colorScheme: ColorScheme, fontStyle: FontStyle) {
        self.currentColorScheme = colorScheme
        self.currentFontStyle = fontStyle
    }
}

extension AdyenTheme {
    // Method to allow method chaining on the theme itself.
    public static func label(_ labelStyle: LabelStyle) -> AdyenTheme {
        let newTheme = AdyenTheme()
        newTheme.labelStyle = labelStyle
        return newTheme
    }

    public static func button(_ buttonStyle: AdyenButtonStyles) -> AdyenTheme {
        let newTheme = AdyenTheme()
        newTheme.buttonStyle = buttonStyle
        return newTheme
    }
}
