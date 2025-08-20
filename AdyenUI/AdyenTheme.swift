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

    // Initialize with a default ButtonStyle and LabelStyle if none is provided
    public init(
        button: AdyenButtonStyles = AdyenButtonStyles(),
        label: AdyenLabelStyle = AdyenLabelStyle()
    ) {
        self.buttonStyle = button
        self.labelStyle = label
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
}
