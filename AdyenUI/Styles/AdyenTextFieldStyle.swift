//
// Copyright (c) 2025 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import UIKit

public struct AdyenTextFieldStyle: CheckoutTextFieldStyle {
    
    /// The title style.
    package var title = AdyenLabelStyle(
        font: .preferredFont(forTextStyle: .footnote),
        color: UIColor.Adyen.componentSecondaryLabel,
        textAlignment: .natural
    )
    
    /// The text field's style.
    package var text = AdyenLabelStyle(
        font: .preferredFont(forTextStyle: .body),
        color: UIColor.Adyen.componentLabel,
        textAlignment: .natural
    )
    
    /// The text field's placeholder text style.
    package var placeholderText: AdyenLabelStyle?

    /// The color of the background.
    public var backgroundColor: UIColor

    /// The color of the text.
    public var textColor: UIColor

    /// The color of the text when the element is active.
    public var activeColor: UIColor
    
    /// The error color of the text.
    public var errorColor: UIColor
    
    /// The cornerRadius
    public var cornerRadius: CornerRounding

    /// The border color of the element
    public var borderColor: UIColor
    
    /// The border width of the element
    public var borderWidth: CGFloat
    
    /// A default instance of AdyenTextFieldStyle.
    public static let `default` = AdyenTextFieldStyle()

    /// Initializes a new AdyenTextFieldStyle with default values.
    public init(
        backgroundColor: UIColor = AdyenColorScheme.default.background,
        textColor: UIColor = AdyenColorScheme.default.text,
        activeColor: UIColor = AdyenColorScheme.default.highlight,
        errorColor: UIColor = AdyenColorScheme.default.destructive,
        cornerRadius: CornerRounding = CornerRounding.fixed(12.0),
        borderColor: UIColor = AdyenColorScheme.default.outline,
        borderWidth: CGFloat = 1.5
    ) {
        self.backgroundColor = backgroundColor
        self.textColor = textColor
        self.activeColor = activeColor
        self.errorColor = errorColor
        self.cornerRadius = cornerRadius
        self.borderColor = borderColor
        self.borderWidth = borderWidth
    }

    public init() {
        self.backgroundColor = AdyenColorScheme.default.background
        self.textColor = AdyenColorScheme.default.text
        self.activeColor = AdyenColorScheme.default.highlight
        self.errorColor = AdyenColorScheme.default.destructive
        self.cornerRadius = CornerRounding.fixed(12.0)
        self.borderColor = AdyenColorScheme.default.outline
        self.borderWidth = 1.5
    }
}

// MARK: - Method Chaining for AdyenTextFieldStyle Properties

// This extension adds the method chaining to the AdyenTextFieldStyle struct.
extension AdyenTextFieldStyle {
    
    /// Returns a new style with the specified background color.
    /// - Parameter backgroundColor: The color to set.
    /// - Returns: A new `AdyenTextFieldStyle` instance.
    public func with(backgroundColor: UIColor) -> AdyenTextFieldStyle {
        var newStyle = self
        newStyle.backgroundColor = backgroundColor
        return newStyle
    }
    
    /// Returns a new style with the specified text color.
    /// - Parameter textColor: The color to set.
    /// - Returns: A new `AdyenTextFieldStyle` instance.
    public func with(textColor: UIColor) -> AdyenTextFieldStyle {
        var newStyle = self
        newStyle.textColor = textColor
        return newStyle
    }
    
    /// Returns a new style with the specified active color.
    /// - Parameter activeColor: The color to set.
    /// - Returns: A new `AdyenTextFieldStyle` instance.
    public func with(activeColor: UIColor) -> AdyenTextFieldStyle {
        var newStyle = self
        newStyle.activeColor = activeColor
        return newStyle
    }
    
    /// Returns a new style with the specified error color.
    /// - Parameter errorColor: The color to set.
    /// - Returns: A new `AdyenTextFieldStyle` instance.
    public func with(errorColor: UIColor) -> AdyenTextFieldStyle {
        var newStyle = self
        newStyle.errorColor = errorColor
        return newStyle
    }
    
    /// Returns a new style with the specified corner radius.
    /// - Parameter cornerRadius: The corner radius to set.
    /// - Returns: A new `AdyenTextFieldStyle` instance.
    public func with(cornerRadius: CornerRounding) -> AdyenTextFieldStyle {
        var newStyle = self
        newStyle.cornerRadius = cornerRadius
        return newStyle
    }
    
    /// Returns a new style with the specified border color.
    /// - Parameter borderColor: The color to set.
    /// - Returns: A new `AdyenTextFieldStyle` instance.
    public func with(borderColor: UIColor) -> AdyenTextFieldStyle {
        var newStyle = self
        newStyle.borderColor = borderColor
        return newStyle
    }
    
    /// Returns a new style with the specified border width.
    /// - Parameter borderWidth: The border width to set.
    /// - Returns: A new `AdyenTextFieldStyle` instance.
    public func with(borderWidth: CGFloat) -> AdyenTextFieldStyle {
        var newStyle = self
        newStyle.borderWidth = borderWidth
        return newStyle
    }
}
