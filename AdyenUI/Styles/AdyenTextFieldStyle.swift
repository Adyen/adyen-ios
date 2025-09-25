//
// Copyright (c) 2025 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import UIKit

public struct AdyenTextFieldStyle {
    
    /// The title style.
    package var title: AdyenLabelStyle
    
    /// The text field's style.
    package var text: AdyenLabelStyle
    
    /// The text field's placeholder text style.
    package var placeholderText: AdyenLabelStyle?

    /// The color of the background.
    package var backgroundColor: UIColor

    /// The color of the text when the element is active.
    package var activeColor: UIColor
    
    /// The error color of the text.
    package var errorColor: UIColor
    
    /// The cornerRadius
    package var cornerRadius: CornerRounding = .fixed(AdyenUIConstants.defaultCornerRadius)

    /// The border color of the element
    package var borderColor: UIColor
    
    /// The border width of the element
    package var borderWidth: CGFloat = AdyenUIConstants.defaultBorderWidth
    
    /// A default instance of AdyenTextFieldStyle.
    public static let `default` = AdyenTextFieldStyle()

    /// Initializes a new AdyenTextFieldStyle with default values.
    public init(
        title: AdyenLabelStyle,
        text: AdyenLabelStyle,
        backgroundColor: UIColor = AdyenColorScheme.default.background,
        textColor: UIColor = AdyenColorScheme.default.text,
        activeColor: UIColor = AdyenColorScheme.default.highlight,
        errorColor: UIColor = AdyenColorScheme.default.destructive,
        cornerRadius: CornerRounding,
        borderColor: UIColor = AdyenColorScheme.default.outline,
        borderWidth: CGFloat,
        placeholderText: AdyenLabelStyle? = nil
    ) {
        self.title = title
        self.text = text
        self.backgroundColor = backgroundColor
        self.activeColor = activeColor
        self.errorColor = errorColor
        self.cornerRadius = cornerRadius
        self.borderColor = borderColor
        self.borderWidth = borderWidth
        self.placeholderText = placeholderText
    }

    public init() {
        self.title = AdyenLabelStyle(
            font: .preferredFont(forTextStyle: .footnote),
            color: UIColor.Adyen.componentSecondaryLabel,
            textAlignment: .natural
        )
        self.text = AdyenLabelStyle(
            font: .preferredFont(forTextStyle: .body),
            color: UIColor.Adyen.componentLabel,
            textAlignment: .natural
        )
        self.backgroundColor = AdyenColorScheme.default.background
        self.activeColor = AdyenColorScheme.default.highlight
        self.errorColor = AdyenColorScheme.default.destructive
        self.cornerRadius = CornerRounding.fixed(AdyenUIConstants.defaultCornerRadius)
        self.borderColor = AdyenColorScheme.default.outline
        self.borderWidth = AdyenUIConstants.defaultBorderWidth
        self.placeholderText = nil
    }
}

// This extension adds the method chaining to the AdyenTextFieldStyle struct.
extension AdyenTextFieldStyle {
    
    /// Returns a new style with the specified background color.
    /// - Parameter backgroundColor: The color to set.
    /// - Returns: A new `AdyenTextFieldStyle` instance.
    public func backgroundColor(backgroundColor: UIColor) -> AdyenTextFieldStyle {
        var newStyle = self
        newStyle.backgroundColor = backgroundColor
        return newStyle
    }
    
    /// Returns a new style with the specified active color.
    /// - Parameter activeColor: The color to set.
    /// - Returns: A new `AdyenTextFieldStyle` instance.
    public func activeColor(activeColor: UIColor) -> AdyenTextFieldStyle {
        var newStyle = self
        newStyle.activeColor = activeColor
        return newStyle
    }
    
    /// Returns a new style with the specified error color.
    /// - Parameter errorColor: The color to set.
    /// - Returns: A new `AdyenTextFieldStyle` instance.
    public func errorColor(errorColor: UIColor) -> AdyenTextFieldStyle {
        var newStyle = self
        newStyle.errorColor = errorColor
        return newStyle
    }
    
    /// Returns a new style with the specified corner radius.
    /// - Parameter cornerRadius: The corner radius to set.
    /// - Returns: A new `AdyenTextFieldStyle` instance.
    public func cornerRadius(cornerRadius: CornerRounding) -> AdyenTextFieldStyle {
        var newStyle = self
        newStyle.cornerRadius = cornerRadius
        return newStyle
    }
    
    /// Returns a new style with the specified border color.
    /// - Parameter borderColor: The color to set.
    /// - Returns: A new `AdyenTextFieldStyle` instance.
    public func borderColor(borderColor: UIColor) -> AdyenTextFieldStyle {
        var newStyle = self
        newStyle.borderColor = borderColor
        return newStyle
    }
    
    /// Returns a new style with the specified border width.
    /// - Parameter borderWidth: The border width to set.
    /// - Returns: A new `AdyenTextFieldStyle` instance.
    public func borderWidth(borderWidth: CGFloat) -> AdyenTextFieldStyle {
        var newStyle = self
        newStyle.borderWidth = borderWidth
        return newStyle
    }
}
