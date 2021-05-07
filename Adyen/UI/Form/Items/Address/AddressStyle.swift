//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation
import UIKit

/// The style of form address
/// :nodoc:
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
}
