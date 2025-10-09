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
    package var placeholder: AdyenLabelStyle

    /// The color of the background.
    package var backgroundColor: UIColor

    /// The error color of the text.
    package var errorColor: UIColor
    
    /// The cornerRadius
    package var cornerRadius: CornerRounding = .fixed(AdyenUIConstants.defaultCornerRadius)

    /// The border color of the element
    package var borderColor: UIColor
    
    /// The border color of the element in active state
    package var borderActiveColor: UIColor

    /// The border width of the element
    package var borderWidth: CGFloat = AdyenUIConstants.defaultBorderWidth
    
    /// A default instance of AdyenTextFieldStyle.
    public static let `default` = AdyenTextFieldStyle()

    /// Initializes a new AdyenTextFieldStyle with default values.
    public init(
        title: AdyenLabelStyle,
        text: AdyenLabelStyle,
        placeholder: AdyenLabelStyle,
        backgroundColor: UIColor = AdyenColorScheme.default.background,
        textColor: UIColor = AdyenColorScheme.default.text,
        errorColor: UIColor = AdyenColorScheme.default.destructive,
        cornerRadius: CornerRounding,
        borderColor: UIColor = AdyenColorScheme.default.outline,
        borderActiveColor: UIColor = AdyenColorScheme.default.outlineActive,
        borderWidth: CGFloat
    ) {
        self.title = title
        self.text = text
        self.backgroundColor = backgroundColor
        self.errorColor = errorColor
        self.cornerRadius = cornerRadius
        self.borderColor = borderColor
        self.borderWidth = borderWidth
        self.borderActiveColor = borderActiveColor
        self.placeholder = placeholder
    }

    public init() {
        self.title = AdyenLabelStyle.default
        self.text = AdyenLabelStyle.default
        // TODO: // create a default placeholder style extension for AdyenTextFieldStyle
        self.placeholder = AdyenLabelStyle.default
        self.backgroundColor = AdyenColorScheme.default.background
        self.errorColor = AdyenColorScheme.default.destructive
        self.cornerRadius = CornerRounding.fixed(AdyenUIConstants.defaultCornerRadius)
        self.borderColor = AdyenColorScheme.default.outline
        self.borderActiveColor = AdyenColorScheme.default.outlineActive
        self.borderWidth = AdyenUIConstants.defaultBorderWidth
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
    
    /// Returns a new style with the specified border color for active state.
    /// - Parameter borderActiveColor: The color to set.
    /// - Returns: A new `AdyenTextFieldStyle` instance.
    public func borderActiveColor(borderActiveColor: UIColor) -> AdyenTextFieldStyle {
        var newStyle = self
        newStyle.borderActiveColor = borderActiveColor
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
