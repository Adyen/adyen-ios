//
// Copyright (c) 2024 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation
import UIKit

/// The style of form address
public struct AddressStyle: FormValueItemStyle {

    /// The section header style.
    public var title = TextStyle(font: .preferredFont(forTextStyle: .headline),
                                 color: UIColor.Adyen.componentLabel,
                                 textAlignment: .natural)

    /// The text field style.
    public var textField = FormTextItemStyle()

    /// The tint color of the view.
    public var tintColor: UIColor? {
        didSet {
            textField.tintColor = tintColor
        }
    }

    /// The background color of the view.
    public var backgroundColor: UIColor = .clear

    /// The color of form view item's separator line.
    public var separatorColor: UIColor? { textField.separatorColor }
    
    /// Whether or not to show country flags in the country picker
    public var showCountryFlags: Bool = true
    
    /// Initializes the form address item configuration.
    /// - Parameters:
    ///   - title: The section header style.
    ///   - textField: The text field style.
    ///   - tintColor: The tint color of the view.
    ///   - backgroundColor: The background color of the view.
    public init(
        title: TextStyle,
        textField: FormTextItemStyle,
        tintColor: UIColor? = nil,
        backgroundColor: UIColor = .clear
    ) {
        self.title = title
        self.textField = textField
        self.tintColor = tintColor
        self.backgroundColor = backgroundColor
    }
    
    /// Initializes the form address item configuration with default values
    public init() {}
}
