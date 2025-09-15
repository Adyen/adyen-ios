//
// Copyright (c) 2025 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import UIKit

// A shared instance of the  theme for easy access throughout your SDK
public struct AdyenTheme {
    
    public var currentColorScheme: AdyenColorScheme = .default
    public var currentFonts: AdyenFonts = .default

    // Available styles
    package var buttonStyle = AdyenButtonStyles()
    package var labelStyle = AdyenLabelStyle()
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

extension AdyenTheme: CheckoutTheme {

    // Conformance to protocol

    public var checkoutLabelStyle: CheckoutLabelStyle {
        get { labelStyle }
        set { labelStyle = newValue as? AdyenLabelStyle ?? AdyenLabelStyle() }
    }
    
    public var checkoutButtonStyles: CheckoutButtonStyles {
        get { buttonStyle }
        set { buttonStyle = newValue as? AdyenButtonStyles ?? AdyenButtonStyles() }
    }
    
    public func withLabelStyle(_ style: CheckoutLabelStyle) -> CheckoutTheme {
        var copy = self
        if let newStyle = style as? AdyenLabelStyle {
            copy.checkoutLabelStyle = newStyle
        }
        return copy
    }
    
    public func withButtonStyle(_ style: CheckoutButtonStyles) -> CheckoutTheme {
        var copy = self
        if let newStyle = style as? AdyenButtonStyles {
            copy.checkoutButtonStyles = newStyle
        }
        return copy
    }
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
