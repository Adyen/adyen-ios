//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation
import UIKit

/// The style of form address
package struct AddressStyle: FormValueItemStyle {

    /// The section header style.
    package var title = TextStyle(
        font: .preferredFont(forTextStyle: .headline),
        color: UIColor.Adyen.componentLabel,
        textAlignment: .natural
    )

    /// The text field style.
    package var textField = FormTextItemStyle()

    /// The tint color of the view.
    package var tintColor: UIColor? {
        didSet {
            textField.tintColor = tintColor
        }
    }

    /// The background color of the view.
    package var backgroundColor: UIColor = .clear

    /// The color of form view item's separator line.
    package var separatorColor: UIColor? {
        textField.separatorColor
    }
    
    /// Initializes the form address item configuration.
    /// - Parameters:
    ///   - title: The section header style.
    ///   - textField: The text field style.
    ///   - tintColor: The tint color of the view.
    ///   - backgroundColor: The background color of the view.
    package init(
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
    package init() {}
}
