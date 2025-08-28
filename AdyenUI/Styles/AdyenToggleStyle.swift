//
// Copyright (c) 2025 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import UIKit

/// Contains the styling customization options for a switch item in a form.
public struct AdyenToggleStyle {
    
    /// The title style.
    internal var title = AdyenLabelStyle()
    
    /// The color of `onTintColor` of switch.
    public var tintColor: UIColor?

    // The background color of the switch.
    public var backgroundColor: UIColor = .clear

    internal var cornerRadius: CornerRounding = .fixed(AdyenUIConstants.defaultCornerRadius)
    
    /// Initializes the form switch item style.
    ///
    /// - Parameter title: The title style.
    public init(title: AdyenLabelStyle) {
        self.title = title
    }
    
    /// Initializes the form switch item style with the default style.
    public init() {}
}

// This extension adds the method chaining to the AdyenToggleStyle struct.
extension AdyenToggleStyle {

    /// Returns a new AdyenToggleStyle with the specified title.
    /// - Parameter title: The title to set.
    /// - Returns: A new `AdyenToggleStyle` instance.
    public func title(_ title: AdyenLabelStyle) -> AdyenToggleStyle {
        var newStyle = self
        newStyle.title = title
        return newStyle
    }
    
    /// Returns a new AdyenToggleStyle with the specified tintColor.
    /// - Parameter tintColor: The tintColor to set.
    /// - Returns: A new `AdyenToggleStyle` instance.
    public func tintColor(_ tintColor: UIColor) -> AdyenToggleStyle {
        var newStyle = self
        newStyle.tintColor = tintColor
        return newStyle
    }
    
    /// Returns a new AdyenToggleStyle with the specified backgroundColor.
    /// - Parameter backgroundColor: The backgroundColor to set.
    /// - Returns: A new `AdyenToggleStyle` instance.
    public func backgroundColor(_ backgroundColor: UIColor) -> AdyenToggleStyle {
        var newStyle = self
        newStyle.backgroundColor = backgroundColor
        return newStyle
    }
    
    /// Returns a new AdyenToggleStyle with the specified cornerRadius.
    /// - Parameter cornerRadius: The cornerRadius to set.
    /// - Returns: A new `AdyenToggleStyle` instance.
    public func cornerRadius(_ cornerRadius: CornerRounding) -> AdyenToggleStyle {
        var newStyle = self
        newStyle.cornerRadius = cornerRadius
        return newStyle
    }

}
