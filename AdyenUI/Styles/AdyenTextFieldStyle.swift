//
// Copyright (c) 2025 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import UIKit

package struct AdyenTextFieldStyle {
    
    /// The title style.
    package var title: AdyenLabelStyle
    
    /// The text field's style.
    package var text: AdyenLabelStyle
    
    /// The text field's placeholder text style.
    package var placeholder: AdyenLabelStyle

    /// The color of the background.
    package var backgroundColor: UIColor

    /// The color of the text input container background.
    package var containerColor: UIColor

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
    internal static let `default` = AdyenTextFieldStyle()

    /// Initializes a new AdyenTextFieldStyle with default values.
    internal init(
        title: AdyenLabelStyle,
        text: AdyenLabelStyle,
        placeholder: AdyenLabelStyle,
        borderWidth: CGFloat,
        cornerRadius: CornerRounding,
        backgroundColor: UIColor = AdyenColors.default.background,
        containerColor: UIColor = AdyenColors.default.container,
        errorColor: UIColor = AdyenColors.default.destructive,
        borderColor: UIColor = AdyenColors.default.containerOutline,
        borderActiveColor: UIColor = AdyenColors.default.primary
    ) {
        self.title = title
        self.text = text
        self.backgroundColor = backgroundColor
        self.containerColor = containerColor
        self.errorColor = errorColor
        self.cornerRadius = cornerRadius
        self.borderColor = borderColor
        self.borderWidth = borderWidth
        self.borderActiveColor = borderActiveColor
        self.placeholder = placeholder
    }

    internal init() {
        self.title = AdyenLabelStyle.default.font(AdyenFonts.default.bodyEmphasized)
        self.text = AdyenLabelStyle.default
        self.placeholder = AdyenLabelStyle.default.color(AdyenColors.default.textSecondary)
        self.backgroundColor = AdyenColors.default.background
        self.containerColor = AdyenColors.default.container
        self.errorColor = AdyenColors.default.destructive
        self.cornerRadius = CornerRounding.fixed(AdyenUIConstants.defaultCornerRadius)
        self.borderColor = AdyenColors.default.containerOutline
        self.borderActiveColor = AdyenColors.default.primary
        self.borderWidth = AdyenUIConstants.defaultBorderWidth
    }
}

// This extension adds the method chaining to the AdyenTextFieldStyle struct.
extension AdyenTextFieldStyle {
    
    /// Returns a new style with the specified background color.
    /// - Parameter backgroundColor: The color to set.
    /// - Returns: A new `AdyenTextFieldStyle` instance.
    internal func backgroundColor(_ backgroundColor: UIColor) -> AdyenTextFieldStyle {
        var newStyle = self
        newStyle.backgroundColor = backgroundColor
        return newStyle
    }
    
    /// Returns a new style with the specified background color of the text input container.
    /// - Parameter containerColor: The color to set.
    /// - Returns: A new `AdyenTextFieldStyle` instance.
    internal func containerColor(_ containerColor: UIColor) -> AdyenTextFieldStyle {
        var newStyle = self
        newStyle.containerColor = containerColor
        return newStyle
    }

    /// Returns a new style with the specified error color.
    /// - Parameter errorColor: The color to set.
    /// - Returns: A new `AdyenTextFieldStyle` instance.
    internal func errorColor(_ errorColor: UIColor) -> AdyenTextFieldStyle {
        var newStyle = self
        newStyle.errorColor = errorColor
        return newStyle
    }
    
    /// Returns a new style with the specified corner radius.
    /// - Parameter cornerRadius: The corner radius to set.
    /// - Returns: A new `AdyenTextFieldStyle` instance.
    internal func cornerRadius(_ cornerRadius: CornerRounding) -> AdyenTextFieldStyle {
        var newStyle = self
        newStyle.cornerRadius = cornerRadius
        return newStyle
    }
    
    /// Returns a new style with the specified border color.
    /// - Parameter borderColor: The color to set.
    /// - Returns: A new `AdyenTextFieldStyle` instance.
    internal func borderColor(_ borderColor: UIColor) -> AdyenTextFieldStyle {
        var newStyle = self
        newStyle.borderColor = borderColor
        return newStyle
    }
    
    /// Returns a new style with the specified border color for active state.
    /// - Parameter borderActiveColor: The color to set.
    /// - Returns: A new `AdyenTextFieldStyle` instance.
    internal func borderActiveColor(_ borderActiveColor: UIColor) -> AdyenTextFieldStyle {
        var newStyle = self
        newStyle.borderActiveColor = borderActiveColor
        return newStyle
    }

    /// Returns a new style with the specified border width.
    /// - Parameter borderWidth: The border width to set.
    /// - Returns: A new `AdyenTextFieldStyle` instance.
    internal func borderWidth(_ borderWidth: CGFloat) -> AdyenTextFieldStyle {
        var newStyle = self
        newStyle.borderWidth = borderWidth
        return newStyle
    }
}
