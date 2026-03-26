//
// Copyright (c) 2025 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import UIKit

// TODO: Robert: Theming: Rename this to CheckoutTheme same as Android.
public struct AdyenTheme {

    package private(set) var colors: AdyenColors
    package private(set) var attributes: AdyenAttributes
    package private(set) var elements: AdyenElements

    /// A default instance of AdyenTheme.
    public static let `default` = AdyenTheme()

    /// Initializes the theme with optional color overrides.
    ///
    /// - Parameter colors: The color scheme. Defaults to `.default`.
    public init(colors: AdyenColors = .default) {
        self.colors = colors
        self.attributes = .default
        self.elements = AdyenElements(colors: colors)
    }
    
    /// Internal initializer that accepts elements (for SDK use).
    internal init(
        colors: AdyenColors = .default,
        elements: AdyenElements = .default,
        attributes: AdyenAttributes = .default
    ) {
        self.colors = colors
        self.attributes = attributes
        self.elements = elements
    }
}

// MARK: - Builder Methods

extension AdyenTheme {
    
    /// Returns a new theme with the specified colors.
    /// - Parameter colors: The color scheme to apply.
    /// - Returns: A new `AdyenTheme` instance.
    public func colors(_ colors: AdyenColors) -> AdyenTheme {
        AdyenTheme(
            colors: colors,
            elements: elements,
            attributes: attributes
        )
    }
    
    /// Returns a new theme with the specified corner radius.
    /// - Parameter cornerRadius: The corner radius to apply to UI elements.
    /// - Returns: A new `AdyenTheme` instance.
    public func cornerRadius(_ cornerRadius: CGFloat) -> AdyenTheme {
        AdyenTheme(
            colors: colors,
            elements: elements,
            attributes: AdyenAttributes(cornerRadius: cornerRadius)
        )
    }

    // TODO: Robert: Do we even need this method for some reason? Would be easier to read if this file was what was public, without any convienience init stuff.
//    internal func attributes(_ attributes: AdyenAttributes) -> AdyenTheme {
//        AdyenTheme(
//            colors: colors,
//            elements: elements,
//            attributes: attributes
//        )
//    }
    
    /// Customizes the body label style using UIKit primitives.
    ///
    /// All parameters are optional and use smart merging - only the specified values are changed,
    /// while others retain their current values.
    ///
    /// - Parameters:
    ///   - font: The font for the label. Defaults to current value.
    ///   - color: The text color. Defaults to current value.
    ///   - disabledColor: The disabled text color. Defaults to current value.
    ///   - textAlignment: The text alignment. Defaults to current value.
    /// - Returns: A new `AdyenTheme` instance with the updated body label style.
    public func bodyLabel(
        font: UIFont? = nil,
        color: UIColor? = nil,
        disabledColor: UIColor? = nil,
        textAlignment: NSTextAlignment? = nil
    ) -> AdyenTheme {
        var newElements = elements
        newElements.labels.body.font = font ?? newElements.labels.body.font
        newElements.labels.body.color = color ?? newElements.labels.body.color
        newElements.labels.body.disabledColor = disabledColor ?? newElements.labels.body.disabledColor
        newElements.labels.body.textAlignment = textAlignment ?? newElements.labels.body.textAlignment
        
        return AdyenTheme(
            colors: colors,
            elements: newElements,
            attributes: attributes
        )
    }
    
    /// Customizes the primary button style using UIKit primitives.
    ///
    /// All parameters are optional and use smart merging - only the specified values are changed,
    /// while others retain their current values.
    ///
    /// - Parameters:
    ///   - backgroundColor: The button background color. Defaults to current value.
    ///   - textColor: The button text color. Defaults to current value.
    ///   - disabledBackgroundColor: The disabled background color. Defaults to current value.
    ///   - disabledTextColor: The disabled text color. Defaults to current value.
    ///   - cornerRadius: The corner radius. Defaults to current value.
    /// - Returns: A new `AdyenTheme` instance with the updated primary button style.
    public func primaryButton(
        backgroundColor: UIColor? = nil,
        textColor: UIColor? = nil,
        disabledBackgroundColor: UIColor? = nil,
        disabledTextColor: UIColor? = nil,
        cornerRadius: CGFloat? = nil
    ) -> AdyenTheme {
        var newElements = elements
        newElements.buttons.primary.backgroundColor = backgroundColor ?? newElements.buttons.primary.backgroundColor
        newElements.buttons.primary.textColor = textColor ?? newElements.buttons.primary.textColor
        newElements.buttons.primary.disabledBackgroundColor = disabledBackgroundColor ?? newElements.buttons.primary.disabledBackgroundColor
        newElements.buttons.primary.disabledTextColor = disabledTextColor ?? newElements.buttons.primary.disabledTextColor
        
        if let cornerRadius {
            newElements.buttons.primary.cornerRadius = .fixed(cornerRadius)
        }
        
        return AdyenTheme(
            colors: colors,
            elements: newElements,
            attributes: attributes
        )
    }
    
    /// Customizes the destructive button style using UIKit primitives.
    ///
    /// All parameters are optional and use smart merging - only the specified values are changed,
    /// while others retain their current values.
    ///
    /// - Parameters:
    ///   - backgroundColor: The button background color. Defaults to current value.
    ///   - textColor: The button text color. Defaults to current value.
    ///   - disabledBackgroundColor: The disabled background color. Defaults to current value.
    ///   - disabledTextColor: The disabled text color. Defaults to current value.
    ///   - cornerRadius: The corner radius. Defaults to current value.
    /// - Returns: A new `AdyenTheme` instance with the updated destructive button style.
    public func destructiveButton(
        backgroundColor: UIColor? = nil,
        textColor: UIColor? = nil,
        disabledBackgroundColor: UIColor? = nil,
        disabledTextColor: UIColor? = nil,
        cornerRadius: CGFloat? = nil
    ) -> AdyenTheme {
        var newElements = elements
        newElements.buttons.destructive.backgroundColor = backgroundColor ?? newElements.buttons.destructive.backgroundColor
        newElements.buttons.destructive.textColor = textColor ?? newElements.buttons.destructive.textColor
        newElements.buttons.destructive.disabledBackgroundColor = disabledBackgroundColor ?? newElements.buttons.destructive.disabledBackgroundColor
        newElements.buttons.destructive.disabledTextColor = disabledTextColor ?? newElements.buttons.destructive.disabledTextColor
        
        if let cornerRadius {
            newElements.buttons.destructive.cornerRadius = .fixed(cornerRadius)
        }
        
        return AdyenTheme(
            colors: colors,
            elements: newElements,
            attributes: attributes
        )
    }
}
