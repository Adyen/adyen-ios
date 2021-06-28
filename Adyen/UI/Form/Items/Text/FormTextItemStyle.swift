//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation
import UIKit

/// Contains the styling customization options for a text item in a form.
public struct FormTextItemStyle: FormValueItemStyle {
    
    /// The title style.
    public var title = TextStyle(font: .preferredFont(forTextStyle: .footnote),
                                 color: UIColor.Adyen.componentSecondaryLabel,
                                 textAlignment: .natural)
    
    /// The text field's style.
    public var text = TextStyle(font: .preferredFont(forTextStyle: .body),
                                color: UIColor.Adyen.componentLabel,
                                textAlignment: .natural)
    
    /// The text field's placeholder text style.
    public var placeholderText: TextStyle?
    
    /// The icons' style.
    public var icon = ImageStyle(borderColor: UIColor.Adyen.componentSeparator,
                                 borderWidth: 1.0 / UIScreen.main.nativeScale,
                                 cornerRadius: 4.0,
                                 clipsToBounds: true,
                                 contentMode: .scaleAspectFit)
    
    /// The tint color of text field and separator in focused state.
    public var tintColor: UIColor? {
        didSet {
            icon.tintColor = tintColor
        }
    }
    
    /// :nodoc:
    public var backgroundColor: UIColor = .clear
    
    /// The accent color for warnings and error messages.
    public var errorColor = UIColor.Adyen.defaultRed
    
    /// The color for separator element.
    /// If value is nil, the default color would be used.
    public var separatorColor: UIColor? = UIColor.Adyen.componentSeparator
    
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
    
    /// Initializes the text item's style with the default style and custom tint for all elements.
    /// - Parameter tintColor: The color for tinting the item and validation icon.
    public init(tintColor: UIColor) {
        self.tintColor = tintColor
        icon.tintColor = tintColor
    }
    
    /// Initializes the text item's style with the default style.
    public init() {}
    
}
