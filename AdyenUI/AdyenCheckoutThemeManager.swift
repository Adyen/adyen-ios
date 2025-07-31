//
// Copyright (c) 2025 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

// A shared instance of the  theme for easy access throughout your SDK

import UIKit

public class AdyenCheckoutThemeManager {
    
    public var currentColorScheme: ColorScheme {
        didSet {
            if oldValue != currentColorScheme {
                updateElementsStyles()
            }
        }
    }
    
    public var currentFontStyle: FontStyle {
        didSet {
            if oldValue != currentFontStyle {
                updateElementsStyles()
            }
        }
    }
    
    public private(set) var uiElementStyles: AdyenElementStyles
    
    // Internal storage for explicitly set custom styles
    private var customElementsStyles: AdyenElementStyles?
    
    public init() {
        self.currentColorScheme = .default
        self.currentFontStyle = .default
        self.uiElementStyles = Self.createDefaultAdyenElementsStyles(for: .default, fontStyle: .default)
    }
    
    public init(colorScheme: ColorScheme, fontStyle: FontStyle) {
        self.currentColorScheme = colorScheme
        self.currentFontStyle = fontStyle
        self.uiElementStyles = Self.createDefaultAdyenElementsStyles(for: self.currentColorScheme, fontStyle: self.currentFontStyle)
    }
    
    public init(elementStyles: AdyenElementStyles) {
        self.currentColorScheme = .default
        self.currentFontStyle = .default
        self.uiElementStyles = elementStyles
    }
    
    public init(colorScheme: ColorScheme, fontStyle: FontStyle, elementStyles: AdyenElementStyles? = nil) {
        self.currentColorScheme = colorScheme
        self.currentFontStyle = fontStyle
        if let customStyles = elementStyles {
            self.uiElementStyles = customStyles // Use the provided custom styles directly
            self.customElementsStyles = customStyles // Store the custom styles
        } else {
            // If no custom styles are provided, initialize with defaults based on scheme and font
            self.uiElementStyles = Self.createDefaultAdyenElementsStyles(for: colorScheme, fontStyle: fontStyle)
        }
    }
    
    public func applyCustomTheme(colorScheme: ColorScheme? = nil, fontStyle: FontStyle? = nil, elementStyles: AdyenElementStyles? = nil) {
        var needsUpdate = false
        
        if let newColorScheme = colorScheme, self.currentColorScheme != newColorScheme {
            self.currentColorScheme = newColorScheme
            needsUpdate = true
        }
        
        if let newFontStyle = fontStyle, self.currentFontStyle != newFontStyle {
            self.currentFontStyle = newFontStyle
            needsUpdate = true
        }
        
        // If specific elementStyles are provided, apply them and store them as custom.
        if let newElementStyles = elementStyles {
            self.uiElementStyles = newElementStyles
            self.customElementsStyles = newElementStyles
            needsUpdate = true // Even if scheme/font didn't change, new custom styles were applied
        } else if needsUpdate {
            // If no new custom elementStyles were provided, but color/font did change,
            // we re-apply the current custom styles (if any)
            // or regenerate defaults with the new color/font scheme.
            updateElementsStyles()
        }
    }
    
    // MARK: Private
    
    // Helper method to create AdyenElements based on a ColorScheme and FontStyle
    private static func createDefaultAdyenElementsStyles(
        for scheme: ColorScheme,
        fontStyle: FontStyle
    ) -> AdyenElementStyles {
        let label = LabelStyle(colorScheme: scheme, fontStyle: fontStyle)
        let button = AdyenButtonTypes(colorScheme: scheme)
        return AdyenElementStyles(button: button, label: label)
    }
    
    /// Keeps the styles up to date if a property changes.
    private func updateElementsStyles() {
        if let customStyles = customElementsStyles {
            self.uiElementStyles = customStyles
        } else {
            // If no custom styles, generate new default styles with the current scheme and font.
            self.uiElementStyles = Self.createDefaultAdyenElementsStyles(
                for: self.currentColorScheme,
                fontStyle: self.currentFontStyle
            )
        }
    }
}
