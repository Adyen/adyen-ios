//
// Copyright (c) 2025 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import UIKit

// A shared instance of the  theme for easy access throughout your SDK
public struct AdyenTheme {

    public var currentColorScheme: AdyenColorScheme = .default
    public var currentFonts: AdyenFonts = .default

    // Available styles
    public var buttonStyle = AdyenButtonStyles()
    public var labelStyle = AdyenLabelStyle()
    package var toggleStyle = AdyenToggleStyle()

    // Initialize with a default ButtonStyle, LabelStyle and ToggleStyle if none is provided
    package init(
        button: AdyenButtonStyles = AdyenButtonStyles(),
        label: AdyenLabelStyle = AdyenLabelStyle(),
        toggle: AdyenToggleStyle = AdyenToggleStyle()
    ) {
        self.buttonStyle = button
        self.labelStyle = label
        self.toggleStyle = toggle
    }
    
    public init(colorScheme: AdyenColorScheme, fonts: AdyenFonts) {
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
        copy.buttonStyle = buttonStyle
        return copy
    }
    
    @discardableResult
    package func toggle(_ toggleStyle: AdyenToggleStyle) -> AdyenTheme {
        var copy = self
        copy.toggleStyle = toggleStyle
        return copy
    }
}
