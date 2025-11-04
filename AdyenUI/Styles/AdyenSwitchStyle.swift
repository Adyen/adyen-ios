//
// Copyright (c) 2025 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import UIKit

/// Contains the styling customization options for a switch item in a form.
public struct AdyenSwitchStyle {
    
    /// The title style.
    package var title: AdyenLabelStyle
    
    /// The color of `onTintColor` of switch.
    package var tintColor: UIColor?

    // The background color of the switch.
    package var backgroundColor: UIColor

    package var cornerRadius: CornerRounding
    
    /// A default instance of AdyenSwitchStyle.
    public static let `default` = AdyenSwitchStyle()
    
    /// Initializes the form switch item style.
    ///
    /// - Parameter title: The title label style.
    /// - Parameter tintColor: The tint color.
    /// - Parameter backgroundColor: The background color.
    /// - Parameter cornerRadius: The corner radius.
    package init(
        title: AdyenLabelStyle = .init(),
        tintColor: UIColor = AdyenColors.default.primary,
        backgroundColor: UIColor = AdyenColors.default.container,
        cornerRadius: CornerRounding = CornerRounding.fixed(AdyenUIConstants.defaultCornerRadius)
    ) {
        self.title = title
        self.tintColor = tintColor
        self.backgroundColor = backgroundColor
        self.cornerRadius = cornerRadius
    }
}

// This extension adds the method chaining to the AdyenToggleStyle struct.
extension AdyenSwitchStyle {

    /// Returns a new AdyenToggleStyle with the specified title.
    /// - Parameter title: The title to set.
    /// - Returns: A new `AdyenToggleStyle` instance.
    package func title(_ title: AdyenLabelStyle) -> AdyenSwitchStyle {
        var newStyle = self
        newStyle.title = title
        return newStyle
    }
    
    /// Returns a new AdyenToggleStyle with the specified tintColor.
    /// - Parameter tintColor: The tintColor to set.
    /// - Returns: A new `AdyenToggleStyle` instance.
    package func tintColor(_ tintColor: UIColor) -> AdyenSwitchStyle {
        var newStyle = self
        newStyle.tintColor = tintColor
        return newStyle
    }
    
    /// Returns a new AdyenToggleStyle with the specified backgroundColor.
    /// - Parameter backgroundColor: The backgroundColor to set.
    /// - Returns: A new `AdyenToggleStyle` instance.
    package func backgroundColor(_ backgroundColor: UIColor) -> AdyenSwitchStyle {
        var newStyle = self
        newStyle.backgroundColor = backgroundColor
        return newStyle
    }
    
    /// Returns a new AdyenToggleStyle with the specified cornerRadius.
    /// - Parameter cornerRadius: The cornerRadius to set.
    /// - Returns: A new `AdyenToggleStyle` instance.
    package func cornerRadius(_ cornerRadius: CornerRounding) -> AdyenSwitchStyle {
        var newStyle = self
        newStyle.cornerRadius = cornerRadius
        return newStyle
    }

}
