//
// Copyright (c) 2020 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// Contains the styling customization options for a text item in a form.
public struct FormTextItemStyle: ViewStyle {
    
    /// The title style.
    public var title: TextStyle = TextStyle(font: .systemFont(ofSize: 13.0),
                                            color: UIColor.AdyenCore.componentSecondaryLabel,
                                            textAlignment: .natural)
    
    /// The text field's style.
    public var text: TextStyle = TextStyle(font: .systemFont(ofSize: 17.0),
                                           color: UIColor.AdyenCore.componentLabel,
                                           textAlignment: .natural)
    
    /// The text field's placeholder text style.
    public var placeholderText: TextStyle?
    
    /// The icons' style.
    public var icon: ImageStyle = ImageStyle(borderColor: UIColor(white: 0.0, alpha: 0.2),
                                             borderWidth: 1.0 / UIScreen.main.nativeScale,
                                             cornerRadius: 4.0,
                                             clipsToBounds: true,
                                             contentMode: .scaleAspectFit)
    
    /// :nodoc:
    public var backgroundColor: UIColor = .clear
    
    /// Accent color for warnings and error messages.
    public var errorColor: UIColor = UIColor.AdyenCore.defaultRed
    
    /// Initializes the form text item style.
    ///
    /// - Parameter title: The title style.
    /// - Parameter text: The text field's style.
    /// - Parameter placeholderText: The text field's placeholder text style.
    /// - Parameter icon: The icon's style.
    public init(title: TextStyle,
                text: TextStyle,
                placeholderText: TextStyle? = nil,
                icon: ImageStyle) {
        self.title = title
        self.text = text
        self.placeholderText = placeholderText
        self.icon = icon
    }
    
    /// Initializes the text item's style with the default style.
    public init() {}
    
}
