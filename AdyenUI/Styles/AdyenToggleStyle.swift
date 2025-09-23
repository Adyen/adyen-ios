//
// Copyright (c) 2025 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import UIKit

/// Contains the styling customization options for a switch item in a form.
package struct AdyenToggleStyle {
    
    /// The title style.
    var title = AdyenLabelStyle()
    
    /// The color of `onTintColor` of switch.
    package var tintColor: UIColor?

    // The background color of the switch.
    package var backgroundColor: UIColor = .clear

    var cornerRadius: CornerRounding = .fixed(AdyenUIConstants.defaultCornerRadius)
    
    /// Initializes the form switch item style.
    ///
    /// - Parameter title: The title style.
    package init(title: AdyenLabelStyle) {
        self.title = title
    }
    
    /// Initializes the form switch item style with the default style.
    package init() {}
}

// This extension adds the method chaining to the AdyenToggleStyle struct.
extension AdyenToggleStyle {

    /// Returns a new AdyenToggleStyle with the specified title.
    /// - Parameter title: The title to set.
    /// - Returns: A new `AdyenToggleStyle` instance.
    func title(_ title: AdyenLabelStyle) -> AdyenToggleStyle {
        var newStyle = self
        newStyle.title = title
        return newStyle
    }
    
    /// Returns a new AdyenToggleStyle with the specified tintColor.
    /// - Parameter tintColor: The tintColor to set.
    /// - Returns: A new `AdyenToggleStyle` instance.
    func tintColor(_ tintColor: UIColor) -> AdyenToggleStyle {
        var newStyle = self
        newStyle.tintColor = tintColor
        return newStyle
    }
    
    /// Returns a new AdyenToggleStyle with the specified backgroundColor.
    /// - Parameter backgroundColor: The backgroundColor to set.
    /// - Returns: A new `AdyenToggleStyle` instance.
    func backgroundColor(_ backgroundColor: UIColor) -> AdyenToggleStyle {
        var newStyle = self
        newStyle.backgroundColor = backgroundColor
        return newStyle
    }
    
    /// Returns a new AdyenToggleStyle with the specified cornerRadius.
    /// - Parameter cornerRadius: The cornerRadius to set.
    /// - Returns: A new `AdyenToggleStyle` instance.
    func cornerRadius(_ cornerRadius: CornerRounding) -> AdyenToggleStyle {
        var newStyle = self
        newStyle.cornerRadius = cornerRadius
        return newStyle
    }

}
